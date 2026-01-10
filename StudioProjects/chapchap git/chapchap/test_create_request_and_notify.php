<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "\n🧪 TEST COMPLET - Création de requête et notification drivers\n";
echo "=============================================================\n\n";

// 1. Vérifier les drivers disponibles
echo "1️⃣  DRIVERS DISPONIBLES\n";
echo "-----------------------\n";

$firebase = app(\Kreait\Firebase\Contract\Database::class);
$drivers = $firebase->getReference('drivers')->getValue();

$availableDrivers = [];
if ($drivers && is_array($drivers)) {
    $now = \Carbon\Carbon::now()->timestamp;
    $threshold = \Carbon\Carbon::now()->subMinutes(30)->timestamp;
    
    foreach ($drivers as $driverId => $driver) {
        if (isset($driver['is_active']) && $driver['is_active'] == 1 &&
            isset($driver['is_available']) && $driver['is_available'] == 1 &&
            isset($driver['l']) && is_array($driver['l']) &&
            isset($driver['g'])) {
            
            $driverTimestamp = \Carbon\Carbon::createFromTimestamp($driver['updated_at'] / 1000)->timestamp;
            $ageMinutes = round(($now - $driverTimestamp) / 60);
            
            echo "✅ " . ($driver['name'] ?? $driverId) . "\n";
            echo "   ID: " . str_replace('driver_', '', $driverId) . "\n";
            echo "   Position: " . $driver['l'][0] . ", " . $driver['l'][1] . "\n";
            echo "   Âge: $ageMinutes minutes\n";
            echo "   Peut recevoir: " . ($driverTimestamp >= $threshold ? "OUI ✅" : "NON (trop vieux)") . "\n\n";
            
            if ($driverTimestamp >= $threshold) {
                $availableDrivers[] = [
                    'id' => str_replace('driver_', '', $driverId),
                    'name' => $driver['name'] ?? 'N/A',
                    'lat' => $driver['l'][0],
                    'lng' => $driver['l'][1],
                ];
            }
        }
    }
}

if (empty($availableDrivers)) {
    echo "❌ AUCUN driver disponible!\n";
    echo "   Les drivers doivent:\n";
    echo "   - Être actifs et disponibles\n";
    echo "   - Avoir des coordonnées GPS\n";
    echo "   - Avoir updated_at < 30 minutes\n\n";
    exit(1);
}

echo "Nombre de drivers disponibles: " . count($availableDrivers) . "\n\n";

// 2. Créer une requête de test
echo "2️⃣  CRÉATION D'UNE REQUÊTE DE TEST\n";
echo "----------------------------------\n";

$user = App\Models\User::find(2);
if (!$user) {
    echo "❌ User ID 2 introuvable!\n";
    exit(1);
}

// Utiliser la position du premier driver disponible
$testDriver = $availableDrivers[0];
$pickLat = $testDriver['lat'];
$pickLng = $testDriver['lng'];

echo "User: {$user->name} (ID: {$user->id})\n";
echo "Position test: $pickLat, $pickLng (près de {$testDriver['name']})\n\n";

// Créer la requête
DB::beginTransaction();

try {
    $request = new App\Models\Request\Request();
    $request->request_number = 'TEST-' . time();
    $request->user_id = $user->id;
    $request->service_location_id = '929c0012-e155-4789-a72a-68e12d8ab28b';
    $request->zone_type_id = '67722fce-9f75-4ae2-b55d-cb886ecccd0f'; // Type de véhicule
    $request->transport_type = 'taxi';
    $request->payment_opt = 1;
    $request->is_later = 0;
    $request->on_search = 1;
    $request->is_completed = 0;
    $request->is_cancelled = 0;
    $request->save();
    
    // Créer request_place
    $request->requestPlace()->create([
        'pick_lat' => $pickLat,
        'pick_lng' => $pickLng,
        'drop_lat' => $pickLat + 0.01,
        'drop_lng' => $pickLng + 0.01,
        'pick_address' => 'Position de test',
        'drop_address' => 'Destination de test',
    ]);
    
    DB::commit();
    
    echo "✅ Requête créée: {$request->id}\n";
    echo "   Request Number: {$request->request_number}\n\n";
    
} catch (\Exception $e) {
    DB::rollBack();
    echo "❌ Erreur création requête: " . $e->getMessage() . "\n";
    exit(1);
}

// 3. Vérifier Firebase
echo "3️⃣  VÉRIFICATION FIREBASE\n";
echo "-------------------------\n";

sleep(2); // Attendre que Firebase soit mis à jour

$firebaseReq = $firebase->getReference('requests/new-request/' . $request->id)->getValue();
if ($firebaseReq) {
    echo "✅ Requête dans Firebase (requests/new-request)\n";
    echo "   Status: " . ($firebaseReq['status'] ?? 'N/A') . "\n";
    echo "   Active: " . ($firebaseReq['active'] ?? 'N/A') . "\n\n";
} else {
    echo "❌ Requête ABSENTE de Firebase!\n";
    echo "   Vérification dans requests/ seulement...\n";
    
    $firebaseReq2 = $firebase->getReference('requests/' . $request->id)->getValue();
    if ($firebaseReq2) {
        echo "⚠️  Trouvée dans requests/ mais PAS dans requests/new-request/\n";
        echo "   Les drivers ne la verront pas!\n\n";
    } else {
        echo "❌ Absente de Firebase complètement!\n\n";
    }
}

// 4. Appeler fetchDriversFromFirebase manuellement
echo "4️⃣  RECHERCHE ET NOTIFICATION DES DRIVERS\n";
echo "-----------------------------------------\n";

$request = App\Models\Request\Request::with('requestPlace', 'zoneType')->find($request->id);

// Simuler l'appel de fetchDriversFromFirebase
$controller = new App\Http\Controllers\Api\V1\Request\CreateRequestController();

try {
    // Utiliser reflection pour appeler la méthode protected
    $reflection = new ReflectionClass($controller);
    $method = $reflection->getMethod('fetchDriversFromFirebase');
    $method->setAccessible(true);
    
    echo "Appel de fetchDriversFromFirebase...\n";
    $result = $method->invoke($controller, $request, $firebase);
    
    if ($result === "success") {
        echo "✅ Drivers notifiés avec succès!\n\n";
    } elseif ($result === null) {
        echo "⚠️  Aucun driver trouvé ou déjà notifié\n\n";
    } else {
        echo "⚠️  Résultat: $result\n\n";
    }
    
} catch (\Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n\n";
}

// 5. Vérifier les request-meta
echo "5️⃣  VÉRIFICATION REQUEST-META\n";
echo "-----------------------------\n";

$metas = App\Models\Request\RequestMeta::where('request_id', $request->id)->get();
if ($metas->count() > 0) {
    echo "✅ Request-meta créés: " . $metas->count() . "\n";
    foreach ($metas as $meta) {
        $driver = App\Models\Admin\Driver::find($meta->driver_id);
        echo "   - Driver: " . ($driver->name ?? 'N/A') . " (ID: {$meta->driver_id})\n";
        echo "     Distance: " . ($meta->distance_to_pickup ?? 'N/A') . " km\n";
        echo "     Active: " . ($meta->active ? 'OUI' : 'NON') . "\n";
    }
    echo "\n";
} else {
    echo "❌ Aucun request-meta créé!\n";
    echo "   Les drivers n'ont PAS été notifiés.\n\n";
}

// 6. Vérifier Firebase request-meta
$firebaseMeta = $firebase->getReference('request-meta/' . $request->id)->getValue();
if ($firebaseMeta) {
    echo "✅ Request-meta dans Firebase\n";
    echo "   Driver ID: " . ($firebaseMeta['driver_id'] ?? 'N/A') . "\n";
    echo "   Active: " . ($firebaseMeta['active'] ?? 'N/A') . "\n\n";
} else {
    echo "❌ Request-meta ABSENT de Firebase!\n\n";
}

// 7. Vérifier les logs
echo "6️⃣  LOGS DE NOTIFICATION\n";
echo "-----------------------\n";

$logFile = storage_path('logs/laravel.log');
if (file_exists($logFile)) {
    $logs = shell_exec("tail -50 $logFile | grep -A 2 'Envoi notification\\|Notification dispatchée\\|Recherche drivers'");
    if ($logs) {
        echo $logs . "\n";
    } else {
        echo "Aucun log de notification trouvé dans les 50 dernières lignes\n\n";
    }
}

// 8. Résumé
echo "\n";
echo "=============================================================\n";
echo "📊 RÉSUMÉ DU TEST\n";
echo "=============================================================\n\n";

echo "Requête créée: {$request->request_number}\n";
echo "Drivers disponibles: " . count($availableDrivers) . "\n";
echo "Request-meta créés: " . $metas->count() . "\n";
echo "Dans Firebase: " . ($firebaseReq ? 'OUI ✅' : 'NON ❌') . "\n";
echo "Meta Firebase: " . ($firebaseMeta ? 'OUI ✅' : 'NON ❌') . "\n\n";

if ($metas->count() > 0 && $firebaseReq && $firebaseMeta) {
    echo "✅ TOUT FONCTIONNE!\n";
    echo "   Si les drivers ne reçoivent pas, c'est un problème dans l'app Flutter.\n";
    echo "   Voir: FIX_FLUTTER_BLOC_CLOSED_ERROR.md\n\n";
} else {
    echo "❌ PROBLÈME BACKEND!\n";
    if (!$firebaseReq) {
        echo "   - Requête pas dans Firebase\n";
    }
    if ($metas->count() == 0) {
        echo "   - Aucun driver notifié\n";
    }
    if (!$firebaseMeta) {
        echo "   - Pas de meta dans Firebase\n";
    }
    echo "\n";
}

// Nettoyer
echo "🧹 Nettoyage...\n";
$firebase->getReference('requests/' . $request->id)->remove();
$firebase->getReference('requests/new-request/' . $request->id)->remove();
$firebase->getReference('request-meta/' . $request->id)->remove();
$request->requestMeta()->delete();
$request->requestPlace()->delete();
$request->delete();
echo "✅ Requête de test supprimée\n\n";
