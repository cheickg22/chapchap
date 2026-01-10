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
    Route::post('callback', 'MoovMoney\MoovMoneyController@handleCallback')->name('moov-money.callback');
    
    // Routes publiques (sans authentification)
    Route::get('agents/nearby', 'MoovMoney\MoovMoneyController@getNearbyAgents');
    
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
        
        // Anciennes routes (à garder pour compatibilité)
        Route::post('deposit/initiate', 'MoovMoney\MoovMoneyController@initiateDeposit');
        Route::post('withdrawal/generate-voucher', 'MoovMoney\MoovMoneyController@generateWithdrawalVoucher');
        Route::get('transactions', 'MoovMoney\MoovMoneyController@getTransactionHistory');
        Route::get('transactions/{id}', 'MoovMoney\MoovMoneyController@getTransactionDetails');
        Route::post('transactions/{id}/cancel', 'MoovMoney\MoovMoneyController@cancelTransaction');
    });
});
