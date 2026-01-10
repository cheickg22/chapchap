<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Moov Money API Routes
|--------------------------------------------------------------------------
|
| Routes pour les transactions Moov Money (Dépôt et Retrait)
|
*/

Route::prefix('moov-money')->group(function () {
    
    // Callback Moov Money (SANS authentification car appelé par Moov Money)
    Route::post('callback', 'MoovMoneyCallbackController@handleCallback')->name('moov-money.callback');
    Route::get('status/{requestId}', 'MoovMoneyCallbackController@checkStatus')->name('moov-money.status');
    
    // Routes publiques (sans authentification)
    Route::get('agents/nearby', 'MoovMoney\MoovMoneyController@getNearbyAgents');
    
    // Route complete en dehors de auth:sanctum pour éviter la redirection HTML
    // La vérification du driver se fait dans le controller
    Route::post('driver/complete/{requestId}', 'Driver\MoovMoneyDriverController@completeCashOut');
    
    // Routes protégées (avec authentification)
    Route::middleware('auth:sanctum')->group(function () {
        
        // Calcul de commission
        Route::get('calculate-commission', 'Request\MoovMoneyRequestController@calculateCommission');
        
        // Création de demandes
        Route::post('deposit/create', 'Request\MoovMoneyRequestController@createDepositRequest');
        Route::post('withdrawal/create', 'Request\MoovMoneyRequestController@createWithdrawalRequest');
        
        // Historique et détails des demandes
        Route::get('my-requests', 'Request\MoovMoneyRequestController@myRequests');
        Route::get('transaction-history', 'Request\MoovMoneyRequestController@transactionHistory');
        Route::get('requests/{id}', 'Request\MoovMoneyRequestController@show');
        
        // Annulation de demande
        Route::post('requests/{id}/cancel', 'Request\MoovMoneyRequestController@cancelRequest');
        
        // Confirmation de paiement
        Route::post('requests/{id}/confirm-payment', 'Request\MoovMoneyRequestController@confirmPayment');
        
        // Statistiques et résumé
        Route::get('statistics', 'Request\MoovMoneyRequestController@getStatistics');
        Route::get('summary', 'Request\MoovMoneyRequestController@getSummary');
        
        // Routes pour la gestion du solde (Balance)
        Route::get('balance', 'MoovMoneyBalanceController@getBalance');
        Route::post('balance/refresh', 'MoovMoneyBalanceController@refreshBalance');
        Route::post('balance/update', 'MoovMoneyBalanceController@updateBalanceAfterTransaction');
        Route::post('fees/calculate', 'MoovMoneyBalanceController@calculateFees');
        
        // Routes pour les drivers
        Route::prefix('driver')->group(function () {
            // Quand le driver arrive chez le client - NE déclenche PAS le USSD
            Route::post('arrived/{requestId}', 'Driver\MoovMoneyDriverController@driverArrived');
            // Quand le driver clique "Traiter" - DÉCLENCHE LE USSD
            Route::post('process/{requestId}', 'Driver\MoovMoneyDriverController@processWithdrawal');
            // Confirmer que la transaction est complétée
            Route::post('confirm/{requestId}', 'Driver\MoovMoneyDriverController@confirmTransaction');
            // Valider le code PIN du client pour finaliser le retrait
            Route::post('validate-pin/{requestId}', 'Driver\MoovMoneyDriverController@validatePinAndComplete');
            // Compléter le retrait après confirmation USSD (COMPLETE_CASHOUT)
            Route::post('complete/{requestId}', 'Driver\MoovMoneyDriverController@completeCashOut');
            // Vérifier le solde Moov Money du driver
            Route::get('check-balance', 'Driver\MoovMoneyDriverController@checkBalance');
            Route::post('check-balance', 'Driver\MoovMoneyDriverController@checkBalance');
        });
        
        // Vérifier le solde Moov Money (pour l'utilisateur)
        Route::get('check-balance', 'Request\MoovMoneyRequestController@checkBalance');
        Route::post('check-balance', 'Request\MoovMoneyRequestController@checkBalance');
        
        // Route pour vérifier manuellement le statut d'une transaction
        Route::post('verify-status/{requestId}', 'Request\MoovMoneyRequestController@verifyTransactionStatus');
        
        // Route de callback pour les notifications Moov Money (sans auth)
        Route::post('callback', 'MoovMoney\MoovMoneyCallbackController@handle')->withoutMiddleware(['auth:sanctum']);
        
        // Anciennes routes (à garder pour compatibilité)
        Route::post('deposit/initiate', 'MoovMoney\MoovMoneyController@initiateDeposit');
        Route::post('withdrawal/generate-voucher', 'MoovMoney\MoovMoneyController@generateWithdrawalVoucher');
        Route::get('transactions', 'MoovMoney\MoovMoneyController@getTransactionHistory');
        Route::get('transactions/{id}', 'MoovMoney\MoovMoneyController@getTransactionDetails');
        Route::post('transactions/{id}/cancel', 'MoovMoney\MoovMoneyController@cancelTransaction');
    });
});
