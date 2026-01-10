<?php

/*
|--------------------------------------------------------------------------
| Admin API Routes
|--------------------------------------------------------------------------
|
| These routes are prefixed with 'api/v1'.
| These routes use the root namespace 'App\Http\Controllers\Api\V1'.
|
 */
use App\Base\Constants\Auth\Role;

/**
 * These routes are prefixed with 'api/v1'.
 * These routes use the root namespace 'App\Http\Controllers\Api\V1\Driver'.
 * These routes use the middleware group 'auth'.
 */
use Illuminate\Support\Facades\Route;


Route::prefix('driver')->namespace('Driver')->middleware(['auth:sanctum','throttle:120,1'])->group(function () {
        // get DriverDocument
        Route::get('documents/needed', 'DriverDocumentController@index');
        // Upload Driver document
        Route::post('upload/documents', 'DriverDocumentController@uploadDocuments');
        // Online-offline
        Route::post('online-offline', 'OnlineOfflineController@toggle');
        Route::get('diagnostic', 'DriverDocumentController@diagnostics');
        Route::get('today-earnings', 'EarningsController@index');
        Route::get('weekly-earnings', 'EarningsController@weeklyEarnings');
        Route::get('earnings-report/{from_date}/{to_date}', 'EarningsController@earningsReport');
        Route::get('history-report', 'EarningsController@historyReport');
        Route::post('add-my-route-address','OnlineOfflineController@addMyRouteAddress');
        Route::post('enable-my-route-booking','OnlineOfflineController@enableMyRouteBooking');

        Route::post('update-price','EarningsController@updatePrice');

        
        Route::get('new-earnings', 'EarningsController@newEarnings');
        Route::post('earnings-by-date','EarningsController@earningsByDate');

        Route::get('all-earnings', 'EarningsController@allEarnings');
        // Route::get('earnings-report/{from_date}/{to_date}', 'EarningsController@earningsReport');

        Route::get('list_of_plans', 'SubscriptionController@listOfSubscription');
        Route::post('subscribe', 'SubscriptionController@addSubscription');

        Route::get('leader-board/trips','EarningsController@leaderBoardTrips');
        Route::get('leader-board/earnings','EarningsController@leaderBoardEarnings');
        
        // Moov Money endpoints for drivers
        Route::prefix('moov-money')->group(function () {
            // Actions sur les requêtes (namespace: Request\Driver)
            Route::namespace('Request\Driver')->group(function () {
                Route::post('accept', 'DriverMoovMoneyController@acceptRequest');
                Route::post('arrived', 'DriverMoovMoneyController@arrivedAtLocation');
                Route::post('process-deposit', 'DriverMoovMoneyController@processDeposit');
                Route::post('process-withdrawal', 'DriverMoovMoneyController@processWithdrawal');
                Route::post('cancel', 'DriverMoovMoneyController@cancelRequest');
                Route::get('request/{id}', 'DriverMoovMoneyController@getRequestDetails');
            });
            
            // Historique et gains (namespace: Driver)
            Route::get('history', 'MoovMoneyHistoryController@index');
            Route::get('history/{id}', 'MoovMoneyHistoryController@show');
            Route::get('earnings', 'MoovMoneyHistoryController@earnings');
        });    

        /*incentives*/
        Route::get('invoice-history', 'EarningsController@invoiceHistory');

        //newIncentive
        Route::get('new-incentives', 'IncentiveController@newIncentive');
        Route::get('week-incentives', 'IncentiveController@weekIncentives');


        Route::get('list/bankinfo', 'DriverDocumentController@listBankInfo');
        Route::post('update/bankinfo', 'DriverDocumentController@updateBankinfoNew');

        Route::get('loyalty/history', 'DriverLevelController@listLevel');
        Route::get('rewards/history', 'DriverLevelController@listRewards');

});
