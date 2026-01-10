#!/usr/bin/env php
<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$firebase = app(\Kreait\Firebase\Contract\Database::class);

echo "🔍 MONITORING FIREBASE EN TEMPS RÉEL\n";
echo "====================================\n\n";
echo "Créez une requête maintenant...\n\n";

$lastRequestCount = 0;
$lastMetaCount = 0;

for ($i = 0; $i < 60; $i++) {
    // Vérifier requests/new-request
    $requests = $firebase->getReference('requests/new-request')->getValue();
    $requestCount = $requests ? count($requests) : 0;
    
    // Vérifier request-meta
    $metas = $firebase->getReference('request-meta')->getValue();
    $metaCount = $metas ? count($metas) : 0;
    
    if ($requestCount != $lastRequestCount || $metaCount != $lastMetaCount) {
        echo "[" . date('H:i:s') . "] ";
        echo "requests/new-request: {$requestCount} | ";
        echo "request-meta: {$metaCount}\n";
        
        if ($requestCount > $lastRequestCount) {
            // Nouvelle requête détectée
            $newRequests = array_slice($requests, -1, 1, true);
            foreach ($newRequests as $id => $req) {
                echo "  ✅ Nouvelle requête: {$id}\n";
                echo "     user_id: " . ($req['user_id'] ?? 'N/A') . " (type: " . gettype($req['user_id'] ?? null) . ")\n";
            }
        }
        
        if ($metaCount > $lastMetaCount) {
            // Nouveau meta détecté
            $newMetas = array_slice($metas, -1, 1, true);
            foreach ($newMetas as $id => $meta) {
                echo "  ✅ Nouveau request-meta: {$id}\n";
                echo "     driver_id: " . ($meta['driver_id'] ?? 'N/A') . " (type: " . gettype($meta['driver_id'] ?? null) . ")\n";
                echo "     user_id: " . ($meta['user_id'] ?? 'N/A') . " (type: " . gettype($meta['user_id'] ?? null) . ")\n";
            }
        }
        
        $lastRequestCount = $requestCount;
        $lastMetaCount = $metaCount;
    }
    
    sleep(1);
}

echo "\n=== FIN DU MONITORING ===\n";
