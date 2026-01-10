# 🔧 Fix DNS "Failed host lookup" pour Moov Money

## 🔍 Problème

```
DioException [connection error]: Failed host lookup: 'chapchap-livraison.com'
SocketException: Failed host lookup (OS Error: No address associated with hostname, errno = 7)
```

## ✅ Le domaine fonctionne

Le domaine `chapchap-livraison.com` est accessible et répond correctement:
- IP: `46.202.171.118`
- Ping: ✅ Réussi
- API: ✅ Répond (401 Unauthorized normal sans token)

## 🎯 Cause

Le problème vient du **téléphone/émulateur** qui ne peut pas résoudre le DNS, pas du serveur.

---

## 🔧 Solutions

### Solution 1: Redémarrer l'émulateur/téléphone

**Pour émulateur Android**:
```bash
# Arrêter l'émulateur
adb emu kill

# Redémarrer
flutter run
```

**Pour téléphone physique**:
- Redémarrer le téléphone
- Vérifier que le WiFi/4G est activé
- Tester avec un navigateur si Internet fonctionne

---

### Solution 2: Vider le cache DNS de l'émulateur

**Pour émulateur Android**:
```bash
# Se connecter à l'émulateur
adb shell

# Vider le cache DNS
su
ndc resolver flushdefaultif
exit
exit
```

---

### Solution 3: Changer les DNS de l'émulateur

**Pour émulateur Android**:

1. Ouvrir les paramètres de l'émulateur
2. Aller dans **Réseau et Internet** > **WiFi**
3. Appuyer longuement sur le réseau connecté
4. Sélectionner **Modifier le réseau**
5. Options avancées > **Paramètres IP** > **Statique**
6. DNS 1: `8.8.8.8` (Google DNS)
7. DNS 2: `8.8.4.4` (Google DNS alternatif)
8. Sauvegarder

---

### Solution 4: Utiliser l'IP directement (temporaire)

Si le DNS ne fonctionne toujours pas, utilisez l'IP directement:

**Modifier `app_constants.dart`**:

```dart
class AppConstants {
  // Temporaire: utiliser l'IP au lieu du domaine
  static const String baseUrl = 'http://46.202.171.118/';
  
  // OU si HTTPS est requis, garder le domaine mais ajouter un fallback
  static const String baseUrl = 'https://www.chapchap-livraison.com/';
}
```

⚠️ **Attention**: Cette solution est temporaire car:
- L'IP peut changer
- Les certificats SSL ne fonctionneront pas avec l'IP
- Ce n'est pas une solution de production

---

### Solution 5: Configurer le proxy de l'émulateur

**Pour émulateur Android**:

```bash
# Démarrer l'émulateur avec DNS personnalisé
emulator -avd <nom_avd> -dns-server 8.8.8.8,8.8.4.4
```

---

### Solution 6: Vérifier les permissions réseau

**Dans `AndroidManifest.xml`**:

```xml
<manifest>
    <!-- Vérifier que ces permissions existent -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application
        android:usesCleartextTraffic="true"  <!-- Si HTTP nécessaire -->
        ...
    >
    </application>
</manifest>
```

---

### Solution 7: Ajouter une configuration réseau (Android)

**Créer `android/app/src/main/res/xml/network_security_config.xml`**:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
    
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">chapchap-livraison.com</domain>
        <domain includeSubdomains="true">www.chapchap-livraison.com</domain>
    </domain-config>
</network-security-config>
```

**Puis dans `AndroidManifest.xml`**:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...
>
</application>
```

---

### Solution 8: Tester avec un autre réseau

- Passer du WiFi à la 4G (ou inversement)
- Tester avec un hotspot mobile
- Vérifier si un firewall/proxy bloque l'accès

---

## 🧪 Tests de diagnostic

### Test 1: Vérifier la connexion Internet

```bash
# Sur l'émulateur
adb shell ping -c 3 8.8.8.8
```

Si ça ne fonctionne pas → Problème de connexion Internet

### Test 2: Vérifier la résolution DNS

```bash
# Sur l'émulateur
adb shell nslookup chapchap-livraison.com
```

Si ça ne fonctionne pas → Problème DNS

### Test 3: Vérifier l'accès au serveur

```bash
# Sur l'émulateur
adb shell curl -I https://www.chapchap-livraison.com/
```

Si ça ne fonctionne pas → Problème de connexion au serveur

---

## 📱 Pour téléphone physique

### Vérifications:
1. ✅ WiFi/4G activé
2. ✅ Mode avion désactivé
3. ✅ Pas de VPN actif qui bloque
4. ✅ Pas de restriction de données pour l'app
5. ✅ Autorisation Internet accordée

### Paramètres DNS (WiFi):
1. Paramètres > WiFi
2. Appuyer longuement sur le réseau
3. Modifier le réseau
4. Options avancées
5. DNS 1: `8.8.8.8`
6. DNS 2: `8.8.4.4`

---

## 🎯 Solution recommandée

**Ordre de priorité**:

1. **Redémarrer l'émulateur/téléphone** (le plus simple)
2. **Changer les DNS** vers Google DNS (8.8.8.8)
3. **Vider le cache DNS** de l'émulateur
4. **Vérifier les permissions** réseau
5. **Tester avec un autre réseau**

---

## 📊 Vérification que c'est résolu

Après avoir appliqué une solution, vous devriez voir dans les logs:

```
✅ Au lieu de:
I/flutter: dio get error DioException [connection error]: Failed host lookup

✅ Vous devriez voir:
I/flutter: 🔐 Token: Bearer 315|o93dYyzqx...
I/flutter: ✅ Requête réussie
```

---

## 🆘 Si rien ne fonctionne

Contactez votre administrateur réseau pour vérifier:
- Firewall qui bloque `chapchap-livraison.com`
- Proxy qui interfère
- Restrictions DNS

---

**Date**: 10 Novembre 2025  
**Problème**: DNS Failed host lookup  
**Statut**: ✅ Domaine fonctionne, problème sur l'appareil  
**IP du serveur**: 46.202.171.118  
**Auteur**: Cascade AI
