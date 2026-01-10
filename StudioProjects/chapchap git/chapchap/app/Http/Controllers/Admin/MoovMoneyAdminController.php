<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Request\Request;
use App\Models\MoovMoney\MoovMoneyTransaction;
use Illuminate\Http\Request as HttpRequest;
use Inertia\Inertia;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class MoovMoneyAdminController extends Controller
{
    /**
     * Afficher la page principale des transactions Moov Money
     */
    public function index()
    {
        // Statistiques générales
        $stats = [
            'total' => Request::where('is_moov_money', 1)->count(),
            'pending' => Request::where('is_moov_money', 1)->where('moov_money_status', 'pending')->count(),
            'completed' => Request::where('is_moov_money', 1)->where('moov_money_status', 'completed')->count(),
            'failed' => Request::where('is_moov_money', 1)->where('moov_money_status', 'failed')->count(),
            'total_amount' => Request::where('is_moov_money', 1)
                ->where('moov_money_status', 'completed')
                ->sum('moov_money_amount'),
            'total_commission' => Request::where('is_moov_money', 1)
                ->where('moov_money_status', 'completed')
                ->sum('moov_money_commission'),
        ];

        // Statistiques par type
        $deposit_stats = [
            'count' => Request::where('is_moov_money', 1)->where('moov_money_type', 'deposit')->count(),
            'amount' => Request::where('is_moov_money', 1)
                ->where('moov_money_type', 'deposit')
                ->where('moov_money_status', 'completed')
                ->sum('moov_money_amount'),
        ];

        $withdrawal_stats = [
            'count' => Request::where('is_moov_money', 1)->where('moov_money_type', 'withdrawal')->count(),
            'amount' => Request::where('is_moov_money', 1)
                ->where('moov_money_type', 'withdrawal')
                ->where('moov_money_status', 'completed')
                ->sum('moov_money_amount'),
        ];

        return Inertia::render('pages/moov_money/index', [
            'stats' => $stats,
            'deposit_stats' => $deposit_stats,
            'withdrawal_stats' => $withdrawal_stats,
            'test_mode' => config('moovmoney.test_mode', true),
        ]);
    }

    /**
     * Lister les transactions avec filtres et pagination
     */
    public function list(HttpRequest $request)
    {
        $query = Request::where('is_moov_money', 1)
            ->with(['userDetail', 'driverDetail.user', 'moovMoneyTransaction'])
            ->orderBy('created_at', 'desc');

        // Filtres
        if ($request->filled('type')) {
            $query->where('moov_money_type', $request->type);
        }

        if ($request->filled('status')) {
            $query->where('moov_money_status', $request->status);
        }

        if ($request->filled('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }

        if ($request->filled('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('request_number', 'like', "%{$search}%")
                  ->orWhere('moov_money_phone', 'like', "%{$search}%")
                  ->orWhereHas('userDetail', function ($userQuery) use ($search) {
                      $userQuery->where('name', 'like', "%{$search}%")
                               ->orWhere('mobile', 'like', "%{$search}%");
                  });
            });
        }

        $transactions = $query->paginate(20);

        return response()->json($transactions);
    }

    /**
     * Voir les détails d'une transaction
     */
    public function show($id)
    {
        $transaction = Request::where('is_moov_money', 1)
            ->with([
                'userDetail',
                'driverDetail.user',
                'moovMoneyTransaction',
                'requestBill',
                'requestPlace'
            ])
            ->findOrFail($id);

        return Inertia::render('pages/moov_money/view', [
            'transaction' => $transaction,
        ]);
    }

    /**
     * Exporter les transactions en CSV
     */
    public function export(HttpRequest $request)
    {
        $query = Request::where('is_moov_money', 1)
            ->with(['userDetail', 'driverDetail.user', 'moovMoneyTransaction']);

        // Appliquer les mêmes filtres que la liste
        if ($request->filled('type')) {
            $query->where('moov_money_type', $request->type);
        }

        if ($request->filled('status')) {
            $query->where('moov_money_status', $request->status);
        }

        if ($request->filled('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }

        if ($request->filled('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }

        $transactions = $query->get();

        $filename = 'moov_money_transactions_' . date('Y-m-d_H-i-s') . '.csv';
        
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
        ];

        $callback = function () use ($transactions) {
            $file = fopen('php://output', 'w');
            
            // En-têtes CSV
            fputcsv($file, [
                'ID Transaction',
                'Numéro Requête',
                'Date',
                'Type',
                'Client',
                'Téléphone Client',
                'Driver',
                'Montant',
                'Commission',
                'Statut',
                'Téléphone Moov',
                'Code Sécurité',
                'Code Validation',
                'Voucher',
            ]);

            // Données
            foreach ($transactions as $transaction) {
                fputcsv($file, [
                    $transaction->id,
                    $transaction->request_number,
                    $transaction->created_at->format('Y-m-d H:i:s'),
                    ucfirst($transaction->moov_money_type),
                    $transaction->userDetail->name ?? 'N/A',
                    $transaction->userDetail->mobile ?? 'N/A',
                    $transaction->driverDetail->name ?? 'N/A',
                    $transaction->moov_money_amount,
                    $transaction->moov_money_commission,
                    ucfirst($transaction->moov_money_status),
                    $transaction->moov_money_phone,
                    $transaction->moov_money_security_code,
                    $transaction->moov_money_validation_code,
                    $transaction->moovMoneyTransaction->voucher_code ?? 'N/A',
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }

    /**
     * Statistiques avancées pour le dashboard
     */
    public function statistics(HttpRequest $request)
    {
        $period = $request->get('period', '30'); // 7, 30, 90 jours
        $startDate = Carbon::now()->subDays($period);

        // Transactions par jour
        $dailyStats = Request::where('is_moov_money', 1)
            ->where('created_at', '>=', $startDate)
            ->select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('COUNT(*) as count'),
                DB::raw('SUM(CASE WHEN moov_money_status = "completed" THEN moov_money_amount ELSE 0 END) as amount'),
                DB::raw('SUM(CASE WHEN moov_money_type = "deposit" THEN 1 ELSE 0 END) as deposits'),
                DB::raw('SUM(CASE WHEN moov_money_type = "withdrawal" THEN 1 ELSE 0 END) as withdrawals')
            )
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        // Top drivers
        $topDrivers = Request::where('is_moov_money', 1)
            ->where('moov_money_status', 'completed')
            ->where('created_at', '>=', $startDate)
            ->with('driverDetail')
            ->select(
                'driver_id',
                DB::raw('COUNT(*) as transaction_count'),
                DB::raw('SUM(moov_money_amount) as total_amount'),
                DB::raw('SUM(moov_money_commission) as total_commission')
            )
            ->groupBy('driver_id')
            ->orderBy('transaction_count', 'desc')
            ->limit(10)
            ->get();

        // Répartition par statut
        $statusDistribution = Request::where('is_moov_money', 1)
            ->where('created_at', '>=', $startDate)
            ->select(
                'moov_money_status',
                DB::raw('COUNT(*) as count')
            )
            ->groupBy('moov_money_status')
            ->get();

        return response()->json([
            'daily_stats' => $dailyStats,
            'top_drivers' => $topDrivers,
            'status_distribution' => $statusDistribution,
        ]);
    }

    /**
     * Forcer le statut d'une transaction (pour résoudre les problèmes)
     */
    public function updateStatus(HttpRequest $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,accepted,en_route,arrived,processing,waiting_payment,completed,failed,cancelled',
            'reason' => 'nullable|string|max:500',
        ]);

        $transaction = Request::where('is_moov_money', 1)->findOrFail($id);
        
        $oldStatus = $transaction->moov_money_status;
        $transaction->moov_money_status = $request->status;
        
        if ($request->status === 'completed') {
            $transaction->is_completed = 1;
            $transaction->completed_at = now();
        }
        
        if ($request->status === 'failed' || $request->status === 'cancelled') {
            $transaction->is_cancelled = 1;
            $transaction->cancel_reason = $request->reason;
        }
        
        $transaction->save();

        // Log de l'action admin
        activity()
            ->performedOn($transaction)
            ->withProperties([
                'old_status' => $oldStatus,
                'new_status' => $request->status,
                'reason' => $request->reason,
                'admin_id' => auth()->id(),
            ])
            ->log('Admin updated Moov Money transaction status');

        return response()->json([
            'success' => true,
            'message' => 'Statut mis à jour avec succès',
        ]);
    }
}
