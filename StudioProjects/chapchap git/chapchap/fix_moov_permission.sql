-- 🔐 Script SQL pour corriger la permission Moov Money

-- 1. Créer la permission si elle n'existe pas
INSERT INTO permissions (slug, name, description, main_menu, sub_menu, main_link, icon, created_at, updated_at)
VALUES (
    'moov-money-transactions',
    'Moov Money Transactions',
    'Voir et gérer les transactions Moov Money',
    'Moov Money',
    NULL,
    '/moov-money-transactions',
    'bx bx-money',
    NOW(),
    NOW()
)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description),
    updated_at = NOW();

-- 2. Récupérer l'ID de la permission
SET @permission_id = (SELECT id FROM permissions WHERE slug = 'moov-money-transactions');

-- 3. Assigner à tous les rôles admin (super-admin et admin)
INSERT IGNORE INTO permission_role (permission_id, role_id, created_at, updated_at)
SELECT 
    @permission_id,
    r.id,
    NOW(),
    NOW()
FROM roles r 
WHERE r.slug IN ('super-admin', 'admin');

-- 4. Vérification - Afficher les assignations
SELECT 
    p.slug as permission_slug,
    p.name as permission_name,
    r.slug as role_slug,
    r.name as role_name,
    'Permission assignée avec succès' as status
FROM permissions p
JOIN permission_role pr ON p.id = pr.permission_id
JOIN roles r ON pr.role_id = r.id
WHERE p.slug = 'moov-money-transactions';

-- 5. Si aucun résultat, afficher les rôles disponibles
SELECT 
    'Rôles disponibles:' as info,
    slug,
    name
FROM roles
ORDER BY slug;
