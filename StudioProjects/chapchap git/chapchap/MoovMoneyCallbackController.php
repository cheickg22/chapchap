<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Models\UserWalletHistory;
use App\Models\User;
use App\Services\FirebaseService;

class MoovMoneyCallbackController extends Controller
{
    /**
     * Recevoir les callbacks de Moov Money après confirmation USSD
     * POST /api/v1/moov-money/callback
     */
    public function handleCallback(Request $request)
    {
        try {
            // Logger toute la requête pour debug
            Log::info('Moov Money Callback Received', [
                'headers' => $request->headers->all(),
                'body' => $request->all(),
                'raw' => $request->getContent()
            ]);

            // Parser la réponse selon le format Moov Money
            $data = $request->all();
            
            // Chercher la transaction par request-id ou trans-id
            $requestId = $data['request-id'] ?? $data['requestId'] ?? null;
            $transId = $data['trans-id'] ?? $data['transId'] ?? null;
            $status = $data['status'] ?? null;
            
            if ($requestId || $transId) {
                // Chercher la requête Moov Money par le voucher code ou request number
                $serviceRequest = \App\Models\Request\Request::where('is_moov_money', 1)
                    ->where(function($query) use ($requestId, $transId) {
                        if ($requestId) {
                            $query->where('request_number', 'LIKE', "%{$requestId}%")
                                  ->orWhere('moov_money_voucher_code', 'LIKE', "%{$requestId}%");
                        }
                        if ($transId) {
                            $query->orWhere('moov_money_voucher_code', $transId);
                        }
                    })
                    ->first();
                    
                if ($serviceRequest) {
                    // Mettre à jour le statut selon la réponse
                    if ($status == '0' || $status == 0) {
                        // Succès
                        $serviceRequest->moov_money_status = 'user_confirmed';
                        if ($transId) {
                            $serviceRequest->moov_money_voucher_code = $transId;
                        }
                        $serviceRequest->save();
                        
                        Log::info('Moov Money request updated to user_confirmed', [
                            'request_id' => $serviceRequest->id,
                            'trans_id' => $transId
                        ]);
                        
                        // Mettre à jour Firebase pour notifier le driver
                        $this->updateFirebaseStatus($serviceRequest, 'user_confirmed');
                        
                        // Envoyer une notification immédiate à l'utilisateur
                        $this->sendCompletionNotification($serviceRequest);
                    } else {
                        // Échec
                        $serviceRequest->moov_money_status = 'failed';
                        $serviceRequest->save();
                        
                        // Mettre à jour Firebase
                        $this->updateFirebaseStatus($serviceRequest, 'failed');
                        
                        Log::warning('Moov Money request failed', [
                            'request_id' => $serviceRequest->id,
                            'status' => $status,
                            'message' => $data['message'] ?? 'Unknown error'
                        ]);
                    }
                    
                    Log::info('Moov Money callback processed', [
                        'request_id' => $serviceRequest->id,
                        'status' => $serviceRequest->moov_money_status,
                        'trans_id' => $transId
                    ]);
                    
                    return response()->json([
                        'success' => true,
                        'message' => 'Callback processed successfully'
                    ]);
                } else {
                    Log::warning('Moov Money callback: Transaction not found', [
                        'request_id' => $requestId,
                        'trans_id' => $transId
                    ]);
                }
            }
            
            // Retourner une réponse de succès même si on ne trouve pas la transaction
            // pour éviter que Moov Money renvoie le callback
            return response()->json([
                'success' => true,
                'message' => 'Callback received'
            ]);
            
        } catch (\Exception $e) {
            Log::error('Moov Money Callback Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error processing callback',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Endpoint pour vérifier le statut d'une transaction
     * GET /api/v1/moov-money/status/{requestId}
     */
    public function checkStatus($requestId)
    {
        try {
            // Chercher la requête Moov Money
            $serviceRequest = \App\Models\Request\Request::where('is_moov_money', 1)
                ->where(function($query) use ($requestId) {
                    $query->where('request_number', 'LIKE', "%{$requestId}%")
                          ->orWhere('moov_money_voucher_code', 'LIKE', "%{$requestId}%")
                          ->orWhere('id', $requestId);
                })
                ->first();
                
            if (!$serviceRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'Transaction not found'
                ], 404);
            }
            
            return response()->json([
                'success' => true,
                'data' => [
                    'status' => $serviceRequest->moov_money_status,
                    'transaction_id' => $serviceRequest->moov_money_voucher_code,
                    'amount' => $serviceRequest->moov_money_amount,
                    'currency' => 'XOF',
                    'phone_number' => $serviceRequest->moov_money_phone,
                    'type' => $serviceRequest->moov_money_type,
                    'created_at' => $serviceRequest->created_at,
                    'updated_at' => $serviceRequest->updated_at
                ]
            ]);
            
        } catch (\Exception $e) {
            Log::error('Moov Money Status Check Error', [
                'error' => $e->getMessage()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Error checking status',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Mettre à jour le statut dans Firebase pour notifier le driver
     */
    protected function updateFirebaseStatus($serviceRequest, $status)
    {
        try {
            $database = app('firebase.database');
            $reference = $database->getReference('moov_money_requests/' . $serviceRequest->id);
            
            $reference->update([
                'moov_money_status' => $status,
                'updated_at' => now()->toIso8601String(),
                '_firebase_status' => $status,
                '_firebase_updated_at' => now()->toIso8601String(),
            ]);
            
            Log::info('Firebase updated for Moov Money callback', [
                'request_id' => $serviceRequest->id,
                'status' => $status
            ]);
            
        } catch (\Exception $e) {
            Log::error('Error updating Firebase for Moov Money callback', [
                'error' => $e->getMessage(),
                'request_id' => $serviceRequest->id
            ]);
        }
    }
    
    /**
     * Envoyer une notification de confirmation à l'utilisateur
     */
    protected function sendCompletionNotification($serviceRequest)
    {
        try {
            $user = User::find($serviceRequest->user_id);
            
            if (!$user) {
                return;
            }

            $message = '';
            if ($serviceRequest->moov_money_type === 'withdrawal') {
                $message = "✅ Retrait confirmé! Montant: {$serviceRequest->moov_money_amount} FCFA. Code voucher: {$serviceRequest->moov_money_voucher_code}. Présentez ce code à l'agent pour recevoir votre argent.";
            } else {
                $message = "✅ Dépôt confirmé! Montant: {$serviceRequest->moov_money_amount} FCFA. La transaction a été complétée avec succès.";
            }

            // Envoyer notification Firebase
            if ($user->fcm_token) {
                app(FirebaseService::class)->sendNotification(
                    $user->fcm_token,
                    '✅ Transaction Moov Money confirmée',
                    $message,
                    [
                        'type' => 'moov_money_completed',
                        'request_id' => $serviceRequest->id,
                        'amount' => $serviceRequest->moov_money_amount,
                        'voucher_code' => $serviceRequest->moov_money_voucher_code,
                        'status' => 'completed'
                    ]
                );
            }

            Log::info('Completion notification sent', [
                'user_id' => $user->id,
                'request_id' => $serviceRequest->id,
                'type' => $serviceRequest->moov_money_type
            ]);
            
        } catch (\Exception $e) {
            Log::error('Error sending completion notification', [
                'error' => $e->getMessage(),
                'request_id' => $serviceRequest->id
            ]);
        }
    }
}
