<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$firebase = app(\Kreait\Firebase\Contract\Database::class);

echo "\n=== VÉRIFICATION FIREBASE ===\n\n";

// 1. Vérifier requests/new-request
echo "📦 Requêtes dans requests/new-request:\n";
echo "--------------------------------------\n";
$newRequests = $firebase->getReference('requests/new-request')->getValue();
echo "Nombre total: " . (is_array($newRequests) ? count($newRequests) : 0) . "\n\n";

if ($newRequests && is_array($newRequests)) {
    foreach ($newRequests as $id => $req) {
        echo "- " . substr($id, 0, 12) . "...\n";
        echo "  Type: " . (isset($req['is_moov_money']) && $req['is_moov_money'] ? 'Moov Money (' . ($req['moov_money_type'] ?? 'N/A') . ')' : 'Normal') . "\n";
        echo "  Status: " . ($req['status'] ?? 'N/A') . "\n";
        echo "  Request #: " . ($req['request_number'] ?? 'N/A') . "\n";
        echo "  Created: " . date('Y-m-d H:i:s', $req['created_at'] ?? 0) . "\n\n";
    }
} else {
    echo "❌ AUCUNE requête dans requests/new-request!\n\n";
}

// 2. Vérifier requests/ (sans new-request)
echo "📦 Requêtes dans requests/ (sans new-request):\n";
echo "----------------------------------------------\n";
$allRequests = $firebase->getReference('requests')->getValue();

if ($allRequests && is_array($allRequests)) {
    $count = 0;
    foreach ($allRequests as $key => $value) {
        if ($key !== 'new-request' && is_array($value) && isset($value['id'])) {
            $count++;
        }
    }
    echo "Nombre total: $count\n\n";
    
    if ($count > 0) {
        echo "⚠️  PROBLÈME DÉTECTÉ!\n";
        echo "Des requêtes existent dans requests/ mais PAS dans requests/new-request/\n";
        echo "Les drivers écoutent requests/new-request/ donc ils ne les voient pas!\n\n";
    }
}

// 3. Vérifier les drivers
echo "🚗 Drivers actifs et disponibles:\n";
echo "---------------------------------\n";
$drivers = $firebase->getReference('drivers')->getValue();

if ($drivers && is_array($drivers)) {
    $activeCount = 0;
    foreach ($drivers as $driverId => $driver) {
        if (isset($driver['is_active']) && $driver['is_active'] == 1 && 
            isset($driver['is_available']) && $driver['is_available'] == 1) {
            $activeCount++;
            echo "- Driver $driverId: " . ($driver['name'] ?? 'N/A') . "\n";
            echo "  Lat/Lng: " . ($driver['lat'] ?? 'N/A') . "/" . ($driver['lng'] ?? 'N/A') . "\n";
        }
    }
    echo "\nTotal drivers disponibles: $activeCount\n";
} else {
    echo "❌ Aucun driver dans Firebase!\n";
}

echo "\n=== FIN ===\n";
