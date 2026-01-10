<?php

namespace App\Http\Controllers\Api\V1\MoovMoney;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request as HttpRequest;
use App\Models\Request\Request as ServiceRequest;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class MoovMoneyCallbackController extends Controller
{
    /**
     * Gérer les callbacks de Moov Money
     */
    public function handle(HttpRequest $request)
    {
        // Logger toute la requête pour debug
        Log::info('Moov Money Callback Received', [
            'headers' => $request->headers->all(),
            'body' => $request->all(),
            'raw' => $request->getContent()
        ]);

        try {
            // Récupérer les données du callback
            $data = $request->all();
            
            // Moov Money envoie généralement ces champs
            $transId = $data['trans-id'] ?? $data['trans_id'] ?? $data['transId'] ?? null;
            $requestId = $data['request-id'] ?? $data['request_id'] ?? $data['requestId'] ?? null;
            $status = $data['status'] ?? null;
            $message = $data['message'] ?? null;
            
            if (!$transId && !$requestId) {
                Log::warning('Moov Money Callback: Missing transaction or request ID', $data);
                return response()->json([
                    'success' => false,
                    'message' => 'Missing transaction or request ID'
                ], 400);
            }

            // Trouver la requête correspondante
            $serviceRequest = null;
            
            // Chercher par trans-id dans moov_money_transactions
            if ($transId) {
                $transaction = DB::table('moov_money_transactions')
                    ->where('transaction_id', $transId)
                    ->orWhere('voucher_code', $transId)
                    ->first();
                    
                if ($transaction) {
                    $serviceRequest = ServiceRequest::where('moov_money_transaction_id', $transaction->id)->first();
                }
            }
            
            // Si pas trouvé, chercher par voucher_code directement
            if (!$serviceRequest && $transId) {
                $serviceRequest = ServiceRequest::where('moov_money_voucher_code', $transId)->first();
            }
            
            // Si pas trouvé, chercher par request-id (qui pourrait être notre request_id)
            if (!$serviceRequest && $requestId) {
                // Le request-id pourrait être notre ID de requête ou un ID personnalisé
                $serviceRequest = ServiceRequest::find($requestId);
                
                if (!$serviceRequest) {
                    // Chercher dans les transactions
                    $transaction = DB::table('moov_money_transactions')
                        ->where('conversation_id', $requestId)
                        ->first();
                        
                    if ($transaction) {
                        $serviceRequest = ServiceRequest::where('moov_money_transaction_id', $transaction->id)->first();
                    }
                }
            }
            
            if (!$serviceRequest) {
                Log::warning('Moov Money Callback: Request not found', [
                    'trans_id' => $transId,
                    'request_id' => $requestId
                ]);
                
                // Retourner succès pour éviter que Moov Money renvoie
                return response()->json([
                    'success' => true,
                    'message' => 'Request not found but acknowledged'
                ]);
            }

            // Mettre à jour le statut selon la réponse
            $newStatus = 'completed'; // Par défaut
            
            if ($status == '0' || strtolower($message) == 'success' || strtolower($message) == 'successful') {
                $newStatus = 'completed';
            } elseif (in_array($status, ['1', '2', '3', '4', '5'])) {
                // Codes d'erreur Moov Money
                $newStatus = 'failed';
            }
            
            // Mettre à jour la requête
            $serviceRequest->moov_money_status = $newStatus;
            if ($newStatus == 'completed') {
                $serviceRequest->is_completed = 1;
                $serviceRequest->completed_at = now();
            }
            $serviceRequest->save();
            
            // Mettre à jour la transaction si elle existe
            if ($serviceRequest->moov_money_transaction_id) {
                DB::table('moov_money_transactions')
                    ->where('id', $serviceRequest->moov_money_transaction_id)
                    ->update([
                        'status' => $newStatus,
                        'callback_response' => json_encode($data),
                        'updated_at' => now()
                    ]);
            }
            
            Log::info('Moov Money Callback Processed', [
                'request_id' => $serviceRequest->id,
                'new_status' => $newStatus,
                'trans_id' => $transId
            ]);
            
            // Notifier via Firebase si nécessaire
            $this->updateFirebase($serviceRequest, $newStatus);
            
            return response()->json([
                'success' => true,
                'message' => 'Callback processed successfully'
            ]);
            
        } catch (\Exception $e) {
            Log::error('Moov Money Callback Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Internal error processing callback'
            ], 500);
        }
    }
    
    /**
     * Mettre à jour Firebase
     */
    private function updateFirebase($serviceRequest, $status)
    {
        try {
            $firebase = app('firebase.database');
            
            $firebase->getReference('moov_money_requests/' . $serviceRequest->id)
                ->update([
                    'status' => $status,
                    'moov_money_status' => $status,
                    'is_completed' => $status == 'completed' ? 1 : 0,
                    'completed_at' => $status == 'completed' ? now()->timestamp : null,
                    'updated_at' => now()->timestamp
                ]);
                
            Log::info('Firebase updated from Moov Money callback', [
                'request_id' => $serviceRequest->id,
                'status' => $status
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to update Firebase from callback', [
                'error' => $e->getMessage()
            ]);
        }
    }
}
