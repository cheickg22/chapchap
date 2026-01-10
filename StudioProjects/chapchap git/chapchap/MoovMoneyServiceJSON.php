<?php

namespace App\Services\MoovMoney;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

/**
 * Service Moov Money Mali - Version JSON
 * 
 * API REST avec authentification et requêtes/réponses JSON
 */
class MoovMoneyServiceJSON
{
    private $baseUrl;
    private $apiKey;
    private $apiSecret;
    private $merchantId;
    private $callbackUrl;
    private $testMode;

    public function __construct()
    {
        $this->baseUrl = config('moovmoney.api_base_url', 'https://api.moovmoney.ml/api/v1');
        $this->apiKey = config('moovmoney.api_key');
        $this->apiSecret = config('moovmoney.api_secret');
        $this->merchantId = config('moovmoney.merchant_id');
        $this->callbackUrl = config('moovmoney.callback_url', config('app.url') . '/api/v1/moov-money/callback');
        $this->testMode = config('moovmoney.test_mode', false);
    }

    /**
     * Obtenir un token d'authentification
     * 
     * @return string
     */
    private function getAuthToken()
    {
        try {
            $response = Http::post($this->baseUrl . '/auth/token', [
                'api_key' => $this->apiKey,
                'api_secret' => $this->apiSecret,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                return $data['access_token'] ?? null;
            }

            throw new Exception('Failed to get auth token: ' . $response->body());
        } catch (Exception $e) {
            Log::error('Moov Money Auth Error', [
                'error' => $e->getMessage(),
            ]);
            throw $e;
        }
    }

    /**
     * Initier un dépôt (Cash In) - Version JSON
     * 
     * @param string $phoneNumber Numéro de téléphone du client
     * @param float $amount Montant à déposer
     * @param string $reference Référence unique de la transaction
     * @return array
     */
    public function initiateCashIn($phoneNumber, $amount, $reference = null)
    {
        try {
            $reference = $reference ?? 'CHAPIN_' . time() . '_' . uniqid();
            $phoneNumber = $this->formatPhoneNumber($phoneNumber);

            // MODE TEST - Simuler le succès
            if ($this->testMode) {
                Log::warning('⚠️ MOOV MONEY TEST MODE - Cash In simulé', [
                    'phone_number' => $phoneNumber,
                    'amount' => $amount,
                    'reference' => $reference,
                ]);
                
                return [
                    'success' => true,
                    'status' => 'PENDING',
                    'transaction_id' => 'TEST_' . uniqid(),
                    'reference' => $reference,
                    'message' => 'TEST MODE - Transaction en attente de confirmation',
                ];
            }

            $token = $this->getAuthToken();

            $payload = [
                'merchant_id' => $this->merchantId,
                'phone_number' => $phoneNumber,
                'amount' => $amount,
                'currency' => 'XOF',
                'reference' => $reference,
                'callback_url' => $this->callbackUrl,
                'description' => 'Dépôt ChapChap',
            ];

            Log::info('[Moov][CashIn][JSON][Request]', $payload);

            $response = Http::withToken($token)
                ->post($this->baseUrl . '/transactions/cashin', $payload);

            $data = $response->json();
            
            Log::info('[Moov][CashIn][JSON][Response]', [
                'status' => $response->status(),
                'data' => $data,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'status' => $data['status'] ?? 'PENDING',
                    'transaction_id' => $data['transaction_id'] ?? null,
                    'reference' => $reference,
                    'message' => $data['message'] ?? 'Transaction initiée',
                ];
            }

            throw new Exception($data['message'] ?? 'Cash In failed');

        } catch (Exception $e) {
            Log::error('[Moov][CashIn][JSON][Error]', [
                'error' => $e->getMessage(),
                'phone' => $phoneNumber,
                'amount' => $amount,
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Initier un retrait (Cash Out) - Version JSON
     * 
     * @param string $phoneNumber Numéro de téléphone du client
     * @param float $amount Montant à retirer
     * @param string $reference Référence unique de la transaction
     * @return array
     */
    public function initiateCashOut($phoneNumber, $amount, $reference = null)
    {
        try {
            $reference = $reference ?? 'CHAPOUT_' . time() . '_' . uniqid();
            $phoneNumber = $this->formatPhoneNumber($phoneNumber);

            // MODE TEST - Simuler le succès
            if ($this->testMode) {
                Log::warning('⚠️ MOOV MONEY TEST MODE - Cash Out simulé', [
                    'phone_number' => $phoneNumber,
                    'amount' => $amount,
                    'reference' => $reference,
                ]);
                
                return [
                    'success' => true,
                    'status' => 'PENDING',
                    'transaction_id' => 'TEST_' . uniqid(),
                    'voucher_code' => 'TEST' . rand(100000, 999999),
                    'reference' => $reference,
                    'message' => 'TEST MODE - Voucher généré',
                ];
            }

            $token = $this->getAuthToken();

            $payload = [
                'merchant_id' => $this->merchantId,
                'phone_number' => $phoneNumber,
                'amount' => $amount,
                'currency' => 'XOF',
                'reference' => $reference,
                'callback_url' => $this->callbackUrl,
                'description' => 'Retrait ChapChap',
            ];

            Log::info('[Moov][CashOut][JSON][Request]', $payload);

            $response = Http::withToken($token)
                ->post($this->baseUrl . '/transactions/cashout', $payload);

            $data = $response->json();
            
            Log::info('[Moov][CashOut][JSON][Response]', [
                'status' => $response->status(),
                'data' => $data,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'status' => $data['status'] ?? 'PENDING',
                    'transaction_id' => $data['transaction_id'] ?? null,
                    'voucher_code' => $data['voucher_code'] ?? null,
                    'reference' => $reference,
                    'message' => $data['message'] ?? 'Voucher généré',
                ];
            }

            throw new Exception($data['message'] ?? 'Cash Out failed');

        } catch (Exception $e) {
            Log::error('[Moov][CashOut][JSON][Error]', [
                'error' => $e->getMessage(),
                'phone' => $phoneNumber,
                'amount' => $amount,
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Vérifier le statut d'une transaction
     * 
     * @param string $transactionId ID de la transaction
     * @return array
     */
    public function checkTransactionStatus($transactionId)
    {
        try {
            // MODE TEST
            if ($this->testMode) {
                return [
                    'success' => true,
                    'status' => 'COMPLETED',
                    'transaction_id' => $transactionId,
                    'message' => 'TEST MODE - Transaction complétée',
                ];
            }

            $token = $this->getAuthToken();

            $response = Http::withToken($token)
                ->get($this->baseUrl . '/transactions/' . $transactionId);

            $data = $response->json();
            
            Log::info('[Moov][Status][JSON][Response]', [
                'transaction_id' => $transactionId,
                'data' => $data,
            ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'status' => $data['status'] ?? 'UNKNOWN',
                    'transaction_id' => $transactionId,
                    'data' => $data,
                ];
            }

            throw new Exception($data['message'] ?? 'Status check failed');

        } catch (Exception $e) {
            Log::error('[Moov][Status][JSON][Error]', [
                'error' => $e->getMessage(),
                'transaction_id' => $transactionId,
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Formater le numéro de téléphone au format international
     * 
     * @param string $phoneNumber
     * @return string
     */
    private function formatPhoneNumber($phoneNumber)
    {
        // Supprimer tous les caractères non numériques
        $phoneNumber = preg_replace('/[^0-9]/', '', $phoneNumber);
        
        // Si le numéro commence par 0, le remplacer par 223 (indicatif Mali)
        if (substr($phoneNumber, 0, 1) === '0') {
            $phoneNumber = '223' . substr($phoneNumber, 1);
        }
        
        // Si le numéro ne commence pas par 223, l'ajouter
        if (substr($phoneNumber, 0, 3) !== '223') {
            $phoneNumber = '223' . $phoneNumber;
        }
        
        return $phoneNumber;
    }

    /**
     * Initier un dépôt avec retry automatique
     * 
     * @param string $phoneNumber
     * @param float $amount
     * @param string $reference
     * @param int $maxRetries
     * @return array
     */
    public function initiateCashInWithRetry($phoneNumber, $amount, $reference = null, $maxRetries = 3)
    {
        $attempt = 0;
        $lastError = null;
        
        while ($attempt < $maxRetries) {
            $attempt++;
            
            Log::info('[Moov][CashIn][Retry]', [
                'attempt' => $attempt,
                'max_retries' => $maxRetries,
            ]);
            
            $result = $this->initiateCashIn($phoneNumber, $amount, $reference);
            
            if ($result['success']) {
                return $result;
            }
            
            $lastError = $result['error'] ?? 'Unknown error';
            
            // Attendre avant de réessayer (sauf pour la dernière tentative)
            if ($attempt < $maxRetries) {
                $waitTime = $attempt * 2; // 2s, 4s, 6s...
                Log::info("[Moov][CashIn][Retry] Attente de {$waitTime}s");
                sleep($waitTime);
            }
        }
        
        // Toutes les tentatives ont échoué
        Log::error('[Moov][CashIn][Retry] Toutes les tentatives ont échoué', [
            'total_attempts' => $maxRetries,
            'last_error' => $lastError,
        ]);
        
        return [
            'success' => false,
            'error' => $lastError,
        ];
    }
}
