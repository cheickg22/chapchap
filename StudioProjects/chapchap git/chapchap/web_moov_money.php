<?php

use App\Http\Controllers\Web\Admin\MoovMoneyTransactionController;

/*
|--------------------------------------------------------------------------
| Routes Admin pour Moov Money
|--------------------------------------------------------------------------
|
| Routes pour la gestion des transactions Moov Money dans le panel admin
|
*/

// À ajouter dans routes/web.php dans le groupe admin

Route::prefix('admin')->middleware(['auth', 'admin'])->name('admin.')->group(function () {
    
    // Moov Money Transactions Management
    Route::prefix('moov-money')->name('moov-money.')->group(function () {
        
        // Dashboard
        Route::get('/dashboard', [MoovMoneyTransactionController::class, 'dashboard'])
            ->name('dashboard');
        
        // Liste des transactions
        Route::get('/', [MoovMoneyTransactionController::class, 'index'])
            ->name('index');
        
        // Export CSV
        Route::get('/export', [MoovMoneyTransactionController::class, 'export'])
            ->name('export');
        
        // Détails d'une transaction
        Route::get('/{id}', [MoovMoneyTransactionController::class, 'show'])
            ->name('show');
        
        // Annuler une transaction
        Route::post('/{id}/cancel', [MoovMoneyTransactionController::class, 'cancel'])
            ->name('cancel');
        
    });
    
});
