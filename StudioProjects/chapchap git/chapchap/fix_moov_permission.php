<?php

require_once __DIR__ . '/vendor/autoload.php';

// Bootstrap Laravel
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔐 Correction Permission Moov Money\n";
echo "===================================\n\n";

try {
    $permissionClass = 'App\Models\Access\Permission';
    $roleClass = 'App\Models\Access\Role';
    
    // Vérifier si la permission existe
    $permission = $permissionClass::where('slug', 'moov-money-transactions')->first();
    
    if (!$permission) {
        echo "📝 Création de la permission...\n";
        $permission = $permissionClass::create([
            'slug' => 'moov-money-transactions',
            'name' => 'Moov Money Transactions',
            'description' => 'Voir et gérer les transactions Moov Money',
            'main_menu' => 'Moov Money',
            'sub_menu' => null,
            'main_link' => '/moov-money-transactions',
            'icon' => 'bx bx-money'
        ]);
        echo "✅ Permission créée: {$permission->name}\n\n";
    } else {
        echo "✅ Permission existe déjà: {$permission->name}\n\n";
    }
    
    // Trouver les rôles admin
    $adminRoles = $roleClass::whereIn('slug', ['super-admin', 'admin'])->get();
    
    if ($adminRoles->count() > 0) {
        foreach ($adminRoles as $role) {
            // Vérifier si la permission est déjà assignée
            if (!$role->permissions()->where('permission_id', $permission->id)->exists()) {
                $role->permissions()->attach($permission->id);
                echo "✅ Permission assignée au rôle: {$role->name}\n";
            } else {
                echo "⚠️  Permission déjà assignée au rôle: {$role->name}\n";
            }
        }
    } else {
        echo "❌ Aucun rôle admin trouvé!\n";
        
        // Lister tous les rôles
        echo "📋 Rôles disponibles:\n";
        $allRoles = $roleClass::all();
        foreach ($allRoles as $role) {
            echo "   - {$role->slug} ({$role->name})\n";
        }
    }
    
    echo "\n🎯 Vérification finale...\n";
    
    // Vérifier les assignations
    $assignedRoles = $permission->roles()->get();
    if ($assignedRoles->count() > 0) {
        echo "✅ Permission assignée aux rôles:\n";
        foreach ($assignedRoles as $role) {
            echo "   - {$role->name} ({$role->slug})\n";
        }
    } else {
        echo "❌ Permission non assignée à aucun rôle\n";
    }
    
    echo "\n💡 Instructions:\n";
    echo "================\n";
    echo "1. 🔄 Déconnectez-vous de l'interface admin\n";
    echo "2. 🔑 Reconnectez-vous\n";
    echo "3. 👀 Le menu 'Moov Money' devrait maintenant être visible\n";
    echo "4. 🌐 URL: http://46.202.171.118/moov-money-transactions\n";

} catch (Exception $e) {
    echo "❌ Erreur: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}

echo "\n===================================\n";
echo "✅ Script terminé\n";
?>
