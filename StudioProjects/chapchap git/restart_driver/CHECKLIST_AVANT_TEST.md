# ✅ Checklist Avant Test - Navigation Moov Money

## 📋 Vérifications Backend (chapchap)

### Routes API
- [ ] Routes `/api/v1/moov-money/*` existent
- [ ] Relation `driverDetail` utilisée (pas `driver`)
- [ ] Cache vidé: `php artisan cache:clear`
- [ ] Routes vérifiées: `php artisan route:list | grep moov-money`

### Test Backend
```bash
# Test endpoint
curl -X GET "https://chapchap.ml/api/v1/moov-money/my-requests" \
  -H "Authorization: Bearer {token}"

# Devrait retourner JSON (pas HTML)
```

---

## 📋 Vérifications Flutter Driver (restart_driver)

### Fichiers Modifiés
- [ ] `lib/features/home/application/home_state.dart`
  - État `NavigateToMoovMoneyRidePageState` ajouté

- [ ] `lib/features/home/application/home_bloc.dart`
  - Méthode `rideArrived()` modifiée (ligne ~2200)
  - Émet `NavigateToMoovMoneyRidePageState`

- [ ] `lib/features/home/presentation/pages/home_page/page/home_page.dart`
  - Listener `NavigateToMoovMoneyRidePageState` ajouté
  - Navigation vers `MoovMoneyRidePage`

### Compilation
```bash
cd /Users/geilanyabdatykounta/StudioProjects/restart_driver

# Nettoyer
flutter clean
flutter pub get

# Compiler
flutter run
```

### Erreurs Possibles
Si erreur de compilation:
- Vérifier imports en haut de `home_page.dart`
- `MoovMoneyRidePage` et `MoovMoneyRequest` doivent être importés via `moov_money.dart`

---

## 🧪 Scénario de Test Complet

### Préparation
1. **App User (restart_user):**
   - Se connecter comme user
   - Avoir du crédit

2. **App Driver (restart_driver):**
   - Se connecter comme driver
   - Être en ligne (online)
   - Être disponible

### Test Dépôt

#### Étape 1: Créer la Demande (User)
```
1. Ouvrir app user
2. Sélectionner "Moov Money Dépôt"
3. Entrer:
   - Montant: 5000 FCFA
   - Téléphone: 97758697
   - Position: Actuelle
4. Confirmer
```

**Vérifier:**
- [ ] Demande créée avec succès
- [ ] Code sécurité affiché (6 chiffres)
- [ ] Statut: "Recherche d'un agent..."

#### Étape 2: Accepter (Driver)
```
1. Driver reçoit notification
2. Animation radar apparaît
3. Cliquer "Accepter"
```

**Vérifier:**
- [ ] Notification reçue
- [ ] Radar visible
- [ ] Acceptation réussie
- [ ] Carte avec itinéraire vers client

#### Étape 3: Arriver (Driver) ⭐ POINT CRITIQUE
```
1. Driver navigue vers client
2. Arrivé à destination
3. Cliquer sur bouton "Arrivé"
```

**Vérifier:**
- [ ] ✅ Navigation AUTOMATIQUE vers `MoovMoneyRidePage`
- [ ] ✅ Carte affichée avec position client
- [ ] ✅ Bouton "Traiter le Dépôt" visible
- [ ] ❌ PAS de page "En attente du client"

**Si ça ne marche pas:**
- Vérifier logs: `🔔 Moov Money request detected`
- Vérifier que `isMoovMoney == true`

#### Étape 4: Traiter (Driver)
```
1. Cliquer "Traiter le Dépôt"
2. Demander code au client
3. Entrer le code (6 chiffres)
4. Confirmer
```

**Vérifier:**
- [ ] Page de saisie code s'ouvre
- [ ] Code validé
- [ ] Transaction complétée
- [ ] Retour à l'accueil

#### Étape 5: Vérifier (User)
```
1. Page user affiche "Transaction complétée"
2. Historique mis à jour
```

**Vérifier:**
- [ ] Statut: Complétée
- [ ] Montant correct
- [ ] Driver affiché

---

## 🐛 Debug si Problème

### Logs à Vérifier

**Driver App:**
```dart
// Devrait apparaître quand vous cliquez "Arrivé"
🔔 Moov Money request detected - navigating to MoovMoneyRidePage
📱 Navigation state received: {requestId}
```

**Si logs n'apparaissent pas:**
```dart
// Ajouter dans onride_slider_button_widget.dart
debugPrint('🔍 Is Moov Money: ${userData!.onTripRequest!.isMoovMoney}');
debugPrint('🔍 Moov Type: ${userData!.onTripRequest!.moovMoneyType}');
debugPrint('🔍 Request ID: ${userData!.onTripRequest!.id}');
```

### Vérifier Firebase

```javascript
// Dans Firebase Console
requests/{requestId}
{
  "is_moov_money": true,
  "moov_money_type": "deposit",
  "moov_money_status": "arrived",  // Devrait changer à "arrived"
  "arrived_at": "2025-11-10T13:45:00Z"
}
```

---

## 📊 Résultats Attendus

### ✅ Succès
- Navigation automatique vers page Moov Money
- Bouton "Traiter" visible et fonctionnel
- Transaction complétée de bout en bout
- User et Driver satisfaits

### ❌ Échec
- Reste sur page d'attente client
- Pas de navigation
- Logs absents

**Si échec:** Vérifier les 3 fichiers modifiés et recompiler

---

## 📞 Support

**Fichiers de référence créés:**
1. `MOOV_MONEY_ARRIVED_NAVIGATION_FIX.md` - Documentation complète
2. `QUICK_FIX_SUMMARY.md` - Résumé rapide
3. `CHECKLIST_AVANT_TEST.md` - Ce fichier
4. `MOOV_MONEY_REDIRECT_FIX_STEPS.md` - Guide étape par étape

---

**Date:** 10 novembre 2025  
**Prêt pour test:** ✅
