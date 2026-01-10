# Guide d'intégration MoovMoney - Temps Réel

## 📋 Vue d'ensemble

Ce guide explique comment utiliser les fonctionnalités temps réel pour MoovMoney, incluant:
- Écoute Firebase Realtime Database
- UI dynamique selon le statut
- Notifications push

## 🔥 Firebase Realtime Database

### Structure des données Firebase

```
requests/
  └── {requestId}/
      ├── status: "pending" | "accepted" | "arrived" | "processing" | "completed" | "cancelled" | "failed"
      ├── amount: 5000
      ├── driver_name: "Jean Dupont"
      ├── driver_phone: "+22890123456"
      ├── moov_money_security_code: "123456"
      ├── transaction_id: "TXN123456"
      ├── error_message: "Message d'erreur si applicable"
      └── ... autres champs
```

### Utilisation du service

```dart
import 'package:restart_user/features/moov_money/data/services/moov_money_realtime_service.dart';

// Créer une instance du service
final realtimeService = MoovMoneyRealtimeService();

// Écouter les changements de statut uniquement
realtimeService.listenToRequestStatus(requestId).listen((data) {
  final status = data['status'];
  print('Nouveau statut: $status');
});

// Écouter toutes les données de la demande
realtimeService.listenToRequest(requestId).listen((data) {
  print('Données mises à jour: $data');
  // Mettre à jour l'UI
});

// Avec callback
realtimeService.subscribeToStatusChanges(
  requestId,
  (status, data) {
    print('Statut changé: $status');
    // Mettre à jour l'UI selon le statut
  },
);

// N'oubliez pas de nettoyer
@override
void dispose() {
  realtimeService.dispose();
  super.dispose();
}
```

## 🎨 Widgets de statut

### MoovMoneyStatusWidget

Widget qui affiche automatiquement l'UI appropriée selon le statut:

```dart
import 'package:restart_user/features/moov_money/presentation/widgets/moov_money_status_widget.dart';

MoovMoneyStatusWidget(
  status: 'pending', // ou 'accepted', 'arrived', 'processing', 'completed', etc.
  additionalData: {
    'driver_name': 'Jean Dupont',
    'driver_phone': '+22890123456',
    'moov_money_security_code': '123456',
    'amount': 5000,
    'transaction_id': 'TXN123456',
  },
)
```

### Statuts disponibles

1. **pending** → "Recherche d'un agent..."
   - Affiche un indicateur de chargement
   - Message: "Nous recherchons un agent disponible près de vous"

2. **accepted/assigned** → "Agent trouvé, en route..."
   - Affiche le nom et téléphone de l'agent
   - Message: "{Agent} se dirige vers vous"

3. **arrived** → "Agent arrivé, montrez votre code"
   - Affiche le code de sécurité en grand
   - Message: "Montrez votre code de sécurité à l'agent"

4. **processing/in_progress** → "Transaction en cours..."
   - Affiche un indicateur de chargement
   - Message: "L'agent traite votre demande"

5. **completed** → "✅ Transaction réussie!"
   - Affiche une icône de succès
   - Affiche le montant et l'ID de transaction

6. **cancelled** → Transaction annulée
   - Affiche un message d'annulation

7. **failed** → Transaction échouée
   - Affiche le message d'erreur

## 📱 Notifications Push

### Configuration backend

Le backend doit envoyer des notifications avec cette structure:

```json
{
  "notification": {
    "title": "MoovMoney - Agent trouvé",
    "body": "Jean Dupont se dirige vers vous"
  },
  "data": {
    "notification_type": "moov_money_status_update",
    "status": "accepted",
    "request_id": "REQ123456",
    "driver_name": "Jean Dupont",
    "driver_phone": "+22890123456"
  }
}
```

### Gestion dans l'app

Les notifications sont automatiquement gérées par `app_notification.dart`:

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (message.data['notification_type'] == 'moov_money_status_update') {
    // Afficher notification locale
    showMoovMoneyNotification(message.notification, message.data);
    // L'UI se met à jour automatiquement via Firebase Realtime Database
  }
});
```

### Notifications en arrière-plan

Gérées automatiquement dans `common_setup.dart`:

```dart
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['notification_type'] == 'moov_money_status_update') {
    print('🔥 MoovMoney notification reçue en arrière-plan');
  }
}
```

## 🔄 Flux complet

### 1. Utilisateur crée une demande

```dart
// L'utilisateur soumet une demande de dépôt/retrait
final response = await moovMoneyApi.createRequest(...);
final requestId = response['request_id'];

// Naviguer vers la page de détails
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MoovMoneyRequestDetailsPage(
      requestId: requestId,
      requestData: response['data'],
    ),
  ),
);
```

### 2. Page de détails écoute Firebase

```dart
// Dans MoovMoneyRequestDetailsPage
@override
void initState() {
  super.initState();
  _listenToRealtimeUpdates(); // Démarre l'écoute Firebase
}

void _listenToRealtimeUpdates() {
  _realtimeService.listenToRequest(widget.requestId).listen((data) {
    setState(() {
      _request = {..._request!, ...data};
    });
    _showStatusChangeNotification(data['status']);
  });
}
```

### 3. Backend met à jour Firebase

```javascript
// Côté backend (exemple Node.js)
const admin = require('firebase-admin');

// Quand un agent accepte
await admin.database()
  .ref(`requests/${requestId}`)
  .update({
    status: 'accepted',
    driver_name: 'Jean Dupont',
    driver_phone: '+22890123456',
    assigned_at: new Date().toISOString(),
  });

// Envoyer notification push
await admin.messaging().send({
  token: userFcmToken,
  notification: {
    title: 'Agent trouvé',
    body: 'Jean Dupont se dirige vers vous',
  },
  data: {
    notification_type: 'moov_money_status_update',
    status: 'accepted',
    request_id: requestId,
    driver_name: 'Jean Dupont',
    driver_phone: '+22890123456',
  },
});
```

### 4. App reçoit la mise à jour

- Firebase Realtime Database déclenche le listener
- L'UI se met à jour automatiquement avec le nouveau statut
- Une notification locale s'affiche
- Si l'app est en arrière-plan, une notification push s'affiche

## 🎯 Exemple complet d'utilisation

```dart
import 'package:flutter/material.dart';
import 'package:restart_user/features/moov_money/data/services/moov_money_realtime_service.dart';
import 'package:restart_user/features/moov_money/presentation/widgets/moov_money_status_widget.dart';

class MyMoovMoneyPage extends StatefulWidget {
  final String requestId;
  
  const MyMoovMoneyPage({required this.requestId});
  
  @override
  State<MyMoovMoneyPage> createState() => _MyMoovMoneyPageState();
}

class _MyMoovMoneyPageState extends State<MyMoovMoneyPage> {
  final _realtimeService = MoovMoneyRealtimeService();
  Map<String, dynamic>? _requestData;
  
  @override
  void initState() {
    super.initState();
    
    // Écouter les mises à jour
    _realtimeService.listenToRequest(widget.requestId).listen((data) {
      setState(() {
        _requestData = data;
      });
    });
  }
  
  @override
  void dispose() {
    _realtimeService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_requestData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('MoovMoney')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MoovMoneyStatusWidget(
          status: _requestData!['status'] ?? 'pending',
          additionalData: _requestData,
        ),
      ),
    );
  }
}
```

## 🔐 Sécurité

### Règles Firebase Realtime Database

```json
{
  "rules": {
    "requests": {
      "$requestId": {
        ".read": "auth != null && (
          root.child('requests').child($requestId).child('user_id').val() === auth.uid ||
          root.child('requests').child($requestId).child('driver_id').val() === auth.uid
        )",
        ".write": "auth != null"
      }
    }
  }
}
```

## 📊 Monitoring

Pour déboguer, surveillez les logs:

```dart
// Dans MoovMoneyRealtimeService
print('🔥 Démarrage de l\'écoute Firebase pour requestId: $requestId');
print('🔥 Mise à jour Firebase reçue: ${data['status']}');
print('❌ Erreur Firebase: $error');
```

## 🚀 Prochaines étapes

1. ✅ Écoute Firebase Realtime Database implémentée
2. ✅ UI dynamique selon statut créée
3. ✅ Notifications push configurées
4. 🔄 Tester avec le backend
5. 🔄 Ajouter des animations de transition entre statuts
6. 🔄 Implémenter le tracking GPS de l'agent en temps réel
