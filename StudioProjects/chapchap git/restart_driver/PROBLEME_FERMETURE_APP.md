# Problème : L'Application se Ferme en Arrière-Plan

## 🔍 Diagnostic

Quand vous passez à une autre application, ChapChap se ferme. C'est causé par :

### Causes Principales

1. **Android tue l'app pour libérer de la mémoire** (Low Memory Killer)
2. **État de l'app non sauvegardé** (perte des données en cours)
3. **Services en arrière-plan mal configurés**
4. **Utilisation excessive de mémoire**

## ✅ Solutions Implémentées

### Solution 1 : Augmenter la Priorité de l'App

**Fichier** : `android/app/src/main/AndroidManifest.xml`

Ajouter dans `<application>` :

```xml
<application
    android:largeHeap="true"
    android:hardwareAccelerated="true"
    android:persistent="false">
    
    <!-- Service pour maintenir l'app en vie -->
    <service
        android:name="id.flutter.flutter_background_service.BackgroundService"
        android:exported="false"
        android:foregroundServiceType="location" />
</application>
```

### Solution 2 : Sauvegarder l'État de l'App

Créer un service de sauvegarde d'état :

```dart
// lib/core/services/app_state_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppStateService {
  static const String _stateKey = 'app_state';
  
  /// Sauvegarder l'état actuel de l'app
  static Future<void> saveState(Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, jsonEncode(state));
    print('💾 État sauvegardé');
  }
  
  /// Restaurer l'état de l'app
  static Future<Map<String, dynamic>?> restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString(_stateKey);
    
    if (stateJson != null) {
      print('📂 État restauré');
      return jsonDecode(stateJson);
    }
    
    return null;
  }
  
  /// Effacer l'état sauvegardé
  static Future<void> clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stateKey);
  }
}
```

### Solution 3 : Gérer le Cycle de Vie de l'App

Modifier le `main.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Observer le cycle de vie
    WidgetsBinding.instance.addObserver(this);
    
    // Restaurer l'état au démarrage
    _restoreAppState();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('✅ App au premier plan');
        _restoreAppState();
        break;
        
      case AppLifecycleState.inactive:
        print('⏸️ App inactive');
        break;
        
      case AppLifecycleState.paused:
        print('⏸️ App en arrière-plan');
        _saveAppState();
        break;
        
      case AppLifecycleState.detached:
        print('🛑 App fermée');
        _saveAppState();
        break;
        
      case AppLifecycleState.hidden:
        print('👁️ App cachée');
        break;
    }
  }
  
  Future<void> _saveAppState() async {
    // Sauvegarder l'état actuel
    final state = {
      'timestamp': DateTime.now().toIso8601String(),
      'currentRoute': Navigator.of(context).currentRoute,
      // Ajouter d'autres données importantes
    };
    
    await AppStateService.saveState(state);
  }
  
  Future<void> _restoreAppState() async {
    final state = await AppStateService.restoreState();
    
    if (state != null) {
      // Restaurer l'état
      print('📂 Restauration de l\'état : $state');
      // Naviguer vers la dernière route, etc.
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
    );
  }
}
```

### Solution 4 : Optimiser l'Utilisation Mémoire

**Configuration Android** :

```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Bundle

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Garder l'activité en vie
        window.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
    
    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        
        when (level) {
            TRIM_MEMORY_RUNNING_LOW -> {
                // Libérer les caches non essentiels
                println("⚠️ Mémoire faible - nettoyage")
            }
            TRIM_MEMORY_RUNNING_CRITICAL -> {
                // Libérer le maximum de mémoire
                println("🚨 Mémoire critique - nettoyage agressif")
                flutterEngine?.dartExecutor?.binaryMessenger?.let {
                    // Nettoyer les caches
                }
            }
        }
    }
}
```

### Solution 5 : Service de Localisation en Arrière-Plan

Pour l'app driver qui doit rester active :

```dart
// lib/core/services/background_location_service.dart
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundLocationService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'chapchap_driver_location',
        initialNotificationTitle: 'ChapChap Driver',
        initialNotificationContent: 'Service de localisation actif',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    
    service.startService();
  }
  
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Service en arrière-plan
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });
      
      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }
    
    // Mettre à jour la position toutes les 10 secondes
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
    
    // Boucle de mise à jour de position
    Timer.periodic(Duration(seconds: 10), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          // Obtenir la position
          final position = await Geolocator.getCurrentPosition();
          
          // Mettre à jour la notification
          service.setForegroundNotificationInfo(
            title: "ChapChap Driver",
            content: "Position: ${position.latitude}, ${position.longitude}",
          );
          
          // Envoyer au serveur
          // await updateLocationToServer(position);
        }
      }
    });
  }
  
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }
}
```

### Solution 6 : Notification Permanente (Driver)

```dart
// lib/core/services/foreground_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ForegroundService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static Future<void> startForegroundService() async {
    const androidDetails = AndroidNotificationDetails(
      'chapchap_foreground',
      'Service ChapChap',
      channelDescription: 'Service actif en arrière-plan',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true, // Ne peut pas être fermée par l'utilisateur
      autoCancel: false,
      playSound: false,
      enableVibration: false,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    
    await _notifications.show(
      888,
      'ChapChap Driver',
      'En ligne - Prêt à recevoir des courses',
      notificationDetails,
    );
  }
  
  static Future<void> stopForegroundService() async {
    await _notifications.cancel(888);
  }
  
  static Future<void> updateNotification(String message) async {
    const androidDetails = AndroidNotificationDetails(
      'chapchap_foreground',
      'Service ChapChap',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    
    await _notifications.show(
      888,
      'ChapChap Driver',
      message,
      notificationDetails,
    );
  }
}
```

## 🔧 Configuration AndroidManifest.xml

Ajouter les permissions nécessaires :

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissions pour service en arrière-plan -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
    
    <application
        android:largeHeap="true"
        android:hardwareAccelerated="true">
        
        <!-- Service de localisation -->
        <service
            android:name="id.flutter.flutter_background_service.BackgroundService"
            android:exported="false"
            android:foregroundServiceType="location" />
    </application>
</manifest>
```

## 📊 Checklist de Résolution

### Priorité HAUTE 🔴
- [ ] Ajouter `android:largeHeap="true"` dans AndroidManifest.xml
- [ ] Implémenter AppStateService pour sauvegarder/restaurer l'état
- [ ] Ajouter WidgetsBindingObserver dans main.dart
- [ ] Configurer le service en arrière-plan (driver uniquement)

### Priorité MOYENNE 🟡
- [ ] Optimiser l'utilisation mémoire (libérer caches)
- [ ] Ajouter notification permanente (driver)
- [ ] Implémenter onTrimMemory dans MainActivity
- [ ] Tester sur différents appareils

### Priorité BASSE 🟢
- [ ] Ajouter logs pour diagnostiquer les fermetures
- [ ] Optimiser les images en mémoire
- [ ] Réduire les listeners actifs

## 🧪 Tests

### Test 1 : Vérifier la Sauvegarde d'État
```dart
// Tester la sauvegarde/restauration
await AppStateService.saveState({'test': 'value'});
final state = await AppStateService.restoreState();
print('État restauré: $state');
```

### Test 2 : Simuler Mémoire Faible
```bash
# Via ADB
adb shell am send-trim-memory com.chapchap_livraison.driver RUNNING_LOW
```

### Test 3 : Vérifier le Service en Arrière-Plan
```bash
# Lister les services actifs
adb shell dumpsys activity services | grep chapchap
```

## 📱 Comportement Attendu

### Avant
- ❌ App se ferme quand on passe à une autre app
- ❌ Perte de l'état en cours
- ❌ Driver perd sa position

### Après
- ✅ App reste en mémoire plus longtemps
- ✅ État sauvegardé et restauré automatiquement
- ✅ Service de localisation continue (driver)
- ✅ Notification permanente (driver)

## ⚠️ Notes Importantes

1. **largeHeap** : Permet d'utiliser plus de mémoire (mais Android peut quand même tuer l'app)
2. **Foreground Service** : Nécessaire pour driver, notification obligatoire
3. **Battery Optimization** : Demander à l'utilisateur de désactiver pour ChapChap
4. **Sauvegarde d'État** : Critique pour ne pas perdre les données

## 🎯 Actions Immédiates

1. **Modifier AndroidManifest.xml** (5 min)
2. **Créer AppStateService** (10 min)
3. **Ajouter WidgetsBindingObserver** (10 min)
4. **Tester sur device réel** (15 min)

---

**Résultat attendu** : L'app reste active plus longtemps et restaure son état si elle est fermée.
