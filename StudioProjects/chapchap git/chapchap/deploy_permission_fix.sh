#!/bin/bash

# 🔐 Déploiement du Fix Permission Moov Money

echo "🔐 Fix Permission Moov Money"
echo "============================"
echo ""

SERVER_HOST="46.202.171.118"
SERVER_USER="root"

echo "📝 Ce script va:"
echo "  1. Copier le script PHP de correction"
echo "  2. Exécuter la correction de permission"
echo "  3. Nettoyer les caches"
echo ""

# Test de connexion SSH
echo "🔧 Test de connexion..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes ${SERVER_USER}@${SERVER_HOST} "echo 'OK'" 2>/dev/null; then
    echo "✅ Connexion SSH OK"
    
    echo ""
    echo "📁 Copie des fichiers..."
    scp fix_moov_permission.php ${SERVER_USER}@${SERVER_HOST}:/var/www/html/chapchap/
    scp fix_moov_permission.sql ${SERVER_USER}@${SERVER_HOST}:/var/www/html/chapchap/
    
    echo ""
    echo "🔐 Exécution du fix..."
    ssh ${SERVER_USER}@${SERVER_HOST} << 'ENDSSH'
cd /var/www/html/chapchap

echo "📝 Exécution du script PHP..."
php fix_moov_permission.php

echo ""
echo "🧹 Nettoyage des caches..."
php artisan cache:clear 2>/dev/null || true
php artisan permission:cache-reset 2>/dev/null || true
php artisan config:clear 2>/dev/null || true

echo ""
echo "✅ Fix terminé!"
ENDSSH

    echo ""
    echo "🎉 FIX DÉPLOYÉ AVEC SUCCÈS!"
    echo ""
    echo "📝 Instructions:"
    echo "1. Déconnectez-vous de l'interface admin"
    echo "2. Reconnectez-vous"
    echo "3. Le menu 'Moov Money' devrait être visible"
    echo ""
    echo "🌐 URL: http://46.202.171.118/moov-money-transactions"
    
else
    echo "❌ Connexion SSH échouée"
    echo ""
    echo "📋 Actions manuelles:"
    echo "1. Copier fix_moov_permission.php sur le serveur"
    echo "2. Exécuter: php fix_moov_permission.php"
    echo "3. OU exécuter le SQL: fix_moov_permission.sql"
    echo "4. Nettoyer les caches"
    echo "5. Se déconnecter/reconnecter"
fi

echo ""
echo "============================"
