<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Orange Money Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration pour l'intégration Orange Money WebPay API
    | Documentation: https://developer.orange.com/apis/orange-money-webpay/
    |
    */

    // Environnement (dev ou prod)
    'environment' => env('ORANGE_MONEY_ENV', 'dev'),

    // URLs selon l'environnement
    'urls' => [
        'dev' => [
            'oauth' => 'https://api.orange.com/oauth/v3/token',
            'webpay' => 'https://api.orange.com/orange-money-webpay/dev/v1/webpayment',
            'transaction_status' => 'https://api.orange.com/orange-money-webpay/dev/v1/transactionstatus',
        ],
        'prod' => [
            'oauth' => 'https://api.orange.com/oauth/v3/token',
            'webpay' => 'https://api.orange.com/orange-money-webpay/ml/v1/webpayment',
            'transaction_status' => 'https://api.orange.com/orange-money-webpay/ml/v1/transactionstatus',
        ],
    ],

    // Credentials OAuth2
    'client_id' => env('ORANGE_MONEY_CLIENT_ID'),
    'client_secret' => env('ORANGE_MONEY_CLIENT_SECRET'),

    // Merchant Key (clé développeur)
    'merchant_key' => env('ORANGE_MONEY_MERCHANT_KEY'),

    // Devise (OUV pour les tests, XOF pour la production)
    'currency' => env('ORANGE_MONEY_CURRENCY', 'OUV'),

    // Langue par défaut
    'default_lang' => env('ORANGE_MONEY_LANG', 'fr'),

    // URLs de callback
    'return_url' => env('ORANGE_MONEY_RETURN_URL', env('APP_URL') . '/api/v1/payment/orange-money/return'),
    'cancel_url' => env('ORANGE_MONEY_CANCEL_URL', env('APP_URL') . '/api/v1/payment/orange-money/cancel'),
    'notif_url' => env('ORANGE_MONEY_NOTIF_URL', env('APP_URL') . '/api/v1/payment/orange-money/webhook'),

    // Durée de validité du token en secondes (3600 = 1h)
    'token_expiry' => 3600,

    // Timeout des requêtes HTTP (en secondes)
    'timeout' => 30,

    // Activer/désactiver Orange Money
    'enabled' => env('ORANGE_MONEY_ENABLED', false),

    // Mode debug
    'debug' => env('ORANGE_MONEY_DEBUG', false),

    // Montants min/max
    'min_amount' => env('ORANGE_MONEY_MIN_AMOUNT', 100),
    'max_amount' => env('ORANGE_MONEY_MAX_AMOUNT', 1000000),
];
