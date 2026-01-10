<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class OrangeMoneyService
{
    protected $baseUrl;
    protected $oauthUrl;
    protected $clientId;
    protected $clientSecret;
    protected $merchantKey;
    protected $environment;

    public function __construct()
    {
        $this->environment = get_settings('orange_money_environment') ?? 'sandbox';
        $this->oauthUrl = 'https://api.orange.com/oauth/v3/token';
        
        if ($this->environment === 'sandbox') {
            $this->baseUrl = 'https://api.orange.com/orange-money-webpay/dev/v1';
            // Credentials corrects de l'application Orange Money
            $this->clientId = get_settings('orange_money_client_id') ?? 'nCGY05GnxCIFbcP6ZeI4AszVXkO34xgM';
            $this->clientSecret = get_settings('orange_money_client_secret') ?? 'djsNSiGskCWklnOzSLcSOk3Rutq8T2D74U86HBgMD2EB';
            // Merchant key configuré dans le portail Orange
            $this->merchantKey = get_settings('orange_money_merchant_key') ?? '2f70a9b1';
        } else {
            $this->baseUrl = 'https://api.orange.com/orange-money-webpay/ml/v1';
            $this->clientId = get_settings('orange_money_client_id');
            $this->clientSecret = get_settings('orange_money_client_secret');
            $msisdn = get_settings('orange_money_merchant_msisdn');
            $agentCode = get_settings('orange_money_merchant_key');
            $this->merchantKey = $msisdn . $agentCode;
        }
    }

    /**
     * Get OAuth access token
     */
    protected function getAccessToken()
    {
        try {
            $authHeader = base64_encode($this->clientId . ':' . $this->clientSecret);
            
            $response = Http::withHeaders([
                'Authorization' => 'Basic ' . $authHeader,
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Accept' => 'application/json',
            ])->asForm()->post($this->oauthUrl, [
                'grant_type' => 'client_credentials'
            ]);

            $data = $response->json();

            Log::info('Orange Money OAuth Token Response', [
                'status' => $response->status(),
                'has_token' => isset($data['access_token'])
            ]);

            if ($response->successful() && isset($data['access_token'])) {
                return [
                    'success' => true,
                    'access_token' => $data['access_token'],
                    'expires_in' => $data['expires_in'] ?? 3600,
                ];
            }

            return [
                'success' => false,
                'message' => $data['error_description'] ?? 'Failed to get access token',
            ];

        } catch (\Exception $e) {
            Log::error('Orange Money OAuth Error', [
                'message' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => $e->getMessage(),
            ];
        }
    }

    /**
     * Initiate a payment
     */
    public function initiatePayment(array $data)
    {
        try {
            // Étape 1: Obtenir le token OAuth
            $tokenResult = $this->getAccessToken();
            
            if (!$tokenResult['success']) {
                return [
                    'success' => false,
                    'message' => 'Failed to get OAuth token: ' . $tokenResult['message'],
                ];
            }

            $accessToken = $tokenResult['access_token'];
            $orderId = $data['order_id'] ?? 'OM-' . Str::upper(Str::random(10)) . '-' . time();
            
            // Étape 2: Initier le paiement avec le token
            // En sandbox, utiliser OUV (Orange Unit Value), en production utiliser XOF
            $currency = $this->environment === 'sandbox' ? 'OUV' : ($data['currency'] ?? 'XOF');
            
            $payload = [
                'merchant_key' => $this->merchantKey,
                'currency' => $currency,
                'order_id' => $orderId,
                'amount' => (int)$data['amount'],
                'return_url' => $data['return_url'] ?? url('/payment/orange-money/success'),
                'cancel_url' => $data['cancel_url'] ?? url('/payment/orange-money/cancel'),
                'notif_url' => $data['notif_url'] ?? url('/api/v1/payment/orange-money/webhook'),
                'lang' => $data['lang'] ?? 'fr',
                'reference' => $data['reference'] ?? $orderId,
            ];

            Log::info('Orange Money Payment Initiation', [
                'payload' => $payload,
                'environment' => $this->environment
            ]);

            $response = Http::withToken($accessToken)
                ->withHeaders([
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json',
                ])
                ->post($this->baseUrl . '/webpayment', $payload);

            $responseData = $response->json();

            Log::info('Orange Money Payment Response', [
                'status' => $response->status(),
                'response' => $responseData
            ]);

            if ($response->successful() && isset($responseData['payment_url'])) {
                return [
                    'success' => true,
                    'order_id' => $orderId,
                    'payment_url' => $responseData['payment_url'],
                    'pay_token' => $responseData['pay_token'] ?? null,
                    'notif_token' => $responseData['notif_token'] ?? null,
                    'response' => $responseData,
                ];
            }

            return [
                'success' => false,
                'message' => $responseData['message'] ?? 'Payment initiation failed',
                'response' => $responseData,
            ];

        } catch (\Exception $e) {
            Log::error('Orange Money Payment Error', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return [
                'success' => false,
                'message' => $e->getMessage(),
            ];
        }
    }

    /**
     * Check payment status
     */
    public function checkPaymentStatus($orderId, $payToken)
    {
        try {
            // Obtenir le token OAuth
            $tokenResult = $this->getAccessToken();
            
            if (!$tokenResult['success']) {
                return [
                    'success' => false,
                    'message' => 'Failed to get OAuth token',
                ];
            }

            $accessToken = $tokenResult['access_token'];

            $response = Http::withToken($accessToken)
                ->withHeaders([
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json',
                ])
                ->get($this->baseUrl . '/webpayment/' . $orderId . '/' . $payToken);

            $responseData = $response->json();

            Log::info('Orange Money Status Check', [
                'order_id' => $orderId,
                'status' => $response->status(),
                'response' => $responseData
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'status' => $responseData['status'] ?? 'unknown',
                    'response' => $responseData,
                ];
            }

            return [
                'success' => false,
                'message' => $responseData['message'] ?? 'Status check failed',
                'response' => $responseData,
            ];

        } catch (\Exception $e) {
            Log::error('Orange Money Status Check Error', [
                'message' => $e->getMessage(),
                'order_id' => $orderId
            ]);

            return [
                'success' => false,
                'message' => $e->getMessage(),
            ];
        }
    }

    /**
     * Process webhook notification
     */
    public function processWebhook(array $data)
    {
        try {
            Log::info('Orange Money Webhook Received', $data);

            // Validate webhook data
            if (!isset($data['order_id']) || !isset($data['status'])) {
                return [
                    'success' => false,
                    'message' => 'Invalid webhook data',
                ];
            }

            return [
                'success' => true,
                'order_id' => $data['order_id'],
                'status' => $data['status'],
                'transaction_id' => $data['txnid'] ?? null,
                'data' => $data,
            ];

        } catch (\Exception $e) {
            Log::error('Orange Money Webhook Error', [
                'message' => $e->getMessage(),
                'data' => $data
            ]);

            return [
                'success' => false,
                'message' => $e->getMessage(),
            ];
        }
    }
}
