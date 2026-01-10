# ✅ Fix: Navigation vers Page Moov Money après "Arrivé"

## 🐛 Problème

Quand le driver clique sur **"Arrivé"** pour une demande Moov Money, il reste sur la page d'attente client normale au lieu d'être redirigé vers la page de traitement Moov Money (dépôt ou retrait).

## 🔍 Cause

Dans `home_bloc.dart`, la méthode `rideArrived()` détectait bien les requêtes Moov Money mais faisait juste un `return` sans émettre d'état pour déclencher la navigation.

## ✅ Solution Appliquée

### 1. Ajout d'un Nouvel État

**Fichier:** `lib/features/home/application/home_state.dart`

```dart
class NavigateToMoovMoneyRidePageState extends HomeState {
  final String requestId;
  
  NavigateToMoovMoneyRidePageState({required this.requestId});
}
```

### 2. Modification du Bloc

**Fichier:** `lib/features/home/application/home_bloc.dart`

**Avant:**
```dart
// ride arrived
FutureOr<void> rideArrived(
    RideArrivedEvent event, Emitter<HomeState> emit) async {
  // Vérifier si c'est une requête Moov Money
  if (userData?.onTripRequest?.isMoovMoney == true) {
    debugPrint('🔔 Moov Money request detected - skipping normal arrived flow');
    // Pour Moov Money, ne PAS appeler l'API normale
    // La navigation est gérée par MoovMoneyRidePage
    return;  // ❌ Pas de navigation!
  }
  // ...
}
```

**Après:**
```dart
// ride arrived
FutureOr<void> rideArrived(
    RideArrivedEvent event, Emitter<HomeState> emit) async {
  // Vérifier si c'est une requête Moov Money
  if (userData?.onTripRequest?.isMoovMoney == true) {
    debugPrint('🔔 Moov Money request detected - navigating to MoovMoneyRidePage');
    
    // Mettre à jour Firebase pour indiquer l'arrivée
    await FirebaseDatabase.instance.ref('requests').child(event.requestId).update({
      'moov_money_status': 'arrived',
      'arrived_at': DateTime.now().toIso8601String(),
      'is_moov_money': true,
    });
    
    // Émettre un état pour déclencher la navigation
    emit(NavigateToMoovMoneyRidePageState(requestId: event.requestId));
    emit(UpdateState());
    return;  // ✅ Navigation déclenchée!
  }
  // ...
}
```

### 3. Ajout du Listener de Navigation

**Fichier:** `lib/features/home/presentation/pages/home_page/page/home_page.dart`

Ajouté dans le `BlocListener`:

```dart
} else if (state is NavigateToMoovMoneyRidePageState) {
  // Navigation vers la page Moov Money
  final request = homeBloc.userData?.onTripRequest;
  if (request != null && request.isMoovMoney == true) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoovMoneyRidePage(
          request: MoovMoneyRequest(
            id: request.id,
            requestNumber: request.requestNumber ?? '',
            userId: '',
            userName: request.userName ?? '',
            userPhone: request.userMobile ?? '',
            driverId: '',
            type: request.moovMoneyType ?? 'deposit',
            amount: double.tryParse(request.moovMoneyAmount?.toString() ?? '0') ?? 0.0,
            phone: request.moovMoneyPhone ?? '',
            status: request.moovMoneyStatus ?? 'arrived',
            securityCode: request.moovMoneySecurityCode,
            commission: null,
            createdAt: DateTime.now(),
            acceptedAt: request.acceptedAt != null && request.acceptedAt!.isNotEmpty
                ? DateTime.tryParse(request.acceptedAt!)
                : null,
            completedAt: request.completedAt != null && request.completedAt!.isNotEmpty
                ? DateTime.tryParse(request.completedAt!)
                : null,
            cancelReason: null,
            userLatitude: request.pickLat,
            userLongitude: request.pickLng,
            userAddress: request.pickAddress,
          ),
        ),
      ),
    );
  }
}
```

---

## 🎯 Flux Complet Après Fix

### Pour une Demande Moov Money Dépôt:

1. **Driver accepte** la demande → Page carte avec itinéraire
2. **Driver clique "Arrivé"** → `RideArrivedEvent` déclenché
3. **Bloc détecte** `isMoovMoney == true`
4. **Firebase mis à jour** avec `moov_money_status: 'arrived'`
5. **État émis** `NavigateToMoovMoneyRidePageState`
6. **Navigation automatique** vers `MoovMoneyRidePage`
7. **Page affiche**:
   - Carte avec position client
   - Bouton "Arrivé" (déjà fait)
   - Bouton "Traiter le Dépôt" (actif)
8. **Driver clique "Traiter"** → Navigation vers `MoovMoneyDepositProcessPage`
9. **Driver entre code sécurité** → Transaction complétée

### Pour une Demande Moov Money Retrait:

Même flux, mais à l'étape 8:
- Navigation vers `MoovMoneyWithdrawalProcessPage`
- Driver entre 2 codes (sécurité + validation)
- Transaction complétée

---

## 📋 Fichiers Modifiés

1. ✅ `lib/features/home/application/home_state.dart`
   - Ajout de `NavigateToMoovMoneyRidePageState`

2. ✅ `lib/features/home/application/home_bloc.dart`
   - Modification de `rideArrived()` pour émettre l'état de navigation

3. ✅ `lib/features/home/presentation/pages/home_page/page/home_page.dart`
   - Ajout du listener pour `NavigateToMoovMoneyRidePageState`

---

## 🧪 Test

### Scénario de Test:

1. **Créer une demande Moov Money** depuis l'app user
2. **Accepter la demande** depuis l'app driver
3. **Naviguer vers le client** (carte avec itinéraire)
4. **Cliquer sur "Arrivé"**

**Résultat Attendu:**
- ✅ Navigation automatique vers `MoovMoneyRidePage`
- ✅ Affichage de la carte avec position client
- ✅ Bouton "Traiter le Dépôt/Retrait" visible et actif
- ✅ Pas de page "En attente du client"

**Résultat Avant Fix:**
- ❌ Reste sur la page d'attente client normale
- ❌ Pas de navigation vers Moov Money

---

## 🔍 Debug

Si la navigation ne fonctionne pas, vérifier:

### 1. Logs dans la Console

```dart
// Dans home_bloc.dart
debugPrint('🔔 Moov Money request detected - navigating to MoovMoneyRidePage');

// Devrait apparaître quand vous cliquez sur "Arrivé"
```

### 2. État Émis

```dart
// Ajouter dans home_page.dart
} else if (state is NavigateToMoovMoneyRidePageState) {
  debugPrint('📱 Navigation state received: ${state.requestId}');
  // ...
}
```

### 3. Vérifier isMoovMoney

```dart
// Dans onride_slider_button_widget.dart
debugPrint('🔍 Is Moov Money: ${userData!.onTripRequest!.isMoovMoney}');
debugPrint('🔍 Moov Type: ${userData!.onTripRequest!.moovMoneyType}');
```

---

## ✅ Résultat Final

Après ces modifications:

- ✅ **Driver clique "Arrivé"** → Navigation automatique vers `MoovMoneyRidePage`
- ✅ **Page correcte affichée** avec carte et boutons Moov Money
- ✅ **Workflow complet** fonctionne de bout en bout
- ✅ **Pas de page d'attente client** pour Moov Money

---

**Date:** 10 novembre 2025  
**Status:** Fix Appliqué ✅  
**Testé:** En attente de test utilisateur
