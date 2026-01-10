<?php

namespace App\Http\Controllers\Web\Admin;

use App\Http\Controllers\Controller;
use App\Models\Request\Request;
use App\Models\MoovMoney\MoovMoneyTransaction;
use App\Models\ThirdPartySetting;
use Illuminate\Http\Request as HttpRequest;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Carbon\Carbon;

/**
 * Contrôleur Admin pour la gestion des transactions Moov Money
 */
class MoovMoneyTransactionController extends Controller
{
    /**
     * Afficher la liste des transactions Moov Money
     */
    public function index(HttpRequest $request)
    {
        // Statistiques
        $stats = [
            'total' => Request::where('is_moov_money', 1)->count(),
            'pending' => Request::where('is_moov_money', 1)->where('moov_money_status', 'pending')->count(),
            'completed' => Request::where('is_moov_money', 1)->where('moov_money_status', 'completed')->count(),
            'failed' => Request::where('is_moov_money', 1)->where('moov_money_status', 'failed')->count(),
            'total_amount' => Request::where('is_moov_money', 1)
                ->where('moov_money_status', 'completed')
                ->sum('moov_money_amount'),
        ];

        // Firebase config
        $settings = ThirdPartySetting::where('module', 'firebase')->pluck('value', 'name')->toArray();
        $firebaseConfig = (object) [
            'apiKey' => $settings['firebase_api_key'] ?? '',
            'authDomain' => $settings['firebase_auth_domain'] ?? '',
            'databaseURL' => $settings['firebase_database_url'] ?? '',
            'projectId' => $settings['firebase_project_id'] ?? '',
            'storageBucket' => $settings['firebase_storage_bucket'] ?? '',
            'messagingSenderId' => $settings['firebase_messaging_sender_id'] ?? '',
            'appId' => $settings['firebase_app_id'] ?? '',
        ];

        return Inertia::render('pages/moov_money/index', [
            'firebaseConfig' => $firebaseConfig,
            'stats' => $stats,
            'test_mode' => config('moovmoney.test_mode', false),
        ]);
    }

    /**
     * Liste des transactions (API pour AJAX)
     */
    public function list(HttpRequest $request)
    {
        $query = Request::where('is_moov_money', 1)
            ->with(['userDetail', 'driverDetail.user', 'moovMoneyTransaction', 'requestPlace'])
            ->orderBy('created_at', 'desc');

        // Filtres
        if ($request->has('type') && in_array($request->type, ['deposit', 'withdrawal'])) {
            $query->where('moov_money_type', $request->type);
        }

        if ($request->has('status')) {
            $query->where('moov_money_status', $request->status);
        }

        if ($request->has('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }

        if ($request->has('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('request_number', 'like', "%{$search}%")
                  ->orWhere('moov_money_phone', 'like', "%{$search}%")
                  ->orWhereHas('userDetail', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  })
                  ->orWhereHas('driverDetail.user', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%");
                  });
            });
        }

        return $query->paginate(20);
    }

    /**
     * Afficher les détails d'une transaction
     */
    public function viewDetails($requestmodel)
    {
        $transaction = Request::where('is_moov_money', 1)
            ->where('id', $requestmodel)
            ->with([
                'userDetail',
                'driverDetail.user',
                'moovMoneyTransaction',
                'requestPlace',
                'requestBill'
            ])
            ->firstOrFail();

        // Firebase config
        $settings = ThirdPartySetting::where('module', 'firebase')->pluck('value', 'name')->toArray();
        $firebaseConfig = (object) [
            'apiKey' => $settings['firebase_api_key'] ?? '',
            'authDomain' => $settings['firebase_auth_domain'] ?? '',
            'databaseURL' => $settings['firebase_database_url'] ?? '',
            'projectId' => $settings['firebase_project_id'] ?? '',
            'storageBucket' => $settings['firebase_storage_bucket'] ?? '',
            'messagingSenderId' => $settings['firebase_messaging_sender_id'] ?? '',
            'appId' => $settings['firebase_app_id'] ?? '',
        ];

        return Inertia::render('pages/moov_money/view', [
            'transaction' => $transaction,
            'firebaseConfig' => $firebaseConfig,
            'test_mode' => config('moovmoney.test_mode', false),
        ]);
    }

    /**
     * Obtenir les statistiques des transactions
     */
    private function getStatistics($request)
    {
        $query = Request::where('is_moov_money', 1);

        // Appliquer les mêmes filtres de date
        if ($request->has('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }
        if ($request->has('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        $stats = [
            // Totaux par type
            'total_deposits' => (clone $query)->where('moov_money_type', 'deposit')->count(),
            'total_withdrawals' => (clone $query)->where('moov_money_type', 'withdrawal')->count(),
            
            // Totaux par statut
            'total_pending' => (clone $query)->where('moov_money_status', 'pending')->count(),
            'total_accepted' => (clone $query)->where('moov_money_status', 'accepted')->count(),
            'total_processing' => (clone $query)->where('moov_money_status', 'processing')->count(),
            'total_completed' => (clone $query)->where('moov_money_status', 'completed')->count(),
            'total_cancelled' => (clone $query)->where('moov_money_status', 'cancelled')->count(),
            'total_failed' => (clone $query)->where('moov_money_status', 'failed')->count(),
            
            // Montants
            'amount_deposits' => (clone $query)
                ->where('moov_money_type', 'deposit')
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
            'amount_withdrawals' => (clone $query)
                ->where('moov_money_type', 'withdrawal')
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
            
            // Total général
            'total_transactions' => $query->count(),
            'total_amount' => (clone $query)
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
        ];

        return $stats;
    }

    /**
     * Exporter les transactions en CSV
     */
    public function export(HttpRequest $request)
    {
        $query = Request::where('is_moov_money', 1)
            ->with(['userDetail', 'driverDetail.user', 'moovMoneyTransaction'])
            ->orderBy('created_at', 'desc');

        // Appliquer les filtres
        if ($request->has('type')) {
            $query->where('moov_money_type', $request->type);
        }
        if ($request->has('status')) {
            $query->where('moov_money_status', $request->status);
        }
        if ($request->has('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }
        if ($request->has('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        $transactions = $query->get();

        $filename = 'moov_money_transactions_' . date('Y-m-d_His') . '.csv';
        
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
        ];

        $callback = function() use ($transactions) {
            $file = fopen('php://output', 'w');
            
            // En-têtes CSV
            fputcsv($file, [
                'N° Demande',
                'Type',
                'Statut',
                'Montant',
                'Téléphone',
                'Utilisateur',
                'Driver',
                'Code Sécurité',
                'Date Création',
                'Date Complétion',
                'Transaction ID',
            ]);

            // Données
            foreach ($transactions as $transaction) {
                fputcsv($file, [
                    $transaction->request_number,
                    ucfirst($transaction->moov_money_type),
                    ucfirst($transaction->moov_money_status),
                    $transaction->moov_money_amount . ' FCFA',
                    $transaction->moov_money_phone,
                    $transaction->userDetail->name ?? 'N/A',
                    $transaction->driverDetail->user->name ?? 'N/A',
                    $transaction->moov_money_security_code,
                    $transaction->created_at->format('Y-m-d H:i:s'),
                    $transaction->completed_at ? $transaction->completed_at->format('Y-m-d H:i:s') : 'N/A',
                    $transaction->moovMoneyTransaction->transaction_id ?? 'N/A',
                ]);
            }

            fclose($file);
        };

        return response()->stream($callback, 200, $headers);
    }

    /**
     * Obtenir les statistiques pour le dashboard
     */
    public function dashboard()
    {
        // Statistiques du jour
        $today = Carbon::today();
        $todayStats = [
            'deposits' => Request::where('is_moov_money', 1)
                ->where('moov_money_type', 'deposit')
                ->whereDate('created_at', $today)
                ->count(),
            'withdrawals' => Request::where('is_moov_money', 1)
                ->where('moov_money_type', 'withdrawal')
                ->whereDate('created_at', $today)
                ->count(),
            'completed' => Request::where('is_moov_money', 1)
                ->where('is_completed', 1)
                ->whereDate('completed_at', $today)
                ->count(),
            'amount' => Request::where('is_moov_money', 1)
                ->where('is_completed', 1)
                ->whereDate('completed_at', $today)
                ->sum('moov_money_amount'),
        ];

        // Statistiques du mois
        $thisMonth = Carbon::now()->startOfMonth();
        $monthStats = [
            'deposits' => Request::where('is_moov_money', 1)
                ->where('moov_money_type', 'deposit')
                ->where('created_at', '>=', $thisMonth)
                ->count(),
            'withdrawals' => Request::where('is_moov_money', 1)
                ->where('moov_money_type', 'withdrawal')
                ->where('created_at', '>=', $thisMonth)
                ->count(),
            'completed' => Request::where('is_moov_money', 1)
                ->where('is_completed', 1)
                ->where('completed_at', '>=', $thisMonth)
                ->count(),
            'amount' => Request::where('is_moov_money', 1)
                ->where('is_completed', 1)
                ->where('completed_at', '>=', $thisMonth)
                ->sum('moov_money_amount'),
        ];

        // Graphique des 7 derniers jours
        $last7Days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::today()->subDays($i);
            $last7Days[] = [
                'date' => $date->format('Y-m-d'),
                'deposits' => Request::where('is_moov_money', 1)
                    ->where('moov_money_type', 'deposit')
                    ->whereDate('created_at', $date)
                    ->count(),
                'withdrawals' => Request::where('is_moov_money', 1)
                    ->where('moov_money_type', 'withdrawal')
                    ->whereDate('created_at', $date)
                    ->count(),
                'amount' => Request::where('is_moov_money', 1)
                    ->where('is_completed', 1)
                    ->whereDate('completed_at', $date)
                    ->sum('moov_money_amount'),
            ];
        }

        // Dernières transactions
        $recentTransactions = Request::where('is_moov_money', 1)
            ->with(['userDetail', 'driverDetail.user'])
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        return view('admin.moov-money.dashboard', compact(
            'todayStats',
            'monthStats',
            'last7Days',
            'recentTransactions'
        ));
    }

    /**
     * Annuler une transaction (admin)
     */
    public function cancel($id, HttpRequest $request)
    {
        $request->validate([
            'reason' => 'required|string|max:500',
        ]);

        $transaction = Request::where('is_moov_money', 1)
            ->where('id', $id)
            ->firstOrFail();

        if ($transaction->is_completed) {
            return back()->with('error', 'Impossible d\'annuler une transaction complétée');
        }

        if ($transaction->is_cancelled) {
            return back()->with('error', 'Cette transaction est déjà annulée');
        }

        DB::beginTransaction();
        try {
            $transaction->is_cancelled = 1;
            $transaction->cancelled_at = Carbon::now();
            $transaction->moov_money_status = 'cancelled';
            $transaction->cancel_reason = 'Admin: ' . $request->reason;
            $transaction->save();

            // Mettre à jour la transaction Moov Money
            if ($transaction->moovMoneyTransaction) {
                $transaction->moovMoneyTransaction->status = 'cancelled';
                $transaction->moovMoneyTransaction->save();
            }

            DB::commit();

            return back()->with('success', 'Transaction annulée avec succès');
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->with('error', 'Erreur lors de l\'annulation: ' . $e->getMessage());
        }
    }

    /**
     * Supprimer une transaction (admin)
     */
    public function delete($id)
    {
        $transaction = Request::where('is_moov_money', 1)
            ->where('id', $id)
            ->firstOrFail();

        // Vérifier que la transaction peut être supprimée
        if ($transaction->is_completed && !$transaction->is_cancelled) {
            return back()->with('error', 'Impossible de supprimer une transaction complétée');
        }

        DB::beginTransaction();
        try {
            // Supprimer la transaction Moov Money associée
            if ($transaction->moovMoneyTransaction) {
                $transaction->moovMoneyTransaction->delete();
            }

            // Supprimer la transaction
            $transaction->delete();

            DB::commit();

            return redirect()->route('moovMoney.index')->with('success', 'Transaction supprimée avec succès');
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->with('error', 'Erreur lors de la suppression: ' . $e->getMessage());
        }
    }
}
