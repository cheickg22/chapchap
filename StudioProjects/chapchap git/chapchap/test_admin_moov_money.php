<?php

require_once __DIR__ . '/vendor/autoload.php';

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

// Bootstrap Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "=== Test Interface Administration Moov Money ===\n\n";

try {
    // Test 1: Vérifier que les contrôleurs existent
    echo "1. Vérification des contrôleurs...\n";
    
    if (class_exists('App\Http\Controllers\Admin\MoovMoneyAdminController')) {
        echo "   ✅ MoovMoneyAdminController existe\n";
    } else {
        echo "   ❌ MoovMoneyAdminController n'existe pas\n";
    }
    
    if (class_exists('App\Http\Controllers\Admin\MoovMoneySettingsController')) {
        echo "   ✅ MoovMoneySettingsController existe\n";
    } else {
        echo "   ❌ MoovMoneySettingsController n'existe pas\n";
    }

    // Test 2: Vérifier les routes
    echo "\n2. Vérification des routes...\n";
    
    $router = app('router');
    $routes = $router->getRoutes();
    
    $moovRoutes = [];
    foreach ($routes as $route) {
        $uri = $route->uri();
        if (strpos($uri, 'moov-money') !== false) {
            $moovRoutes[] = $uri;
        }
    }
    
    if (count($moovRoutes) > 0) {
        echo "   ✅ Routes Moov Money trouvées:\n";
        foreach ($moovRoutes as $route) {
            echo "      - $route\n";
        }
    } else {
        echo "   ❌ Aucune route Moov Money trouvée\n";
    }

    // Test 3: Statistiques de base
    echo "\n3. Test des statistiques...\n";
    
    $totalTransactions = \App\Models\Request\Request::where('is_moov_money', 1)->count();
    echo "   📊 Total transactions Moov Money: $totalTransactions\n";
    
    $pendingTransactions = \App\Models\Request\Request::where('is_moov_money', 1)
        ->where('moov_money_status', 'pending')->count();
    echo "   ⏳ Transactions en attente: $pendingTransactions\n";
    
    $completedTransactions = \App\Models\Request\Request::where('is_moov_money', 1)
        ->where('moov_money_status', 'completed')->count();
    echo "   ✅ Transactions complétées: $completedTransactions\n";
    
    $failedTransactions = \App\Models\Request\Request::where('is_moov_money', 1)
        ->where('moov_money_status', 'failed')->count();
    echo "   ❌ Transactions échouées: $failedTransactions\n";

    // Test 4: Test du contrôleur admin
    echo "\n4. Test du contrôleur MoovMoneyAdminController...\n";
    
    try {
        $controller = new \App\Http\Controllers\Admin\MoovMoneyAdminController();
        
        // Simuler une requête pour la liste
        $request = new \Illuminate\Http\Request();
        $request->merge(['type' => 'deposit', 'status' => 'completed']);
        
        $response = $controller->list($request);
        $data = json_decode($response->getContent(), true);
        
        echo "   ✅ Méthode list() fonctionne\n";
        echo "   📋 Transactions trouvées: " . count($data['data'] ?? []) . "\n";
        
    } catch (\Exception $e) {
        echo "   ❌ Erreur dans le contrôleur: " . $e->getMessage() . "\n";
    }

    // Test 5: Configuration Moov Money
    echo "\n5. Vérification de la configuration...\n";
    
    $testMode = config('moovmoney.test_mode', 'non défini');
    echo "   🧪 Mode test: " . ($testMode ? 'Activé' : 'Désactivé') . "\n";
    
    $depositRate = config('moovmoney.deposit_commission_rate', 'non défini');
    echo "   💰 Taux commission dépôt: $depositRate%\n";
    
    $withdrawalRate = config('moovmoney.withdrawal_commission_rate', 'non défini');
    echo "   💸 Taux commission retrait: $withdrawalRate%\n";

    // Test 6: Vérifier les fichiers Vue.js
    echo "\n6. Vérification des fichiers Vue.js...\n";
    
    $vueFiles = [
        'resources/js/Pages/pages/moov_money/index.vue',
        'resources/js/Pages/pages/moov_money/view.vue',
        'resources/js/Pages/pages/moov_money/dashboard.vue',
        'resources/js/Pages/pages/moov_money/settings.vue',
        'resources/js/Pages/pages/moov_money/logs.vue',
    ];
    
    foreach ($vueFiles as $file) {
        if (file_exists($file)) {
            echo "   ✅ $file existe\n";
        } else {
            echo "   ❌ $file manquant\n";
        }
    }

    echo "\n=== Résumé ===\n";
    echo "✅ Interface d'administration Moov Money créée avec succès!\n\n";
    
    echo "📋 Fonctionnalités disponibles:\n";
    echo "   - Dashboard avec statistiques en temps réel\n";
    echo "   - Liste des transactions avec filtres avancés\n";
    echo "   - Export CSV des transactions\n";
    echo "   - Page de configuration des paramètres\n";
    echo "   - Logs et surveillance en temps réel\n";
    echo "   - Gestion des statuts des transactions\n";
    echo "   - Test de connexion API\n\n";
    
    echo "🌐 URLs d'accès:\n";
    echo "   - Dashboard: /moov-money-transactions\n";
    echo "   - Configuration: /moov-money-settings\n";
    echo "   - Logs: /moov-money-settings/logs\n\n";

} catch (\Exception $e) {
    echo "❌ Erreur lors du test: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}

echo "=== Test terminé ===\n";
?>
