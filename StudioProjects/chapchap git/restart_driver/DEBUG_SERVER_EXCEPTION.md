# 🐛 Debug: ServerException - Chargement Détails Moov Money

## 📋 Erreur Observée

```
I/flutter: ❌ Erreur chargement détails: Instance of 'ServerException'
I/flutter: 🔍 Chargement des détails pour requestId: 79eacccb-df7f-488b-b71c-29b3e718b1d5
I/flutter: dio get error DioException [connection error]: Failed host lookup: 'chapchap-livraison.com'
```

## 🔍 Causes Possibles

### 1. Problème de Connexion Réseau
```
Failed host lookup: 'chapchap-livraison.com'
SocketException: Failed host lookup (OS Error: No address associated with hostname, errno = 7)
```

**Signification:** Le téléphone ne peut pas résoudre le nom de domaine.

### 2. Problème Backend
- Routes API non accessibles
- Erreur 500 sur le serveur
- Relation `driver` non corrigée

---

## ✅ Solutions à Vérifier

### Solution 1: Vérifier la Connexion

**Sur le téléphone:**
- [ ] WiFi/4G activé?
- [ ] Connexion Internet fonctionne?
- [ ] Peut accéder à d'autres sites?

**Test:**
```bash
# Sur votre ordinateur
ping chapchap-livraison.com

# Devrait répondre
```

### Solution 2: Vérifier le Backend

**A. Vérifier que le fichier corrigé est sur le serveur**

```bash
# Se connecter au serveur
ssh root@srv671145

# Vérifier la syntaxe
cd /var/www/html/chapchap
php -l app/Http/Controllers/Api/V1/Request/MoovMoneyRequestController.php

# Devrait afficher: No syntax errors detected
```

**B. Vérifier les routes**

```bash
# Sur le serveur
cd /var/www/html/chapchap
php artisan route:list | grep moov-money

# Devrait afficher:
# GET|HEAD  api/v1/moov-money/my-requests
# GET|HEAD  api/v1/moov-money/requests/{id}
```

**C. Vider le cache**

```bash
# Sur le serveur
cd /var/www/html/chapchap
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### Solution 3: Tester l'API Manuellement

**Test avec curl:**

```bash
# Remplacer {token} par un vrai token
curl -X GET "https://chapchap.ml/api/v1/moov-money/requests/79eacccb-df7f-488b-b71c-29b3e718b1d5" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json" \
  -v

# Vérifier:
# - Status 200 (pas 500)
# - Retourne JSON (pas HTML)
# - Contient les données de la demande
```

**Si erreur 500:**
```bash
# Vérifier les logs Laravel
tail -f /var/www/html/chapchap/storage/logs/laravel.log

# Rechercher l'erreur exacte
```

### Solution 4: Vérifier le Fichier sur le Serveur

**Le fichier `MoovMoneyRequestController.php` doit avoir les corrections:**

```bash
# Sur le serveur
cd /var/www/html/chapchap
grep -n "driverDetail" app/Http/Controllers/Api/V1/Request/MoovMoneyRequestController.php

# Devrait afficher les lignes avec 'driverDetail' (pas 'driver')
# Lignes attendues: 523, 544, 690, 734
```

**Si 'driver' apparaît encore:**
```bash
# Le fichier n'a pas été mis à jour
# Recopier depuis votre machine locale:

# Sur votre machine
cd /Users/geilanyabdatykounta/StudioProjects/chapchap
scp app/Http/Controllers/Api/V1/Request/MoovMoneyRequestController.php \
  root@srv671145:/var/www/html/chapchap/app/Http/Controllers/Api/V1/Request/

# Puis sur le serveur
ssh root@srv671145
cd /var/www/html/chapchap
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

---

## 🔍 Debug Détaillé

### Étape 1: Identifier l'Endpoint Appelé

**Dans l'app Flutter (restart_user):**

Chercher dans les logs:
```
🌐 URL: api/v1/moov-money/requests/{id}
```

**Vérifier que c'est le bon endpoint:**
- ✅ `/api/v1/moov-money/requests/{id}` (correct)
- ❌ `/api/v1/request/moov-money/...` (incorrect - retourne HTML)

### Étape 2: Vérifier la Réponse du Serveur

**Ajouter plus de logs dans Flutter:**

```dart
// Dans moov_money_remote_datasource.dart
Future<MoovMoneyRequest> getRequestDetails(String id) async {
  try {
    final url = '$_baseUrl/requests/$id';
    debugPrint('🌐 URL complète: $url');
    
    final response = await dio.get(url);
    
    debugPrint('📡 Status: ${response.statusCode}');
    debugPrint('📦 Data type: ${response.data.runtimeType}');
    debugPrint('📦 Data: ${response.data}');
    
    // ...
  } catch (e) {
    debugPrint('❌ Erreur détaillée: $e');
    rethrow;
  }
}
```

### Étape 3: Vérifier le Token

```dart
// Le token est-il valide?
debugPrint('🔐 Token: Bearer ${token.substring(0, 20)}...');
```

---

## 🧪 Tests à Effectuer

### Test 1: Connexion Internet

```bash
# Sur le téléphone
# Ouvrir navigateur → Aller sur https://chapchap.ml
# Devrait charger la page
```

### Test 2: API Accessible

```bash
# Sur votre ordinateur
curl https://chapchap.ml/api/v1/moov-money/my-requests \
  -H "Authorization: Bearer {token}"

# Devrait retourner JSON
```

### Test 3: Backend Logs

```bash
# Sur le serveur
tail -f /var/www/html/chapchap/storage/logs/laravel.log

# Puis dans l'app, recharger la page
# Observer les erreurs dans les logs
```

---

## 📊 Checklist de Résolution

- [ ] **Connexion Internet:** Téléphone connecté
- [ ] **DNS:** `chapchap-livraison.com` résolvable
- [ ] **Backend:** Fichier `MoovMoneyRequestController.php` corrigé sur serveur
- [ ] **Cache:** Laravel cache vidé
- [ ] **Routes:** Routes `/api/v1/moov-money/*` existent
- [ ] **Syntaxe:** Pas d'erreur PHP sur le serveur
- [ ] **Logs:** Pas d'erreur 500 dans `laravel.log`
- [ ] **API:** Test curl retourne JSON (pas HTML)

---

## 🚨 Actions Immédiates

### 1. Vérifier le Backend (PRIORITÉ)

```bash
# Sur le serveur
ssh root@srv671145
cd /var/www/html/chapchap

# Vérifier syntaxe
php -l app/Http/Controllers/Api/V1/Request/MoovMoneyRequestController.php

# Si erreur, recopier le fichier
exit

# Sur votre machine
scp app/Http/Controllers/Api/V1/Request/MoovMoneyRequestController.php \
  root@srv671145:/var/www/html/chapchap/app/Http/Controllers/Api/V1/Request/

# Retour sur serveur
ssh root@srv671145
cd /var/www/html/chapchap
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

### 2. Tester l'API

```bash
# Obtenir un token depuis l'app ou la DB
# Puis tester:
curl -X GET "https://chapchap.ml/api/v1/moov-money/requests/79eacccb-df7f-488b-b71c-29b3e718b1d5" \
  -H "Authorization: Bearer {VOTRE_TOKEN}" \
  -H "Accept: application/json"
```

### 3. Vérifier les Logs

```bash
# Sur le serveur
tail -100 /var/www/html/chapchap/storage/logs/laravel.log

# Rechercher l'erreur exacte
```

---

## ✅ Résultat Attendu

Après corrections:
- ✅ API retourne JSON (status 200)
- ✅ Pas d'erreur dans les logs
- ✅ App charge les détails correctement
- ✅ Pas de `ServerException`

---

**Date:** 10 novembre 2025  
**Status:** Guide de debug créé ✅  
**Action:** Vérifier backend en priorité
