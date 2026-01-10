<?php

namespace App\Http\Controllers\Api\V1\Payment;

use App\Http\Controllers\Controller;
use App\Services\OrangeMoneyService;
use App\Models\Payment\UserWallet;
use App\Models\Payment\UserWalletHistory;
use App\Models\Payment\WalletRemarks;
use App\Models\Request\Request as RequestModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class OrangeMoneyPaymentController extends Controller
{
    protected $orangeMoneyService;

    public function __construct(OrangeMoneyService $orangeMoneyService)
    {
        $this->orangeMoneyService = $orangeMoneyService;
    }

    /**
     * Initiate Orange Money payment for wallet recharge
     */
    public function initiateWalletRecharge(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:100',
        ]);

        try {
            $user = auth()->user();
            $amount = $request->amount;

            // Create transaction record
            $orderId = 'OM-WALLET-' . Str::upper(Str::random(8)) . '-' . time();
            $transaction = DB::table('orange_money_transactions')->insertGetId([
                'uuid' => Str::uuid(),
                'user_id' => $user->id,
                'user_type' => 'user',
                'order_id' => $orderId,
                'amount' => $amount,
                'currency' => 'OUV', // OUV pour sandbox, XOF pour production
                'payment_for' => 'wallet',
                'status' => 'pending',
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Initiate payment with Orange Money
            $paymentData = [
                'amount' => $amount,
                'order_id' => $orderId,
                'reference' => 'Wallet Recharge - User #' . $user->id,
                'return_url' => url('/api/v1/payment/orange-money/callback?transaction_id=' . $transaction),
                'cancel_url' => url('/api/v1/payment/orange-money/cancel?transaction_id=' . $transaction),
                'notif_url' => url('/api/v1/payment/orange-money/webhook'),
            ];

            $result = $this->orangeMoneyService->initiatePayment($paymentData);

            if ($result['success']) {
                // Update transaction with payment details
                DB::table('orange_money_transactions')
                    ->where('id', $transaction)
                    ->update([
                        'pay_token' => $result['pay_token'] ?? null,
                        'notif_token' => $result['notif_token'],
                        'payment_url' => $result['payment_url'],
                        'status' => 'initiated',
                        'om_response' => json_encode($result['response']),
                        'initiated_at' => now(),
                        'updated_at' => now(),
                    ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Payment initiated successfully',
                    'data' => [
                        'transaction_id' => $transaction,
                        'order_id' => $orderId,
                        'payment_url' => $result['payment_url'],
                        'amount' => $amount,
                    ],
                ]);
            }

            // Update transaction status to failed
            DB::table('orange_money_transactions')
                ->where('id', $transaction)
                ->update([
                    'status' => 'failed',
                    'om_error_message' => $result['message'] ?? 'Payment initiation failed',
                    'failed_at' => now(),
                    'updated_at' => now(),
                ]);

            return response()->json([
                'success' => false,
                'message' => $result['message'] ?? 'Payment initiation failed',
            ], 400);

        } catch (\Exception $e) {
            Log::error('Orange Money Wallet Recharge Error', [
                'user_id' => auth()->id(),
                'message' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'An error occurred while processing your request',
            ], 500);
        }
    }

    /**
     * Handle Orange Money callback
     */
    public function callback(Request $request)
    {
        try {
            $transactionId = $request->query('transaction_id');
            
            if (!$transactionId) {
                return redirect('/payment/failed?message=Invalid transaction');
            }

            $transaction = DB::table('orange_money_transactions')->find($transactionId);

            if (!$transaction) {
                return redirect('/payment/failed?message=Transaction not found');
            }

            // Check payment status
            $statusResult = $this->orangeMoneyService->checkPaymentStatus(
                $transaction->order_id,
                $transaction->pay_token
            );

            if ($statusResult['success'] && $statusResult['status'] === 'SUCCESS') {
                $this->processSuccessfulPayment($transaction, $statusResult);
                return redirect('/payment/success?amount=' . $transaction->amount);
            }

            return redirect('/payment/failed?message=Payment not completed');

        } catch (\Exception $e) {
            Log::error('Orange Money Callback Error', [
                'message' => $e->getMessage(),
                'request' => $request->all(),
            ]);

            return redirect('/payment/failed?message=An error occurred');
        }
    }

    /**
     * Handle Orange Money webhook
     */
    public function webhook(Request $request)
    {
        try {
            Log::info('Orange Money Webhook', $request->all());

            $webhookData = $this->orangeMoneyService->processWebhook($request->all());

            if (!$webhookData['success']) {
                return response()->json(['message' => 'Invalid webhook data'], 400);
            }

            // Find transaction by order_id
            $transaction = DB::table('orange_money_transactions')
                ->where('order_id', $webhookData['order_id'])
                ->first();

            if (!$transaction) {
                Log::warning('Orange Money Webhook - Transaction not found', [
                    'order_id' => $webhookData['order_id']
                ]);
                return response()->json(['message' => 'Transaction not found'], 404);
            }

            // Process based on status
            if ($webhookData['status'] === 'SUCCESS' || $webhookData['status'] === 'SUCCESSFUL') {
                $this->processSuccessfulPayment($transaction, $webhookData);
            } elseif ($webhookData['status'] === 'FAILED' || $webhookData['status'] === 'EXPIRED') {
                DB::table('orange_money_transactions')
                    ->where('id', $transaction->id)
                    ->update([
                        'status' => 'failed',
                        'om_status' => $webhookData['status'],
                        'om_transaction_id' => $webhookData['transaction_id'],
                        'om_response' => json_encode($webhookData['data']),
                        'failed_at' => now(),
                        'updated_at' => now(),
                    ]);
            }

            return response()->json(['message' => 'Webhook processed successfully']);

        } catch (\Exception $e) {
            Log::error('Orange Money Webhook Error', [
                'message' => $e->getMessage(),
                'request' => $request->all(),
            ]);

            return response()->json(['message' => 'Webhook processing failed'], 500);
        }
    }

    /**
     * Process successful payment
     */
    protected function processSuccessfulPayment($transaction, $statusData)
    {
        DB::beginTransaction();

        try {
            // Update transaction status
            DB::table('orange_money_transactions')
                ->where('id', $transaction->id)
                ->update([
                    'status' => 'success',
                    'om_status' => $statusData['status'],
                    'om_transaction_id' => $statusData['transaction_id'] ?? null,
                    'om_response' => json_encode($statusData),
                    'completed_at' => now(),
                    'updated_at' => now(),
                ]);

            // Credit user wallet
            if ($transaction->payment_for === 'wallet') {
                $userWallet = UserWallet::firstOrCreate(
                    ['user_id' => $transaction->user_id],
                    [
                        'amount_added' => 0,
                        'amount_balance' => 0,
                        'amount_spent' => 0,
                    ]
                );

                $userWallet->amount_added += $transaction->amount;
                $userWallet->amount_balance += $transaction->amount;
                $userWallet->save();

                // Create wallet history
                UserWalletHistory::create([
                    'user_id' => $transaction->user_id,
                    'amount' => $transaction->amount,
                    'transaction_id' => $transaction->order_id,
                    'remarks' => WalletRemarks::MONEY_DEPOSITED_TO_E_WALLET_FROM_ORANGE_MONEY,
                    'is_credit' => true,
                ]);

                Log::info('Orange Money Wallet Credited', [
                    'user_id' => $transaction->user_id,
                    'amount' => $transaction->amount,
                    'order_id' => $transaction->order_id,
                ]);
            }

            DB::commit();

        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Orange Money Payment Processing Error', [
                'transaction_id' => $transaction->id,
                'message' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    /**
     * Handle payment cancellation
     */
    public function cancel(Request $request)
    {
        try {
            $transactionId = $request->query('transaction_id');
            
            if ($transactionId) {
                DB::table('orange_money_transactions')
                    ->where('id', $transactionId)
                    ->update([
                        'status' => 'cancelled',
                        'updated_at' => now(),
                    ]);
            }

            return redirect('/payment/cancelled');

        } catch (\Exception $e) {
            Log::error('Orange Money Cancel Error', [
                'message' => $e->getMessage(),
                'request' => $request->all(),
            ]);

            return redirect('/payment/failed?message=An error occurred');
        }
    }
}
