# Plan d'Optimisation ChapChap Driver

## 📊 Analyse Actuelle

### Taille des Assets : **11 MB**

#### Images les plus lourdes (>200KB) :
- `login_as.png` - 782KB
- `no_faq_image.png` - 711KB
- `diagnostic_init.png` - 673KB
- `support_empty.png` - 551KB
- `bottomBackground.png` - 383KB
- `customBg.png` - 320KB
- `logo.png` / `loader_image.png` / `icon.png` - 246KB chacun
- `delivery_splash.png` - 241KB
- `Luxury.png` - 233KB
- `noSubscription.png` - 228KB
- `unionPay.png` - 222KB
- `diagnostic_alert.png` - 222KB
- `Premium.png` - 204KB
- `SUV.png` - 198KB

#### Fichiers audio :
- `request_sound.mp3` - 172KB
- `paiement.mp3` - 57KB
- `ended.mp3` - 56KB
- `started.mp3` - 55KB

### Packages Lourds Identifiés :

#### ❌ Packages INUTILISÉS (à supprimer) :
1. **firebase_auth** (5.5.0) - Non utilisé (seulement 1 import mort)
2. **firebase_crashlytics** (4.3.3) - Non utilisé (seulement 1 import)
3. **flutter_stripe** (11.4.0) - Utilisé 3 fois seulement
4. **change_app_package_name** (1.5.0) - Outil dev uniquement
5. **avatar_glow** (3.0.1) - Effet visuel non essentiel
6. **flutter_html** (3.0.0) - Utilisé 1 fois seulement

#### ⚠️ Packages LOURDS mais nécessaires :
1. **google_fonts** (6.2.1) - Télécharge fonts à la volée (~5MB)
2. **google_maps_flutter** (2.10.1) - Nécessaire mais lourd
3. **flutter_map** (8.0.0) - Alternative à Google Maps (doublon?)
4. **firebase_database** (11.3.3) - Nécessaire pour temps réel
5. **firebase_messaging** (15.2.3) - Nécessaire pour notifications

## 🎯 Plan d'Optimisation (Gain estimé : 30-50%)

### Phase 1 : Suppression Packages Inutilisés ✅ (-15MB)

**Packages à supprimer** :
- firebase_auth
- firebase_crashlytics
- flutter_stripe
- change_app_package_name
- avatar_glow
- flutter_html

**Gain estimé** : ~15 MB

### Phase 2 : Optimisation Images ✅ (-5MB)

**Actions** :
1. Compresser toutes les PNG >200KB avec TinyPNG
2. Convertir les PNG non-transparentes en JPEG
3. Utiliser WebP pour les images modernes
4. Supprimer les images dupliquées (logo/icon/loader)

**Gain estimé** : ~5 MB

### Phase 3 : Remplacement Google Fonts ✅ (-3MB)

**Action** :
- Remplacer `google_fonts` par fonts locales
- Inclure uniquement les fonts utilisées
- Utiliser fonts système quand possible

**Gain estimé** : ~3 MB

### Phase 4 : Configuration Build Android ✅ (-20MB)

**Actions** :
1. Activer ProGuard/R8 (minification)
2. Activer split-per-abi (APK par architecture)
3. Activer shrinkResources
4. Désactiver Compose (non utilisé)

**Gain estimé** : ~20 MB par APK

### Phase 5 : Optimisation Firebase ✅ (-5MB)

**Actions** :
1. Supprimer firebase_auth et crashlytics
2. Garder uniquement database + messaging
3. Utiliser le mode Mali optimisé (déjà fait)

**Gain estimé** : ~5 MB

### Phase 6 : Nettoyage Maps ✅ (-10MB)

**Action** :
- Choisir entre google_maps_flutter OU flutter_map
- Supprimer l'alternative non utilisée
- Recommandation : Garder google_maps_flutter

**Gain estimé** : ~10 MB

## 📈 Résultat Attendu

| Composant | Avant | Après | Gain |
|-----------|-------|-------|------|
| APK Release | ~80MB | ~40-50MB | -40% |
| Assets | 11MB | 6MB | -45% |
| Packages | 45+ | 35 | -22% |
| Code mort | Oui | Non | - |

## 🚀 Ordre d'Exécution Recommandé

1. ✅ **Supprimer packages inutilisés** (5 min)
2. ✅ **Configurer build.gradle** (5 min)
3. ✅ **Optimiser images** (15 min)
4. ⚠️ **Remplacer Google Fonts** (optionnel, 30 min)
5. ⚠️ **Choisir une solution Maps** (optionnel, 10 min)

## ⚡ Actions Immédiates (Gain rapide)

### 1. Supprimer Packages Inutilisés
```yaml
# À SUPPRIMER de pubspec.yaml :
# firebase_auth: ^5.5.0
# firebase_crashlytics: ^4.3.3
# flutter_stripe: ^11.4.0
# change_app_package_name: ^1.5.0
# avatar_glow: ^3.0.1
# flutter_html: ^3.0.0
```

### 2. Configurer ProGuard
```gradle
// Dans android/app/build.gradle.kts
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(...)
    }
}
```

### 3. Activer Split APK
```gradle
android {
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
            isUniversalApk = false
        }
    }
}
```

## 🔍 Détails Techniques

### Packages à Garder (Essentiels)

**Firebase** :
- ✅ firebase_core (nécessaire)
- ✅ firebase_database (temps réel)
- ✅ firebase_messaging (notifications)
- ❌ firebase_auth (inutilisé)
- ❌ firebase_crashlytics (inutilisé)

**Maps & Location** :
- ✅ google_maps_flutter (principal)
- ⚠️ flutter_map (doublon? vérifier usage)
- ✅ geolocator (nécessaire)
- ✅ geocoding (nécessaire)
- ✅ location (nécessaire)

**UI & Widgets** :
- ✅ google_fonts (à remplacer par fonts locales)
- ✅ cached_network_image (optimisation)
- ✅ flutter_svg (léger)
- ❌ avatar_glow (effet non essentiel)

**Paiement** :
- ❌ flutter_stripe (3 usages seulement, à évaluer)

### Images à Optimiser en Priorité

1. **login_as.png** (782KB) → Compresser à ~150KB
2. **no_faq_image.png** (711KB) → Compresser à ~150KB
3. **diagnostic_init.png** (673KB) → Compresser à ~150KB
4. **support_empty.png** (551KB) → Compresser à ~120KB
5. **bottomBackground.png** (383KB) → Convertir en JPEG ou WebP

### Commandes d'Optimisation

```bash
# Compresser toutes les PNG
find assets/images -name "*.png" -exec pngquant --quality=65-80 --ext .png --force {} \;

# Analyser la taille de l'APK
flutter build apk --analyze-size

# Build avec split-per-abi
flutter build apk --split-per-abi --release

# Vérifier les packages inutilisés
flutter pub deps --no-dev | grep -E "^\w"
```

## 📱 Impact Utilisateur

### Avant Optimisation :
- Taille APK : ~80MB
- Téléchargement 4G : ~2 minutes
- Installation : ~150MB
- Première ouverture : 5-8 secondes

### Après Optimisation :
- Taille APK : ~40-50MB (-40%)
- Téléchargement 4G : ~1 minute (-50%)
- Installation : ~80MB (-45%)
- Première ouverture : 3-5 secondes (-40%)

## ⚠️ Précautions

1. **Tester après chaque modification**
2. **Garder une sauvegarde du pubspec.yaml**
3. **Vérifier que Stripe n'est pas critique**
4. **Tester sur device réel après optimisation**
5. **Vérifier que flutter_map n'est pas utilisé**

## 🎯 Prochaines Étapes

1. Appliquer Phase 1 (packages)
2. Tester l'application
3. Appliquer Phase 4 (build config)
4. Builder et mesurer
5. Appliquer Phase 2 (images) si nécessaire
