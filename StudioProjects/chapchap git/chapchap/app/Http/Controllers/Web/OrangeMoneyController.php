<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Services\OrangeMoneyService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;
use App\Models\Payment\UserWallet;
use App\Models\Payment\DriverWallet;
use App\Models\Payment\OwnerWallet;
use App\Models\Payment\UserWalletHistory;
use App\Models\Payment\DriverWalletHistory;
use App\Models\Payment\OwnerWalletHistory;
use App\Base\Constants\Masters\WalletRemarks;
use App\Jobs\Notifications\SendPushNotification;
use App\Models\Admin\Role;

class OrangeMoneyController extends Controller
{
    protected $orangeMoneyService;

    public function __construct()
    {
        $this->orangeMoneyService = new OrangeMoneyService();
    }

    /**
     * Display Orange Money payment page and initiate payment
     * URL: /payment/orange-money?amount=100&payment_for=wallet&currency=XOF&user_id=2&request_id=xxx
     */
    public function index(Request $request)
    {
        $amount = $request->amount;
        $currency_code = $request->currency ?? 'XOF';
        $user_id = $request->user_id;
        $payment_for = $request->payment_for ?? 'wallet';
        $request_id = $request->request_id;
        $plan_id = $request->plan_id;

        // Validate user exists
        $user = User::find($user_id);
        if (!$user) {
            return redirect('/payment/failed?message=User not found');
        }

        // Si l'app envoie auto_redirect=1, initier le paiement automatiquement
        if ($request->auto_redirect == '1') {
            try {
                // Create transaction
                $orderId = 'OM-' . Str::upper(Str::random(8)) . '-' . time();
                $transaction = DB::table('orange_money_transactions')->insertGetId([
                    'uuid' => Str::uuid(),
                    'user_id' => $user->id,
                    'user_type' => 'user',
                    'order_id' => $orderId,
                    'amount' => $amount,
                    'currency' => 'OUV',
                    'payment_for' => $payment_for,
                    'request_id' => $request_id,
                    'status' => 'pending',
                    'ip_address' => $request->ip(),
                    'user_agent' => $request->userAgent(),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                // Initiate payment
                $result = $this->orangeMoneyService->initiatePayment([
                    'amount' => $amount,
                    'order_id' => $orderId,
                    'return_url' => url('/payment/orange-money/success?transaction_id=' . $transaction),
                    'cancel_url' => url('/payment/orange-money/cancel?transaction_id=' . $transaction),
                    'notif_url' => url('/api/v1/payment/orange-money/webhook'),
                ]);

                if ($result['success']) {
                    // Update transaction
                    DB::table('orange_money_transactions')
                        ->where('id', $transaction)
                        ->update([
                            'pay_token' => $result['pay_token'] ?? null,
                            'payment_url' => $result['payment_url'] ?? null,
                            'notif_token' => $result['notif_token'] ?? null,
                            'status' => 'initiated',
                            'updated_at' => now(),
                        ]);

                    // Redirect to Orange Money payment page
                    return redirect($result['payment_url']);
                }

                return redirect('/payment/failed?message=' . urlencode($result['message'] ?? 'Payment initiation failed'));
            } catch (\Exception $e) {
                Log::error('Orange Money auto redirect error: ' . $e->getMessage());
                return redirect('/payment/failed?message=An error occurred');
            }
        }

        return view('payment.orange-money', compact(
            'amount',
            'currency_code',
            'user_id',
            'payment_for',
            'request_id',
            'plan_id'
        ));
    }

    /**
     * Process Orange Money payment
     * POST: /payment/orange
     */
    public function payment(Request $request)
    {
        try {
            $request->validate([
                'mobile' => 'required|string',
                'amount' => 'required|numeric|min:100',
                'user_id' => 'required|exists:users,id',
            ]);

            $user = User::find($request->user_id);
            $amount = $request->amount;
            $mobile = $request->mobile;
            $payment_for = $request->payment_for ?? 'wallet';
            $request_id = $request->request_id;

            // Create transaction record
            $orderId = 'OM-' . Str::upper(Str::random(8)) . '-' . time();
            $transaction = DB::table('orange_money_transactions')->insertGetId([
                'uuid' => Str::uuid(),
                'user_id' => $user->id,
                'user_type' => 'user',
                'order_id' => $orderId,
                'amount' => $amount,
                'currency' => 'XOF',
                'payment_for' => $payment_for,
                'request_id' => $request_id,
                'status' => 'pending',
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Initiate payment with Orange Money API
            $result = $this->orangeMoneyService->initiatePayment([
                'amount' => $amount,
                'order_id' => $orderId,
                'return_url' => url('/payment/orange-money/success?transaction_id=' . $transaction),
                'cancel_url' => url('/payment/orange-money/cancel?transaction_id=' . $transaction),
                'notif_url' => url('/api/v1/payment/orange-money/webhook'),
            ]);

            if ($result['success']) {
                // Update transaction with payment details
                DB::table('orange_money_transactions')
                    ->where('id', $transaction)
                    ->update([
                        'pay_token' => $result['pay_token'] ?? null,
                        'payment_url' => $result['payment_url'] ?? null,
                        'notif_token' => $result['notif_token'] ?? null,
                        'updated_at' => now(),
                    ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Payment initiated successfully',
                    'payment_url' => $result['payment_url'],
                    'order_id' => $result['order_id'],
                ]);
            }

            // Update transaction status to failed
            DB::table('orange_money_transactions')
                ->where('id', $transaction)
                ->update([
                    'status' => 'failed',
                    'om_error_message' => $result['message'] ?? 'Payment initiation failed',
                    'updated_at' => now(),
                ]);

            return response()->json([
                'success' => false,
                'message' => $result['message'] ?? 'Payment initiation failed',
            ], 400);

        } catch (\Exception $e) {
            Log::error('Orange Money payment error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while processing your payment',
            ], 500);
        }
    }

    /**
     * Handle payment success callback
     * GET: /payment/orange-money/success
     */
    public function paymentSuccess(Request $request)
    {
        $transactionId = $request->query('transaction_id');
        $web_booking_value = 0;
        
        if (!$transactionId) {
            return redirect('/payment/failed?message=Transaction ID missing');
        }

        $transaction = DB::table('orange_money_transactions')->find($transactionId);
        
        if (!$transaction) {
            return redirect('/payment/failed?message=Transaction not found');
        }

        // Si la transaction est déjà traitée, afficher le succès
        if ($transaction->status === 'success') {
            return view('payment.success', [
                'message' => 'Votre paiement Orange Money a été effectué avec succès!',
                'amount' => $transaction->amount,
                'transaction_id' => $transaction->order_id,
            ]);
        }

        // Marquer la transaction comme success
        DB::table('orange_money_transactions')
            ->where('id', $transactionId)
            ->update([
                'status' => 'success',
                'completed_at' => now(),
                'updated_at' => now(),
            ]);

        $amount = $transaction->amount;
        $payment_for = $transaction->payment_for;
        $request_id = $transaction->request_id;
        $user_id = $transaction->user_id;

        // Si c'est un paiement wallet, créditer le wallet
        if ($payment_for == "wallet") {
            $user = User::find($user_id);

            if ($user->hasRole('user')) {
                $wallet_model = new UserWallet();
                $wallet_add_history_model = new UserWalletHistory();
                $user_id = $user->id;
            } elseif($user->hasRole('driver')) {
                $wallet_model = new DriverWallet();
                $wallet_add_history_model = new DriverWalletHistory();
                $user_id = $user->driver->id;
            } else {
                $wallet_model = new OwnerWallet();
                $wallet_add_history_model = new OwnerWalletHistory();
                $user_id = $user->owner->id;
            }

            $user_wallet = $wallet_model::firstOrCreate(['user_id'=>$user_id]);
            $user_wallet->amount_added += $amount;
            $user_wallet->amount_balance += $amount;
            $user_wallet->save();
            $user_wallet->fresh();

            $wallet_add_history_model::create([
                'user_id'=>$user_id,
                'amount'=>$amount,
                'transaction_id'=>$transaction->order_id,
                'remarks'=>WalletRemarks::MONEY_DEPOSITED_TO_E_WALLET_FROM_ORANGE_MONEY,
                'is_credit'=>true
            ]);

            // Envoyer notification push
            $notification = DB::table('notification_channels')
                ->where('topics', 'User Wallet Amount')
                ->first();

            if ($notification && $notification->push_notification == 1) {
                $userLang = $user->lang ?? 'en';
                
                $translation = DB::table('notification_channels_translations')
                    ->where('notification_channel_id', $notification->id)
                    ->where('locale', $userLang)
                    ->first();
                
                if (!$translation) {
                    $translation = DB::table('notification_channels_translations')
                        ->where('notification_channel_id', $notification->id)
                        ->where('locale', 'en')
                        ->first();
                }            
                
                $title = $translation->push_title ?? $notification->push_title;
                $body = strip_tags($translation->push_body ?? $notification->push_body);
                dispatch(new SendPushNotification($user, $title, $body));
            }

            Log::info('Orange Money wallet credited', [
                'user_id' => $user->id,
                'amount' => $amount,
                'transaction_id' => $transaction->order_id,
            ]);
        } else {
            // Pour les paiements de courses
            $web_booking_value = 1;
        }

        return view('payment.success', [
            'message' => 'Votre paiement Orange Money a été effectué avec succès!',
            'amount' => $transaction->amount,
            'transaction_id' => $transaction->order_id,
            'payment_for' => $payment_for,
            'web_booking_value' => $web_booking_value,
            'request_id' => $request_id,
        ]);
    }

    /**
     * Handle payment cancellation
     * GET: /payment/orange-money/cancel
     */
    public function paymentCancel(Request $request)
    {
        $transactionId = $request->query('transaction_id');
        
        if ($transactionId) {
            DB::table('orange_money_transactions')
                ->where('id', $transactionId)
                ->update([
                    'status' => 'cancelled',
                    'updated_at' => now(),
                ]);
        }

        return view('payment.failed', [
            'message' => 'Votre paiement Orange Money a été annulé.',
        ]);
    }
}
