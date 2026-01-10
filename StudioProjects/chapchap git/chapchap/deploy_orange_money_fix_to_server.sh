#!/bin/bash

# Script de déploiement de la correction Orange Money sur le serveur
# À exécuter sur le serveur de production

echo "🚀 Déploiement de la correction Orange Money sur le serveur..."

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Vérifier qu'on est sur le serveur
if [ ! -f "/var/www/html/chapchap/artisan" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté sur le serveur de production${NC}"
    echo "Chemin attendu: /var/www/html/chapchap/"
    exit 1
fi

cd /var/www/html/chapchap

# Backup des fichiers
echo -e "${YELLOW}📦 Création des backups...${NC}"
cp app/Http/Requests/Request/CreateTripRequest.php app/Http/Requests/Request/CreateTripRequest.php.backup.$(date +%Y%m%d_%H%M%S)
cp app/Http/Controllers/UserWebBookingController.php app/Http/Controllers/UserWebBookingController.php.backup.$(date +%Y%m%d_%H%M%S)
cp app/Http/Controllers/Web/Admin/DispatcherCreateRequestController.php app/Http/Controllers/Web/Admin/DispatcherCreateRequestController.php.backup.$(date +%Y%m%d_%H%M%S)

# Correction 1: CreateTripRequest.php
echo -e "${YELLOW}🔧 Correction de CreateTripRequest.php...${NC}"
sed -i "s/'payment_opt'=>'sometimes|required|in:0,1,2'/'payment_opt'=>'sometimes|required|in:0,1,2,3,4,5,6,7,8,9'/g" app/Http/Requests/Request/CreateTripRequest.php

# Correction 2: UserWebBookingController.php
echo -e "${YELLOW}🔧 Correction de UserWebBookingController.php...${NC}"
sed -i "s/'payment_opt'=>'sometimes|required|in:0,1,2'/'payment_opt'=>'sometimes|required|in:0,1,2,3,4,5,6,7,8,9'/g" app/Http/Controllers/UserWebBookingController.php

# Correction 3: DispatcherCreateRequestController.php
echo -e "${YELLOW}🔧 Correction de DispatcherCreateRequestController.php...${NC}"
sed -i "s/'payment_opt'=>'sometimes|required|in:0,1,2'/'payment_opt'=>'sometimes|required|in:0,1,2,3,4,5,6,7,8,9'/g" app/Http/Controllers/Web/Admin/DispatcherCreateRequestController.php

# Vérification
echo -e "${YELLOW}🔍 Vérification des modifications...${NC}"
echo ""
echo "CreateTripRequest.php:"
grep "payment_opt" app/Http/Requests/Request/CreateTripRequest.php | grep "in:" | head -1
echo ""
echo "UserWebBookingController.php:"
grep "payment_opt" app/Http/Controllers/UserWebBookingController.php | grep "in:" | head -1
echo ""
echo "DispatcherCreateRequestController.php:"
grep "payment_opt" app/Http/Controllers/Web/Admin/DispatcherCreateRequestController.php | grep "in:" | head -1
echo ""

# Clear cache Laravel
echo -e "${YELLOW}🧹 Nettoyage du cache Laravel...${NC}"
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Redémarrer les services
echo -e "${YELLOW}🔄 Redémarrage des services...${NC}"
sudo systemctl restart php8.2-fpm 2>/dev/null || sudo systemctl restart php-fpm 2>/dev/null || echo "PHP-FPM non redémarré"
sudo systemctl reload nginx 2>/dev/null || sudo systemctl reload apache2 2>/dev/null || echo "Serveur web non rechargé"

echo ""
echo -e "${GREEN}✅ Déploiement terminé avec succès !${NC}"
echo ""
echo -e "${GREEN}📝 Méthodes de paiement supportées :${NC}"
echo "  0 = Card (Carte bancaire)"
echo "  1 = Cash (Espèces)"
echo "  2 = Wallet (Portefeuille)"
echo "  4 = Orange Money ← NOUVEAU"
echo ""
echo -e "${YELLOW}⚠️  Backups créés avec timestamp dans le nom${NC}"
echo -e "${GREEN}🧪 Testez maintenant le paiement Orange Money depuis l'app !${NC}"
