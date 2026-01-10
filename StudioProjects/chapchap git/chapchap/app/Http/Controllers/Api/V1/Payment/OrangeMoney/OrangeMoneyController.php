<?php

namespace App\Http\Controllers\Api\V1\Payment\OrangeMoney;

use App\Http\Controllers\ApiController;
use App\Services\OrangeMoneyService;
use App\Models\Payment\OrangeMoneyTransaction;
use App\Models\Payment\UserWallet;
use App\Models\Payment\DriverWallet;
use App\Models\Payment\OwnerWallet;
use App\Models\Payment\UserWalletHistory;
use App\Models\Payment\DriverWalletHistory;
use App\Models\Payment\OwnerWalletHistory;
use App\Base\Constants\Masters\WalletRemarks;
use App\Jobs\Notifications\SendPushNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Exception;

/**
 * @group Orange Money Payment Gateway
 *
 * APIs pour les paiements Orange Money WebPay
 */
class OrangeMoneyController extends ApiController
{
    protected $orangeMoneyService;

    public function __construct(OrangeMoneyService $orangeMoneyService)
    {
        $this->orangeMoneyService = $orangeMoneyService;
    }

    /**
     * Initier un paiement Orange Money
     * 
     * @bodyParam amount numeric required Montant à payer. Example: 5000
     * @bodyParam payment_for string required Type de paiement (wallet, subscription, trip). Example: wallet
     * @bodyParam request_id string ID de la course (si payment_for=trip). Example: REQ123
     * @bodyParam plan_id string ID du plan (si payment_for=subscription). Example: PLAN456
     * 
     * @response {
     *   "success": true,
     *   "message": "Paiement initié avec succès",
     *   "data": {
     *     "transaction_id": "uuid",
     *     "order_id": "OM-1234567890-ABCD1234",
     *     "payment_url": "https://mpayment.orange-money.com/...",
     *     "amount": 5000,
     *     "currency": "XOF"
     *   }
     * }
     */
    public function initiatePayment(Request $request)
    {
        try {
            // Vérifier si Orange Money est activé
            if (!$this->orangeMoneyService->isEnabled()) {
                return $this->respondBadRequest('Orange Money n\'est pas activé');
            }

            // Validation
            $validator = Validator::make($request->all(), [
                'amount' => 'required|numeric|min:100',
                'payment_for' => 'required|in:wallet,subscription,trip',
                'request_id' => 'required_if:payment_for,trip',
                'plan_id' => 'required_if:payment_for,subscription',
            ]);

            if ($validator->fails()) {
                return $this->respondValidationError($validator->errors());
            }

            $user = auth()->user();
            $amount = $request->amount;
            $paymentFor = $request->payment_for;

            // Générer un order_id unique
            $orderId = $this->orangeMoneyService->generateOrderId();

            // Créer la transaction en base de données
            $transaction = OrangeMoneyTransaction::create([
                'user_id' => $user->id,
                'user_type' => $this->getUserType($user),
                'order_id' => $orderId,
                'amount' => $amount,
                'currency' => config('orange_money.currency'),
                'payment_for' => $paymentFor,
                'request_id' => $request->request_id,
                'plan_id' => $request->plan_id,
                'status' => 'pending',
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'metadata' => [
                    'user_name' => $user->name,
                    'user_mobile' => $user->mobile,
                ],
            ]);

            // Initier le paiement avec Orange Money
            $paymentResult = $this->orangeMoneyService->initiatePayment([
                'order_id' => $orderId,
                'amount' => $amount,
                'reference' => 'ChapChap-' . $transaction->uuid,
            ]);

            if (!$paymentResult['success']) {
                $transaction->markAsFailed($paymentResult['message']);
                return $this->respondBadRequest($paymentResult['message']);
            }

            // Mettre à jour la transaction
            $transaction->markAsInitiated($paymentResult);

            return $this->respondSuccess([
                'transaction_id' => $transaction->uuid,
                'order_id' => $orderId,
                'payment_url' => $paymentResult['payment_url'],
                'amount' => $amount,
                'currency' => config('orange_money.currency'),
            ], 'Paiement initié avec succès');

        } catch (Exception $e) {
            Log::error('[Orange Money] Initiate Payment Error: ' . $e->getMessage());
            return $this->respondInternalError('Erreur lors de l\'initiation du paiement');
        }
    }

    /**
     * Vérifier le statut d'une transaction
     * 
     * @urlParam transaction_id required UUID de la transaction. Example: 550e8400-e29b-41d4-a716-446655440000
     * 
     * @response {
     *   "success": true,
     *   "data": {
     *     "transaction_id": "uuid",
     *     "order_id": "OM-1234567890-ABCD1234",
     *     "status": "success",
     *     "amount": 5000,
     *     "currency": "XOF"
     *   }
     * }
     */
    public function checkStatus($transactionId)
    {
        try {
            $transaction = OrangeMoneyTransaction::where('uuid', $transactionId)
                ->where('user_id', auth()->id())
                ->first();

            if (!$transaction) {
                return $this->respondNotFound('Transaction non trouvée');
            }

            // Si la transaction est déjà complétée, retourner le statut
            if ($transaction->isCompleted()) {
                return $this->respondSuccess([
                    'transaction_id' => $transaction->uuid,
                    'order_id' => $transaction->order_id,
                    'status' => $transaction->status,
                    'amount' => $transaction->amount,
                    'currency' => $transaction->currency,
                ]);
            }

            // Vérifier le statut auprès d'Orange Money
            if ($transaction->pay_token) {
                $statusResult = $this->orangeMoneyService->checkTransactionStatus(
                    $transaction->order_id,
                    $transaction->pay_token
                );

                // Mettre à jour le statut si nécessaire
                if (isset($statusResult['status'])) {
                    $this->updateTransactionStatus($transaction, $statusResult);
                }
            }

            return $this->respondSuccess([
                'transaction_id' => $transaction->uuid,
                'order_id' => $transaction->order_id,
                'status' => $transaction->status,
                'amount' => $transaction->amount,
                'currency' => $transaction->currency,
            ]);

        } catch (Exception $e) {
            Log::error('[Orange Money] Check Status Error: ' . $e->getMessage());
            return $this->respondInternalError('Erreur lors de la vérification du statut');
        }
    }

    /**
     * Webhook de notification Orange Money
     * 
     * Cette route est appelée par Orange Money pour notifier du statut du paiement
     */
    public function webhook(Request $request)
    {
        try {
            Log::info('[Orange Money] Webhook received', $request->all());

            $orderId = $request->input('order_id');
            $notifToken = $request->input('notif_token');
            $status = $request->input('status');

            if (!$orderId) {
                return response()->json(['success' => false, 'message' => 'order_id manquant'], 400);
            }

            $transaction = OrangeMoneyTransaction::where('order_id', $orderId)->first();

            if (!$transaction) {
                Log::warning('[Orange Money] Transaction not found for order_id: ' . $orderId);
                return response()->json(['success' => false, 'message' => 'Transaction non trouvée'], 404);
            }

            // Vérifier le notif_token pour la sécurité
            if ($transaction->notif_token && $transaction->notif_token !== $notifToken) {
                Log::warning('[Orange Money] Invalid notif_token for order_id: ' . $orderId);
                return response()->json(['success' => false, 'message' => 'Token invalide'], 403);
            }

            // Mettre à jour le statut de la transaction
            $this->updateTransactionStatus($transaction, $request->all());

            // Si le paiement est réussi, créditer le wallet
            if ($status === 'SUCCESS' && $transaction->status === 'success') {
                $this->processSuccessfulPayment($transaction);
            }

            return response()->json(['success' => true, 'message' => 'Notification traitée']);

        } catch (Exception $e) {
            Log::error('[Orange Money] Webhook Error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Erreur serveur'], 500);
        }
    }

    /**
     * Annuler une transaction
     * 
     * @urlParam transaction_id required UUID de la transaction. Example: 550e8400-e29b-41d4-a716-446655440000
     */
    public function cancelTransaction($transactionId)
    {
        try {
            $transaction = OrangeMoneyTransaction::where('uuid', $transactionId)
                ->where('user_id', auth()->id())
                ->first();

            if (!$transaction) {
                return $this->respondNotFound('Transaction non trouvée');
            }

            if ($transaction->isCompleted()) {
                return $this->respondBadRequest('Cette transaction ne peut plus être annulée');
            }

            $transaction->markAsCancelled();

            return $this->respondSuccess(null, 'Transaction annulée avec succès');

        } catch (Exception $e) {
            Log::error('[Orange Money] Cancel Transaction Error: ' . $e->getMessage());
            return $this->respondInternalError('Erreur lors de l\'annulation');
        }
    }

    /**
     * Historique des transactions
     * 
     * @queryParam status string Filtrer par statut. Example: success
     * @queryParam payment_for string Filtrer par type. Example: wallet
     * @queryParam limit int Nombre de résultats par page. Example: 20
     */
    public function history(Request $request)
    {
        try {
            $query = OrangeMoneyTransaction::where('user_id', auth()->id())
                ->orderBy('created_at', 'desc');

            // Filtres
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            if ($request->has('payment_for')) {
                $query->where('payment_for', $request->payment_for);
            }

            $transactions = $query->paginate($request->input('limit', 20));

            return $this->respondSuccess($transactions);

        } catch (Exception $e) {
            Log::error('[Orange Money] History Error: ' . $e->getMessage());
            return $this->respondInternalError('Erreur lors de la récupération de l\'historique');
        }
    }

    /**
     * Méthodes privées
     */
    private function getUserType($user)
    {
        if ($user->hasRole('user')) {
            return 'user';
        } elseif ($user->hasRole('driver')) {
            return 'driver';
        } elseif ($user->hasRole('owner')) {
            return 'owner';
        }
        return 'user';
    }

    private function updateTransactionStatus($transaction, $omResponse)
    {
        $status = $omResponse['status'] ?? null;

        if ($status === 'SUCCESS' || $status === '200') {
            $transaction->markAsSuccess($omResponse);
        } elseif ($status === 'FAILED' || $status === 'CANCELLED') {
            $errorMessage = $omResponse['message'] ?? 'Paiement échoué';
            $transaction->markAsFailed($errorMessage, $omResponse);
        }
    }

    private function processSuccessfulPayment($transaction)
    {
        try {
            DB::beginTransaction();

            $user = $transaction->user;
            $amount = $transaction->amount;
            $paymentFor = $transaction->payment_for;

            if ($paymentFor === 'wallet') {
                $this->creditWallet($user, $amount);
            } elseif ($paymentFor === 'subscription') {
                // Gérer l'abonnement
                // TODO: Implémenter la logique d'abonnement
            } elseif ($paymentFor === 'trip') {
                // Marquer la course comme payée
                // TODO: Implémenter la logique de paiement de course
            }

            DB::commit();

            Log::info('[Orange Money] Payment processed successfully', [
                'transaction_id' => $transaction->uuid,
                'amount' => $amount,
            ]);

        } catch (Exception $e) {
            DB::rollBack();
            Log::error('[Orange Money] Process Payment Error: ' . $e->getMessage());
            throw $e;
        }
    }

    private function creditWallet($user, $amount)
    {
        if ($user->hasRole('user')) {
            $wallet = UserWallet::firstOrCreate(['user_id' => $user->id]);
            $wallet->amount_added += $amount;
            $wallet->amount_balance += $amount;
            $wallet->save();

            UserWalletHistory::create([
                'user_id' => $user->id,
                'amount' => $amount,
                'transaction_id' => 'OM-' . time(),
                'remarks' => WalletRemarks::MONEY_DEPOSITED_TO_E_WALLET,
                'is_credit' => true,
            ]);

        } elseif ($user->hasRole('driver')) {
            $wallet = DriverWallet::firstOrCreate(['user_id' => $user->driver->id]);
            $wallet->amount_added += $amount;
            $wallet->amount_balance += $amount;
            $wallet->save();

            DriverWalletHistory::create([
                'user_id' => $user->driver->id,
                'amount' => $amount,
                'transaction_id' => 'OM-' . time(),
                'remarks' => WalletRemarks::MONEY_DEPOSITED_TO_E_WALLET,
                'is_credit' => true,
            ]);
        }

        // Envoyer une notification
        $title = 'Recharge réussie';
        $body = "Votre wallet a été crédité de {$amount} XOF via Orange Money";
        dispatch(new SendPushNotification($user, $title, $body));
    }
}
