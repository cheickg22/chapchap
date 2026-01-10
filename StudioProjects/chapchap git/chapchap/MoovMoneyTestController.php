<?php

namespace App\Http\Controllers;

use App\Models\Request\Request;
use Illuminate\Http\Request as HttpRequest;

/**
 * Contrôleur de test pour visualiser rapidement les transactions Moov Money
 */
class MoovMoneyTestController extends Controller
{
    /**
     * Afficher toutes les transactions Moov Money
     */
    public function index()
    {
        $transactions = Request::where('is_moov_money', 1)
            ->with(['userDetail', 'driverDetail.user', 'moovMoneyTransaction'])
            ->orderBy('created_at', 'desc')
            ->paginate(50);

        // Statistiques
        $stats = [
            'total_deposits' => Request::where('is_moov_money', 1)->where('moov_money_type', 'deposit')->count(),
            'total_withdrawals' => Request::where('is_moov_money', 1)->where('moov_money_type', 'withdrawal')->count(),
            'total_completed' => Request::where('is_moov_money', 1)->where('is_completed', 1)->count(),
            'total_amount' => Request::where('is_moov_money', 1)->where('is_completed', 1)->sum('moov_money_amount'),
        ];

        return view('moov-money-test', compact('transactions', 'stats'));
    }
}
