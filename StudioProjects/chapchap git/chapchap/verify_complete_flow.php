#!/usr/bin/env php
<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$firebase = app(\Kreait\Firebase\Contract\Database::class);

echo "🔍 VÉRIFICATION COMPLÈTE DU FLUX\n";
echo "=================================\n\n";

// ========================================
// 1️⃣  CÔTÉ USER - Dernière requête créée
// ========================================
echo "1️⃣  CÔTÉ USER - Dernière requête en DB:\n";
echo "----------------------------------------\n";

$lastRequest = \App\Models\Request\Request::orderBy('created_at', 'desc')->first();

if ($lastRequest) {
    echo "✅ Requête trouvée:\n";
    echo "  ID: {$lastRequest->id}\n";
    echo "  Request Number: {$lastRequest->request_number}\n";
    echo "  User ID: {$lastRequest->user_id} (type: " . gettype($lastRequest->user_id) . ")\n";
    echo "  Service Location ID: {$lastRequest->service_location_id} (type: " . gettype($lastRequest->service_location_id) . ")\n";
    echo "  Zone Type ID: {$lastRequest->zone_type_id} (type: " . gettype($lastRequest->zone_type_id) . ")\n";
    echo "  Is Moov Money: " . ($lastRequest->is_moov_money ? 'OUI' : 'NON') . "\n";
    echo "  Status: {$lastRequest->is_completed}/{$lastRequest->is_cancelled}\n";
    echo "  Créée: {$lastRequest->created_at}\n";
    
    if ($lastRequest->requestPlace) {
        echo "\n  📍 Localisation:\n";
        echo "    Pick: {$lastRequest->requestPlace->pick_lat}, {$lastRequest->requestPlace->pick_lng}\n";
        echo "    Pick Address: {$lastRequest->requestPlace->pick_address}\n";
    }
} else {
    echo "❌ Aucune requête trouvée en DB\n";
}

echo "\n";

// ========================================
// 2️⃣  CÔTÉ BACKEND - Firebase requests/new-request
// ========================================
echo "2️⃣  CÔTÉ BACKEND - Firebase requests/new-request:\n";
echo "--------------------------------------------------\n";

$firebaseRequests = $firebase->getReference('requests/new-request')->getValue();

if ($firebaseRequests && is_array($firebaseRequests)) {
    echo "✅ " . count($firebaseRequests) . " requête(s) dans Firebase:\n\n";
    
    foreach ($firebaseRequests as $id => $req) {
        echo "  Request ID: " . substr($id, 0, 20) . "...\n";
        echo "  Request Number: " . ($req['request_number'] ?? 'N/A') . "\n";
        echo "  User ID: " . ($req['user_id'] ?? 'N/A') . " (type: " . gettype($req['user_id'] ?? null) . ")\n";
        echo "  Service Location ID: " . ($req['service_location_id'] ?? 'N/A') . " (type: " . gettype($req['service_location_id'] ?? null) . ")\n";
        echo "  Request ID field: " . ($req['request_id'] ?? 'N/A') . " (type: " . gettype($req['request_id'] ?? null) . ")\n";
        echo "  Active: " . ($req['active'] ?? 'N/A') . "\n";
        echo "  Is Moov Money: " . ($req['is_moov_money'] ?? 'NON') . "\n";
        
        if (isset($req['pick_lat']) && isset($req['pick_lng'])) {
            echo "  📍 Localisation: {$req['pick_lat']}, {$req['pick_lng']}\n";
        }
        
        echo "\n";
    }
} else {
    echo "❌ Aucune requête dans Firebase requests/new-request\n\n";
}

// ========================================
// 3️⃣  CÔTÉ DRIVER - Firebase request-meta
// ========================================
echo "3️⃣  CÔTÉ DRIVER - Firebase request-meta:\n";
echo "----------------------------------------\n";

$firebaseMeta = $firebase->getReference('request-meta')->getValue();

if ($firebaseMeta && is_array($firebaseMeta)) {
    echo "✅ " . count($firebaseMeta) . " meta(s) dans Firebase:\n\n";
    
    foreach ($firebaseMeta as $id => $meta) {
        echo "  Request ID: " . substr($id, 0, 20) . "...\n";
        echo "  Driver ID: " . ($meta['driver_id'] ?? 'N/A') . " (type: " . gettype($meta['driver_id'] ?? null) . ")\n";
        echo "  Request ID field: " . ($meta['request_id'] ?? 'N/A') . " (type: " . gettype($meta['request_id'] ?? null) . ")\n";
        echo "  User ID: " . ($meta['user_id'] ?? 'N/A') . " (type: " . gettype($meta['user_id'] ?? null) . ")\n";
        echo "  Active: " . ($meta['active'] ?? 'N/A') . "\n";
        echo "\n";
    }
} else {
    echo "❌ Aucune meta dans Firebase request-meta\n\n";
}

// ========================================
// 4️⃣  DRIVERS DISPONIBLES
// ========================================
echo "4️⃣  DRIVERS DISPONIBLES dans Firebase:\n";
echo "---------------------------------------\n";

$drivers = $firebase->getReference('drivers')->getValue();
$now = time();
$threshold = $now - (30 * 60); // 30 minutes

if ($drivers && is_array($drivers)) {
    $availableCount = 0;
    
    foreach ($drivers as $driverId => $driver) {
        if (isset($driver['is_active']) && $driver['is_active'] == 1 && 
            isset($driver['is_available']) && $driver['is_available'] == 1) {
            
            $ts = isset($driver['updated_at']) ? $driver['updated_at'] / 1000 : 0;
            $age = $now - $ts;
            $ageMin = round($age / 60);
            $canReceive = $ts >= $threshold ? '✅ OUI' : "❌ NON (trop vieux: {$ageMin} min)";
            
            echo "  Driver ID: {$driverId}\n";
            echo "    Name: " . ($driver['name'] ?? 'N/A') . "\n";
            echo "    Active: {$driver['is_active']}\n";
            echo "    Available: {$driver['is_available']}\n";
            echo "    Updated: " . date('H:i:s', $ts) . " (il y a {$ageMin} min)\n";
            echo "    Peut recevoir: {$canReceive}\n";
            
            if (isset($driver['l']) && is_array($driver['l'])) {
                echo "    📍 Position: {$driver['l'][0]}, {$driver['l'][1]}\n";
                echo "    Geohash: " . ($driver['g'] ?? 'N/A') . "\n";
            } else {
                echo "    ❌ Pas de coordonnées (l)\n";
            }
            
            if (isset($driver['vehicle_type'])) {
                echo "    Vehicle Type: {$driver['vehicle_type']}\n";
            } elseif (isset($driver['vehicle_types'])) {
                echo "    Vehicle Types: {$driver['vehicle_types']}\n";
            }
            
            echo "\n";
            $availableCount++;
        }
    }
    
    if ($availableCount == 0) {
        echo "  ❌ Aucun driver actif et disponible\n\n";
    } else {
        echo "  ✅ Total: {$availableCount} driver(s) disponible(s)\n\n";
    }
} else {
    echo "  ❌ Aucun driver dans Firebase\n\n";
}

// ========================================
// 5️⃣  VÉRIFICATION COHÉRENCE
// ========================================
echo "5️⃣  VÉRIFICATION COHÉRENCE:\n";
echo "----------------------------\n";

$issues = [];

// Vérifier si la requête DB est dans Firebase
if ($lastRequest && (!$firebaseRequests || !isset($firebaseRequests[$lastRequest->id]))) {
    $issues[] = "❌ La requête DB n'est PAS dans Firebase requests/new-request";
}

// Vérifier les types dans Firebase
if ($firebaseRequests) {
    foreach ($firebaseRequests as $id => $req) {
        if (isset($req['user_id']) && !is_string($req['user_id'])) {
            $issues[] = "❌ user_id n'est pas un String dans Firebase";
        }
        if (isset($req['service_location_id']) && !is_string($req['service_location_id'])) {
            $issues[] = "❌ service_location_id n'est pas un String dans Firebase";
        }
        if (isset($req['request_id']) && !is_string($req['request_id'])) {
            $issues[] = "❌ request_id n'est pas un String dans Firebase";
        }
    }
}

// Vérifier les types dans request-meta
if ($firebaseMeta) {
    foreach ($firebaseMeta as $id => $meta) {
        if (isset($meta['driver_id']) && !is_string($meta['driver_id'])) {
            $issues[] = "❌ driver_id n'est pas un String dans request-meta";
        }
        if (isset($meta['user_id']) && !is_string($meta['user_id'])) {
            $issues[] = "❌ user_id n'est pas un String dans request-meta";
        }
        if (isset($meta['request_id']) && !is_string($meta['request_id'])) {
            $issues[] = "❌ request_id n'est pas un String dans request-meta";
        }
    }
}

// Vérifier si des drivers sont disponibles
if (!$drivers || $availableCount == 0) {
    $issues[] = "❌ Aucun driver disponible pour recevoir la requête";
}

if (empty($issues)) {
    echo "✅ Tout est cohérent!\n";
    echo "  - Requête en DB ✅\n";
    echo "  - Requête dans Firebase ✅\n";
    echo "  - Tous les IDs en String ✅\n";
    echo "  - Drivers disponibles ✅\n";
} else {
    echo "⚠️  Problèmes détectés:\n";
    foreach ($issues as $issue) {
        echo "  {$issue}\n";
    }
}

echo "\n";
echo "=== FIN DE LA VÉRIFICATION ===\n";
