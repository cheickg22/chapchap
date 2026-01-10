#!/usr/bin/env php
<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$firebase = app(\Kreait\Firebase\Contract\Database::class);

echo "🔍 VÉRIFICATION DES TYPES DANS FIREBASE\n";
echo "========================================\n\n";

// Vérifier requests/new-request
echo "1️⃣  requests/new-request:\n";
echo "-------------------------\n";
$requests = $firebase->getReference('requests/new-request')->getValue();
if ($requests && is_array($requests)) {
    foreach ($requests as $id => $req) {
        echo "Request ID: " . substr($id, 0, 12) . "...\n";
        echo "  user_id: " . ($req['user_id'] ?? 'N/A') . " (type: " . gettype($req['user_id'] ?? null) . ")\n";
        echo "  service_location_id: " . ($req['service_location_id'] ?? 'N/A') . " (type: " . gettype($req['service_location_id'] ?? null) . ")\n";
        echo "  request_id: " . ($req['request_id'] ?? 'N/A') . " (type: " . gettype($req['request_id'] ?? null) . ")\n";
        echo "\n";
        break; // Juste le premier
    }
} else {
    echo "  ❌ Aucune requête\n\n";
}

// Vérifier request-meta
echo "2️⃣  request-meta:\n";
echo "----------------\n";
$requestMeta = $firebase->getReference('request-meta')->getValue();
if ($requestMeta && is_array($requestMeta)) {
    foreach ($requestMeta as $id => $meta) {
        echo "Request ID: " . substr($id, 0, 12) . "...\n";
        echo "  driver_id: " . ($meta['driver_id'] ?? 'N/A') . " (type: " . gettype($meta['driver_id'] ?? null) . ")\n";
        echo "  request_id: " . ($meta['request_id'] ?? 'N/A') . " (type: " . gettype($meta['request_id'] ?? null) . ")\n";
        echo "  user_id: " . ($meta['user_id'] ?? 'N/A') . " (type: " . gettype($meta['user_id'] ?? null) . ")\n";
        echo "\n";
        break; // Juste le premier
    }
} else {
    echo "  ❌ Aucune meta\n\n";
}

echo "✅ Vérification terminée\n";
