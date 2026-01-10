# 📊 Guide de l'Historique MoovMoney

## 🎯 Vue d'ensemble

L'historique des transactions MoovMoney permet aux utilisateurs de consulter toutes leurs transactions passées avec des filtres avancés et des statistiques en temps réel.

---

## 📱 Accès à l'Historique

### Depuis la Page d'Accueil MoovMoney

1. Ouvrir l'application
2. Aller dans **MoovMoney**
3. Cliquer sur l'icône **Historique** (⏱️) dans l'AppBar en haut à droite

---

## 🔍 Fonctionnalités

### 1. Filtres Disponibles

#### Filtre par Type
- **Tous** : Affiche toutes les transactions
- **Dépôt** : Affiche uniquement les dépôts
- **Retrait** : Affiche uniquement les retraits

#### Filtre par Statut
- **Tous** : Affiche toutes les transactions
- **En attente** : Transactions en cours de traitement
- **Terminées** : Transactions complétées avec succès
- **Annulées** : Transactions annulées

### 2. Statistiques en Temps Réel

Le widget de statistiques affiche:
- **Total** : Nombre total de transactions
- **Terminées** : Nombre de transactions complétées
- **En cours** : Nombre de transactions actives
- **Montant total** : Somme des montants des transactions terminées

### 3. Liste des Transactions

Chaque carte de transaction affiche:
- **Type** : Icône et couleur (vert pour dépôt, bleu pour retrait)
- **Numéro de demande** : Identifiant unique
- **Montant** : En FCFA
- **Statut** : Badge coloré avec le statut actuel
- **Date** : Date et heure de la transaction
- **Téléphone** : Numéro Moov Money utilisé

### 4. Mises à Jour en Temps Réel

- Les transactions sont automatiquement mises à jour via Firebase
- Les changements de statut apparaissent instantanément
- Pas besoin de rafraîchir manuellement la page

---

## 🔌 API Endpoints Utilisés

### 1. Récupérer l'Historique

```
GET /api/v1/moov-money/my-requests
```

**Paramètres de requête:**
- `type` (optional): `deposit` ou `withdrawal`
- `status` (optional): `pending`, `completed`, `cancelled`
- `per_page` (optional): Nombre par page (défaut: 20)

**Exemple de réponse:**
```json
{
  "success": true,
  "message": "Historique récupéré avec succès",
  "data": [
    {
      "id": "uuid",
      "request_number": "MM-DEP-1234567890-5678",
      "moov_money_type": "deposit",
      "moov_money_amount": 5000,
      "moov_money_phone": "97758697",
      "moov_money_status": "completed",
      "status": "completed",
      "created_at": "2025-11-04T10:30:00.000000Z",
      "completed_at": "2025-11-04T10:35:00.000000Z"
    }
  ]
}
```

### 2. Statistiques (Endpoint Backend Disponible)

```
GET /api/v1/moov-money/statistics
```

**Paramètres:**
- `period` (optional): `today`, `week`, `month`, `year`

**Réponse:**
```json
{
  "success": true,
  "data": {
    "total_deposits": 15,
    "total_withdrawals": 8,
    "total_completed": 20,
    "total_cancelled": 3,
    "total_pending": 0,
    "total_processing": 0,
    "amount_deposits": 75000,
    "amount_withdrawals": 40000,
    "total_amount": 115000,
    "total_transactions": 23
  }
}
```

### 3. Résumé par Période (Endpoint Backend Disponible)

```
GET /api/v1/moov-money/summary
```

**Réponse:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "today": {
        "total_transactions": 2,
        "total_completed": 2,
        "total_amount": 10000,
        "deposits": 1,
        "withdrawals": 1
      },
      "week": {...},
      "month": {...},
      "year": {...},
      "all_time": {...}
    },
    "chart": [
      {
        "date": "2025-11-01",
        "day": "Fri",
        "deposits": 3,
        "withdrawals": 1,
        "amount": 15000
      }
    ]
  }
}
```

---

## 📂 Structure des Fichiers

```
lib/features/moov_money/
├── presentation/
│   ├── pages/
│   │   ├── moov_money_home_page.dart          # Page d'accueil avec bouton historique
│   │   ├── moov_money_history_page.dart       # Page d'historique principale
│   │   └── moov_money_request_details_page.dart
│   └── widgets/
│       ├── moov_money_stats_widget.dart       # Widget de statistiques
│       └── moov_money_status_widget.dart
├── data/
│   └── services/
│       └── moov_money_realtime_service.dart   # Service Firebase temps réel
└── MOOV_MONEY_HISTORY_GUIDE.md               # Ce fichier
```

---

## 🎨 Interface Utilisateur

### Couleurs et Thème

- **Dépôt** : Vert (`Colors.green`)
- **Retrait** : Bleu (`Colors.blue`)
- **En attente** : Orange (`Colors.orange`)
- **Terminé** : Vert (`Colors.green`)
- **Annulé** : Rouge (`Colors.red`)

### Icônes

- **Dépôt** : `Icons.arrow_upward`
- **Retrait** : `Icons.arrow_downward`
- **Historique** : `Icons.history`
- **Statistiques** : `Icons.analytics`

---

## 🔄 Flux de Données

```
┌─────────────────┐
│  User Interface │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  History Page   │ ◄─── Filtres (Type, Statut)
└────────┬────────┘
         │
         ├──────────────────┐
         │                  │
         ▼                  ▼
┌─────────────────┐  ┌──────────────────┐
│   API Request   │  │ Firebase Listener│
│  (HTTP GET)     │  │  (Real-time)     │
└────────┬────────┘  └────────┬─────────┘
         │                    │
         ▼                    ▼
┌─────────────────────────────────┐
│   Merge & Update UI State      │
└─────────────────────────────────┘
```

---

## 🚀 Utilisation

### Exemple de Code

```dart
// Navigation vers l'historique
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MoovMoneyHistoryPage(),
  ),
);

// Afficher les statistiques
MoovMoneyStatsWidget(
  requests: _requests,
)

// Écouter les mises à jour en temps réel
final subscription = _realtimeService.listenToRequest(requestId).listen(
  (data) {
    setState(() {
      // Mettre à jour la transaction
    });
  },
);
```

---

## ✅ Fonctionnalités Implémentées

- ✅ Affichage de l'historique des transactions
- ✅ Filtres par type (dépôt/retrait)
- ✅ Filtres par statut (en attente/terminé/annulé)
- ✅ Statistiques en temps réel
- ✅ Mises à jour Firebase automatiques
- ✅ Navigation vers les détails d'une transaction
- ✅ Bouton d'accès depuis la page d'accueil
- ✅ Interface utilisateur responsive
- ✅ Gestion des erreurs
- ✅ Pull-to-refresh

---

## 🔮 Améliorations Futures Possibles

1. **Filtres Avancés**
   - Filtre par période (aujourd'hui, semaine, mois)
   - Filtre par plage de dates
   - Filtre par montant

2. **Statistiques Avancées**
   - Graphiques de tendance
   - Comparaison par période
   - Export des données (PDF, CSV)

3. **Recherche**
   - Recherche par numéro de demande
   - Recherche par montant
   - Recherche par téléphone

4. **Notifications**
   - Alertes pour nouvelles transactions
   - Rappels pour transactions en attente

---

## 📞 Support

Pour toute question ou problème:
1. Vérifier les logs de la console
2. Vérifier la connexion Firebase
3. Vérifier les endpoints API
4. Contacter l'équipe de développement

---

**Dernière mise à jour:** 4 novembre 2025
**Version:** 1.0.0
