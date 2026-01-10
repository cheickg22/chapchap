#!/bin/bash

# Script d'optimisation des images pour ChapChap Driver
# Réduit la taille des images de 50-70% sans perte visible de qualité

echo "🖼️  Optimisation des images ChapChap Driver"
echo "==========================================="

# Vérifier si pngquant est installé
if ! command -v pngquant &> /dev/null; then
    echo "⚠️  pngquant n'est pas installé"
    echo "Installation: brew install pngquant"
    exit 1
fi

# Créer un backup
echo "📦 Création du backup..."
cp -r assets/images assets/images_backup_$(date +%Y%m%d_%H%M%S)

# Compter les fichiers
total_files=$(find assets/images -name "*.png" | wc -l)
echo "📊 Fichiers PNG trouvés: $total_files"

# Optimiser les PNG
echo "🔧 Compression des PNG..."
find assets/images -name "*.png" -exec pngquant --quality=65-80 --ext .png --force --skip-if-larger {} \;

# Calculer l'économie
original_size=$(du -sh assets/images_backup_* 2>/dev/null | tail -1 | awk '{print $1}')
new_size=$(du -sh assets/images | awk '{print $1}')

echo ""
echo "✅ Optimisation terminée!"
echo "📊 Taille originale: $original_size"
echo "📊 Nouvelle taille: $new_size"
echo ""
echo "💡 Pour restaurer: mv assets/images_backup_* assets/images"
