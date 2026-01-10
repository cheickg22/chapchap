<?php

require_once 'bootstrap/app.php';

use App\Models\Request\Request;
use Illuminate\Support\Facades\Log;

// Récupérer une requête de retrait
$request = Request::with(['requestPlace', 'userDetail', 'zoneType.vehicleType'])
    ->where('moov_money_type', 'withdrawal')
    ->first();

if (!$request) {
    echo "Aucune requête de retrait trouvée\n";
    exit;
}

echo "Requête trouvée: {$request->id}\n";
echo "Type: {$request->moov_money_type}\n";
echo "Montant: {$request->moov_money_amount}\n";

// Vérifier s'il y a déjà des requestMeta
$existingMeta = $request->requestMeta()->count();
echo "RequestMeta existants: {$existingMeta}\n";

if ($existingMeta > 0) {
    echo "Suppression des requestMeta existants...\n";
    $request->requestMeta()->delete();
}

// Simuler la recherche de drivers
$database = app('firebase.database');
$pick_lat = $request->requestPlace->pick_lat;
$pick_lng = $request->requestPlace->pick_lng;
$driver_search_radius = get_settings('driver_search_radius') ?: 30;

echo "Recherche de drivers dans un rayon de {$driver_search_radius}km\n";
echo "Position: {$pick_lat}, {$pick_lng}\n";

// Récupérer tous les drivers Firebase
$fire_drivers = $database->getReference('drivers')->getValue();

if (!$fire_drivers) {
    echo "Aucun driver trouvé dans Firebase\n";
    exit;
}

echo "Drivers dans Firebase: " . count($fire_drivers) . "\n";

$available_drivers = 0;
foreach ($fire_drivers as $key => $fire_driver) {
    if (isset($fire_driver['is_active']) && $fire_driver['is_active'] == 1 && 
        isset($fire_driver['is_available']) && $fire_driver['is_available'] == 1) {
        $available_drivers++;
        echo "Driver disponible: {$key}\n";
    }
}

echo "Drivers disponibles: {$available_drivers}\n";

if ($available_drivers > 0) {
    echo "✅ Des drivers sont disponibles pour recevoir la requête\n";
} else {
    echo "❌ Aucun driver disponible\n";
}
