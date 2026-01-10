## 🔄 Workflow Complet d'Acceptation des Requêtes Moov Money

## 📋 Vue d'ensemble

Système complet de gestion des requêtes Moov Money pour les drivers, incluant l'écoute Firebase, l'acceptation/refus, et le traitement des dépôts et retraits.

---

## 🎯 Flux complet

```
1. Backend crée une requête Moov Money
   ↓
2. Requête ajoutée dans Firebase (request-meta + requests)
   ↓
3. Driver reçoit notification via MoovMoneyNotificationHandler
   ↓
4. Driver voit la requête et ouvre MoovMoneyRequestDetailsPage
   ↓
5. Driver accepte ou refuse la requête
   ↓
6a. Si ACCEPTÉ → Navigation vers page de traitement
   ↓
7a. DÉPÔT: Génération code sécurité → Client valide
   ↓
8a. Firebase notifie complétion → Retour automatique
   
6b. Si REFUSÉ → Requête annulée avec raison
   ↓
7b. RETRAIT: Driver entre code client → Validation
   ↓
8b. Firebase notifie complétion → Retour automatique
```

---

## 📦 Fichiers créés

### 1. Modèles (Domain Layer)

✅ **`moov_money_request_model.dart`**
```dart
class MoovMoneyRequest {
  final String id;
  final String requestNumber;
  final String userId;
  final String userName;
  final String userPhone;
  final String type; // 'deposit' ou 'withdrawal'
  final int amount;
  final String phone;
  final String status;
  final String? securityCode;
  final int? commission;
  // ... autres champs
}
```

**Getters utiles**:
- `isDeposit` / `isWithdrawal`
- `isPending` / `isAccepted` / `isProcessing` / `isCompleted` / `isCancelled`
- `typeLabel` / `statusLabel`

### 2. Services

✅ **`moov_money_notification_handler.dart`**
- Écoute les nouvelles requêtes via Firebase
- Callbacks pour nouvelle requête, mise à jour, annulation
- Méthodes: `listenToMoovMoneyRequests()`, `getRequest()`, `acceptRequest()`, `rejectRequest()`

✅ **`moov_money_firebase_service.dart`** (déjà existant)
- Écoute les changements de statut
- Détection de complétion
- Utilise le même chemin Firebase que les delivery: `requests/{requestId}`

✅ **`moov_money_driver_service.dart`** (mis à jour)
- `getRequest()` - Récupérer une requête
- `acceptRequest()` - Accepter une requête
- `rejectRequest()` - Refuser une requête
- `processDeposit()` - Traiter un dépôt (génère code)
- `processWithdrawal()` - Traiter un retrait (valide code)

### 3. Pages

✅ **`moov_money_request_details_page.dart`**
- Affiche les détails de la requête
- Boutons Accepter / Refuser
- Dialog de refus avec raison
- Navigation automatique vers page de traitement

✅ **`moov_money_deposit_process_page.dart`**
- Instructions pour le dépôt
- Bouton "Traiter le dépôt"
- Génération du code de sécurité
- Navigation vers page d'affichage du code
- Écoute Firebase pour complétion automatique

✅ **`moov_money_withdrawal_process_page.dart`**
- Instructions pour le retrait
- Input du code de sécurité (6 chiffres)
- Validation du code
- Écoute Firebase pour complétion automatique

✅ **`moov_money_security_code_display_page.dart`**
- Affichage grand format du code
- Bouton copier le code
- Informations du dépôt
- Indicateur d'attente de validation
- Écoute Firebase pour complétion automatique

### 4. Widgets

✅ **`security_code_input.dart`**
- 6 champs pour code de sécurité
- Auto-focus sur champ suivant
- Validation automatique quand complet
- Support backspace

---

## 🔔 Écoute des requêtes (HomePage)

### Intégration dans HomePage

```dart
class _HomePageState extends State<HomePage> {
  late MoovMoneyNotificationHandler _moovMoneyHandler;
  
  @override
  void initState() {
    super.initState();
    _moovMoneyHandler = MoovMoneyNotificationHandler();
    _startListeningToMoovMoneyRequests();
  }
  
  void _startListeningToMoovMoneyRequests() {
    if (userData != null && userData!.active) {
      _moovMoneyHandler.listenToMoovMoneyRequests(
        driverId: userData!.id,
        onNewRequest: (request) {
          // Afficher notification
          _showMoovMoneyNotification(request);
        },
        onRequestUpdated: (request) {
          // Mettre à jour l'UI si nécessaire
          debugPrint('Requête mise à jour: ${request.requestNumber}');
        },
        onRequestCancelled: (requestId) {
          // Gérer l'annulation
          debugPrint('Requête annulée: $requestId');
        },
      );
    }
  }
  
  void _showMoovMoneyNotification(MoovMoneyRequest request) {
    // Jouer un son
    playRequestSound();
    
    // Afficher dialog ou bottom sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle requête ${request.typeLabel}'),
        content: Text(
          'Montant: ${request.amount} FCFA\n'
          'Client: ${request.userName}\n'
          'Commission: ${request.commission} FCFA'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoovMoneyRequestDetailsPage(
                    request: request,
                  ),
                ),
              );
            },
            child: Text('Voir'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _moovMoneyHandler.dispose();
    super.dispose();
  }
}
```

---

## 🎬 Scénarios d'utilisation

### Scénario 1: Dépôt Moov Money

```
1. Driver reçoit notification de nouvelle requête
   ↓
2. Driver ouvre MoovMoneyRequestDetailsPage
   - Voit: Type (Dépôt), Montant, Client, Commission
   ↓
3. Driver clique sur "Accepter"
   - API: POST /api/v1/driver/moov-money/request/{id}/accept
   - Firebase: moov_money_status = 'accepted'
   ↓
4. Navigation vers MoovMoneyDepositProcessPage
   - Affiche montant et instructions
   ↓
5. Driver clique sur "Traiter le dépôt"
   - API: POST /api/v1/driver/moov-money/process-deposit
   - Reçoit: {security_code: "123456"}
   ↓
6. Navigation vers MoovMoneySecurityCodeDisplayPage
   - Affiche code en grand format
   - Bouton copier
   - Écoute Firebase
   ↓
7. Driver communique le code au client
   ↓
8. Client entre le code dans son app
   - Backend valide et complète
   - Firebase: moov_money_status = 'completed'
   ↓
9. Firebase notifie l'app driver
   - Dialog "Dépôt complété"
   - Retour automatique à la page précédente
```

### Scénario 2: Retrait Moov Money

```
1. Driver reçoit notification de nouvelle requête
   ↓
2. Driver ouvre MoovMoneyRequestDetailsPage
   - Voit: Type (Retrait), Montant, Client, Commission
   ↓
3. Driver clique sur "Accepter"
   - API: POST /api/v1/driver/moov-money/request/{id}/accept
   - Firebase: moov_money_status = 'accepted'
   ↓
4. Navigation vers MoovMoneyWithdrawalProcessPage
   - Affiche montant et instructions
   - Input pour code de sécurité
   ↓
5. Driver demande le code au client
   ↓
6. Driver entre le code (6 chiffres)
   - Auto-submit quand complet
   ↓
7. Driver clique sur "Traiter le retrait"
   - API: POST /api/v1/driver/moov-money/process-withdrawal
   - Envoie: {request_id, security_code}
   - Backend valide le code
   ↓
8. Si code valide:
   - Backend complète la transaction
   - Firebase: moov_money_status = 'completed'
   ↓
9. Firebase notifie l'app driver
   - Dialog "Retrait complété"
   - Retour automatique à la page précédente
```

### Scénario 3: Refus de requête

```
1. Driver reçoit notification de nouvelle requête
   ↓
2. Driver ouvre MoovMoneyRequestDetailsPage
   ↓
3. Driver clique sur "Refuser"
   - Dialog demande la raison
   ↓
4. Driver entre la raison et confirme
   - API: POST /api/v1/driver/moov-money/request/{id}/reject
   - Envoie: {reason: "Pas disponible"}
   - Firebase: moov_money_status = 'rejected'
   - Firebase: Suppression de request-meta
   ↓
5. Retour à la page précédente
   - Snackbar "Requête refusée"
```

---

## 🔥 Structure Firebase

### Nœuds utilisés

```
firebase/
├── request-meta/
│   └── {requestId}/
│       ├── driver_id: "driver123"
│       ├── is_moov_money: true
│       ├── moov_money_type: "deposit"
│       ├── moov_money_amount: 5000
│       └── ... autres champs
│
└── requests/
    └── {requestId}/
        ├── moov_money_status: "pending|accepted|processing|completed|cancelled"
        ├── moov_money_security_code: "123456"
        ├── moov_money_type: "deposit|withdrawal"
        ├── moov_money_amount: 5000
        └── ... autres champs
```

### Événements Firebase écoutés

1. **request-meta** (onChildAdded)
   - Nouvelle requête assignée au driver
   - Filtre: `driver_id == currentDriverId && is_moov_money == true`

2. **request-meta** (onChildChanged)
   - Mise à jour d'une requête existante

3. **request-meta** (onChildRemoved)
   - Requête annulée ou complétée

4. **requests/{id}/moov_money_status** (onValue)
   - Changement de statut
   - Détection de complétion

5. **requests/{id}** (onValue)
   - Suppression de la requête (complétion)

---

## 📡 API Endpoints requis

### 1. Récupérer une requête

```
GET /api/v1/driver/moov-money/request/{requestId}

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "request_number": "REQ-001",
    "user_name": "John Doe",
    "user_phone": "70123456",
    "moov_money_type": "deposit",
    "moov_money_amount": 5000,
    "moov_money_phone": "70987654",
    "moov_money_status": "pending",
    "commission": 100,
    ...
  }
}
```

### 2. Accepter une requête

```
POST /api/v1/driver/moov-money/request/{requestId}/accept

Response:
{
  "success": true,
  "message": "Request accepted"
}
```

### 3. Refuser une requête

```
POST /api/v1/driver/moov-money/request/{requestId}/reject

Body:
{
  "reason": "Pas disponible"
}

Response:
{
  "success": true,
  "message": "Request rejected"
}
```

### 4. Traiter un dépôt

```
POST /api/v1/driver/moov-money/process-deposit

Body:
{
  "request_id": "uuid"
}

Response:
{
  "success": true,
  "data": {
    "security_code": "123456"
  }
}
```

### 5. Traiter un retrait

```
POST /api/v1/driver/moov-money/process-withdrawal

Body:
{
  "request_id": "uuid",
  "security_code": "123456"
}

Response:
{
  "success": true,
  "message": "Withdrawal processed"
}
```

---

## 🧪 Tests recommandés

### Test 1: Réception de requête

```
1. Backend crée une requête Moov Money
2. ✅ Driver reçoit notification
3. ✅ Dialog/notification s'affiche
4. ✅ Cliquer sur "Voir"
5. ✅ Page de détails s'ouvre
```

### Test 2: Acceptation et dépôt

```
1. Ouvrir requête de dépôt
2. ✅ Cliquer sur "Accepter"
3. ✅ Navigation vers page de traitement
4. ✅ Cliquer sur "Traiter le dépôt"
5. ✅ Code de sécurité s'affiche
6. ✅ Copier le code
7. Backend complète la transaction
8. ✅ Dialog "Dépôt complété" s'affiche
9. ✅ Retour automatique
```

### Test 3: Acceptation et retrait

```
1. Ouvrir requête de retrait
2. ✅ Cliquer sur "Accepter"
3. ✅ Navigation vers page de traitement
4. ✅ Entrer code de sécurité
5. ✅ Cliquer sur "Traiter le retrait"
6. Backend valide et complète
7. ✅ Dialog "Retrait complété" s'affiche
8. ✅ Retour automatique
```

### Test 4: Refus de requête

```
1. Ouvrir requête
2. ✅ Cliquer sur "Refuser"
3. ✅ Dialog de raison s'affiche
4. ✅ Entrer raison et confirmer
5. ✅ Requête refusée
6. ✅ Retour à la page précédente
```

### Test 5: Code de sécurité invalide

```
1. Traiter un retrait
2. ✅ Entrer code invalide
3. ✅ Erreur affichée
4. ✅ Possibilité de réessayer
```

---

## ✅ Checklist d'implémentation

### Flutter (restart_driver)
- [x] Modèle MoovMoneyRequest créé
- [x] MoovMoneyNotificationHandler créé
- [x] MoovMoneyFirebaseService existe
- [x] MoovMoneyDriverService mis à jour
- [x] MoovMoneyRequestDetailsPage créée
- [x] MoovMoneyDepositProcessPage créée
- [x] MoovMoneyWithdrawalProcessPage créée
- [x] MoovMoneySecurityCodeDisplayPage créée
- [x] SecurityCodeInput widget créé
- [x] Exports mis à jour
- [x] Compilation sans erreur

### Intégration HomePage
- [ ] Importer MoovMoneyNotificationHandler
- [ ] Démarrer l'écoute dans initState
- [ ] Implémenter _showMoovMoneyNotification
- [ ] Arrêter l'écoute dans dispose
- [ ] Tester réception de requêtes

### Backend
- [ ] Endpoint GET /request/{id}
- [ ] Endpoint POST /request/{id}/accept
- [ ] Endpoint POST /request/{id}/reject
- [ ] Endpoint POST /process-deposit
- [ ] Endpoint POST /process-withdrawal
- [ ] Génération code de sécurité
- [ ] Validation code de sécurité
- [ ] Mise à jour Firebase
- [ ] Tests unitaires
- [ ] Tests d'intégration

---

## 🎯 Résultat

Le workflow complet d'acceptation des requêtes Moov Money est maintenant:
- ✅ **Fonctionnel** - Toutes les pages créées
- ✅ **Robuste** - Gestion d'erreurs complète
- ✅ **Automatique** - Firebase pour notifications temps réel
- ✅ **User-friendly** - UX fluide et intuitive
- ✅ **Sécurisé** - Codes de sécurité pour validation

**Prêt pour intégration dans HomePage!** 🚀

---

**Date**: 8 Novembre 2025  
**Version**: 3.0.0  
**Statut**: ✅ Workflow complet implémenté  
**Auteur**: Cascade AI  
**Projet**: Restart Driver - Moov Money Workflow
