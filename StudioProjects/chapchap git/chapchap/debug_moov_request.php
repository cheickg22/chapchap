<?php

/**
 * Script de Diagnostic Moov Money Request
 * Usage: php debug_moov_request.php REQUEST_ID
 */

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

if ($argc < 2) {
    echo "❌ Usage: php debug_moov_request.php REQUEST_ID\n";
    echo "Exemple: php debug_moov_request.php e36dcc3d-7325-42ae-b801-3bf6bdaf00b4\n";
    exit(1);
}

$requestId = $argv[1];

echo "🔍 Diagnostic Moov Money Request\n";
echo "================================\n";
echo "Request ID: {$requestId}\n\n";

// 1. Vérifier si la requête existe
echo "1️⃣ Vérification existence de la requête...\n";
$request = \App\Models\Request\Request::where('id', $requestId)->first();

if (!$request) {
    echo "❌ La requête n'existe pas dans la table 'requests'\n";
    echo "\n💡 Solutions:\n";
    echo "   - Vérifier que l'ID est correct\n";
    echo "   - Vérifier que la requête a été créée\n";
    echo "   - Vérifier les logs de création\n";
    exit(1);
}

echo "✅ Requête trouvée\n\n";

// 2. Afficher les détails
echo "2️⃣ Détails de la requête:\n";
echo "   - ID: {$request->id}\n";
echo "   - Request Number: {$request->request_number}\n";
echo "   - User ID: {$request->user_id}\n";
echo "   - Is Moov Money: " . ($request->is_moov_money ? 'OUI' : 'NON') . "\n";
echo "   - Moov Money Type: {$request->moov_money_type}\n";
echo "   - Moov Money Amount: {$request->moov_money_amount}\n";
echo "   - Moov Money Status: {$request->moov_money_status}\n";
echo "   - Is Completed: " . ($request->is_completed ? 'OUI' : 'NON') . "\n";
echo "   - Is Cancelled: " . ($request->is_cancelled ? 'OUI' : 'NON') . "\n";
echo "   - Driver ID: " . ($request->driver_id ?? 'NULL') . "\n";
echo "   - Created At: {$request->created_at}\n";
echo "\n";

// 3. Vérifier le flag is_moov_money
if (!$request->is_moov_money) {
    echo "⚠️  PROBLÈME: is_moov_money = 0\n";
    echo "   La requête n'est pas marquée comme Moov Money\n";
    echo "\n💡 Solution:\n";
    echo "   UPDATE requests SET is_moov_money = 1 WHERE id = '{$requestId}';\n\n";
}

// 4. Vérifier l'utilisateur
echo "3️⃣ Vérification utilisateur:\n";
$user = \App\Models\User::find($request->user_id);
if ($user) {
    echo "   - User Name: {$user->name}\n";
    echo "   - User Email: {$user->email}\n";
    echo "   - User Mobile: {$user->mobile}\n";
} else {
    echo "   ❌ Utilisateur non trouvé\n";
}
echo "\n";

// 5. Vérifier la transaction Moov Money
echo "4️⃣ Vérification transaction Moov Money:\n";
$transaction = \App\Models\MoovMoney\MoovMoneyTransaction::where('request_id', $requestId)->first();
if ($transaction) {
    echo "   ✅ Transaction trouvée\n";
    echo "   - Transaction ID: {$transaction->id}\n";
    echo "   - Type: {$transaction->type}\n";
    echo "   - Amount: {$transaction->amount}\n";
    echo "   - Status: {$transaction->status}\n";
    echo "   - Phone Number: {$transaction->phone_number}\n";
} else {
    echo "   ⚠️  Aucune transaction dans moov_money_transactions\n";
}
echo "\n";

// 6. Vérifier Firebase
echo "5️⃣ Vérification Firebase:\n";
try {
    $database = app('firebase.database');
    $firebaseRequest = $database->getReference('requests/' . $requestId)->getValue();
    
    if ($firebaseRequest) {
        echo "   ✅ Requête trouvée dans Firebase\n";
        echo "   - Status: " . ($firebaseRequest['status'] ?? 'N/A') . "\n";
        echo "   - Moov Money Status: " . ($firebaseRequest['moov_money_status'] ?? 'N/A') . "\n";
        echo "   - Driver ID: " . ($firebaseRequest['driver_id'] ?? 'NULL') . "\n";
    } else {
        echo "   ⚠️  Requête non trouvée dans Firebase\n";
    }
} catch (\Exception $e) {
    echo "   ❌ Erreur Firebase: " . $e->getMessage() . "\n";
}
echo "\n";

// 7. Résumé et recommandations
echo "📋 RÉSUMÉ\n";
echo "=========\n";

$issues = [];

if (!$request->is_moov_money) {
    $issues[] = "is_moov_money = 0 (devrait être 1)";
}

if (!$transaction) {
    $issues[] = "Pas de transaction dans moov_money_transactions";
}

if (empty($issues)) {
    echo "✅ Aucun problème détecté\n";
    echo "\n💡 Si l'erreur 404 persiste:\n";
    echo "   1. Vérifier que le token utilisateur est correct\n";
    echo "   2. Vérifier que l'utilisateur connecté est bien user_id = {$request->user_id}\n";
    echo "   3. Vider le cache: php artisan cache:clear\n";
} else {
    echo "⚠️  Problèmes détectés:\n";
    foreach ($issues as $issue) {
        echo "   - {$issue}\n";
    }
    
    echo "\n🔧 CORRECTIONS SQL:\n";
    if (!$request->is_moov_money) {
        echo "UPDATE requests SET is_moov_money = 1 WHERE id = '{$requestId}';\n";
    }
}

echo "\n";
echo "✅ Diagnostic terminé\n";
