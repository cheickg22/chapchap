<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Request\Request as ServiceRequest;
use App\Services\MoovMoney\MoovMoneyService;
use Illuminate\Support\Facades\Log;
use App\Services\FirebaseService;
use App\Models\User;

class MoovMoneyDriverController extends Controller
{
    protected $moovMoneyService;
    protected $firebaseService;

    public function __construct(MoovMoneyService $moovMoneyService, FirebaseService $firebaseService)
    {
        $this->moovMoneyService = $moovMoneyService;
        $this->firebaseService = $firebaseService;
    }

    /**
     * Appelé quand le driver arrive chez le client
     * Marque simplement l'arrivée sans envoyer le USSD
     */
    public function driverArrived(Request $request, $requestId)
    {
        $user = auth()->user();
        $driver = $user->driver;
        
        if (!$driver) {
            return response()->json([
                'success' => false,
                'message' => 'Driver profile not found'
            ], 404);
        }
        
        // Log pour déboguer
        Log::info('MoovMoneyDriverController::driverArrived - Recherche de la requête', [
            'request_id' => $requestId,
            'driver_id' => $driver->id,
            'user_id' => $user->id
        ]);
        
        // Essayons d'abord de trouver la requête sans vérifier le driver_id
        $serviceRequestCheck = ServiceRequest::where('id', $requestId)
            ->where('is_moov_money', 1)
            ->first();
            
        if ($serviceRequestCheck) {
            Log::info('Requête trouvée, détails:', [
                'request_driver_id' => $serviceRequestCheck->driver_id,
                'current_driver_id' => $driver->id,
                'match' => $serviceRequestCheck->driver_id == $driver->id
            ]);
        }
        
        $serviceRequest = ServiceRequest::where('id', $requestId)
            ->where('driver_id', $driver->id)
            ->where('is_moov_money', 1)
            ->first();

        if (!$serviceRequest) {
            // Si on ne trouve pas avec driver_id, essayons sans pour voir
            $serviceRequestAny = ServiceRequest::where('id', $requestId)
                ->where('is_moov_money', 1)
                ->first();
                
            if ($serviceRequestAny) {
                Log::error('Requête trouvée mais driver_id ne correspond pas', [
                    'request_driver_id' => $serviceRequestAny->driver_id,
                    'current_driver_id' => $driver->id
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => 'Demande non assignée à ce driver (driver_id: ' . $serviceRequestAny->driver_id . ', votre id: ' . $driver->id . ')'
                ], 404);
            }
            
            return response()->json([
                'success' => false,
                'message' => 'Demande non trouvée'
            ], 404);
        }

        // Marquer le driver comme arrivé
        $serviceRequest->is_driver_arrived = 1;
        $serviceRequest->arrived_at = now();
        $serviceRequest->save();

        Log::info('Driver arrived at customer location', [
            'request_id' => $requestId,
            'driver_id' => $driver->id
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Arrivée confirmée',
            'data' => [
                'request_id' => $requestId,
                'status' => 'arrived'
            ]
        ]);
    }

    /**
     * Appelé quand le driver clique sur "Traiter" 
     * C'EST ICI qu'on envoie le USSD au client
     */
    public function processWithdrawal(Request $request, $requestId)
    {
        $user = auth()->user();
        $driver = $user->driver;
        
        if (!$driver) {
            return response()->json([
                'success' => false,
                'message' => 'Driver profile not found'
            ], 404);
        }
        
        // Récupérer la demande
        $serviceRequest = ServiceRequest::where('id', $requestId)
            ->where('driver_id', $driver->id)
            ->where('is_moov_money', 1)
            ->where('moov_money_type', 'withdrawal')
            ->first();

        if (!$serviceRequest) {
            return response()->json([
                'success' => false,
                'message' => 'Demande non trouvée ou non assignée à ce driver'
            ], 404);
        }

        // Vérifier que le driver est bien arrivé avant de traiter
        if ($serviceRequest->is_driver_arrived != 1) {
            return response()->json([
                'success' => false,
                'message' => 'Vous devez d\'abord signaler votre arrivée'
            ], 400);
        }

        // Vérifier que le USSD n'a pas déjà été envoyé
        // Ignorer les trans_id temporaires (DEFERRED_, PENDING, ou UUID de test)
        $hasRealTransId = !empty($serviceRequest->moov_money_transaction_id) && 
                         !str_starts_with($serviceRequest->moov_money_transaction_id, 'DEFERRED_') &&
                         !str_starts_with($serviceRequest->moov_money_transaction_id, 'PENDING');
        
        if ($serviceRequest->moov_money_status == 'ussd_sent' || 
            $serviceRequest->moov_money_status == 'completed') {
            
            Log::warning('Tentative de renvoyer un USSD déjà envoyé', [
                'request_id' => $requestId,
                'status' => $serviceRequest->moov_money_status,
                'trans_id' => $serviceRequest->moov_money_transaction_id
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Le USSD a déjà été envoyé ou la transaction est déjà complétée',
                'data' => [
                    'status' => $serviceRequest->moov_money_status,
                    'trans_id' => $serviceRequest->moov_money_transaction_id
                ]
            ], 400);
        }
        
        // Si le statut est pending mais qu'il y a un trans_id, permettre le renvoi
        if ($serviceRequest->moov_money_status == 'pending' && !empty($serviceRequest->moov_money_transaction_id)) {
            Log::info('Transaction en attente avec trans_id, autorisation du renvoi du USSD', [
                'request_id' => $requestId,
                'status' => $serviceRequest->moov_money_status,
                'trans_id' => $serviceRequest->moov_money_transaction_id
            ]);
        }

        // NOUVEAU: Envoyer le USSD maintenant que le driver est arrivé
        Log::info('Driver arrived - Sending USSD to customer', [
            'request_id' => $requestId,
            'driver_id' => $driver->id,
            'phone' => $serviceRequest->moov_money_phone,
            'amount' => $serviceRequest->moov_money_amount
        ]);

        try {
            // Générer un nouveau request-id unique pour le USSD
            $ussdRequestId = 'CO-' . date('YmdHis') . '-' . rand(100000, 999999);
            
            // Envoyer le USSD via l'API Moov Money
            $ussdResponse = $this->moovMoneyService->generateCashOutVoucher(
                $serviceRequest->moov_money_phone,
                $serviceRequest->moov_money_amount,
                'XOF',
                $ussdRequestId
            );

            // Vérifier si le USSD a été envoyé avec succès
            if ($ussdResponse['success']) {
                // Mettre à jour la transaction Moov Money existante avec le vrai trans-id
                if ($serviceRequest->moov_money_transaction_id) {
                    \DB::table('moov_money_transactions')
                        ->where('id', $serviceRequest->moov_money_transaction_id)
                        ->update([
                            'transaction_id' => $ussdResponse['transaction_id'] ?? $ussdResponse['voucher_code'],
                            'voucher_code' => $ussdResponse['voucher_code'] ?? $ussdResponse['transaction_id'],
                            'status' => 'ussd_sent',
                            'api_response' => json_encode($ussdResponse),
                            'updated_at' => now()
                        ]);
                }
                
                // Mettre à jour la requête avec le voucher code (pas le transaction_id qui est une FK)
                $serviceRequest->moov_money_voucher_code = $ussdResponse['voucher_code'] ?? $ussdResponse['transaction_id'];
                $serviceRequest->moov_money_status = 'ussd_sent';
                $serviceRequest->save();
                
                Log::info('USSD sent successfully', [
                    'request_id' => $requestId,
                    'trans_id' => $serviceRequest->moov_money_transaction_id,
                    'message' => $ussdResponse['message'] ?? 'USSD sent'
                ]);
            } else {
                // Erreur lors de l'envoi du USSD
                Log::error('Failed to send USSD', [
                    'request_id' => $requestId,
                    'error' => $ussdResponse['error'] ?? 'Unknown error',
                    'response' => $ussdResponse
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => 'Erreur lors de l\'envoi du USSD: ' . ($ussdResponse['error'] ?? 'Erreur inconnue')
                ], 500);
            }

            // Notifier le client que le driver est arrivé et qu'il doit confirmer le USSD
            $this->notifyCustomerDriverArrived($serviceRequest);

            Log::info('USSD sent successfully after driver arrival', [
                'request_id' => $requestId,
                'ussd_response' => $ussdResponse
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Arrivée confirmée. USSD envoyé au client.',
                'data' => [
                    'request_id' => $requestId,
                    'ussd_sent' => true,
                    'customer_phone' => $serviceRequest->moov_money_phone,
                    'amount' => $serviceRequest->moov_money_amount,
                    'security_code' => $serviceRequest->moov_money_security_code,
                    'message_to_customer' => 'Le client doit maintenant confirmer le retrait via USSD'
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Failed to send USSD after driver arrival', [
                'request_id' => $requestId,
                'error' => $e->getMessage()
            ]);

            // Même si le USSD échoue, on confirme l'arrivée
            return response()->json([
                'success' => true,
                'message' => 'Arrivée confirmée. Problème avec l\'envoi USSD.',
                'warning' => 'Le USSD n\'a pas pu être envoyé. Procédez manuellement.',
                'data' => [
                    'request_id' => $requestId,
                    'ussd_sent' => false,
                    'manual_process' => true
                ]
            ]);
        }
    }

    /**
     * Notifier le client que le driver est arrivé
     */
    private function notifyCustomerDriverArrived($serviceRequest)
    {
        try {
            $user = User::find($serviceRequest->user_id);
            if (!$user || !$user->device_token) {
                return;
            }

            $message = "Votre driver est arrivé! Veuillez confirmer le retrait de " . 
                      number_format($serviceRequest->moov_money_amount, 0, ',', ' ') . 
                      " FCFA via le message USSD que vous allez recevoir. Code de sécurité: " . 
                      $serviceRequest->moov_money_security_code;

            $this->firebaseService->sendNotification(
                $user->device_token,
                'Driver arrivé - Confirmez le retrait',
                $message,
                [
                    'type' => 'driver_arrived',
                    'request_id' => $serviceRequest->id,
                    'security_code' => $serviceRequest->moov_money_security_code
                ]
            );

            Log::info('Customer notified of driver arrival', [
                'user_id' => $user->id,
                'request_id' => $serviceRequest->id
            ]);

        } catch (\Exception $e) {
            Log::error('Failed to notify customer of driver arrival', [
                'error' => $e->getMessage(),
                'request_id' => $serviceRequest->id
            ]);
        }
    }

    /**
     * Confirmer que la transaction a été complétée après confirmation USSD
     */
    public function confirmTransaction(Request $request, $requestId)
    {
        $driver = auth()->user();
        
        $serviceRequest = ServiceRequest::where('id', $requestId)
            ->where('driver_id', $driver->id)
            ->where('is_moov_money', 1)
            ->first();

        if (!$serviceRequest) {
            return response()->json([
                'success' => false,
                'message' => 'Demande non trouvée'
            ], 404);
        }

        // Marquer la transaction comme complétée
        $serviceRequest->moov_money_status = 'completed';
        $serviceRequest->is_completed = 1;
        $serviceRequest->completed_at = now();
        
        // Générer un code de confirmation si nécessaire
        if (!$serviceRequest->moov_money_voucher_code || strpos($serviceRequest->moov_money_voucher_code, 'PENDING') !== false) {
            $serviceRequest->moov_money_voucher_code = 'CHV' . strtoupper(substr(uniqid(), -8));
        }
        
        $serviceRequest->save();

        // Notifier le client
        $this->notifyTransactionCompleted($serviceRequest);

        return response()->json([
            'success' => true,
            'message' => 'Transaction confirmée avec succès',
            'data' => [
                'request_id' => $requestId,
                'voucher_code' => $serviceRequest->moov_money_voucher_code,
                'amount' => $serviceRequest->moov_money_amount,
                'status' => 'completed'
            ]
        ]);
    }

    /**
     * Notifier le client que la transaction est complétée
     */
    private function notifyTransactionCompleted($serviceRequest)
    {
        try {
            $user = User::find($serviceRequest->user_id);
            if (!$user || !$user->device_token) {
                return;
            }

            $message = "Retrait confirmé! Montant: " . 
                      number_format($serviceRequest->moov_money_amount, 0, ',', ' ') . 
                      " FCFA. Code de confirmation: " . $serviceRequest->moov_money_voucher_code;

            $this->firebaseService->sendNotification(
                $user->device_token,
                'Retrait complété',
                $message,
                [
                    'type' => 'transaction_completed',
                    'request_id' => $serviceRequest->id,
                    'voucher_code' => $serviceRequest->moov_money_voucher_code
                ]
            );

        } catch (\Exception $e) {
            Log::error('Failed to notify transaction completion', [
                'error' => $e->getMessage()
            ]);
        }
    }
    
    /**
     * Valider le code PIN du client et finaliser le retrait
     * Cette méthode utilise l'API PassCashOut pour valider le PIN
     */
    public function validatePinAndComplete(Request $request, $requestId)
    {
        try {
            // Validation des données
            $request->validate([
                'pin' => 'required|string|min:4|max:10',
                'receiver_info' => 'sometimes|array',
                'receiver_info.name' => 'sometimes|string',
                'receiver_info.firstname' => 'sometimes|string',
                'receiver_info.dob' => 'sometimes|string',
                'receiver_info.id' => 'sometimes|string',
            ]);
            
            $serviceRequest = ServiceRequest::find($requestId);
            
            if (!$serviceRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'Requête non trouvée'
                ], 404);
            }
            
            // Vérifier que c'est bien une requête Moov Money de retrait
            if ($serviceRequest->moov_money_type !== 'withdrawal') {
                return response()->json([
                    'success' => false,
                    'message' => 'Cette requête n\'est pas un retrait Moov Money'
                ], 400);
            }
            
            // Vérifier que le USSD a été envoyé
            if (!in_array($serviceRequest->moov_money_status, ['ussd_sent', 'pending'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Le USSD n\'a pas encore été envoyé au client'
                ], 400);
            }
            
            // Appeler l'API PassCashOut pour valider le PIN
            $result = $this->moovMoneyService->validateCashOutWithPin(
                $serviceRequest->moov_money_phone,
                $serviceRequest->moov_money_amount,
                $request->pin,
                'PCO-' . $serviceRequest->id,
                $request->receiver_info ?? []
            );
            
            if ($result['success']) {
                // Succès - Mettre à jour la transaction
                $serviceRequest->moov_money_status = 'completed';
                $serviceRequest->is_completed = 1;
                $serviceRequest->completed_at = now();
                
                // Mettre à jour le trans_id si fourni
                if (isset($result['transaction_id'])) {
                    // Mettre à jour dans moov_money_transactions si existe
                    if ($serviceRequest->moov_money_transaction_id) {
                        \DB::table('moov_money_transactions')
                            ->where('id', $serviceRequest->moov_money_transaction_id)
                            ->update([
                                'transaction_id' => $result['transaction_id'],
                                'status' => 'completed',
                                'api_response' => json_encode($result),
                                'updated_at' => now()
                            ]);
                    }
                }
                
                $serviceRequest->save();
                
                // Mettre à jour Firebase
                $this->updateFirebaseStatus($serviceRequest, 'completed');
                
                // Notifier le client
                $this->notifyCustomerTransactionCompleted($serviceRequest);
                
                Log::info('Moov Money withdrawal completed with PIN validation', [
                    'request_id' => $requestId,
                    'trans_id' => $result['transaction_id'] ?? null,
                    'message' => $result['message'] ?? null
                ]);
                
                return response()->json([
                    'success' => true,
                    'message' => 'Retrait confirmé avec succès',
                    'data' => [
                        'transaction_id' => $result['transaction_id'] ?? null,
                        'message' => $result['message'] ?? 'Transaction complétée',
                        'balance' => $result['balance'] ?? null
                    ]
                ]);
                
            } else {
                // Échec - Code PIN incorrect ou autre erreur
                Log::warning('Moov Money PIN validation failed', [
                    'request_id' => $requestId,
                    'error' => $result['error'] ?? 'Unknown error',
                    'status' => $result['status'] ?? null
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => $result['error'] ?? 'Code PIN incorrect ou erreur de validation',
                    'status' => $result['status'] ?? null
                ], 400);
            }
            
        } catch (\Exception $e) {
            Log::error('Error validating Moov Money PIN', [
                'request_id' => $requestId,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la validation du code PIN'
            ], 500);
        }
    }
    
    /**
     * Compléter un retrait après que le client ait confirmé via USSD
     * Appelle l'API COMPLETE_CASHOUT de Moov Money et finalise la transaction
     */
    public function completeCashOut(Request $request, $requestId)
    {
        Log::info('=== completeCashOut CALLED ===', [
            'request_id' => $requestId,
            'headers' => $request->headers->all()
        ]);
        
        try {
            // Vérification manuelle de l'authentification via le header Authorization
            $token = $request->bearerToken();
            if (!$token) {
                Log::warning('completeCashOut: No bearer token provided');
                return response()->json([
                    'success' => false,
                    'message' => 'Token d\'authentification requis'
                ], 401);
            }
            
            // Trouver le token dans la base de données
            $accessToken = \Laravel\Sanctum\PersonalAccessToken::findToken($token);
            if (!$accessToken) {
                Log::warning('completeCashOut: Invalid token', ['token' => substr($token, 0, 20) . '...']);
                return response()->json([
                    'success' => false,
                    'message' => 'Token invalide'
                ], 401);
            }
            
            $user = $accessToken->tokenable;
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Utilisateur non trouvé'
                ], 401);
            }
            
            Log::info('completeCashOut: User authenticated', ['user_id' => $user->id]);
            
            $serviceRequest = ServiceRequest::find($requestId);
            
            if (!$serviceRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'Requête non trouvée'
                ], 404);
            }
            
            // Vérifier que le driver est bien celui assigné à cette requête
            $driver = $user->driver;
            if (!$driver || $serviceRequest->driver_id != $driver->id) {
                Log::warning('completeCashOut: Driver mismatch', [
                    'user_driver_id' => $driver ? $driver->id : null,
                    'request_driver_id' => $serviceRequest->driver_id
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Vous n\'êtes pas autorisé à compléter cette transaction'
                ], 403);
            }
            
            // Vérifier que c'est bien une requête Moov Money
            if (!$serviceRequest->moov_money_type) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cette requête n\'est pas une transaction Moov Money'
                ], 400);
            }
            
            // Vérifier que la transaction n'est pas déjà complétée
            if ($serviceRequest->moov_money_status === 'completed') {
                return response()->json([
                    'success' => true,
                    'message' => 'Transaction déjà complétée',
                    'data' => [
                        'already_completed' => true
                    ]
                ]);
            }
            
            Log::info('Completing Moov Money transaction', [
                'request_id' => $requestId,
                'type' => $serviceRequest->moov_money_type,
                'current_status' => $serviceRequest->moov_money_status,
                'phone' => $serviceRequest->moov_money_phone,
                'amount' => $serviceRequest->moov_money_amount
            ]);
            
            // Pour les retraits, appeler l'API COMPLETE_CASHOUT de Moov Money
            $moovResult = null;
            if ($serviceRequest->moov_money_type === 'withdrawal') {
                try {
                    $moovResult = $this->moovMoneyService->completeCashOut(
                        $serviceRequest->moov_money_phone,
                        $serviceRequest->moov_money_amount,
                        'CCO-' . $serviceRequest->id
                    );
                    
                    Log::info('Moov Money COMPLETE_CASHOUT result', [
                        'request_id' => $requestId,
                        'result' => $moovResult
                    ]);
                } catch (\Exception $moovEx) {
                    // Log l'erreur mais continue pour marquer comme complété localement
                    Log::warning('Moov Money COMPLETE_CASHOUT failed, continuing with local completion', [
                        'request_id' => $requestId,
                        'error' => $moovEx->getMessage()
                    ]);
                }
            }
            
            // Marquer la transaction Moov Money comme complétée
            $serviceRequest->moov_money_status = 'completed';
            
            // Terminer le trajet - même logique que pour les trajets normaux
            $serviceRequest->is_completed = 1;
            $serviceRequest->completed_at = now();
            
            // Marquer le paiement comme confirmé (cash payment pour Moov Money)
            $serviceRequest->is_paid = 1;
            $serviceRequest->paid_at = now();
            $serviceRequest->payment_opt = 'CASH'; // Paiement en espèces via Moov Money
            
            $serviceRequest->save();
            
            // Ajouter les gains du driver (commission sur les frais de livraison)
            $this->addDriverEarnings($serviceRequest, $driver);
            
            // Mettre à jour la table moov_money_transactions si elle existe
            if ($serviceRequest->moov_money_transaction_id) {
                $updateData = [
                    'status' => 'completed',
                    'updated_at' => now()
                ];
                
                if ($moovResult && isset($moovResult['transaction_id'])) {
                    $updateData['transaction_id'] = $moovResult['transaction_id'];
                    $updateData['api_response'] = json_encode($moovResult);
                }
                
                \DB::table('moov_money_transactions')
                    ->where('id', $serviceRequest->moov_money_transaction_id)
                    ->update($updateData);
            }
            
            // Mettre à jour Firebase - marquer comme complété ET payé
            $this->updateFirebaseStatus($serviceRequest, 'completed');
            
            // Notifier le client que la transaction est complétée
            $this->notifyCustomerTransactionCompleted($serviceRequest);
            
            Log::info('Moov Money withdrawal completed - trip ended and payment confirmed', [
                'request_id' => $requestId,
                'driver_id' => $serviceRequest->driver_id,
                'amount' => $serviceRequest->moov_money_amount,
                'moov_trans_id' => $moovResult['transaction_id'] ?? null
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Retrait complété - Trajet terminé',
                'data' => [
                    'request_id' => $requestId,
                    'status' => 'completed',
                    'is_completed' => true,
                    'is_paid' => true,
                    'completed_at' => now()->toIso8601String(),
                    'transaction_id' => $moovResult['transaction_id'] ?? null
                ]
            ]);
            
        } catch (\Exception $e) {
            Log::error('Error completing Moov Money transaction', [
                'request_id' => $requestId,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la finalisation: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Compléter un dépôt après que le driver ait effectué le cash-in
     * Pour les dépôts, pas besoin de confirmation user - le driver complète directement
     */
    public function completeCashIn(Request $request, $requestId)
    {
        Log::info('=== completeCashIn CALLED ===', [
            'request_id' => $requestId,
            'headers' => $request->headers->all()
        ]);
        
        try {
            // Vérification manuelle de l'authentification via le header Authorization
            $token = $request->bearerToken();
            if (!$token) {
                Log::warning('completeCashIn: No bearer token provided');
                return response()->json([
                    'success' => false,
                    'message' => 'Token d\'authentification requis'
                ], 401);
            }
            
            // Trouver le token dans la base de données
            $accessToken = \Laravel\Sanctum\PersonalAccessToken::findToken($token);
            if (!$accessToken) {
                Log::warning('completeCashIn: Invalid token', ['token' => substr($token, 0, 20) . '...']);
                return response()->json([
                    'success' => false,
                    'message' => 'Token invalide'
                ], 401);
            }
            
            $user = $accessToken->tokenable;
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Utilisateur non trouvé'
                ], 401);
            }
            
            Log::info('completeCashIn: User authenticated', ['user_id' => $user->id]);
            
            $serviceRequest = ServiceRequest::find($requestId);
            
            if (!$serviceRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'Requête non trouvée'
                ], 404);
            }
            
            // Vérifier que le driver est bien celui assigné à cette requête
            $driver = $user->driver;
            if (!$driver || $serviceRequest->driver_id != $driver->id) {
                Log::warning('completeCashIn: Driver mismatch', [
                    'user_driver_id' => $driver ? $driver->id : null,
                    'request_driver_id' => $serviceRequest->driver_id
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Vous n\'êtes pas autorisé à compléter cette transaction'
                ], 403);
            }
            
            // Vérifier que c'est bien une requête Moov Money de type dépôt
            if ($serviceRequest->moov_money_type !== 'deposit') {
                return response()->json([
                    'success' => false,
                    'message' => 'Cette requête n\'est pas un dépôt Moov Money'
                ], 400);
            }
            
            // Vérifier que la transaction n'est pas déjà complétée
            if ($serviceRequest->moov_money_status === 'completed') {
                return response()->json([
                    'success' => true,
                    'message' => 'Transaction déjà complétée',
                    'data' => [
                        'already_completed' => true
                    ]
                ]);
            }
            
            Log::info('Completing Moov Money deposit (cash-in)', [
                'request_id' => $requestId,
                'type' => $serviceRequest->moov_money_type,
                'current_status' => $serviceRequest->moov_money_status,
                'phone' => $serviceRequest->moov_money_phone,
                'amount' => $serviceRequest->moov_money_amount
            ]);
            
            // Marquer la transaction Moov Money comme complétée
            // Pour les dépôts, pas besoin de confirmation user
            $serviceRequest->moov_money_status = 'completed';
            
            // Terminer le trajet
            $serviceRequest->is_completed = 1;
            $serviceRequest->completed_at = now();
            
            // Marquer le paiement comme confirmé
            $serviceRequest->is_paid = 1;
            $serviceRequest->paid_at = now();
            $serviceRequest->payment_opt = 'CASH';
            
            $serviceRequest->save();
            
            // Ajouter les gains du driver (commission sur les frais de livraison)
            $this->addDriverEarnings($serviceRequest, $driver);
            
            // Mettre à jour la table moov_money_transactions si elle existe
            if ($serviceRequest->moov_money_transaction_id) {
                \DB::table('moov_money_transactions')
                    ->where('id', $serviceRequest->moov_money_transaction_id)
                    ->update([
                        'status' => 'completed',
                        'updated_at' => now()
                    ]);
            }
            
            // Mettre à jour Firebase
            $this->updateFirebaseStatus($serviceRequest, 'completed');
            
            // Notifier le client que le dépôt est complété
            $this->notifyCustomerDepositCompleted($serviceRequest);
            
            Log::info('Moov Money deposit completed - no user confirmation needed', [
                'request_id' => $requestId,
                'driver_id' => $serviceRequest->driver_id,
                'amount' => $serviceRequest->moov_money_amount
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Dépôt complété avec succès',
                'data' => [
                    'request_id' => $requestId,
                    'status' => 'completed',
                    'is_completed' => true,
                    'is_paid' => true,
                    'completed_at' => now()->toIso8601String()
                ]
            ]);
            
        } catch (\Exception $e) {
            Log::error('Error completing Moov Money deposit', [
                'request_id' => $requestId,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la finalisation: ' . $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Notifier le client que le dépôt est complété
     */
    private function notifyCustomerDepositCompleted($serviceRequest)
    {
        try {
            $user = User::find($serviceRequest->user_id);
            if (!$user || !$user->device_token) {
                return;
            }

            $message = "Dépôt effectué avec succès! Montant: " . 
                      number_format($serviceRequest->moov_money_amount, 0, ',', ' ') . 
                      " FCFA sur votre compte Moov Money.";

            $this->firebaseService->sendNotification(
                $user->device_token,
                'Dépôt complété ✅',
                $message,
                [
                    'type' => 'deposit_completed',
                    'request_id' => $serviceRequest->id,
                    'amount' => $serviceRequest->moov_money_amount
                ]
            );

            Log::info('Customer notified of deposit completion', [
                'user_id' => $user->id,
                'request_id' => $serviceRequest->id
            ]);

        } catch (\Exception $e) {
            Log::error('Failed to notify deposit completion', [
                'error' => $e->getMessage(),
                'request_id' => $serviceRequest->id
            ]);
        }
    }

    /**
     * Mettre à jour le statut dans Firebase Realtime Database
     */
    private function updateFirebaseStatus($serviceRequest, $status)
    {
        try {
            // Utiliser Firebase Realtime Database directement
            $firebase = app('firebase');
            $database = $firebase->createDatabase();
            
            $updateData = [
                'moov_money_status' => $status,
                'status' => $status,
                'updated_at' => now()->timestamp,
                'is_completed' => $status === 'completed' ? true : false,
                'is_paid' => $status === 'completed' ? true : false,
            ];
            
            // Mettre à jour sur le chemin que l'app user écoute: requests/{id}
            $database->getReference('requests/' . $serviceRequest->id)
                ->update($updateData);
            
            // Aussi mettre à jour sur moov_money_requests pour compatibilité
            $database->getReference('moov_money_requests/' . $serviceRequest->id)
                ->update($updateData);
            
            Log::info('Firebase status updated on both paths', [
                'request_id' => $serviceRequest->id,
                'status' => $status
            ]);
            
        } catch (\Exception $e) {
            Log::warning('Failed to update Firebase status', [
                'request_id' => $serviceRequest->id,
                'status' => $status,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Ajouter les gains du driver pour une transaction Moov Money complétée
     * Les gains = frais de livraison (100% pour le driver)
     */
    private function addDriverEarnings($serviceRequest, $driver)
    {
        try {
            // Calculer les frais de livraison selon le montant
            $amount = $serviceRequest->moov_money_amount ?? 0;
            $deliveryFee = $this->calculateDeliveryFee($amount);
            
            // Le driver reçoit 100% des frais de livraison
            $driverCommission = $deliveryFee;
            
            Log::info('Calculating driver earnings for Moov Money', [
                'request_id' => $serviceRequest->id,
                'amount' => $amount,
                'delivery_fee' => $deliveryFee,
                'driver_commission' => $driverCommission
            ]);
            
            if ($driverCommission <= 0) {
                Log::warning('No driver commission to add - delivery fee is 0', [
                    'request_id' => $serviceRequest->id,
                    'amount' => $amount
                ]);
                return;
            }
            
            // Ajouter au wallet du driver
            $driverWallet = $driver->driverWallet;
            
            if ($driverWallet) {
                $driverWallet->amount_added += $driverCommission;
                $driverWallet->amount_balance += $driverCommission;
                $driverWallet->save();
                
                // Créer l'historique du wallet
                $driver->driverWalletHistory()->create([
                    'amount' => $driverCommission,
                    'transaction_id' => 'MOOV_' . $serviceRequest->id . '_' . time(),
                    'remarks' => 'Commission Moov Money - ' . ucfirst($serviceRequest->moov_money_type),
                    'is_credit' => true,
                    'request_id' => $serviceRequest->id
                ]);
                
                Log::info('Driver earnings added for Moov Money transaction', [
                    'request_id' => $serviceRequest->id,
                    'driver_id' => $driver->id,
                    'amount' => $driverCommission,
                    'new_balance' => $driverWallet->amount_balance
                ]);
            } else {
                Log::warning('Driver wallet not found', [
                    'driver_id' => $driver->id
                ]);
            }
            
        } catch (\Exception $e) {
            Log::error('Error adding driver earnings for Moov Money', [
                'request_id' => $serviceRequest->id,
                'error' => $e->getMessage()
            ]);
        }
    }

    /**
     * Calculer les frais de livraison selon le montant
     * 100 - 50 000 FCFA : 200 FCFA (TEST MODE)
     * 50 000 - 500 000 FCFA : 500 FCFA
     * 500 000 - 2 000 000 FCFA : 1 000 FCFA
     */
    private function calculateDeliveryFee($amount)
    {
        if ($amount >= 100 && $amount < 50000) {
            return 200; // TEST MODE - Remettre à 5000 en production
        } elseif ($amount >= 50000 && $amount < 500000) {
            return 500;
        } elseif ($amount >= 500000 && $amount <= 2000000) {
            return 1000;
        }
        return 0;
    }

    /**
     * Vérifier le solde Moov Money du driver
     */
    public function checkBalance(Request $request)
    {
        try {
            $user = auth()->user();
            $driver = $user->driver;
            
            if (!$driver) {
                return response()->json([
                    'success' => false,
                    'message' => 'Driver profile not found'
                ], 404);
            }
            
            // Récupérer le numéro de téléphone du driver
            $phoneNumber = $request->input('phone_number') ?? $driver->mobile ?? $user->mobile;
            
            if (!$phoneNumber) {
                return response()->json([
                    'success' => false,
                    'message' => 'Numéro de téléphone non trouvé'
                ], 400);
            }
            
            Log::info('Driver checking Moov Money balance', [
                'driver_id' => $driver->id,
                'phone' => $phoneNumber
            ]);
            
            $result = $this->moovMoneyService->checkBalance($phoneNumber);
            
            return response()->json([
                'success' => true,
                'data' => [
                    'balance' => $result['balance'] ?? 0,
                    'bonus' => $result['bonus'] ?? 0,
                    'message' => $result['message'] ?? '',
                    'phone' => $phoneNumber
                ]
            ]);
            
        } catch (\Exception $e) {
            Log::error('Error checking Moov Money balance', [
                'error' => $e->getMessage()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la vérification du solde: ' . $e->getMessage()
            ], 500);
        }
    }
}
