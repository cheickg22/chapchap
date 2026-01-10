import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service de sauvegarde et restauration de l'état de l'application
/// Permet de ne pas perdre les données quand l'app est fermée par le système
class AppStateService {
  static const String _stateKey = 'app_state';
  static const String _lastActiveKey = 'last_active';
  
  /// Sauvegarder l'état actuel de l'app
  static Future<void> saveState(Map<String, dynamic> state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Ajouter timestamp
      state['savedAt'] = DateTime.now().toIso8601String();
      
      await prefs.setString(_stateKey, jsonEncode(state));
      await prefs.setString(_lastActiveKey, DateTime.now().toIso8601String());
      
      print('💾 État sauvegardé : ${state.keys.length} clés');
    } catch (e) {
      print('❌ Erreur sauvegarde état : $e');
    }
  }
  
  /// Restaurer l'état de l'app
  static Future<Map<String, dynamic>?> restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_stateKey);
      
      if (stateJson != null) {
        final state = jsonDecode(stateJson) as Map<String, dynamic>;
        print('📂 État restauré : ${state.keys.length} clés');
        return state;
      }
      
      print('ℹ️ Aucun état à restaurer');
      return null;
    } catch (e) {
      print('❌ Erreur restauration état : $e');
      return null;
    }
  }
  
  /// Vérifier si l'app a été fermée récemment
  static Future<bool> wasRecentlyClosed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActive = prefs.getString(_lastActiveKey);
      
      if (lastActive != null) {
        final lastActiveTime = DateTime.parse(lastActive);
        final difference = DateTime.now().difference(lastActiveTime);
        
        // Si fermée il y a moins de 5 minutes
        return difference.inMinutes < 5;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Effacer l'état sauvegardé
  static Future<void> clearState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_stateKey);
      print('🗑️ État effacé');
    } catch (e) {
      print('❌ Erreur effacement état : $e');
    }
  }
  
  /// Sauvegarder une valeur spécifique
  static Future<void> saveValue(String key, dynamic value) async {
    try {
      final state = await restoreState() ?? {};
      state[key] = value;
      await saveState(state);
    } catch (e) {
      print('❌ Erreur sauvegarde valeur : $e');
    }
  }
  
  /// Récupérer une valeur spécifique
  static Future<dynamic> getValue(String key) async {
    try {
      final state = await restoreState();
      return state?[key];
    } catch (e) {
      print('❌ Erreur récupération valeur : $e');
      return null;
    }
  }
}
