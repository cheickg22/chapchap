# 🔧 Étapes pour Régler le Problème de Redirection Moov Money

## 📋 Problèmes Identifiés et Solutions

### ✅ 1. Backend Laravel - Corrections Appliquées

#### A. Routes API Corrigées

**Fichier:** `chapchap/routes/api/v1/moov_money.php`

Routes disponibles:
```php
// Historique et détails
GET  /api/v1/moov-money/my-requests        // Liste des demandes
GET  /api/v1/moov-money/requests/{id}      // Détails d'une demande
GET  /api/v1/moov-money/statistics         // Statistiques
GET  /api/v1/moov-money/summary            // Résumé
```

#### B. Relation `driver` → `driverDetail` Corrigée

**Fichier:** `chapchap/app/Http/Controllers/Api/V1/Request/MoovMoneyRequestController.php`

4 corrections appliquées:
- Ligne 523: `->with(['requestPlace', 'driverDetail.user', ...])`
- Ligne 544: `->with(['requestPlace', 'driverDetail.user', ...])`
- Ligne 690: `if ($request->driverDetail) { ... }`
- Ligne 734: `if ($request->driverDetail) { ... }`

#### C. Routes Web Admin Ajoutées

**Fichier:** `chapchap/routes/web.php`

```php
Route::group(['prefix' => 'moov-money', 'middleware' => 'permission:admin'], function () {
    Route::get('/', [MoovMoneyTransactionController::class, 'index']);
    Route::get('/{id}', [MoovMoneyTransactionController::class, 'show']);
});
```

---

### 🚀 2. Flutter User App - Corrections à Appliquer

#### A. Corriger l'URL de Base

**Fichier:** `restart_user/lib/features/moov_money/data/datasources/moov_money_remote_datasource.dart`

```dart
class MoovMoneyRemoteDataSource {
  // ❌ INCORRECT
  static const String _baseUrl = 'api/v1/request/moov-money';
  
  // ✅ CORRECT
  static const String _baseUrl = 'api/v1/moov-money';
  
  Future<List<MoovMoneyRequest>> getMyRequests({String? type}) async {
    final url = '$_baseUrl/my-requests${type != null ? '?type=$type' : ''}';
    // ...
  }
  
  Future<MoovMoneyRequest> getRequestDetails(String id) async {
    final url = '$_baseUrl/requests/$id';
    // ...
  }
}
```

#### B. Vérifier la Navigation vers les Détails

**Fichier:** `restart_user/lib/features/moov_money/presentation/pages/moov_money_history_page.dart`

```dart
// Navigation vers la page détails
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MoovMoneyDetailsPage(
        requestId: request.id,  // ✅ Passer l'ID correct
      ),
    ),
  );
}
```

#### C. Page Détails - Charger les Données

**Fichier:** `restart_user/lib/features/moov_money/presentation/pages/moov_money_details_page.dart`

```dart
class MoovMoneyDetailsPage extends StatefulWidget {
  final String requestId;
  
  const MoovMoneyDetailsPage({
    Key? key,
    required this.requestId,
  }) : super(key: key);
  
  @override
  State<MoovMoneyDetailsPage> createState() => _MoovMoneyDetailsPageState();
}

class _MoovMoneyDetailsPageState extends State<MoovMoneyDetailsPage> {
  MoovMoneyRequest? _request;
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadRequestDetails();
  }
  
  Future<void> _loadRequestDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // ✅ Appeler l'API avec le bon endpoint
      final datasource = MoovMoneyRemoteDataSource();
      final request = await datasource.getRequestDetails(widget.requestId);
      
      setState(() {
        _request = request;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('❌ Erreur chargement détails: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Détails')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Détails')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Erreur: $_error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRequestDetails,
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_request == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Détails')),
        body: Center(child: Text('Demande non trouvée')),
      );
    }
    
    // ✅ Afficher les détails
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails ${_request!.requestNumber}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations de base
            _buildInfoCard(),
            SizedBox(height: 16),
            
            // Codes de sécurité
            if (_request!.moovMoneySecurityCode != null)
              _buildSecurityCodeCard(),
            
            // Informations du driver
            if (_request!.driver != null)
              _buildDriverCard(),
            
            // Timeline
            _buildTimeline(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_request!.moovMoneyType == 'deposit' ? 'Dépôt' : 'Retrait'),
            SizedBox(height: 8),
            
            Text('Montant', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${_request!.moovMoneyAmount} FCFA'),
            SizedBox(height: 8),
            
            Text('Téléphone', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_request!.moovMoneyPhone ?? 'N/A'),
            SizedBox(height: 8),
            
            Text('Statut', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildStatusChip(_request!.moovMoneyStatus),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'accepted':
        color = Colors.blue;
        label = 'Acceptée';
        break;
      case 'processing':
        color = Colors.purple;
        label = 'En cours';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Complétée';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Annulée';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
  
  Widget _buildSecurityCodeCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code de Sécurité', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              _request!.moovMoneySecurityCode!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Montrez ce code au driver', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDriverCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(_request!.driver!.name ?? 'N/A'),
            if (_request!.driver!.mobile != null)
              Text(_request!.driver!.mobile!),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimeline() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            
            _buildTimelineItem(
              'Créée',
              _request!.createdAt,
              Icons.add_circle,
              Colors.blue,
            ),
            
            if (_request!.acceptedAt != null)
              _buildTimelineItem(
                'Acceptée',
                _request!.acceptedAt!,
                Icons.check_circle,
                Colors.green,
              ),
            
            if (_request!.completedAt != null)
              _buildTimelineItem(
                'Complétée',
                _request!.completedAt!,
                Icons.done_all,
                Colors.green,
              ),
            
            if (_request!.cancelledAt != null)
              _buildTimelineItem(
                'Annulée',
                _request!.cancelledAt!,
                Icons.cancel,
                Colors.red,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimelineItem(String label, DateTime date, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

### 🧪 3. Tests à Effectuer

#### A. Test Backend

```bash
# Sur le serveur
cd /var/www/html/chapchap

# Vérifier les routes
php artisan route:list | grep moov-money

# Test API
curl -X GET "https://chapchap.ml/api/v1/moov-money/my-requests" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"

# Test détails
curl -X GET "https://chapchap.ml/api/v1/moov-money/requests/{id}" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

#### B. Test Flutter

```dart
// Dans votre app, ajoutez des logs
print('🌐 URL: ${datasource._baseUrl}/requests/$id');
print('📡 Réponse: ${response.statusCode}');
print('📦 Data: ${response.data}');
```

---

### 📝 4. Checklist de Vérification

- [ ] Backend: Routes `/api/v1/moov-money/*` fonctionnent
- [ ] Backend: Relation `driverDetail` utilisée (pas `driver`)
- [ ] Backend: Cache Laravel vidé (`php artisan cache:clear`)
- [ ] Flutter: URL de base = `api/v1/moov-money` (pas `api/v1/request/moov-money`)
- [ ] Flutter: Navigation passe le bon `requestId`
- [ ] Flutter: Page détails charge les données via l'API
- [ ] Flutter: Gestion des erreurs (loading, error states)
- [ ] Test: Clic sur une demande → Page détails s'affiche correctement

---

### 🚨 Erreurs Courantes

1. **HTML au lieu de JSON** → Vérifier l'URL (doit être `/api/v1/moov-money/...`)
2. **Erreur 500 "driver relation"** → Utiliser `driverDetail` dans le backend
3. **Parse error ligne 825** → Recopier le fichier `MoovMoneyRequestController.php` sur le serveur
4. **Page blanche** → Vérifier les logs Flutter et ajouter gestion d'erreur
5. **Navigation ne fonctionne pas** → Vérifier que `requestId` est bien passé

---

**Date:** 10 novembre 2025  
**Status:** Guide Complet ✅
