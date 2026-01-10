<?php

namespace App\Services\MoovMoney;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class MoovMoneyService
{
    private $cashInUrl;
    private $cashOutUrl;
    private $passCashOutUrl;
    private $checkBalanceUrl;
    private $shortcode;
    private $testMode;
    private $apiType;
    private $resultUrl;
    private $bearerToken;
    private $username;
    private $password;

    public function __construct()
    {
        $this->cashInUrl = 'https://testbed.moovmoney.ml:38443/apiaccess/IntegratingCashIn';
        $this->cashOutUrl = 'https://testbed.moovmoney.ml:38443/apiaccess/IntegratingCashOut';
        $this->passCashOutUrl = 'https://testbed.moovmoney.ml:38443/apiaccess/IntegratingPassCashOut';
        $this->checkBalanceUrl = 'https://testbed.moovmoney.ml:38443/apiaccess/IntegratingCheckBalance';
        $this->shortcode = '22300001009';
        $this->username = '00001009';
        $this->password = 'Accounting_2025test';
        $this->resultUrl = config('moovmoney.result_url', config('app.url') . '/api/v1/moov-money/callback');
        $this->testMode = config('moovmoney.test_mode', false);
        $this->apiType = config('moovmoney.api_type', 'soap');
        
        // Générer le Bearer Token pour l'authentification
        $this->bearerToken = base64_encode($this->username . ':' . $this->password);
        
        // Pour les tests uniquement
        if ($this->testMode) {
            Log::info('MoovMoneyService running in TEST MODE');
        } else {
            Log::info('MoovMoneyService Bearer Token generated', [
                'token' => 'Bearer ' . $this->bearerToken
            ]);
        }
    }

    /**
     * Initier un dépôt (Cash In) avec retry automatique
     * 
     * @param string $phoneNumber Numéro de téléphone
     * @param float $amount Montant
     * @param string $currency Code devise (XOF)
     * @param string $conversationId ID unique de conversation
     * @param int $maxRetries Nombre maximum de tentatives
     * @return array
     */
    public function initiateCashInWithRetry($phoneNumber, $amount, $currency = 'XOF', $conversationId = null, $maxRetries = 3)
    {
        $attempt = 0;
        $lastException = null;
        
        while ($attempt < $maxRetries) {
            try {
                $attempt++;
                
                Log::channel('moov_money')->info('Tentative de transaction', [
                    'attempt' => $attempt,
                    'max_retries' => $maxRetries,
                    'phone' => $phoneNumber,
                    'amount' => $amount,
                ]);
                
                return $this->initiateCashIn($phoneNumber, $amount, $currency, $conversationId);
                
            } catch (Exception $e) {
                $lastException = $e;
                
                Log::channel('moov_money')->warning('Échec tentative ' . $attempt, [
                    'error' => $e->getMessage(),
                    'phone' => $phoneNumber,
                    'remaining_attempts' => $maxRetries - $attempt,
                ]);
                
                // Si ce n'est pas la dernière tentative, attendre avant de réessayer
                if ($attempt < $maxRetries) {
                    $waitTime = $attempt * 2; // 2s, 4s, 6s...
                    Log::channel('moov_money')->info("Attente de {$waitTime}s avant nouvelle tentative");
                    sleep($waitTime);
                }
            }
        }
        
        // Toutes les tentatives ont échoué
        Log::channel('moov_money')->error('Toutes les tentatives ont échoué', [
            'total_attempts' => $maxRetries,
            'phone' => $phoneNumber,
            'last_error' => $lastException->getMessage(),
        ]);
        
        throw $lastException;
    }

    /**
     * Initier un dépôt (Cash In)
     * 
     * @param string $phoneNumber Numéro de téléphone du client
     * @param float $amount Montant à déposer
     * @param string $currency Code devise (XOF)
     * @param string $conversationId ID unique de conversation
     * @return array
     */
    public function initiateCashIn($phoneNumber, $amount, $currency = 'XOF', $conversationId = null)
    {
        try {
            $conversationId = $conversationId ?? 'CHAPIN_' . time() . '_' . uniqid();
            $phoneNumber = $this->formatPhoneNumber($phoneNumber);

            // MODE TEST - Simuler le succès en attendant la résolution du problème API
            if (config('moovmoney.test_mode', false)) {
                Log::warning('⚠️ MOOV MONEY TEST MODE - Transaction simulée', [
                    'phone_number' => $phoneNumber,
                ]);
                return $this->generateTestResponse('cash_in', $phoneNumber, $amount, $conversationId);
            }

            // Générer un ID de conversation unique si non fourni
            if (!$conversationId) {
                $conversationId = 'CHAPIN_' . time() . '_' . rand(1000, 9999);
            }

            // Nettoyer le numéro de téléphone
            $phoneNumber = $this->formatPhoneNumber($phoneNumber);
            
            // Nouvelle implémentation selon la documentation officielle Moov Money
            $requestId = 'IT-' . date('Ymd') . substr(time(), -6);
            
            $payload = [
                'request-id' => $requestId,
                'destination' => $phoneNumber,
                'amount' => (string)$amount,
                'remarks' => '',
                'extended-data' => new \stdClass() // Objet vide en JSON
            ];

            Log::info('[Moov][CashIn][Request] (NEW API)', [
                'phoneNumber' => $phoneNumber,
                'amount' => $amount,
                'requestId' => $requestId,
                'url' => $this->cashInUrl,
                'payload' => $payload,
            ]);
            
            $response = Http::timeout(30)
                ->withHeaders([
                    'command-id' => 'process-cashin-transaction',
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' . $this->bearerToken,
                ])
                ->post($this->cashInUrl, $payload);

            $responseBody = $response->body();
            
            Log::info('[Moov][CashIn][Response]', [
                'status' => $response->status(),
                'body' => $responseBody,
            ]);

            // Parser la réponse JSON
            $data = json_decode($responseBody, true);
            
            if ($data && isset($data['status']) && $data['status'] == '0') {
                return [
                    'success' => true,
                    'transaction_id' => $data['trans-id'] ?? null,
                    'request_id' => $data['request-id'] ?? $requestId,
                    'message' => $data['message'] ?? 'Transaction réussie',
                    'raw_response' => $data
                ];
            } else {
                return [
                    'success' => false,
                    'error' => $data['message'] ?? 'Erreur inconnue',
                    'status' => $data['status'] ?? null,
                    'raw_response' => $data
                ];
            }

        } catch (Exception $e) {
            Log::error('Moov Money Cash In Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            throw $e;
        }
    }

    /**
     * Générer un voucher pour retrait (Cash Out)
     * Alias pour generateVoucher pour compatibilité
     */
    public function generateCashOutVoucher($phoneNumber, $amount, $currency = 'XOF', $conversationId = null)
    {
        return $this->generateVoucher($phoneNumber, $amount, $currency, $conversationId);
    }

    /**
     * Effectuer un retrait (Cash Out) avec voucher
     * Alias pour generateVoucher pour compatibilité
     */
    public function cashOutVoucher($phoneNumber, $amount, $currency = 'XOF', $conversationId = null)
    {
        return $this->generateVoucher($phoneNumber, $amount, $currency, $conversationId);
    }

    /**
     * Générer un voucher pour retrait (Cash Out)
     */
    public function generateVoucher($phoneNumber, $amount, $currency = 'XOF', $conversationId = null)
    {
        try {
            // Mode test
            if ($this->testMode) {
                return $this->generateTestResponse('voucher', $phoneNumber, $amount, $conversationId);
            }

            // Générer un ID de conversation unique si non fourni
            if (!$conversationId) {
                $conversationId = 'CHAPOUT_' . time() . '_' . rand(1000, 9999);
            }

            // Nettoyer le numéro de téléphone
            $phoneNumber = $this->formatPhoneNumber($phoneNumber);
            
            // Nouvelle implémentation selon la documentation officielle Moov Money
            // Utiliser l'ID fourni ou en générer un nouveau
            $requestId = $conversationId ?: 'CO-' . date('YmdHis') . '-' . rand(1000, 9999);
            
            $payload = [
                'request-id' => $requestId,
                'destination' => $phoneNumber,
                'amount' => (string)intval($amount),
                'remarks' => 'CASHOUT',
                'extended-data' => [
                    'module' => 'cashwithdraw',
                    'operation-type' => 'CASHOUT'
                ]
            ];

            Log::info('Moov Money Cash Out Request (NEW API)', [
                'phone_number' => $phoneNumber,
                'amount' => $amount,
                'request_id' => $requestId,
                'url' => $this->cashOutUrl,
                'payload' => $payload,
                'bearer_token' => 'Bearer ' . $this->bearerToken,
                'command_id' => 'process-mror-transaction'
            ]);
            
            // Augmenter le timeout car l'API Moov Money peut être lente
            try {
                $response = Http::timeout(30) // Augmenter à 30 secondes
                    ->withHeaders([
                        'command-id' => 'process-mror-transaction',
                        'Content-Type' => 'application/json',
                        'Authorization' => 'Bearer ' . $this->bearerToken,
                    ])
                    ->retry(2, 2000) // Réessayer 2 fois avec 2 secondes entre chaque tentative
                    ->post($this->cashOutUrl, $payload);
                    
                $responseBody = $response->body();
            } catch (\Illuminate\Http\Client\ConnectionException $e) {
                // En cas de timeout, on considère que le USSD a peut-être été envoyé
                Log::warning('Moov Money: USSD envoyé mais timeout de réponse', [
                    'phone' => $phoneNumber,
                    'amount' => $amount,
                    'request_id' => $requestId
                ]);
                
                // Retourner un succès partiel avec un trans-id temporaire
                return [
                    'success' => true,
                    'voucher_code' => 'PENDING_' . $requestId,
                    'transaction_id' => $requestId,
                    'message' => 'USSD envoyé (timeout de confirmation)',
                    'warning' => 'Timeout de réponse - vérifier manuellement'
                ];
            }
            
            Log::info('Moov Money Cash Out Response', [
                'status' => $response->status(),
                'body' => $responseBody,
            ]);

            // Parser la réponse JSON
            $data = json_decode($responseBody, true);
            
            if ($data && isset($data['status']) && $data['status'] == '0') {
                // Succès - Format selon la documentation
                // Exemple: {"message": "Succesful ussd push", "request-id": "33445552", "status": "0", "trans-id": "CHV507FE3V"}
                Log::info('Moov Money Cash Out Success', [
                    'trans_id' => $data['trans-id'] ?? null,
                    'request_id' => $data['request-id'] ?? null,
                    'message' => $data['message'] ?? null
                ]);
                
                return [
                    'success' => true,
                    'voucher_code' => $data['trans-id'] ?? null,  // Le trans-id sert de code voucher
                    'transaction_id' => $data['trans-id'] ?? null,
                    'request_id' => $data['request-id'] ?? $requestId,
                    'message' => $data['message'] ?? 'Successful USSD push',
                    'raw_response' => $data
                ];
            } else if ($data && isset($data['status']) && $data['status'] == '12') {
                // Erreur d'authentification
                return [
                    'success' => false,
                    'error' => 'Erreur d\'authentification avec l\'API Moov Money',
                    'status' => '12',
                    'raw_response' => $data
                ];
            } else {
                // Autres erreurs
                return [
                    'success' => false,
                    'error' => $data['message'] ?? 'Erreur lors de la transaction',
                    'status' => $data['status'] ?? null,
                    'raw_response' => $data
                ];
            }

        } catch (Exception $e) {
            Log::error('Moov Money Cash Out Voucher Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            // Si c'est un timeout et que le USSD a été envoyé
            if (strpos($e->getMessage(), 'cURL error 28') !== false) {
                Log::warning('Moov Money: USSD envoyé mais timeout de réponse');
                
                // Retourner un succès partiel car le USSD a été envoyé
                return [
                    'success' => true,
                    'voucher_code' => 'PENDING_' . $requestId,
                    'transaction_id' => $requestId,
                    'request_id' => $requestId,
                    'message' => 'USSD envoyé avec succès. Veuillez vérifier votre téléphone pour confirmer la transaction.',
                    'warning' => 'Timeout de réponse API mais le USSD a été envoyé',
                    'raw_response' => [
                        'status' => 'pending',
                        'ussd_sent' => true
                    ]
                ];
            }

            throw $e;
        }
    }
    
    /**
     * Compléter un retrait Cash Out après confirmation du client
     * Utilise COMPLETE_CASHOUT au lieu de CASHOUT
     */
    public function completeCashOut($phoneNumber, $amount, $requestId = null)
    {
        try {
            // Formater le numéro de téléphone
            $phoneNumber = $this->formatPhoneNumber($phoneNumber);
            
            // Utiliser l'ID fourni ou en générer un nouveau
            $requestId = $requestId ?: 'CCO-' . date('YmdHis') . '-' . rand(100000, 999999);
            
            $payload = [
                'request-id' => $requestId,
                'destination' => $phoneNumber,
                'amount' => (string)$amount,
                'remarks' => 'ChapChap complete withdrawal',
                'source' => $this->shortcode,
                'operation' => 'COMPLETE_CASHOUT',
                'extended-data' => ''
            ];
            
            Log::info('Moov Money Complete Cash Out Request', [
                'phone_number' => $phoneNumber,
                'amount' => $amount,
                'request_id' => $requestId,
                'url' => $this->cashOutUrl
            ]);
            
            // Appeler la même URL mais avec COMPLETE_CASHOUT
            try {
                $response = Http::timeout(30)
                    ->withHeaders([
                        'command-id' => 'process-cashout-transaction',
                        'Content-Type' => 'application/json',
                        'Authorization' => 'Bearer ' . $this->bearerToken,
                    ])
                    ->retry(2, 2000)
                    ->post($this->cashOutUrl, $payload);
                    
                $responseBody = $response->body();
            } catch (\Illuminate\Http\Client\ConnectionException $e) {
                Log::error('Moov Money Complete Cash Out Timeout', [
                    'phone' => $phoneNumber,
                    'amount' => $amount,
                    'request_id' => $requestId
                ]);
                
                return [
                    'success' => false,
                    'error' => 'Timeout de connexion avec Moov Money'
                ];
            }
            
            Log::info('Moov Money Complete Cash Out Response', [
                'status' => $response->status(),
                'body' => $responseBody,
            ]);
            
            // Parser la réponse
            $data = json_decode($responseBody, true);
            
            if ($data && isset($data['status']) && $data['status'] == '0') {
                // Succès
                return [
                    'success' => true,
                    'transaction_id' => $data['trans-id'] ?? $data['trans_id'] ?? null,
                    'request_id' => $data['request-id'] ?? $data['request_id'] ?? $requestId,
                    'message' => $data['message'] ?? 'Transaction complétée avec succès',
                    'raw_response' => $data
                ];
            } else {
                // Échec
                $errorMessage = $this->getErrorMessage($data['status'] ?? '99');
                
                return [
                    'success' => false,
                    'error' => $errorMessage,
                    'status' => $data['status'] ?? null,
                    'message' => $data['message'] ?? $errorMessage,
                    'raw_response' => $data
                ];
            }
            
        } catch (Exception $e) {
            Log::error('Moov Money Complete Cash Out Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return [
                'success' => false,
                'error' => 'Erreur lors de la finalisation du retrait: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Construire la requête SOAP pour Cash In (Dépôt)
     */
    private function buildCashInSoapRequest($phoneNumber, $amount, $currency, $conversationId)
    {
        $timestamp = now()->format('YmdHis');
        
        // Générer un CommandID unique (selon Moov Money, doit être unique pour chaque requête)
        $commandId = 'CMD_' . uniqid() . '_' . time();
        
        // Format SOAP simplifié avec CommandID unique
        return <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Header/>
  <soapenv:Body>
    <Request>
      <CommandID>{$commandId}</CommandID>
      <Version>1.0</Version>
      <OriginatorConversationID>{$conversationId}</OriginatorConversationID>
      <ThirdPartyID>{$this->shortcode}</ThirdPartyID>
      <Username>{$this->username}</Username>
      <Password>{$this->password}</Password>
      <ResultURL>{$this->resultUrl}</ResultURL>
      <Timestamp>{$timestamp}</Timestamp>
      <MSISDN>{$phoneNumber}</MSISDN>
      <Amount>{$amount}</Amount>
      <Currency>{$currency}</Currency>
      <CallerType>2</CallerType>
      <KeyOwner>1</KeyOwner>
      <IdentifierType>11</IdentifierType>
      <ShortCode>{$this->shortcode}</ShortCode>
      <SecurityCredential>{$this->password}</SecurityCredential>
      <TransactionType>InitTrans_2001</TransactionType>
    </Request>
  </soapenv:Body>
</soapenv:Envelope>
XML;
    }

    /**
     * Construire la requête SOAP pour Direct Withdrawal (retrait direct)
     */
    private function buildCashOutVoucherRequest($phoneNumber, $amount, $currency, $conversationId, $commandId = null)
    {
        $timestamp = now()->format('YmdHis');
        
        // Formater le montant avec 2 décimales max
        $formattedAmount = number_format((float)$amount, 2, '.', '');
        
        // Générer un CommandID unique (selon Moov Money, doit être unique pour chaque requête)
        $generatedCommandId = 'CMD_' . uniqid() . '_' . time();
        
        // Format SOAP avec CommandID unique
        return <<<XML
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
  <soapenv:Header/>
  <soapenv:Body>
    <Request>
      <CommandID>{$generatedCommandId}</CommandID>
      <Version>1.0</Version>
      <OriginatorConversationID>{$conversationId}</OriginatorConversationID>
      <ThirdPartyID>{$this->shortcode}</ThirdPartyID>
      <Password>{$this->password}</Password>
      <ResultURL>{$this->resultUrl}</ResultURL>
      <Timestamp>{$timestamp}</Timestamp>
      <MSISDN>{$phoneNumber}</MSISDN>
      <Amount>{$formattedAmount}</Amount>
      <Currency>{$currency}</Currency>
      <CallerType>2</CallerType>
      <KeyOwner>1</KeyOwner>
      <IdentifierType>1</IdentifierType>
      <SecurityCredential>{$this->password}</SecurityCredential>
      <TransactionType>InitTrans_2002</TransactionType>
    </Request>
  </soapenv:Body>
</soapenv:Envelope>
XML;
    }

    /**
     * Parser la réponse SOAP ou JSON
     */
    private function parseSoapResponse($xmlResponse)
    {
        try {
            // Logger la réponse brute pour debug
            Log::info('Moov Money SOAP Response (raw)', [
                'response' => substr($xmlResponse, 0, 500), // Premiers 500 caractères
                'length' => strlen($xmlResponse),
            ]);
            
            // Vérifier si la réponse est vide
            if (empty($xmlResponse)) {
                throw new Exception('Empty response from Moov Money API');
            }
            
            // Vérifier si c'est une réponse JSON (l'API peut répondre en JSON)
            $trimmedResponse = trim($xmlResponse);
            if (strpos($trimmedResponse, '{') === 0 || strpos($trimmedResponse, '[') === 0) {
                Log::info('Moov Money JSON Response detected, parsing as JSON');
                return $this->parseJsonResponse($xmlResponse);
            }
            
            // Vérifier si c'est du XML valide
            if (strpos($trimmedResponse, '<') !== 0) {
                throw new Exception('Response is not XML or JSON. Got: ' . substr($xmlResponse, 0, 100));
            }
            
            // Supprimer les namespaces pour faciliter le parsing
            $xmlResponse = preg_replace('/xmlns[^=]*="[^"]*"/i', '', $xmlResponse);
            
            // Désactiver les erreurs XML pour les gérer manuellement
            libxml_use_internal_errors(true);
            $xml = simplexml_load_string($xmlResponse);
            
            if ($xml === false) {
                $errors = libxml_get_errors();
                $errorMessages = array_map(function($error) {
                    return $error->message;
                }, $errors);
                libxml_clear_errors();
                
                throw new Exception('Failed to parse XML response: ' . implode(', ', $errorMessages));
            }

            // Extraire les données de la réponse
            $body = $xml->children('soapenv', true)->Body->children();
            
            // Vérifier si c'est une réponse ou un résultat
            if (isset($body->Response)) {
                $response = $body->Response;
                $header = $response->Header;
                $responseBody = $response->Body;

                return [
                    'success' => true,
                    'type' => 'response',
                    'originator_conversation_id' => (string) $header->OriginatorConversationID,
                    'conversation_id' => (string) $header->ConversationID,
                    'response_code' => (string) $responseBody->ResponseCode,
                    'response_desc' => (string) $responseBody->ResponseDesc,
                    'service_status' => (string) $responseBody->ServiceStatus,
                ];
            } elseif (isset($body->Result)) {
                $result = $body->Result;
                $header = $result->Header;
                $resultBody = $result->Body;

                $data = [
                    'success' => true,
                    'type' => 'result',
                    'originator_conversation_id' => (string) $header->OriginatorConversationID,
                    'conversation_id' => (string) $header->ConversationID,
                    'result_type' => (string) $resultBody->ResultType,
                    'result_code' => (string) $resultBody->ResultCode,
                    'result_desc' => (string) $resultBody->ResultDesc,
                ];

                // Ajouter l'ID de transaction si disponible
                if (isset($resultBody->TransactionResult->TransactionID)) {
                    $data['transaction_id'] = (string) $resultBody->TransactionResult->TransactionID;
                }

                return $data;
            }
        } catch (Exception $e) {
            Log::error('Failed to parse Moov Money SOAP result', [
                'error' => $e->getMessage(),
                'xml' => $xmlResponse,
            ]);
            
            return [
                'success' => false,
                'error' => 'Failed to parse result: ' . $e->getMessage(),
            ];
        }
    }

    /**
     * Parser une réponse JSON de l'API Moov Money
     */
    private function parseJsonResponse($jsonResponse)
    {
        try {
            $data = json_decode($jsonResponse, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception('Invalid JSON response: ' . json_last_error_msg());
            }
            
            Log::info('Moov Money JSON Response parsed', ['data' => $data]);
            
            // Gérer les erreurs de l'API
            if (isset($data['status']) && $data['status'] != 0) {
                $errorMessage = $data['message'] ?? 'Unknown error';
                
                Log::error('Moov Money API Error', [
                    'status' => $data['status'],
                    'message' => $errorMessage,
                ]);
                
                return [
                    'success' => false,
                    'response_code' => (string) $data['status'],
                    'response_desc' => $errorMessage,
                    'error' => $errorMessage,
                ];
            }
            
            // Réponse réussie
            return [
                'success' => true,
                'response_code' => '0',
                'response_desc' => $data['message'] ?? 'Success',
                'conversation_id' => $data['conversationId'] ?? $data['conversation_id'] ?? null,
                'transaction_id' => $data['transactionId'] ?? $data['transaction_id'] ?? null,
                'voucher_code' => $data['voucherCode'] ?? $data['voucher_code'] ?? null,
                'data' => $data,
            ];
            
        } catch (Exception $e) {
            Log::error('Failed to parse Moov Money JSON response', [
                'error' => $e->getMessage(),
                'response' => $jsonResponse,
            ]);
            
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Vérifier le solde d'un compte Moov Money
     * 
     * @param string $phoneNumber Numéro de téléphone
     * @return array
     */
    public function checkBalance($phoneNumber)
    {
        try {
            // Mode test
            if ($this->testMode) {
                return [
                    'success' => true,
                    'balance' => 50000,
                    'bonus' => 0,
                    'message' => 'Vous avez actuellement 50000.00 FCFA disponible sur votre compte MOOV MONEY.',
                    'raw_response' => [
                        'status' => '0',
                        'message' => 'Test mode - Solde simulé',
                        'test_mode' => true,
                    ]
                ];
            }

            // Nettoyer le numéro de téléphone
            $phoneNumber = $this->formatPhoneNumber($phoneNumber);
            
            // Générer un ID de requête unique
            $requestId = 'BAL_' . date('YmdHis') . '_' . rand(1000, 9999);
            
            $payload = [
                'request-id' => $requestId,
                'destination' => $phoneNumber,
            ];

            Log::channel('moov_money')->info('Check Balance Request', [
                'url' => $this->checkBalanceUrl,
                'phone' => $phoneNumber,
                'request_id' => $requestId,
            ]);

            $response = Http::withOptions([
                'verify' => false,
                'timeout' => 30,
            ])
            ->withHeaders([
                'command-id' => 'process-baln-transaction',
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' . $this->bearerToken,
            ])
            ->post($this->checkBalanceUrl, $payload);

            $responseData = $response->json();

            Log::channel('moov_money')->info('Check Balance Response', [
                'status' => $response->status(),
                'response' => $responseData,
            ]);

            if ($response->successful() && isset($responseData['status']) && $responseData['status'] === '0') {
                // Parser le message pour extraire le solde
                $message = $responseData['message'] ?? '';
                $balance = 0;
                $bonus = 0;
                
                // Extraire le solde principal
                if (preg_match('/(\d+(?:\.\d+)?)\s*FCFA\s*disponible/', $message, $matches)) {
                    $balance = floatval($matches[1]);
                }
                
                // Extraire le bonus
                if (preg_match('/Bonus\s*(?:est)?\s*(\d+(?:\.\d+)?)\s*FCFA/', $message, $matches)) {
                    $bonus = floatval($matches[1]);
                }
                
                return [
                    'success' => true,
                    'balance' => $balance,
                    'bonus' => $bonus,
                    'message' => $message,
                    'raw_response' => $responseData,
                ];
            }

            throw new Exception($responseData['message'] ?? 'Erreur lors de la vérification du solde');

        } catch (Exception $e) {
            Log::channel('moov_money')->error('Check Balance Error', [
                'phone' => $phoneNumber,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    /**
     * Générer une réponse de test pour le mode test
     */
    private function generateTestResponse($type, $phoneNumber, $amount, $conversationId = null)
    {
        $transactionId = 'TEST_' . strtoupper($type) . '_' . time() . '_' . rand(1000, 9999);
        $voucherCode = 'VOUCHER_' . rand(100000, 999999);
        
        Log::info('Moov Money Test Mode Response', [
            'type' => $type,
            'phone_number' => $phoneNumber,
            'amount' => $amount,
            'transaction_id' => $transactionId,
            'voucher_code' => $voucherCode,
        ]);
        
        return [
            'success' => true,
            'voucher_code' => $voucherCode,
            'transaction_id' => $transactionId,
            'request_id' => $conversationId ?? $transactionId,
            'message' => 'Test mode - Transaction simulée avec succès',
            'raw_response' => [
                'status' => '0',
                'message' => 'Test mode successful',
                'trans-id' => $transactionId,
                'request-id' => $conversationId ?? $transactionId,
                'voucher-code' => $voucherCode,
                'test_mode' => true,
            ]
        ];
    }

    /**
     * Formater le numéro de téléphone au format international
     * Ex: 62335272 -> 22362335272
     */
    private function formatPhoneNumber($phoneNumber)
    {
        // Supprimer tous les espaces et caractères spéciaux
        $phoneNumber = preg_replace('/[^0-9]/', '', $phoneNumber);
        
        // Si le numéro commence par 223, c'est déjà au bon format
        if (substr($phoneNumber, 0, 3) === '223') {
            return $phoneNumber;
        }
        
        // Si le numéro commence par +223, enlever le +
        if (substr($phoneNumber, 0, 4) === '+223') {
            return substr($phoneNumber, 1);
        }
        
        // Sinon, ajouter le préfixe 223 (Mali)
        return '223' . $phoneNumber;
    }
}
