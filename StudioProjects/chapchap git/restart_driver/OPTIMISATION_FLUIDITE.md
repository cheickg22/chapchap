# Guide d'Optimisation de la Fluidité - ChapChap

## 🎯 Objectif : 60 FPS Constant

Une application fluide = **60 images par seconde** (16ms par frame)

## 📊 Analyse des Points de Ralentissement

### 1. **Rebuilds Inutiles** ❌
- Widgets qui se reconstruisent trop souvent
- État global mal géré
- Listeners non optimisés

### 2. **Listes Non Optimisées** ❌
- ListView sans builder
- Chargement de toutes les données en mémoire
- Pas de pagination

### 3. **Images Non Optimisées** ❌
- Images trop grandes
- Pas de cache
- Chargement synchrone

### 4. **Animations Lourdes** ❌
- Animations non optimisées
- Trop d'animations simultanées
- Pas de repaint boundaries

## ✅ Solutions Implémentées

### 1. Configuration Flutter Optimale

Créer un fichier de configuration des performances :

```dart
// lib/core/config/performance_config.dart
class PerformanceConfig {
  // Activer le mode release optimisé
  static const bool enablePerformanceOverlay = false;
  
  // Limiter les rebuilds
  static const bool useConstWidgets = true;
  
  // Optimiser les animations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);
  
  // Cache des images
  static const int imageCacheSize = 100; // MB
  static const int imageCacheCount = 1000;
  
  // Pagination
  static const int itemsPerPage = 20;
  static const int preloadThreshold = 5;
  
  // Debounce pour recherche
  static const Duration searchDebounce = Duration(milliseconds: 300);
}
```

### 2. Optimisation des Listes

**Avant (Lent)** :
```dart
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)
```

**Après (Rapide)** :
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(items[index]);
  },
  // Optimisation : Hauteur fixe si possible
  itemExtent: 80.0,
  // Optimisation : Cache des items
  cacheExtent: 500.0,
)
```

### 3. Optimisation des Images

**Configuration globale** :
```dart
// Dans main.dart
void main() {
  // Augmenter le cache des images
  PaintingBinding.instance.imageCache.maximumSize = 1000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB
  
  runApp(MyApp());
}
```

**Utilisation optimisée** :
```dart
// Utiliser CachedNetworkImage partout
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(color: Colors.white),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fadeInDuration: Duration(milliseconds: 200),
  memCacheWidth: 400, // Limiter la taille en mémoire
  maxHeightDiskCache: 400,
)
```

### 4. Optimisation BLoC (Réduire les Rebuilds)

**Avant (Trop de rebuilds)** :
```dart
BlocBuilder<HomeBloc, HomeState>(
  builder: (context, state) {
    return Column(
      children: [
        Header(state.user),
        Body(state.data),
        Footer(state.settings),
      ],
    );
  },
)
```

**Après (Rebuilds ciblés)** :
```dart
Column(
  children: [
    // Rebuild seulement si user change
    BlocSelector<HomeBloc, HomeState, User>(
      selector: (state) => state.user,
      builder: (context, user) => Header(user),
    ),
    // Rebuild seulement si data change
    BlocSelector<HomeBloc, HomeState, List<Data>>(
      selector: (state) => state.data,
      builder: (context, data) => Body(data),
    ),
    // Rebuild seulement si settings change
    BlocSelector<HomeBloc, HomeState, Settings>(
      selector: (state) => state.settings,
      builder: (context, settings) => Footer(settings),
    ),
  ],
)
```

### 5. Optimisation des Animations

**Utiliser RepaintBoundary** :
```dart
RepaintBoundary(
  child: AnimatedContainer(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    // ... propriétés animées
  ),
)
```

**Limiter les animations simultanées** :
```dart
// Désactiver les animations pendant le scroll
class OptimizedListView extends StatefulWidget {
  @override
  _OptimizedListViewState createState() => _OptimizedListViewState();
}

class _OptimizedListViewState extends State<OptimizedListView> {
  bool _isScrolling = false;
  
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          setState(() => _isScrolling = true);
        } else if (notification is ScrollEndNotification) {
          setState(() => _isScrolling = false);
        }
        return false;
      },
      child: ListView.builder(
        itemBuilder: (context, index) {
          return ItemWidget(
            item: items[index],
            disableAnimations: _isScrolling,
          );
        },
      ),
    );
  }
}
```

### 6. Lazy Loading et Pagination

```dart
class PaginatedListView extends StatefulWidget {
  @override
  _PaginatedListViewState createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }
  
  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    
    // Charger plus de données
    await context.read<DataBloc>().add(LoadMoreEvent());
    
    setState(() => _isLoadingMore = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Center(child: CircularProgressIndicator());
        }
        return ItemWidget(items[index]);
      },
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### 7. Optimisation Google Maps

```dart
GoogleMap(
  // Limiter les marqueurs visibles
  markers: _getVisibleMarkers(),
  
  // Désactiver les animations pendant le mouvement
  myLocationButtonEnabled: false,
  zoomControlsEnabled: false,
  
  // Optimiser le rendu
  liteModeEnabled: false, // Sauf si vraiment nécessaire
  
  // Callback optimisé
  onCameraMove: _debounce(() {
    // Mettre à jour les marqueurs
  }, Duration(milliseconds: 300)),
)

// Fonction debounce
Timer? _debounceTimer;
void Function() _debounce(VoidCallback callback, Duration delay) {
  return () {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  };
}
```

### 8. Optimisation des Requêtes API

```dart
class OptimizedRepository {
  // Cache des requêtes
  final Map<String, CachedResponse> _cache = {};
  
  Future<Response> get(String url) async {
    // Vérifier le cache
    if (_cache.containsKey(url)) {
      final cached = _cache[url]!;
      if (DateTime.now().difference(cached.timestamp) < Duration(minutes: 5)) {
        return cached.response;
      }
    }
    
    // Faire la requête
    final response = await dio.get(url);
    
    // Mettre en cache
    _cache[url] = CachedResponse(
      response: response,
      timestamp: DateTime.now(),
    );
    
    return response;
  }
}

class CachedResponse {
  final Response response;
  final DateTime timestamp;
  
  CachedResponse({required this.response, required this.timestamp});
}
```

## 🚀 Checklist d'Optimisation

### Général
- [ ] Activer ProGuard/R8 (déjà fait ✅)
- [ ] Utiliser `const` partout où possible
- [ ] Éviter les `setState()` dans les boucles
- [ ] Utiliser `BlocSelector` au lieu de `BlocBuilder`

### Listes
- [ ] Remplacer `ListView` par `ListView.builder`
- [ ] Ajouter `itemExtent` si hauteur fixe
- [ ] Implémenter la pagination
- [ ] Utiliser `AutomaticKeepAliveClientMixin` pour garder l'état

### Images
- [ ] Utiliser `CachedNetworkImage` partout
- [ ] Définir `memCacheWidth` et `maxHeightDiskCache`
- [ ] Augmenter le cache global des images
- [ ] Compresser les images locales

### Animations
- [ ] Utiliser `RepaintBoundary` pour les widgets animés
- [ ] Limiter à 200-300ms les animations
- [ ] Désactiver les animations pendant le scroll
- [ ] Utiliser `AnimatedBuilder` au lieu de `setState`

### Maps
- [ ] Limiter le nombre de marqueurs affichés
- [ ] Utiliser le clustering pour beaucoup de marqueurs
- [ ] Debouncer les callbacks de mouvement
- [ ] Charger les marqueurs de manière asynchrone

### API
- [ ] Implémenter un cache des requêtes
- [ ] Utiliser le debounce pour les recherches
- [ ] Pagination côté serveur
- [ ] Compression gzip activée

## 📱 Outils de Diagnostic

### 1. Performance Overlay
```dart
// Dans main.dart (mode debug uniquement)
MaterialApp(
  showPerformanceOverlay: true, // Affiche les FPS
  // ...
)
```

### 2. Timeline Profiler
```bash
# Profiler l'application
flutter run --profile --trace-startup

# Ouvrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### 3. Mesurer les Rebuilds
```dart
class RebuildCounter extends StatelessWidget {
  static int count = 0;
  
  @override
  Widget build(BuildContext context) {
    count++;
    print('Widget rebuilt $count times');
    return YourWidget();
  }
}
```

## 🎯 Résultats Attendus

| Métrique | Avant | Après | Objectif |
|----------|-------|-------|----------|
| FPS moyen | 30-40 | 55-60 | 60 |
| Temps de démarrage | 5-8s | 2-4s | <3s |
| Utilisation mémoire | 200MB+ | 100-150MB | <150MB |
| Temps de scroll | Saccadé | Fluide | 60fps |
| Chargement liste | 2-3s | <1s | <1s |

## ⚠️ Pièges à Éviter

1. **Ne pas utiliser `setState()` dans `build()`**
2. **Éviter les `FutureBuilder` imbriqués**
3. **Ne pas créer de widgets dans les boucles**
4. **Éviter les `GlobalKey` inutiles**
5. **Ne pas oublier de `dispose()` les controllers**

## 🔧 Configuration Recommandée

### pubspec.yaml
```yaml
flutter:
  # Activer le tree shaking
  uses-material-design: true
  
  # Optimiser les assets
  assets:
    - assets/images/ # Seulement ce qui est nécessaire
```

### android/app/build.gradle.kts
```kotlin
// Déjà configuré ✅
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
    }
}
```

## 📈 Monitoring en Production

```dart
// Tracker les performances
class PerformanceMonitor {
  static void trackFrameTime() {
    WidgetsBinding.instance.addTimingsCallback((timings) {
      for (final timing in timings) {
        final frameTime = timing.totalSpan.inMilliseconds;
        if (frameTime > 16) {
          print('⚠️ Frame lent: ${frameTime}ms');
          // Logger vers analytics
        }
      }
    });
  }
}

// Dans main.dart
void main() {
  PerformanceMonitor.trackFrameTime();
  runApp(MyApp());
}
```

---

**Prochaines étapes** :
1. Implémenter les optimisations prioritaires
2. Tester avec Performance Overlay
3. Profiler avec DevTools
4. Mesurer les améliorations
