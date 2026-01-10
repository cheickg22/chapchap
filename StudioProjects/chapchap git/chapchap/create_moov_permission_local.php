<?php

require_once __DIR__ . '/vendor/autoload.php';

// Bootstrap Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔐 Création de la permission Moov Money\n";
echo "=====================================\n\n";

try {
    // Utiliser les modèles
    $permissionClass = 'App\Models\Access\Permission';
    $roleClass = 'App\Models\Access\Role';
    
    // Vérifier si la permission existe
    $existingPermission = $permissionClass::where('slug', 'moov-money-transactions')->first();
    
    if ($existingPermission) {
        echo "⚠️  Permission déjà existante: {$existingPermission->name}\n";
        $permission = $existingPermission;
    } else {
        // Créer la permission
        $permission = $permissionClass::create([
            'slug' => 'moov-money-transactions',
            'name' => 'Gestion Moov Money',
            'description' => 'Voir et gérer les transactions Moov Money',
            'main_menu' => 'Moov Money',
            'sub_menu' => null,
            'main_link' => '/moov-money-transactions',
            'icon' => 'bx bx-money'
        ]);
        
        echo "✅ Permission créée: {$permission->name}\n";
    }

    // Trouver le rôle admin
    $adminRole = $roleClass::where('slug', 'super-admin')->first();
    if (!$adminRole) {
        $adminRole = $roleClass::where('slug', 'admin')->first();
    }

    if ($adminRole) {
        // Vérifier si déjà assignée
        if (!$adminRole->permissions()->where('permission_id', $permission->id)->exists()) {
            $adminRole->permissions()->attach($permission->id);
            echo "✅ Permission assignée au rôle: {$adminRole->name}\n";
        } else {
            echo "⚠️  Permission déjà assignée au rôle: {$adminRole->name}\n";
        }
    } else {
        echo "❌ Aucun rôle admin trouvé!\n";
        
        // Lister les rôles disponibles
        echo "📋 Rôles disponibles:\n";
        $roles = $roleClass::all();
        foreach ($roles as $role) {
            echo "   - {$role->slug} ({$role->name})\n";
        }
    }

    echo "\n🎉 Configuration terminée!\n";
    echo "🌐 URL: http://46.202.171.118/moov-money-transactions\n";

} catch (Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}

echo "\n=====================================\n";
echo "✅ SCRIPT TERMINÉ\n";
echo "=====================================\n";
?>
