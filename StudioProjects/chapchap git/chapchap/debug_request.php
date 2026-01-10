#!/usr/bin/env php
<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$firebase = app(\Kreait\Firebase\Contract\Database::class);

echo "🔍 DEBUG REQUÊTE SPÉCIFIQUE\n";
echo "============================\n\n";

$requestId = 'be7875de-8323-4e6f-b379-87e28be86d7d';

// Vérifier en DB
$request = \App\Models\Request\Request::find($requestId);

if ($request) {
    echo "✅ Requête en DB:\n";
    echo "  ID: {$request->id}\n";
    echo "  Request Number: {$request->request_number}\n";
    echo "  User ID: {$request->user_id}\n";
    echo "  Service Location ID: {$request->service_location_id}\n";
    echo "  Zone Type ID: {$request->zone_type_id}\n";
    echo "  Is Moov Money: " . ($request->is_moov_money ? 'OUI' : 'NON') . "\n";
    echo "  Is Completed: {$request->is_completed}\n";
    echo "  Is Cancelled: {$request->is_cancelled}\n";
    echo "  Trip Start Time: {$request->trip_start_time}\n";
    echo "  Is Later: {$request->is_later}\n";
    echo "\n";
} else {
    echo "❌ Requête non trouvée en DB\n\n";
    exit(1);
}

// Vérifier dans Firebase requests/
echo "Firebase requests/{$requestId}:\n";
$firebaseRequest = $firebase->getReference('requests/' . $requestId)->getValue();
if ($firebaseRequest) {
    echo "  ✅ Trouvée\n";
    echo "  Keys: " . implode(', ', array_keys($firebaseRequest)) . "\n\n";
} else {
    echo "  ❌ Pas trouvée\n\n";
}

// Vérifier dans Firebase requests/new-request/
echo "Firebase requests/new-request/{$requestId}:\n";
$firebaseNewRequest = $firebase->getReference('requests/new-request/' . $requestId)->getValue();
if ($firebaseNewRequest) {
    echo "  ✅ Trouvée\n";
    echo "  Keys: " . implode(', ', array_keys($firebaseNewRequest)) . "\n\n";
} else {
    echo "  ❌ Pas trouvée\n\n";
}

// Vérifier dans Firebase request-meta/
echo "Firebase request-meta/{$requestId}:\n";
$firebaseMeta = $firebase->getReference('request-meta/' . $requestId)->getValue();
if ($firebaseMeta) {
    echo "  ✅ Trouvée\n";
    echo "  Driver ID: " . ($firebaseMeta['driver_id'] ?? 'N/A') . "\n\n";
} else {
    echo "  ❌ Pas trouvée\n\n";
}

// Essayer de créer manuellement dans Firebase
echo "🔧 Test: Création manuelle dans Firebase...\n";

$testData = [
    'request_id' => (string)$request->id,
    'request_number' => (string)$request->request_number,
    'service_location_id' => (string)$request->service_location_id,
    'user_id' => (string)$request->user_id,
    'pick_address' => (string)($request->requestPlace->pick_address ?? 'N/A'),
    'drop_address' => (string)($request->requestPlace->drop_address ?? 'N/A'),
    'active' => 1,
    'date' => (string)time(),
    'updated_at' => ['sv' => 'timestamp'],
];

try {
    $firebase->getReference('requests/' . $request->id)->set($testData);
    $firebase->getReference('requests/new-request/' . $request->id)->set($testData);
    echo "  ✅ Création réussie!\n\n";
    
    echo "Vérification:\n";
    $check = $firebase->getReference('requests/new-request/' . $request->id)->getValue();
    if ($check) {
        echo "  ✅ Maintenant présente dans Firebase\n";
        echo "  user_id type: " . gettype($check['user_id']) . "\n";
        echo "  service_location_id type: " . gettype($check['service_location_id']) . "\n";
    }
} catch (\Exception $e) {
    echo "  ❌ Erreur: " . $e->getMessage() . "\n";
}

echo "\n=== FIN ===\n";
