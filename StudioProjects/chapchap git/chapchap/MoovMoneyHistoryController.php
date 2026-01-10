<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Api\V1\BaseController;
use App\Models\Request\Request;
use App\Transformers\Requests\TripRequestTransformer;
use Illuminate\Http\Request as HttpRequest;
use Carbon\Carbon;

/**
 * Historique des transactions Moov Money pour les drivers
 */
class MoovMoneyHistoryController extends BaseController
{
    /**
     * Obtenir l'historique des transactions Moov Money du driver
     * 
     * @param HttpRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(HttpRequest $request)
    {
        $driver = auth()->user()->driver;

        $query = Request::where('driver_id', $driver->id)
            ->where('is_moov_money', 1)
            ->with(['userDetail', 'requestPlace', 'moovMoneyTransaction', 'requestBill'])
            ->orderBy('created_at', 'desc');

        // Filtrer par type (deposit ou withdrawal)
        if ($request->has('type') && in_array($request->type, ['deposit', 'withdrawal'])) {
            $query->where('moov_money_type', $request->type);
        }

        // Filtrer par statut
        if ($request->has('status')) {
            $query->where('moov_money_status', $request->status);
        }

        // Filtrer par période
        if ($request->has('period')) {
            switch ($request->period) {
                case 'today':
                    $query->whereDate('created_at', Carbon::today());
                    break;
                case 'week':
                    $query->whereBetween('created_at', [
                        Carbon::now()->startOfWeek(),
                        Carbon::now()->endOfWeek()
                    ]);
                    break;
                case 'month':
                    $query->whereMonth('created_at', Carbon::now()->month)
                          ->whereYear('created_at', Carbon::now()->year);
                    break;
                case 'year':
                    $query->whereYear('created_at', Carbon::now()->year);
                    break;
            }
        }

        // Filtrer par date personnalisée
        if ($request->has('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }
        if ($request->has('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        // Pagination
        $perPage = $request->input('per_page', 20);
        $transactions = $query->paginate($perPage);

        // Statistiques du driver
        $stats = $this->getDriverStats($driver->id, $request);

        return $this->respondSuccess([
            'transactions' => fractal($transactions, new TripRequestTransformer)->toArray(),
            'stats' => $stats,
        ]);
    }

    /**
     * Obtenir les statistiques des transactions du driver
     * 
     * @param int $driverId
     * @param HttpRequest $request
     * @return array
     */
    private function getDriverStats($driverId, $request)
    {
        $query = Request::where('driver_id', $driverId)
            ->where('is_moov_money', 1);

        // Appliquer les mêmes filtres de période
        if ($request->has('period')) {
            switch ($request->period) {
                case 'today':
                    $query->whereDate('created_at', Carbon::today());
                    break;
                case 'week':
                    $query->whereBetween('created_at', [
                        Carbon::now()->startOfWeek(),
                        Carbon::now()->endOfWeek()
                    ]);
                    break;
                case 'month':
                    $query->whereMonth('created_at', Carbon::now()->month);
                    break;
            }
        }

        if ($request->has('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }
        if ($request->has('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        return [
            // Totaux par type
            'total_deposits' => (clone $query)->where('moov_money_type', 'deposit')->count(),
            'total_withdrawals' => (clone $query)->where('moov_money_type', 'withdrawal')->count(),
            
            // Totaux par statut
            'total_completed' => (clone $query)->where('is_completed', 1)->count(),
            'total_cancelled' => (clone $query)->where('is_cancelled', 1)->count(),
            'total_pending' => (clone $query)->where('moov_money_status', 'pending')->count(),
            
            // Montants
            'amount_deposits' => (clone $query)
                ->where('moov_money_type', 'deposit')
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
            'amount_withdrawals' => (clone $query)
                ->where('moov_money_type', 'withdrawal')
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
            'total_amount' => (clone $query)
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
            
            // Commissions gagnées
            'total_commission' => (clone $query)
                ->where('is_completed', 1)
                ->sum('driver_commision'),
            
            // Total général
            'total_transactions' => $query->count(),
        ];
    }

    /**
     * Obtenir les détails d'une transaction spécifique
     * 
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $driver = auth()->user()->driver;

        $transaction = Request::where('driver_id', $driver->id)
            ->where('is_moov_money', 1)
            ->where('id', $id)
            ->with([
                'userDetail',
                'requestPlace',
                'moovMoneyTransaction',
                'requestBill'
            ])
            ->first();

        if (!$transaction) {
            return $this->respondNotFound('Transaction non trouvée');
        }

        return $this->respondSuccess([
            'transaction' => fractal($transaction, new TripRequestTransformer)->toArray(),
        ]);
    }

    /**
     * Obtenir le résumé des gains Moov Money du driver
     * 
     * @param HttpRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function earnings(HttpRequest $request)
    {
        $driver = auth()->user()->driver;

        // Gains par période
        $earnings = [
            'today' => $this->getEarningsByPeriod($driver->id, 'today'),
            'week' => $this->getEarningsByPeriod($driver->id, 'week'),
            'month' => $this->getEarningsByPeriod($driver->id, 'month'),
            'year' => $this->getEarningsByPeriod($driver->id, 'year'),
            'all_time' => $this->getEarningsByPeriod($driver->id, 'all'),
        ];

        // Graphique des 7 derniers jours
        $last7Days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::today()->subDays($i);
            $dayEarnings = Request::where('driver_id', $driver->id)
                ->where('is_moov_money', 1)
                ->where('is_completed', 1)
                ->whereDate('completed_at', $date)
                ->sum('driver_commision');
            
            $last7Days[] = [
                'date' => $date->format('Y-m-d'),
                'day' => $date->format('D'),
                'earnings' => $dayEarnings,
            ];
        }

        return $this->respondSuccess([
            'earnings' => $earnings,
            'chart' => $last7Days,
        ]);
    }

    /**
     * Obtenir les gains par période
     * 
     * @param int $driverId
     * @param string $period
     * @return array
     */
    private function getEarningsByPeriod($driverId, $period)
    {
        $query = Request::where('driver_id', $driverId)
            ->where('is_moov_money', 1)
            ->where('is_completed', 1);

        switch ($period) {
            case 'today':
                $query->whereDate('completed_at', Carbon::today());
                break;
            case 'week':
                $query->whereBetween('completed_at', [
                    Carbon::now()->startOfWeek(),
                    Carbon::now()->endOfWeek()
                ]);
                break;
            case 'month':
                $query->whereMonth('completed_at', Carbon::now()->month)
                      ->whereYear('completed_at', Carbon::now()->year);
                break;
            case 'year':
                $query->whereYear('completed_at', Carbon::now()->year);
                break;
            case 'all':
                // Pas de filtre
                break;
        }

        return [
            'total_transactions' => $query->count(),
            'total_commission' => $query->sum('driver_commision'),
            'total_amount_processed' => $query->sum('moov_money_amount'),
            'deposits' => (clone $query)->where('moov_money_type', 'deposit')->count(),
            'withdrawals' => (clone $query)->where('moov_money_type', 'withdrawal')->count(),
        ];
    }
}
