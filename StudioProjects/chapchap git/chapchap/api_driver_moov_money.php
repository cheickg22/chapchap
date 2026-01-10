<?php

use App\Http\Controllers\Api\V1\Driver\MoovMoneyHistoryController;

/*
|--------------------------------------------------------------------------
| Routes API Driver pour Moov Money
|--------------------------------------------------------------------------
|
| Routes pour l'historique et les gains Moov Money des drivers
|
*/

// À ajouter dans routes/api/v1/driver.php

Route::middleware('auth:sanctum')->prefix('driver')->group(function () {
    
    // Historique et Gains Moov Money
    Route::prefix('moov-money')->group(function () {
        
        // Historique des transactions
        Route::get('/history', [MoovMoneyHistoryController::class, 'index']);
        
        // Détails d'une transaction
        Route::get('/history/{id}', [MoovMoneyHistoryController::class, 'show']);
        
        // Résumé des gains
        Route::get('/earnings', [MoovMoneyHistoryController::class, 'earnings']);
        
    });
    
});
