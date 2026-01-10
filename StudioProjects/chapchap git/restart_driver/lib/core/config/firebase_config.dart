/// Configuration Firebase pour gérer les zones à connectivité limitée
/// Permet de désactiver complètement Firebase si nécessaire
class FirebaseConfig {
  // MODE MALI : Désactiver Firebase complètement
  // Mettre à true pour utiliser uniquement les APIs REST
  static const bool disableFirebase = false;
  
  // Si Firebase est activé mais instable, utiliser le mode hybride
  static const bool useHybridMode = true;
  
  // Configuration du polling de secours
  static const int pollingIntervalSeconds = 3;
  static const int maxPollingIntervalSeconds = 15;
  
  // Timeout Firebase avant fallback vers polling
  static const int firebaseTimeoutSeconds = 2;
  
  /// Vérifier si Firebase doit être utilisé
  static bool get shouldUseFirebase => !disableFirebase;
  
  /// Vérifier si le mode hybride est activé
  static bool get shouldUseHybridMode => useHybridMode && shouldUseFirebase;
  
  /// Vérifier si on doit utiliser uniquement le polling
  static bool get shouldUsePollingOnly => disableFirebase || !shouldUseFirebase;
}
