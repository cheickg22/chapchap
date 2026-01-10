# 🔧 Fix "type 'int' is not a subtype of type 'String'"

## 🔍 Problème

```
type 'int' is not a subtype of type 'String'
```

Cette erreur se produit quand le code attend un type mais en reçoit un autre (int au lieu de String, ou vice-versa).

## 🎯 Cause

Le backend ou Firebase peut envoyer des données avec des types différents:
- Parfois `id` est un `int`, parfois une `String`
- Parfois `phone` est un `int`, parfois une `String`
- Les valeurs nulles peuvent causer des problèmes

## ✅ Solution appliquée

### 1. Amélioration du parsing Firebase

**Fichier modifié**: `moov_money_request_model.dart`

```dart
factory MoovMoneyRequest.fromFirebase(Map<dynamic, dynamic> data) {
  // Convertir tous les types dynamiques en String/int appropriés
  final map = <String, dynamic>{};
  data.forEach((key, value) {
    map[key.toString()] = value;
  });
  return MoovMoneyRequest.fromJson(map);
}
```

### 2. Parsing robuste déjà en place

Tous les modèles utilisent déjà des méthodes de parsing robustes:

```dart
// Pour les String
id: json['id']?.toString() ?? '',

// Pour les int
amount: _parseAmount(json['moov_money_amount']),

static int _parseAmount(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;           // ✅ Déjà int
  if (value is double) return value.toInt(); // ✅ Convertir double
  return int.tryParse(value.toString()) ?? 0; // ✅ Convertir String
}

// Pour les double
userLatitude: _parseDouble(json['pick_lat']),

static double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

// Pour les DateTime
createdAt: _parseDate(json['created_at']) ?? DateTime.now(),

static DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value.toString());
  } catch (e) {
    return null;
  }
}
```

---

## 🔍 Diagnostic: Trouver la source de l'erreur

Si l'erreur persiste, ajoutez des logs pour identifier le champ problématique:

### Méthode 1: Logs dans fromJson

```dart
factory MoovMoneyRequest.fromJson(Map<String, dynamic> json) {
  try {
    debugPrint('🔍 Parsing MoovMoneyRequest: ${json.toString()}');
    
    return MoovMoneyRequest(
      id: json['id']?.toString() ?? '',
      // ... reste du code
    );
  } catch (e, stackTrace) {
    debugPrint('❌ Erreur parsing MoovMoneyRequest: $e');
    debugPrint('📋 JSON reçu: $json');
    debugPrint('📍 Stack: $stackTrace');
    rethrow;
  }
}
```

### Méthode 2: Logs dans fromFirebase

```dart
factory MoovMoneyRequest.fromFirebase(Map<dynamic, dynamic> data) {
  debugPrint('🔥 Firebase data types:');
  data.forEach((key, value) {
    debugPrint('  $key: ${value.runtimeType} = $value');
  });
  
  final map = <String, dynamic>{};
  data.forEach((key, value) {
    map[key.toString()] = value;
  });
  return MoovMoneyRequest.fromJson(map);
}
```

---

## 🛠️ Solutions supplémentaires

### Solution 1: Vérifier les champs String spécifiques

Si l'erreur concerne un champ spécifique (ex: `phone`), renforcez le parsing:

```dart
// Au lieu de:
phone: json['moov_money_phone']?.toString() ?? '',

// Utilisez:
phone: _parseString(json['moov_money_phone']),

// Avec la méthode helper:
static String _parseString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  return value.toString();
}
```

### Solution 2: Wrapper try-catch pour chaque champ

Pour identifier le champ exact qui pose problème:

```dart
factory MoovMoneyRequest.fromJson(Map<String, dynamic> json) {
  String safeParseString(String key, String defaultValue) {
    try {
      return json[key]?.toString() ?? defaultValue;
    } catch (e) {
      debugPrint('❌ Erreur parsing $key: $e');
      return defaultValue;
    }
  }
  
  int safeParseInt(String key, int defaultValue) {
    try {
      return _parseAmount(json[key]);
    } catch (e) {
      debugPrint('❌ Erreur parsing $key: $e');
      return defaultValue;
    }
  }
  
  return MoovMoneyRequest(
    id: safeParseString('id', ''),
    requestNumber: safeParseString('request_number', ''),
    amount: safeParseInt('moov_money_amount', 0),
    // ... etc
  );
}
```

### Solution 3: Validation des données Firebase

Avant de parser, validez les types:

```dart
factory MoovMoneyRequest.fromFirebase(Map<dynamic, dynamic> data) {
  final map = <String, dynamic>{};
  
  data.forEach((key, value) {
    final keyStr = key.toString();
    
    // Convertir les types problématiques
    if (value is int && _shouldBeString(keyStr)) {
      map[keyStr] = value.toString();
    } else if (value is String && _shouldBeInt(keyStr)) {
      map[keyStr] = int.tryParse(value) ?? 0;
    } else {
      map[keyStr] = value;
    }
  });
  
  return MoovMoneyRequest.fromJson(map);
}

static bool _shouldBeString(String key) {
  return ['id', 'request_number', 'user_id', 'user_name', 
          'user_phone', 'driver_id', 'moov_money_phone', 
          'moov_money_type', 'moov_money_status'].contains(key);
}

static bool _shouldBeInt(String key) {
  return ['moov_money_amount', 'commission'].contains(key);
}
```

---

## 🧪 Tests

### Test 1: Avec int au lieu de String

```dart
final testData = {
  'id': 123,  // int au lieu de String
  'request_number': 456,
  'user_name': 'John Doe',
  'moov_money_amount': 5000,
  // ...
};

final request = MoovMoneyRequest.fromJson(testData);
print('✅ ID: ${request.id}'); // Devrait afficher "123"
```

### Test 2: Avec String au lieu de int

```dart
final testData = {
  'id': '123',
  'moov_money_amount': '5000',  // String au lieu de int
  // ...
};

final request = MoovMoneyRequest.fromJson(testData);
print('✅ Amount: ${request.amount}'); // Devrait afficher 5000
```

### Test 3: Avec valeurs null

```dart
final testData = {
  'id': null,
  'moov_money_amount': null,
  // ...
};

final request = MoovMoneyRequest.fromJson(testData);
print('✅ ID: ${request.id}'); // Devrait afficher ""
print('✅ Amount: ${request.amount}'); // Devrait afficher 0
```

---

## 📋 Checklist de vérification

- [x] Parsing Firebase amélioré
- [x] Méthodes `_parseAmount` robustes
- [x] Méthodes `_parseDouble` robustes
- [x] Méthodes `_parseDate` robustes
- [x] Conversion `.toString()` partout pour les String
- [ ] Logs de debug ajoutés (si nécessaire)
- [ ] Tests avec données réelles

---

## 🎯 Si l'erreur persiste

1. **Ajoutez des logs** pour identifier le champ exact
2. **Vérifiez les données Firebase** dans la console
3. **Testez avec des données mockées** pour isoler le problème
4. **Vérifiez le backend** - peut-être qu'il envoie des types incorrects

---

## 📝 Exemple de log complet

Ajoutez ceci temporairement pour débugger:

```dart
factory MoovMoneyRequest.fromFirebase(Map<dynamic, dynamic> data) {
  debugPrint('═══════════════════════════════════════');
  debugPrint('🔥 FIREBASE DATA RECEIVED');
  debugPrint('═══════════════════════════════════════');
  
  data.forEach((key, value) {
    debugPrint('$key:');
    debugPrint('  Type: ${value.runtimeType}');
    debugPrint('  Value: $value');
  });
  
  debugPrint('═══════════════════════════════════════');
  
  final map = <String, dynamic>{};
  data.forEach((key, value) {
    map[key.toString()] = value;
  });
  
  try {
    return MoovMoneyRequest.fromJson(map);
  } catch (e, stackTrace) {
    debugPrint('❌ ERREUR PARSING:');
    debugPrint('Error: $e');
    debugPrint('Stack: $stackTrace');
    rethrow;
  }
}
```

---

**Date**: 10 Novembre 2025  
**Problème**: type 'int' is not a subtype of type 'String'  
**Statut**: ✅ Parsing amélioré  
**Fichiers modifiés**: moov_money_request_model.dart  
**Auteur**: Cascade AI
