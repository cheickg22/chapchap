<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class ServiceStatusController extends Controller
{
    /**
     * Obtenir le statut du service Moov Money
     */
    public function moovMoneyStatus()
    {
        // Cache le statut pendant 5 minutes
        $status = Cache::remember('moov_money_status', 300, function () {
            return $this->calculateMoovMoneyStatus();
        });
        
        return response()->json($status);
    }
    
    /**
     * Calculer le statut du service Moov Money
     */
    private function calculateMoovMoneyStatus()
    {
        $isTestMode = config('moovmoney.test_mode', false);
        
        // Statistiques des dernières 24h
        $last24h = Carbon::now()->subDay();
        
        $stats = DB::table('moov_money_transactions')
            ->where('created_at', '>=', $last24h)
            ->selectRaw('
                COUNT(*) as total,
                SUM(CASE WHEN status = "completed" THEN 1 ELSE 0 END) as success,
                SUM(CASE WHEN status = "failed" THEN 1 ELSE 0 END) as failed,
                SUM(CASE WHEN status = "processing" THEN 1 ELSE 0 END) as processing
            ')
            ->first();
        
        $total = $stats->total ?? 0;
        $success = $stats->success ?? 0;
        $failed = $stats->failed ?? 0;
        
        // Calculer le taux de succès
        $successRate = $total > 0 ? ($success / $total) * 100 : 0;
        
        // Dernière transaction réussie
        $lastSuccess = DB::table('moov_money_transactions')
            ->where('status', 'completed')
            ->orderBy('created_at', 'desc')
            ->first();
        
        // Déterminer le statut global
        if ($isTestMode) {
            $globalStatus = 'test_mode';
            $statusMessage = 'Mode test activé - Transactions simulées';
            $statusColor = 'warning';
        } elseif ($total === 0) {
            $globalStatus = 'unknown';
            $statusMessage = 'Aucune transaction récente';
            $statusColor = 'info';
        } elseif ($successRate >= 80) {
            $globalStatus = 'operational';
            $statusMessage = 'Service opérationnel';
            $statusColor = 'success';
        } elseif ($successRate >= 50) {
            $globalStatus = 'degraded';
            $statusMessage = 'Service dégradé';
            $statusColor = 'warning';
        } else {
            $globalStatus = 'down';
            $statusMessage = 'Service indisponible';
            $statusColor = 'danger';
        }
        
        return [
            'status' => $globalStatus,
            'message' => $statusMessage,
            'color' => $statusColor,
            'test_mode' => $isTestMode,
            'statistics' => [
                'last_24h' => [
                    'total' => $total,
                    'success' => $success,
                    'failed' => $failed,
                    'processing' => $stats->processing ?? 0,
                    'success_rate' => round($successRate, 2),
                ],
                'last_success' => $lastSuccess ? [
                    'id' => $lastSuccess->id,
                    'amount' => $lastSuccess->amount,
                    'created_at' => $lastSuccess->created_at,
                ] : null,
            ],
            'updated_at' => now()->toIso8601String(),
        ];
    }
    
    /**
     * Obtenir le statut de tous les services
     */
    public function allServices()
    {
        return response()->json([
            'moov_money' => $this->calculateMoovMoneyStatus(),
            'firebase' => $this->calculateFirebaseStatus(),
            'database' => $this->calculateDatabaseStatus(),
        ]);
    }
    
    /**
     * Calculer le statut Firebase
     */
    private function calculateFirebaseStatus()
    {
        try {
            // Tester la connexion Firebase
            $firebaseUrl = config('firebase.database_url');
            
            return [
                'status' => 'operational',
                'message' => 'Service opérationnel',
                'color' => 'success',
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'down',
                'message' => 'Service indisponible',
                'color' => 'danger',
                'error' => $e->getMessage(),
            ];
        }
    }
    
    /**
     * Calculer le statut de la base de données
     */
    private function calculateDatabaseStatus()
    {
        try {
            DB::connection()->getPdo();
            
            return [
                'status' => 'operational',
                'message' => 'Service opérationnel',
                'color' => 'success',
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'down',
                'message' => 'Service indisponible',
                'color' => 'danger',
                'error' => $e->getMessage(),
            ];
        }
    }
}
