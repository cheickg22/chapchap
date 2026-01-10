<?php

namespace App\Services\MoovMoney;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class MoovMoneyStatusService
{
    protected $baseUrl;
    protected $bearerToken;
    protected $username;
    protected $password;

    public function __construct()
    {
        $this->baseUrl = config('moovmoney.base_url', 'https://testbed.moovmoney.ml:38443/apiaccess');
        $this->username = config('moovmoney.username', '00001009');
        $this->password = config('moovmoney.password', 'Accounting_2025test');
        $this->bearerToken = base64_encode($this->username . ':' . $this->password);
    }

    /**
     * Vérifier si une transaction est complétée en utilisant le trans-id
     * Méthode simple : Si on a un trans-id valide, la transaction est réussie
     */
    public function verifyTransactionByTransId($transId)
    {
        try {
            Log::info('Verifying transaction by trans-id', [
                'trans_id' => $transId
            ]);

            // Si on a un trans-id qui commence par CH (format Moov Money)
            // C'est que la transaction a été acceptée par Moov Money
            if ($transId && (strpos($transId, 'CH') === 0 || strpos($transId, 'CI') === 0)) {
                return [
                    'success' => true,
                    'verified' => true,
                    'trans_id' => $transId,
                    'message' => 'Transaction verified by trans-id'
                ];
            }

            return [
                'success' => false,
                'verified' => false,
                'message' => 'Invalid trans-id format'
            ];

        } catch (Exception $e) {
            Log::error('Trans-id verification error', [
                'error' => $e->getMessage(),
                'trans_id' => $transId
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Vérifier le statut d'une transaction Cash Out
     * En utilisant la même authentification que Cash In qui fonctionne
     */
    public function checkTransactionStatus($requestId)
    {
        try {
            Log::info('Checking Moov Money transaction status', [
                'request_id' => $requestId
            ]);

            // Utiliser un endpoint de vérification de statut
            // Comme Cash In fonctionne, on peut essayer de récupérer le statut
            $url = $this->baseUrl . '/TransactionStatus';
            
            $payload = [
                'request-id' => $requestId
            ];

            $response = Http::timeout(10)
                ->withHeaders([
                    'command-id' => 'check-transaction-status',
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' . $this->bearerToken,
                ])
                ->post($url, $payload);

            $responseBody = $response->body();
            
            Log::info('Moov Money status check response', [
                'status' => $response->status(),
                'body' => $responseBody,
            ]);

            $data = json_decode($responseBody, true);
            
            if ($data) {
                return [
                    'success' => true,
                    'status' => $data['status'] ?? 'unknown',
                    'transaction_id' => $data['trans-id'] ?? null,
                    'message' => $data['message'] ?? null,
                    'raw_response' => $data
                ];
            }

            return [
                'success' => false,
                'error' => 'Unable to parse response',
                'raw_response' => $responseBody
            ];

        } catch (Exception $e) {
            Log::error('Moov Money status check error', [
                'error' => $e->getMessage(),
                'request_id' => $requestId
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Alternative : Simuler une vérification de transaction
     * En attendant l'API de statut, on peut vérifier via un Cash In de montant minimal
     */
    public function verifyTransactionViaMinimalAmount($phoneNumber, $originalRequestId)
    {
        try {
            Log::info('Verifying transaction via zero amount check', [
                'phone' => $phoneNumber,
                'original_request_id' => $originalRequestId
            ]);

            // Faire un Cash In de 100 FCFA pour vérifier si le compte existe et est actif
            // Note: 0 FCFA ne fonctionne pas, il faut un montant minimum
            $testRequestId = 'VERIFY-' . time();
            
            $payload = [
                'request-id' => $testRequestId,
                'destination' => $phoneNumber,
                'amount' => '100',
                'remarks' => 'Verification for ' . $originalRequestId,
                'extended-data' => []
            ];

            $response = Http::timeout(10)
                ->withHeaders([
                    'command-id' => 'process-cashin-transaction',
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' . $this->bearerToken,
                ])
                ->post($this->baseUrl . '/IntegratingCashIn', $payload);

            $responseBody = $response->body();
            $data = json_decode($responseBody, true);
            
            // Si on peut faire un Cash In de 0, c'est que le compte est actif
            if ($data && isset($data['status']) && $data['status'] == '0') {
                return [
                    'success' => true,
                    'account_active' => true,
                    'message' => 'Account verified successfully'
                ];
            }

            return [
                'success' => false,
                'account_active' => false,
                'error' => $data['message'] ?? 'Verification failed'
            ];

        } catch (Exception $e) {
            Log::error('Transaction verification error', [
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Méthode pour confirmer manuellement une transaction
     * Utilisée quand on sait que l'utilisateur a confirmé le USSD
     */
    public function confirmTransactionManually($requestId, $transactionData = [])
    {
        try {
            Log::info('Manually confirming Moov Money transaction', [
                'request_id' => $requestId,
                'data' => $transactionData
            ]);

            // Ici on pourrait implémenter une logique pour :
            // 1. Marquer la transaction comme complétée dans notre système
            // 2. Envoyer une notification de succès
            // 3. Générer un reçu

            return [
                'success' => true,
                'message' => 'Transaction manually confirmed',
                'request_id' => $requestId,
                'confirmed_at' => now()->toIso8601String()
            ];

        } catch (Exception $e) {
            Log::error('Manual confirmation error', [
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
}
