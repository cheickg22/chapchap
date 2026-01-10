#!/usr/bin/env php
<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$firebase = app(\Kreait\Firebase\Contract\Database::class);

echo "🔍 TEST COMPLET DU FLUX\n";
echo "======================\n\n";

// 1. Dernière requête en DB
$request = \App\Models\Request\Request::orderBy('created_at', 'desc')->first();
if (!$request) {
    echo "❌ Aucune requête en DB\n";
    exit(1);
}

echo "1️⃣  Dernière requête en DB:\n";
echo "  ID: {$request->id}\n";
echo "  Created: {$request->created_at}\n";
echo "  Status: is_completed={$request->is_completed}, is_cancelled={$request->is_cancelled}\n\n";

// 2. Vérifier dans Firebase requests/new-request
echo "2️⃣  Firebase requests/new-request/{$request->id}:\n";
$firebaseReq = $firebase->getReference('requests/new-request/' . $request->id)->getValue();
if ($firebaseReq) {
    echo "  ✅ Trouvée\n";
    echo "  user_id: {$firebaseReq['user_id']} (type: " . gettype($firebaseReq['user_id']) . ")\n";
    echo "  active: {$firebaseReq['active']}\n";
} else {
    echo "  ❌ PAS trouvée\n";
}
echo "\n";

// 3. Vérifier request-meta
echo "3️⃣  Firebase request-meta/{$request->id}:\n";
$meta = $firebase->getReference('request-meta/' . $request->id)->getValue();
if ($meta) {
    echo "  ✅ Trouvée\n";
    echo "  driver_id: " . ($meta['driver_id'] ?? 'NULL') . " (type: " . gettype($meta['driver_id'] ?? null) . ")\n";
    echo "  user_id: " . ($meta['user_id'] ?? 'NULL') . " (type: " . gettype($meta['user_id'] ?? null) . ")\n";
    echo "  active: " . ($meta['active'] ?? 'NULL') . "\n";
    
    // 4. Vérifier que le driver existe
    if (isset($meta['driver_id'])) {
        $driverId = $meta['driver_id'];
        echo "\n4️⃣  Vérification driver_{$driverId} dans Firebase:\n";
        $driver = $firebase->getReference('drivers/driver_' . $driverId)->getValue();
        if ($driver) {
            echo "  ✅ Driver trouvé\n";
            echo "  name: " . ($driver['name'] ?? 'N/A') . "\n";
            echo "  is_active: " . ($driver['is_active'] ?? 'N/A') . "\n";
            echo "  is_available: " . ($driver['is_available'] ?? 'N/A') . "\n";
            
            $timestamp = $driver['updated_at'] ?? 0;
            $now = time() * 1000;
            $diff = ($now - $timestamp) / 1000 / 60;
            echo "  updated_at: " . date('H:i:s', $timestamp / 1000) . " (il y a " . round($diff) . " min)\n";
            
            // 5. Test de correspondance
            echo "\n5️⃣  TEST DE CORRESPONDANCE:\n";
            echo "  request-meta cherche driver_id: '{$driverId}' (type: " . gettype($driverId) . ")\n";
            echo "  Firebase a driver: 'driver_{$driverId}'\n";
            
            // Simuler la requête Firebase que Flutter fait
            echo "\n6️⃣  SIMULATION REQUÊTE FLUTTER:\n";
            echo "  Flutter cherche: .orderByChild('driver_id').equalTo('{$driverId}')\n";
            
            $allMeta = $firebase->getReference('request-meta')->getValue();
            $found = false;
            if ($allMeta) {
                foreach ($allMeta as $metaId => $metaData) {
                    if (isset($metaData['driver_id']) && $metaData['driver_id'] == $driverId) {
                        echo "  ✅ MATCH TROUVÉ: request-meta/{$metaId}\n";
                        echo "     driver_id: {$metaData['driver_id']} (type: " . gettype($metaData['driver_id']) . ")\n";
                        echo "     active: " . ($metaData['active'] ?? 'N/A') . "\n";
                        $found = true;
                    }
                }
            }
            
            if (!$found) {
                echo "  ❌ AUCUN MATCH TROUVÉ!\n";
                echo "  Problème: Flutter ne peut pas trouver cette requête\n";
            }
            
        } else {
            echo "  ❌ Driver PAS trouvé dans Firebase\n";
        }
    }
} else {
    echo "  ❌ PAS trouvée\n";
    echo "  Problème: Le driver n'a pas été assigné!\n";
}

echo "\n=== FIN DU TEST ===\n";
