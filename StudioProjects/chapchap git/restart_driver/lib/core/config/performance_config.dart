/// Configuration des performances pour ChapChap Driver
/// Optimisations pour garantir 60 FPS constant
class PerformanceConfig {
  // ==================== CACHE ====================
  
  /// Taille maximale du cache d'images en MB
  static const int imageCacheSize = 100;
  
  /// Nombre maximum d'images en cache
  static const int imageCacheCount = 1000;
  
  // ==================== PAGINATION ====================
  
  /// Nombre d'items par page
  static const int itemsPerPage = 20;
  
  /// Seuil de préchargement (charger plus quand il reste X items)
  static const int preloadThreshold = 5;
  
  // ==================== ANIMATIONS ====================
  
  /// Durée par défaut des animations (200ms = fluide)
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);
  
  /// Durée des animations rapides
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  
  /// Durée des animations lentes
  static const Duration slowAnimationDuration = Duration(milliseconds: 300);
  
  // ==================== DEBOUNCE ====================
  
  /// Délai de debounce pour la recherche
  static const Duration searchDebounce = Duration(milliseconds: 300);
  
  /// Délai de debounce pour les callbacks de map
  static const Duration mapDebounce = Duration(milliseconds: 300);
  
  /// Délai de debounce pour les inputs
  static const Duration inputDebounce = Duration(milliseconds: 500);
  
  // ==================== MAPS ====================
  
  /// Nombre maximum de marqueurs visibles sur la carte
  static const int maxVisibleMarkers = 50;
  
  /// Distance de clustering des marqueurs (en mètres)
  static const double markerClusterDistance = 100.0;
  
  // ==================== LISTES ====================
  
  /// Hauteur par défaut des items de liste (si fixe)
  static const double defaultItemHeight = 80.0;
  
  /// Cache extent pour les listes (pixels à précharger)
  static const double listCacheExtent = 500.0;
  
  // ==================== API ====================
  
  /// Durée du cache des requêtes API
  static const Duration apiCacheDuration = Duration(minutes: 5);
  
  /// Timeout des requêtes API
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // ==================== IMAGES ====================
  
  /// Largeur maximale des images en cache (pixels)
  static const int maxImageCacheWidth = 400;
  
  /// Hauteur maximale des images en cache (pixels)
  static const int maxImageCacheHeight = 400;
  
  /// Durée du fade-in des images
  static const Duration imageFadeInDuration = Duration(milliseconds: 200);
  
  // ==================== MONITORING ====================
  
  /// Activer le monitoring des performances (debug uniquement)
  static const bool enablePerformanceMonitoring = false;
  
  /// Seuil de frame lent (ms)
  static const int slowFrameThreshold = 16; // 60fps = 16ms par frame
  
  // ==================== OPTIMISATIONS ====================
  
  /// Désactiver les animations pendant le scroll
  static const bool disableAnimationsWhileScrolling = true;
  
  /// Utiliser const widgets partout où possible
  static const bool useConstWidgets = true;
  
  /// Activer le lazy loading
  static const bool enableLazyLoading = true;
}
