<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$firebase = app(\Kreait\Firebase\Contract\Database::class);

echo "\n🧹 NETTOYAGE FIREBASE\n\n";

// Supprimer toutes les requêtes en attente (plus de 1 heure)
$requests = $firebase->getReference('requests/new-request')->getValue();

if ($requests && is_array($requests)) {
    $now = time();
    $deleted = 0;
    
    foreach ($requests as $id => $req) {
        $createdAt = $req['created_at'] ?? 0;
        $age = $now - $createdAt;
        
        // Supprimer si plus de 1 heure (3600 secondes)
        if ($age > 3600 || $createdAt == 0) {
            echo "Suppression: " . substr($id, 0, 12) . "... (âge: " . round($age/60) . " min)\n";
            $firebase->getReference('requests/new-request/' . $id)->remove();
            $firebase->getReference('requests/' . $id)->remove();
            $deleted++;
        }
    }
    
    echo "\n✅ $deleted requêtes supprimées\n";
} else {
    echo "Aucune requête à nettoyer\n";
}

echo "\n=== FIN ===\n";
