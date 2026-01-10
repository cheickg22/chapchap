<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$firebase = app(\Kreait\Firebase\Contract\Database::class);

echo "\n🔍 DIAGNOSTIC COMPLET - Système de Notification Drivers\n";
echo "========================================================\n\n";

// 1. Vérifier les drivers dans Firebase
echo "1️⃣  DRIVERS DANS FIREBASE\n";
echo "-------------------------\n";
$drivers = $firebase->getReference('drivers')->getValue();

if ($drivers && is_array($drivers)) {
    foreach ($drivers as $driverId => $driver) {
        echo "\n🚗 Driver: $driverId\n";
        echo "   Nom: " . ($driver['name'] ?? 'N/A') . "\n";
        echo "   Active: " . ($driver['is_active'] ?? 0) . "\n";
        echo "   Available: " . ($driver['is_available'] ?? 0) . "\n";
        echo "   Vehicle Type: " . ($driver['vehicle_type'] ?? 'N/A') . "\n";
        echo "   Vehicle Types: " . (isset($driver['vehicle_types']) ? implode(', ', $driver['vehicle_types']) : 'N/A') . "\n";
        echo "   Coordonnées (l): " . (isset($driver['l']) ? $driver['l'][0] . ', ' . $driver['l'][1] : '❌ MANQUANT') . "\n";
        echo "   Geohash (g): " . ($driver['g'] ?? '❌ MANQUANT') . "\n";
        echo "   Updated At: " . (isset($driver['updated_at']) ? date('Y-m-d H:i:s', $driver['updated_at'] / 1000) : 'N/A') . "\n";
        
        // Vérifier si le driver peut recevoir des notifications
        $canReceive = true;
        $reasons = [];
        
        if (!isset($driver['is_active']) || $driver['is_active'] != 1) {
            $canReceive = false;
            $reasons[] = "Pas actif";
        }
        if (!isset($driver['is_available']) || $driver['is_available'] != 1) {
            $canReceive = false;
            $reasons[] = "Pas disponible";
        }
        if (!isset($driver['l']) || !is_array($driver['l'])) {
            $canReceive = false;
            $reasons[] = "❌ PAS DE COORDONNÉES GPS";
        }
        if (!isset($driver['g'])) {
            $canReceive = false;
            $reasons[] = "❌ PAS DE GEOHASH";
        }
        if (!isset($driver['vehicle_type']) && !isset($driver['vehicle_types'])) {
            $canReceive = false;
            $reasons[] = "Pas de type de véhicule";
        }
        
        // Vérifier timestamp (7 minutes)
        if (isset($driver['updated_at'])) {
            $driverTimestamp = \Carbon\Carbon::createFromTimestamp($driver['updated_at'] / 1000)->timestamp;
            $conditionalTimestamp = \Carbon\Carbon::now()->subMinutes(7)->timestamp;
            if ($driverTimestamp < $conditionalTimestamp) {
                $canReceive = false;
                $reasons[] = "Dernière mise à jour > 7 min";
            }
        }
        
        if ($canReceive) {
            echo "   ✅ PEUT RECEVOIR DES NOTIFICATIONS\n";
        } else {
            echo "   ❌ NE PEUT PAS RECEVOIR: " . implode(', ', $reasons) . "\n";
        }
    }
} else {
    echo "❌ Aucun driver dans Firebase!\n";
}

// 2. Vérifier les drivers en base de données
echo "\n\n2️⃣  DRIVERS EN BASE DE DONNÉES\n";
echo "------------------------------\n";
$dbDrivers = \App\Models\Admin\Driver::where('active', 1)->get();

foreach ($dbDrivers as $driver) {
    echo "\n🚗 Driver ID: {$driver->id}\n";
    echo "   Nom: {$driver->name}\n";
    echo "   Active: {$driver->active}\n";
    echo "   Approve: {$driver->approve}\n";
    echo "   Available: {$driver->available}\n";
    echo "   Mobile: {$driver->mobile}\n";
    echo "   FCM Token: " . ($driver->user->fcm_token ? 'OUI ✅' : '❌ MANQUANT') . "\n";
    
    // Vérifier dans Firebase
    $firebaseDriver = $firebase->getReference('drivers/driver_' . $driver->id)->getValue();
    if ($firebaseDriver) {
        echo "   Firebase: ✅ Présent\n";
        echo "   Firebase Coords: " . (isset($firebaseDriver['l']) ? 'OUI ✅' : '❌ MANQUANT') . "\n";
    } else {
        echo "   Firebase: ❌ ABSENT\n";
    }
}

// 3. Vérifier les notification channels
echo "\n\n3️⃣  NOTIFICATION CHANNELS\n";
echo "-------------------------\n";
$notifications = \DB::table('notification_channels')
    ->whereIn('topics', ['Driver New Request', 'User Ride Later'])
    ->get();

foreach ($notifications as $notif) {
    echo "\n📢 Topic: {$notif->topics}\n";
    echo "   Push Enabled: " . ($notif->push_notification ? 'OUI ✅' : '❌ NON') . "\n";
    echo "   SMS Enabled: " . ($notif->sms_notification ? 'OUI' : 'NON') . "\n";
    echo "   Title: {$notif->push_title}\n";
    echo "   Body: {$notif->push_body}\n";
}

// 4. Vérifier les request-meta
echo "\n\n4️⃣  REQUEST META (Assignations en cours)\n";
echo "----------------------------------------\n";
$requestMetas = $firebase->getReference('request-meta')->getValue();

if ($requestMetas && is_array($requestMetas)) {
    echo "Nombre de meta: " . count($requestMetas) . "\n";
    foreach ($requestMetas as $requestId => $meta) {
        echo "\n📋 Request: " . substr($requestId, 0, 12) . "...\n";
        echo "   Driver ID: " . ($meta['driver_id'] ?? 'N/A') . "\n";
        echo "   User ID: " . ($meta['user_id'] ?? 'N/A') . "\n";
        echo "   Active: " . ($meta['active'] ?? 'N/A') . "\n";
    }
} else {
    echo "Aucune meta en cours\n";
}

// 5. Test de recherche de drivers
echo "\n\n5️⃣  TEST DE RECHERCHE DE DRIVERS\n";
echo "--------------------------------\n";

// Coordonnées de test (Bamako centre)
$testLat = 12.6392;
$testLng = -8.0029;
$radius = 30; // km

echo "Position de test: $testLat, $testLng\n";
echo "Rayon de recherche: $radius km\n\n";

$calculatable_radius = ($radius / 2);
$calulatable_lat = 0.0144927536231884 * $calculatable_radius;
$calulatable_long = 0.0181818181818182 * $calculatable_radius;

$lower_lat = ($testLat - $calulatable_lat);
$lower_long = ($testLng - $calulatable_long);
$higher_lat = ($testLat + $calulatable_lat);
$higher_long = ($testLng + $calulatable_long);

$g = new \Sk\Geohash\Geohash();
$lower_hash = $g->encode($lower_lat, $lower_long, 12);
$higher_hash = $g->encode($higher_lat, $higher_long, 12);

echo "Geohash range: $lower_hash -> $higher_hash\n\n";

$fire_drivers = $firebase->getReference('drivers')
    ->orderByChild('g')
    ->startAt($lower_hash)
    ->endAt($higher_hash)
    ->getValue();

if ($fire_drivers && is_array($fire_drivers)) {
    echo "✅ Drivers trouvés dans le rayon: " . count($fire_drivers) . "\n\n";
    
    foreach ($fire_drivers as $driverId => $driver) {
        if (isset($driver['l']) && is_array($driver['l'])) {
            $distance = distance_between_two_coordinates(
                $testLat, 
                $testLng, 
                $driver['l'][0], 
                $driver['l'][1], 
                'K'
            );
            
            echo "   - " . ($driver['name'] ?? $driverId) . ": " . round($distance, 2) . " km\n";
        }
    }
} else {
    echo "❌ Aucun driver trouvé dans le rayon!\n";
    echo "   Cela signifie que les drivers n'ont pas de geohash ou coordonnées dans Firebase\n";
}

echo "\n\n========================================================\n";
echo "🎯 RÉSUMÉ DU DIAGNOSTIC\n";
echo "========================================================\n\n";

echo "Pour qu'un driver reçoive des notifications, il DOIT avoir:\n";
echo "1. ✅ is_active = 1\n";
echo "2. ✅ is_available = 1\n";
echo "3. ✅ Coordonnées GPS (l: [lat, lng]) dans Firebase\n";
echo "4. ✅ Geohash (g) dans Firebase\n";
echo "5. ✅ vehicle_type ou vehicle_types\n";
echo "6. ✅ updated_at < 7 minutes\n";
echo "7. ✅ FCM token pour recevoir les push\n\n";

echo "Si un driver ne reçoit pas de notifications, vérifiez ces points!\n\n";
