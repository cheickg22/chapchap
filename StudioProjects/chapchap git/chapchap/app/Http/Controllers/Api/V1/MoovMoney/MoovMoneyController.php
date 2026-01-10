<?php

namespace App\Http\Controllers\Api\V1\MoovMoney;

use App\Http\Controllers\ApiController;
use App\Models\MoovMoney\MoovMoneyTransaction;
use App\Services\MoovMoney\MoovMoneyService;
use App\Transformers\MoovMoney\MoovMoneyTransactionTransformer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class MoovMoneyController extends ApiController
{
    protected $moovMoneyService;

    public function __construct(MoovMoneyService $moovMoneyService)
    {
        $this->moovMoneyService = $moovMoneyService;
    }

    /**
     * Gérer le callback de Moov Money
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handleCallback(Request $request)
    {
        // Logger toute la requête pour debug
        Log::info('Moov Money Callback Received', [
            'method' => $request->method(),
            'url' => $request->fullUrl(),
            'headers' => $request->headers->all(),
            'body' => $request->all(),
            'raw_content' => $request->getContent(),
        ]);

        // Parser la réponse selon le format (XML ou JSON)
        $contentType = $request->header('Content-Type');
        
        if (strpos($contentType, 'xml') !== false) {
            // Parser XML
            try {
                $xml = simplexml_load_string($request->getContent());
                $json = json_encode($xml);
                $data = json_decode($json, true);
                
                Log::info('Moov Money Callback Parsed (XML)', ['data' => $data]);
            } catch (\Exception $e) {
                Log::error('Failed to parse XML callback', ['error' => $e->getMessage()]);
                return response()->json(['status' => 'error', 'message' => 'Invalid XML'], 400);
            }
        } else {
            // Parser JSON
            $data = $request->all();
            Log::info('Moov Money Callback Parsed (JSON)', ['data' => $data]);
        }

        // Extraire les informations importantes
        $conversationId = $data['OriginatorConversationID'] ?? $data['ConversationID'] ?? null;
        $resultCode = $data['ResultCode'] ?? $data['status'] ?? null;
        $resultDesc = $data['ResultDesc'] ?? $data['message'] ?? null;
        $transactionId = $data['TransactionID'] ?? null;

        // Mettre à jour la transaction dans la base de données
        if ($conversationId) {
            try {
                $transaction = MoovMoneyTransaction::where('conversation_id', $conversationId)->first();
                
                if ($transaction) {
                    $transaction->update([
                        'moov_transaction_id' => $transactionId,
                        'result_code' => $resultCode,
                        'result_desc' => $resultDesc,
                        'status' => $resultCode == 0 ? 'completed' : 'failed',
                        'callback_received_at' => now(),
                        'callback_data' => json_encode($data),
                    ]);
                    
                    Log::info('Transaction updated from callback', [
                        'conversation_id' => $conversationId,
                        'status' => $transaction->status,
                    ]);
                }
            } catch (\Exception $e) {
                Log::error('Failed to update transaction from callback', [
                    'error' => $e->getMessage(),
                    'conversation_id' => $conversationId,
                ]);
            }
        }

        // Retourner une réponse de succès à Moov Money
        return response()->json(['status' => 'success', 'message' => 'Callback received'], 200);
    }

    /**
     * Obtenir les agents Moov Money à proximité
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getNearbyAgents(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius' => 'nullable|numeric|min:1|max:50', // Rayon en km
        ]);

        if ($validator->fails()) {
            return $this->respondBadRequest('Validation failed', $validator->errors());
        }

        $latitude = $request->latitude;
        $longitude = $request->longitude;
        $radius = $request->radius ?? 5; // 5km par défaut

        // TODO: Implémenter la logique pour récupérer les agents depuis l'API Moov Money
        // Pour l'instant, retourner des données fictives
        $agents = [
            [
                'id' => 1,
                'name' => 'Agent Moov Money - Centre Ville',
                'address' => 'Avenue de la République, Bamako',
                'phone' => '+223 70 00 00 01',
                'latitude' => $latitude + 0.01,
                'longitude' => $longitude + 0.01,
                'distance' => 1.2, // en km
                'opening_hours' => '08:00 - 18:00',
                'is_open' => true,
            ],
            [
                'id' => 2,
                'name' => 'Agent Moov Money - Marché',
                'address' => 'Grand Marché, Bamako',
                'phone' => '+223 70 00 00 02',
                'latitude' => $latitude - 0.02,
                'longitude' => $longitude + 0.015,
                'distance' => 2.5,
                'opening_hours' => '07:00 - 19:00',
                'is_open' => true,
            ],
        ];

        return $this->respondSuccess($agents, 'Agents trouvés avec succès');
    }

    /**
     * Initier un dépôt Moov Money
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function initiateDeposit(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:100', // Montant minimum 100 XOF
            'phone_number' => 'required|string|max:20',
            'agent_id' => 'nullable|integer',
            'agent_location' => 'nullable|string',
            'agent_lat' => 'nullable|numeric',
            'agent_lng' => 'nullable|numeric',
        ]);

        if ($validator->fails()) {
            return $this->respondBadRequest('Validation failed', $validator->errors());
        }

        $user = auth()->user();

        try {
            // Créer la transaction
            $transaction = MoovMoneyTransaction::create([
                'user_id' => $user->id,
                'transaction_type' => 'deposit',
                'status' => 'pending',
                'amount' => $request->amount,
                'currency' => 'XOF',
                'phone_number' => $request->phone_number,
                'agent_location' => $request->agent_location,
                'agent_lat' => $request->agent_lat,
                'agent_lng' => $request->agent_lng,
            ]);

            Log::info('Moov Money Deposit initiated', [
                'transaction_id' => $transaction->id,
                'user_id' => $user->id,
                'amount' => $request->amount,
            ]);

            // Appeler l'API Moov Money pour initier le dépôt
            $apiResponse = $this->moovMoneyService->initiateCashIn(
                $request->phone_number,
                $request->amount,
                'XOF',
                'CHAPIN_' . $transaction->id
            );

            // Sauvegarder la réponse API
            $transaction->api_response = json_encode($apiResponse);
            $transaction->originator_conversation_id = $apiResponse['originator_conversation_id'] ?? null;
            $transaction->conversation_id = $apiResponse['conversation_id'] ?? null;

            if ($apiResponse['success'] && isset($apiResponse['response_code']) && $apiResponse['response_code'] == '0') {
                // La requête a été acceptée, en attente du résultat
                $transaction->status = 'pending';
                $transaction->save();
            } else {
                // Échec de la requête
                $transaction->markAsFailed($apiResponse['response_desc'] ?? $apiResponse['error'] ?? 'Erreur API Moov Money');
            }

            return $this->respondWithItem($transaction, new MoovMoneyTransactionTransformer);

        } catch (\Exception $e) {
            Log::error('Moov Money Deposit failed', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

            return $this->respondInternalError('Erreur lors de l\'initiation du dépôt');
        }
    }

    /**
     * Générer un voucher de retrait
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function generateWithdrawalVoucher(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:100',
            'phone_number' => 'required|string|max:20',
        ]);

        if ($validator->fails()) {
            return $this->respondBadRequest('Validation failed', $validator->errors());
        }

        $user = auth()->user();

        try {
            // Vérifier le solde de l'utilisateur (si applicable)
            // TODO: Implémenter la vérification du solde

            // Générer le code voucher
            $voucherCode = MoovMoneyTransaction::generateVoucherCode();
            
            // Les 4 derniers chiffres du numéro de téléphone pour validation
            $validationValue = substr($request->phone_number, -4);

            // Créer la transaction
            $transaction = MoovMoneyTransaction::create([
                'user_id' => $user->id,
                'transaction_type' => 'withdrawal',
                'status' => 'pending',
                'amount' => $request->amount,
                'currency' => 'XOF',
                'phone_number' => $request->phone_number,
                'voucher_code' => $voucherCode,
                'voucher_validation_value' => $validationValue,
                'voucher_expires_at' => Carbon::now()->addHours(24), // Expire dans 24h
            ]);

            Log::info('Moov Money Withdrawal Voucher generated', [
                'transaction_id' => $transaction->id,
                'user_id' => $user->id,
                'voucher_code' => $voucherCode,
                'amount' => $request->amount,
            ]);

            // Appeler l'API Moov Money pour générer le voucher
            $apiResponse = $this->moovMoneyService->generateCashOutVoucher(
                $request->phone_number,
                $request->amount,
                'XOF',
                'CHAPOUT_' . $transaction->id
            );

            // Sauvegarder la réponse API
            $transaction->api_response = json_encode($apiResponse);
            $transaction->originator_conversation_id = $apiResponse['originator_conversation_id'] ?? null;
            $transaction->conversation_id = $apiResponse['conversation_id'] ?? null;

            if ($apiResponse['success']) {
                // Le voucher a été généré avec succès
                if (isset($apiResponse['transaction_id'])) {
                    $transaction->transaction_id = $apiResponse['transaction_id'];
                    // Utiliser le transaction_id comme voucher_code
                    $transaction->voucher_code = $apiResponse['transaction_id'];
                }
                $transaction->status = 'pending';
                $transaction->save();
            } else {
                // Échec de la génération du voucher
                $transaction->markAsFailed($apiResponse['error'] ?? 'Erreur API Moov Money');
            }

            return $this->respondWithItem($transaction, new MoovMoneyTransactionTransformer);

        } catch (\Exception $e) {
            Log::error('Moov Money Withdrawal Voucher generation failed', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

            return $this->respondInternalError('Erreur lors de la génération du voucher');
        }
    }

    /**
     * Obtenir l'historique des transactions Moov Money
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTransactionHistory(Request $request)
    {
        $user = auth()->user();

        $query = MoovMoneyTransaction::where('user_id', $user->id)
            ->orderBy('created_at', 'desc');

        // Filtrer par type si spécifié
        if ($request->has('type') && in_array($request->type, ['deposit', 'withdrawal'])) {
            $query->where('transaction_type', $request->type);
        }

        // Filtrer par statut si spécifié
        if ($request->has('status') && in_array($request->status, ['pending', 'completed', 'failed', 'cancelled'])) {
            $query->where('status', $request->status);
        }

        $transactions = $query->paginate(20);

        return $this->respondWithCollection($transactions, new MoovMoneyTransactionTransformer);
    }

    /**
     * Obtenir les détails d'une transaction
     * 
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTransactionDetails($id)
    {
        $user = auth()->user();

        $transaction = MoovMoneyTransaction::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$transaction) {
            return $this->respondNotFound('Transaction non trouvée');
        }

        return $this->respondWithItem($transaction, new MoovMoneyTransactionTransformer);
    }

    /**
     * Annuler une transaction en attente
     * 
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function cancelTransaction($id)
    {
        $user = auth()->user();

        $transaction = MoovMoneyTransaction::where('id', $id)
            ->where('user_id', $user->id)
            ->where('status', 'pending')
            ->first();

        if (!$transaction) {
            return $this->respondNotFound('Transaction non trouvée ou déjà traitée');
        }

        $transaction->status = 'cancelled';
        $transaction->save();

        Log::info('Moov Money Transaction cancelled', [
            'transaction_id' => $transaction->id,
            'user_id' => $user->id,
        ]);

        return $this->respondWithItem($transaction, new MoovMoneyTransactionTransformer);
    }
}
