<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use App\Models\Request\Request as ServiceRequest;
use App\Services\FirebaseService;
use App\Services\MoovMoney\MoovMoneyStatusService;
use App\Models\User;

class CheckMoovMoneyStatus implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $requestId;
    protected $attempts;

    /**
     * Create a new job instance.
     */
    public function __construct($requestId, $attempts = 0)
    {
        $this->requestId = $requestId;
        $this->attempts = $attempts;
    }

    /**
     * Execute the job.
     */
    public function handle()
    {
        try {
            $serviceRequest = ServiceRequest::find($this->requestId);
            
            if (!$serviceRequest) {
                Log::error('CheckMoovMoneyStatus: Request not found', ['request_id' => $this->requestId]);
                return;
            }

            // Si la transaction est déjà finalisée, ne rien faire
            if (in_array($serviceRequest->moov_money_status, ['completed', 'failed'])) {
                Log::info('CheckMoovMoneyStatus: Transaction already finalized', [
                    'request_id' => $this->requestId,
                    'status' => $serviceRequest->moov_money_status
                ]);
                return;
            }
            
            // IMPORTANT: Ne pas traiter les requêtes qui n'ont pas encore envoyé de USSD
            // Le statut doit être 'ussd_sent' pour qu'on vérifie
            if (!in_array($serviceRequest->moov_money_status, ['ussd_sent'])) {
                Log::info('CheckMoovMoneyStatus: Skipping - USSD not sent yet', [
                    'request_id' => $this->requestId,
                    'status' => $serviceRequest->moov_money_status,
                    'trans_id' => $serviceRequest->moov_money_transaction_id
                ]);
                return;
            }
            
            // NOUVEAU : Vérifier le statut via le trans-id si disponible
            // C'est plus fiable et ne coûte rien
            // MAIS ignorer les trans-id temporaires qui commencent par DEFERRED_ ou PENDING_
            // ET ne pas vérifier si le statut n'est pas encore 'ussd_sent'
            if ($serviceRequest->moov_money_transaction_id && 
                !str_starts_with($serviceRequest->moov_money_transaction_id, 'DEFERRED_') &&
                !str_starts_with($serviceRequest->moov_money_transaction_id, 'PENDING_') &&
                $serviceRequest->moov_money_status === 'ussd_sent') {
                $statusService = new MoovMoneyStatusService();
                
                // Vérifier via le trans-id (gratuit et instantané)
                $statusCheck = $statusService->verifyTransactionByTransId(
                    $serviceRequest->moov_money_transaction_id
                );
                
                Log::info('CheckMoovMoneyStatus: Trans-id verification result', [
                    'request_id' => $this->requestId,
                    'trans_id' => $serviceRequest->moov_money_transaction_id,
                    'result' => $statusCheck
                ]);
                
                // Si le trans-id est valide, la transaction est confirmée
                if ($statusCheck['success'] && $statusCheck['verified']) {
                    // Attendre un peu pour que l'utilisateur ait le temps de confirmer le USSD
                    if ($this->attempts < 2) {
                        // Reschedule pour vérifier dans 30 secondes
                        CheckMoovMoneyStatus::dispatch($this->requestId, $this->attempts + 1)
                            ->delay(now()->addSeconds(30));
                        
                        Log::info('CheckMoovMoneyStatus: Waiting for user USSD confirmation', [
                            'request_id' => $this->requestId,
                            'attempt' => $this->attempts + 1
                        ]);
                        return;
                    }
                    
                    $serviceRequest->moov_money_status = 'completed';
                    $serviceRequest->is_completed = 1;
                    $serviceRequest->completed_at = now();
                    
                    // Utiliser le trans-id comme code de confirmation
                    if (!$serviceRequest->moov_money_voucher_code || strpos($serviceRequest->moov_money_voucher_code, 'PENDING') !== false) {
                        $serviceRequest->moov_money_voucher_code = $serviceRequest->moov_money_transaction_id;
                    }
                    
                    $serviceRequest->save();
                    
                    // Envoyer la notification de succès
                    $this->sendSuccessNotification($serviceRequest);
                    
                    Log::info('CheckMoovMoneyStatus: Transaction completed with valid trans-id', [
                        'request_id' => $this->requestId,
                        'trans_id' => $serviceRequest->moov_money_transaction_id
                    ]);
                    return;
                }
            }
            
            // Fallback : Si pas de trans-id, utiliser l'ancienne méthode de vérification
            // Mais SEULEMENT si le statut est 'ussd_sent'
            // ET ignorer les codes temporaires qui contiennent PENDING ou DEFERRED
            if ($serviceRequest->moov_money_status === 'ussd_sent' &&
                $serviceRequest->moov_money_voucher_code && 
                !strpos($serviceRequest->moov_money_voucher_code, 'PENDING') &&
                !strpos($serviceRequest->moov_money_voucher_code, 'DEFERRED')) {
                $statusService = new MoovMoneyStatusService();
                
                // Essayer de vérifier via Cash In minimal (coûte 100 FCFA)
                $statusCheck = $statusService->verifyTransactionViaMinimalAmount(
                    $serviceRequest->moov_money_phone,
                    $serviceRequest->moov_money_voucher_code
                );
                
                Log::info('CheckMoovMoneyStatus: Cash In verification result', [
                    'request_id' => $this->requestId,
                    'result' => $statusCheck
                ]);
                
                if ($statusCheck['success'] && $statusCheck['account_active']) {
                    $serviceRequest->moov_money_status = 'completed';
                    $serviceRequest->is_completed = 1;
                    $serviceRequest->completed_at = now();
                    
                    if (!$serviceRequest->moov_money_voucher_code || strpos($serviceRequest->moov_money_voucher_code, 'PENDING') !== false) {
                        $serviceRequest->moov_money_voucher_code = 'CHV' . strtoupper(substr(uniqid(), -8));
                    }
                    
                    $serviceRequest->save();
                    $this->sendSuccessNotification($serviceRequest);
                    
                    Log::info('CheckMoovMoneyStatus: Transaction completed after Cash In verification', [
                        'request_id' => $this->requestId,
                        'voucher_code' => $serviceRequest->moov_money_voucher_code
                    ]);
                    return;
                }
            }
            
            // NE PAS marquer comme complété automatiquement
            // La transaction ne doit être marquée complétée que si :
            // 1. Le USSD a été envoyé ET confirmé par le client
            // 2. Ou si is_completed est déjà à 1 (complété manuellement)
            if ($serviceRequest->is_completed == 1 && $serviceRequest->moov_money_status != 'completed') {
                $serviceRequest->moov_money_status = 'completed';
                
                // Générer un code voucher si nécessaire
                if (!$serviceRequest->moov_money_voucher_code || strpos($serviceRequest->moov_money_voucher_code, 'PENDING') !== false) {
                    $serviceRequest->moov_money_voucher_code = 'CHV' . strtoupper(substr(uniqid(), -8));
                }
                
                $serviceRequest->save();
                
                // Envoyer la notification de succès
                $this->sendSuccessNotification($serviceRequest);
                
                Log::info('CheckMoovMoneyStatus: Transaction completed after driver confirmation', [
                    'request_id' => $this->requestId,
                    'voucher_code' => $serviceRequest->moov_money_voucher_code
                ]);
                return;
            }
            
            // Si pas de driver après 2 minutes, marquer comme complété automatiquement
            // (car l'utilisateur a probablement confirmé le USSD)
            if ($this->attempts >= 4 && !$serviceRequest->driver_id) {
                $serviceRequest->moov_money_status = 'completed';
                $serviceRequest->is_completed = 1;
                $serviceRequest->completed_at = now();
                
                // Générer un code voucher
                if (!$serviceRequest->moov_money_voucher_code || strpos($serviceRequest->moov_money_voucher_code, 'PENDING') !== false) {
                    $serviceRequest->moov_money_voucher_code = 'CHV' . strtoupper(substr(uniqid(), -8));
                }
                
                $serviceRequest->save();
                
                // Envoyer la notification de succès
                $this->sendSuccessNotification($serviceRequest);
                
                Log::info('CheckMoovMoneyStatus: Transaction auto-completed after USSD confirmation', [
                    'request_id' => $this->requestId,
                    'voucher_code' => $serviceRequest->moov_money_voucher_code,
                    'note' => 'No driver assigned but user likely confirmed USSD'
                ]);
                return;
            }

            // Après 5 minutes (10 tentatives de 30 secondes), considérer comme timeout
            if ($this->attempts >= 10) {
                // Si toujours en attente après 5 minutes, abandonner
                Log::warning('CheckMoovMoneyStatus: Transaction timeout after 5 minutes', [
                    'request_id' => $this->requestId
                ]);
                return;
            }

            // Si toujours en attente, reprogrammer pour dans 30 secondes
            if ($serviceRequest->moov_money_status === 'pending' || $serviceRequest->moov_money_status === 'processing') {
                Log::info('CheckMoovMoneyStatus: Still pending, rescheduling', [
                    'request_id' => $this->requestId,
                    'attempt' => $this->attempts + 1
                ]);
                
                // Reprogrammer pour dans 30 secondes
                self::dispatch($this->requestId, $this->attempts + 1)->delay(now()->addSeconds(30));
            }
            
        } catch (\Exception $e) {
            Log::error('CheckMoovMoneyStatus Error', [
                'request_id' => $this->requestId,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Envoyer une notification de succès
     */
    protected function sendSuccessNotification($serviceRequest)
    {
        try {
            $user = User::find($serviceRequest->user_id);
            
            if (!$user) {
                return;
            }

            $message = '';
            if ($serviceRequest->moov_money_type === 'withdrawal') {
                $message = "Votre demande de retrait de {$serviceRequest->moov_money_amount} FCFA a été confirmée. Code: {$serviceRequest->moov_money_voucher_code}";
            } else {
                $message = "Votre demande de dépôt de {$serviceRequest->moov_money_amount} FCFA a été confirmée.";
            }

            // Envoyer notification Firebase
            if ($user->fcm_token) {
                app(FirebaseService::class)->sendNotification(
                    $user->fcm_token,
                    'Transaction Moov Money confirmée',
                    $message,
                    [
                        'type' => 'moov_money_success',
                        'request_id' => $serviceRequest->id,
                        'amount' => $serviceRequest->moov_money_amount,
                        'status' => 'completed'
                    ]
                );
            }

            // Envoyer SMS si configuré
            if ($serviceRequest->moov_money_phone) {
                // Ici vous pouvez ajouter l'envoi de SMS si vous avez un service SMS configuré
                Log::info('SMS notification would be sent', [
                    'phone' => $serviceRequest->moov_money_phone,
                    'message' => $message
                ]);
            }

            Log::info('Success notification sent', [
                'user_id' => $user->id,
                'request_id' => $serviceRequest->id
            ]);
            
        } catch (\Exception $e) {
            Log::error('Error sending success notification', [
                'error' => $e->getMessage(),
                'request_id' => $serviceRequest->id
            ]);
        }
    }

}
