<?php

namespace App\Http\Controllers\Web\Admin;

use App\Http\Controllers\Controller;
use App\Models\Request\Request;
use App\Services\MoovMoney\MoovMoneyService;
use Illuminate\Http\Request as HttpRequest;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Config;
use Inertia\Inertia;
use Carbon\Carbon;

class MoovMoneySettingsController extends Controller
{
    protected $moovMoneyService;

    public function __construct(MoovMoneyService $moovMoneyService)
    {
        $this->moovMoneyService = $moovMoneyService;
    }

    /**
     * Afficher la page de configuration
     */
    public function index()
    {
        $currentSettings = [
            'test_mode' => config('moovmoney.test_mode', true),
            'cash_in_url' => config('moovmoney.cash_in_url'),
            'cash_out_url' => config('moovmoney.cash_out_url'),
            'shortcode' => config('moovmoney.shortcode'),
            'username' => config('moovmoney.username'),
            'password' => '••••••••••••', // Masquer le mot de passe
            'deposit_commission_rate' => config('moovmoney.deposit_commission_rate', 2.0),
            'withdrawal_commission_rate' => config('moovmoney.withdrawal_commission_rate', 2.5),
            'min_amount' => config('moovmoney.min_amount', 500),
            'max_amount' => config('moovmoney.max_amount', 1000000),
            'email_notifications' => config('moovmoney.email_notifications', true),
            'sms_notifications' => config('moovmoney.sms_notifications', false),
        ];

        return Inertia::render('pages/moov_money/settings', [
            'currentSettings' => $currentSettings,
        ]);
    }

    /**
     * Sauvegarder la configuration
     */
    public function save(HttpRequest $request)
    {
        $request->validate([
            'test_mode' => 'required|boolean',
            'cash_in_url' => 'required|url',
            'cash_out_url' => 'required|url',
            'shortcode' => 'required|string|max:20',
            'username' => 'required|string|max:50',
            'password' => 'nullable|string|max:100',
            'deposit_commission_rate' => 'required|numeric|min:0|max:100',
            'withdrawal_commission_rate' => 'required|numeric|min:0|max:100',
            'min_amount' => 'required|numeric|min:0',
            'max_amount' => 'required|numeric|min:0',
            'email_notifications' => 'required|boolean',
            'sms_notifications' => 'required|boolean',
        ]);

        try {
            // Sauvegarder dans le fichier de configuration ou la base de données
            $this->updateConfigFile($request->all());

            // Vider le cache de configuration
            Cache::forget('moovmoney.config');
            
            // Log de l'action
            activity()
                ->withProperties($request->only([
                    'test_mode', 'deposit_commission_rate', 'withdrawal_commission_rate',
                    'min_amount', 'max_amount', 'email_notifications', 'sms_notifications'
                ]))
                ->log('Admin updated Moov Money settings');

            return response()->json([
                'success' => true,
                'message' => 'Configuration sauvegardée avec succès',
                'reload_required' => $request->test_mode !== config('moovmoney.test_mode'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la sauvegarde: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Tester la connexion à l'API Moov Money
     */
    public function testConnection(HttpRequest $request)
    {
        $request->validate([
            'cash_in_url' => 'required|url',
            'cash_out_url' => 'required|url',
            'shortcode' => 'required|string',
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        try {
            // Créer une instance temporaire du service avec les nouvelles configurations
            $tempConfig = [
                'cash_in_url' => $request->cash_in_url,
                'cash_out_url' => $request->cash_out_url,
                'shortcode' => $request->shortcode,
                'username' => $request->username,
                'password' => $request->password,
            ];

            // Tester la connexion (vous devrez implémenter cette méthode dans MoovMoneyService)
            $result = $this->moovMoneyService->testConnection($tempConfig);

            return response()->json([
                'success' => $result['success'],
                'message' => $result['message'],
                'response_time' => $result['response_time'] ?? null,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de connexion: ' . $e->getMessage(),
            ]);
        }
    }

    /**
     * Obtenir le statut du service
     */
    public function status()
    {
        try {
            // Statistiques des dernières 24 heures
            $last24h = Carbon::now()->subDay();
            
            $stats = Request::where('is_moov_money', 1)
                ->where('created_at', '>=', $last24h)
                ->selectRaw('
                    COUNT(*) as total_transactions,
                    SUM(CASE WHEN moov_money_status = "completed" THEN 1 ELSE 0 END) as completed_transactions,
                    SUM(CASE WHEN moov_money_status = "failed" THEN 1 ELSE 0 END) as failed_transactions,
                    MAX(created_at) as last_transaction
                ')
                ->first();

            $successRate = $stats->total_transactions > 0 
                ? round(($stats->completed_transactions / $stats->total_transactions) * 100, 1)
                : 0;

            // Vérifier le statut de l'API (si pas en mode test)
            $apiStatus = config('moovmoney.test_mode') ? 'test_mode' : 'online';
            
            if (!config('moovmoney.test_mode')) {
                // Vérifier le statut de l'API (simulation pour l'instant)
                try {
                    // Pour l'instant, on considère l'API comme online si on a des transactions récentes
                    $apiStatus = $stats->total_transactions > 0 ? 'online' : 'offline';
                } catch (\Exception $e) {
                    $apiStatus = 'offline';
                }
            }

            return response()->json([
                'api_status' => $apiStatus,
                'last_transaction' => $stats->last_transaction 
                    ? Carbon::parse($stats->last_transaction)->diffForHumans()
                    : null,
                'error_count' => $stats->failed_transactions,
                'success_rate' => $successRate,
                'total_transactions_24h' => $stats->total_transactions,
                'test_mode' => config('moovmoney.test_mode'),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'api_status' => 'error',
                'last_transaction' => null,
                'error_count' => 0,
                'success_rate' => 0,
                'error_message' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Obtenir les logs des transactions
     */
    public function logs(HttpRequest $request)
    {
        $period = $request->get('period', 7); // 7 jours par défaut
        $level = $request->get('level', 'all'); // all, error, warning, info
        
        $startDate = Carbon::now()->subDays($period);
        
        $query = Request::where('is_moov_money', 1)
            ->where('created_at', '>=', $startDate)
            ->with(['userDetail', 'driverDetail'])
            ->orderBy('created_at', 'desc');

        if ($level !== 'all') {
            switch ($level) {
                case 'error':
                    $query->where('moov_money_status', 'failed');
                    break;
                case 'warning':
                    $query->whereIn('moov_money_status', ['pending', 'processing']);
                    break;
                case 'info':
                    $query->where('moov_money_status', 'completed');
                    break;
            }
        }

        $logs = $query->paginate(50);

        return response()->json($logs);
    }

    /**
     * Forcer la synchronisation avec l'API Moov Money
     */
    public function forceSync()
    {
        try {
            // Récupérer toutes les transactions en attente
            $pendingTransactions = Request::where('is_moov_money', 1)
                ->whereIn('moov_money_status', ['pending', 'processing'])
                ->get();

            $syncResults = [];
            
            foreach ($pendingTransactions as $transaction) {
                try {
                    // Vérifier le statut auprès de Moov Money
                    $status = $this->moovMoneyService->checkTransactionStatus($transaction->id);
                    
                    if ($status && $status !== $transaction->moov_money_status) {
                        $transaction->moov_money_status = $status;
                        $transaction->save();
                        
                        $syncResults[] = [
                            'transaction_id' => $transaction->id,
                            'old_status' => $transaction->moov_money_status,
                            'new_status' => $status,
                            'synced' => true,
                        ];
                    }
                } catch (\Exception $e) {
                    $syncResults[] = [
                        'transaction_id' => $transaction->id,
                        'error' => $e->getMessage(),
                        'synced' => false,
                    ];
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Synchronisation terminée',
                'results' => $syncResults,
                'synced_count' => count(array_filter($syncResults, fn($r) => $r['synced'] ?? false)),
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la synchronisation: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mettre à jour le fichier de configuration
     */
    private function updateConfigFile(array $settings)
    {
        $configPath = config_path('moovmoney.php');
        
        if (!file_exists($configPath)) {
            // Créer le fichier de configuration s'il n'existe pas
            $this->createConfigFile($configPath);
        }

        // Lire le fichier actuel
        $configContent = file_get_contents($configPath);
        
        // Mettre à jour les valeurs (implémentation simplifiée)
        foreach ($settings as $key => $value) {
            if ($key === 'password' && $value === '••••••••••••') {
                continue; // Ne pas mettre à jour le mot de passe masqué
            }
            
            $pattern = "/'$key'\s*=>\s*[^,]+,/";
            $replacement = "'$key' => " . $this->formatConfigValue($value) . ",";
            $configContent = preg_replace($pattern, $replacement, $configContent);
        }
        
        file_put_contents($configPath, $configContent);
    }

    /**
     * Créer le fichier de configuration
     */
    private function createConfigFile($path)
    {
        $content = "<?php\n\nreturn [\n";
        $content .= "    'test_mode' => true,\n";
        $content .= "    'cash_in_url' => 'https://api.moovmoney.ml:38443/apiaccess/IntegratingCashIn',\n";
        $content .= "    'cash_out_url' => 'https://api.moovmoney.ml:38443/apiaccess/IntegratingCashOut',\n";
        $content .= "    'shortcode' => '22300001009',\n";
        $content .= "    'username' => '00001009',\n";
        $content .= "    'password' => 'Accounting_2025test',\n";
        $content .= "    'deposit_commission_rate' => 2.0,\n";
        $content .= "    'withdrawal_commission_rate' => 2.5,\n";
        $content .= "    'min_amount' => 500,\n";
        $content .= "    'max_amount' => 1000000,\n";
        $content .= "    'email_notifications' => true,\n";
        $content .= "    'sms_notifications' => false,\n";
        $content .= "];\n";
        
        file_put_contents($path, $content);
    }

    /**
     * Formater une valeur pour le fichier de configuration
     */
    private function formatConfigValue($value)
    {
        if (is_bool($value)) {
            return $value ? 'true' : 'false';
        } elseif (is_numeric($value)) {
            return $value;
        } else {
            return "'" . addslashes($value) . "'";
        }
    }
}
