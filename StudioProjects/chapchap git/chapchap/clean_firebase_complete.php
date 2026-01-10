#!/usr/bin/env php
<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$firebase = app(\Kreait\Firebase\Contract\Database::class);

echo "🧹 NETTOYAGE COMPLET FIREBASE\n";
echo "==============================\n\n";

// Nettoyer requests/new-request
echo "1️⃣  Nettoyage requests/new-request...\n";
$requests = $firebase->getReference('requests/new-request')->getValue();
$count = 0;
if ($requests && is_array($requests)) {
    foreach ($requests as $id => $req) {
        $firebase->getReference('requests/new-request/' . $id)->remove();
        $count++;
        echo "  Supprimé: " . substr($id, 0, 12) . "...\n";
    }
}
echo "  ✅ $count requêtes supprimées\n\n";

// Nettoyer requests/
echo "2️⃣  Nettoyage requests/...\n";
$requests = $firebase->getReference('requests')->getValue();
$count = 0;
if ($requests && is_array($requests)) {
    foreach ($requests as $id => $req) {
        if ($id !== 'new-request') { // Ne pas supprimer le dossier new-request
            $firebase->getReference('requests/' . $id)->remove();
            $count++;
            echo "  Supprimé: " . substr($id, 0, 12) . "...\n";
        }
    }
}
echo "  ✅ $count requêtes supprimées\n\n";

// Nettoyer request-meta
echo "3️⃣  Nettoyage request-meta...\n";
$requestMeta = $firebase->getReference('request-meta')->getValue();
$count = 0;
if ($requestMeta && is_array($requestMeta)) {
    foreach ($requestMeta as $id => $meta) {
        $firebase->getReference('request-meta/' . $id)->remove();
        $count++;
        echo "  Supprimé: " . substr($id, 0, 12) . "...\n";
    }
}
echo "  ✅ $count metas supprimées\n\n";

echo "🎉 NETTOYAGE TERMINÉ!\n";
echo "Vous pouvez maintenant créer une nouvelle requête.\n";
