<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Moov Money Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration pour l'API Moov Money Mali
    |
    */

    // URL de l'API
    'api_url' => env('MOOV_API_URL', 'https://testbed.moovmoney.ml:38443/apiaccess'),
    
    // Identifiants d'authentification
    'short_code' => env('MOOV_SHORT_CODE', '22300001009'),
    'username' => env('MOOV_USERNAME', '00001009'),
    'password' => env('MOOV_PASSWORD', 'Accounting_2025test'),
    
    // Numéro de compte principal (pour les tests)
    'test_account' => env('MOOV_TEST_ACCOUNT', '22362335272'),
    
    // Timeout pour les requêtes API (en secondes)
    'timeout' => env('MOOV_API_TIMEOUT', 30),
    
    // Mode debug
    'debug' => env('MOOV_DEBUG', false),
    
    // Vérification SSL (désactiver en test avec certificat auto-signé)
    'verify_ssl' => env('MOOV_VERIFY_SSL', false),
    
    // Grille tarifaire (en XOF)
    'fees' => [
        'withdrawal' => [
            ['max' => 5000, 'fee' => 50],
            ['max' => 10000, 'fee' => 100],
            ['max' => 25000, 'fee' => 200],
            ['max' => 50000, 'fee' => 400],
            ['max' => null, 'fee_percent' => 1], // 1% pour les montants supérieurs
        ],
        'deposit' => [
            ['max' => 10000, 'fee' => 25],
            ['max' => 50000, 'fee' => 50],
            ['max' => null, 'fee' => 100],
        ],
    ],
    
    // Commissions pour les drivers
    'commissions' => [
        'withdrawal' => [
            'percent' => 3, // 3%
            'fixed' => 300, // + 300 XOF
        ],
        'deposit' => [
            'percent' => 2, // 2%
            'fixed' => 200, // + 200 XOF
        ],
    ],
    
    // Limites de transaction
    'limits' => [
        'min_amount' => 500,
        'max_amount' => 5000000,
        'daily_limit' => 10000000,
    ],
];
