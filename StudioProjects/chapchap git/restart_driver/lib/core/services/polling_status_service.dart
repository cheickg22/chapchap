import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_provider_impl.dart';

/// Service de polling pur (sans Firebase)
/// Alternative complète pour les zones où Firebase est bloqué
/// Utilise uniquement les APIs REST avec polling intelligent
class PollingStatusService {
  final DioProviderImpl _dioProvider = DioProviderImpl();
  
  Timer? _pollingTimer;
  String? _lastStatus;
  
  // Configuration optimisée pour Mali
  static const int _initialPollingInterval = 2; // secondes
  static const int _normalPollingInterval = 5; // secondes
  static const int _maxPollingInterval = 15; // secondes
  int _currentPollingInterval = 2;
  
  /// Démarrer le polling pur (sans Firebase)
  /// 
  /// [requestId] - ID de la requête à surveiller
  /// [onStatusChanged] - Callback appelé quand le statut change
  /// [apiEndpoint] - Endpoint API (ex: '/api/v1/driver/moov-money/request/{id}')
  void startPolling({
    required String requestId,
    required Function(String status) onStatusChanged,
    required String apiEndpoint,
  }) {
    debugPrint('🔄 PollingService: Démarrage polling pour $requestId');
    debugPrint('   Endpoint: $apiEndpoint');
    debugPrint('   Intervalle initial: ${_currentPollingInterval}s');
    
    // 1. Vérifier le cache local d'abord
    _checkLocalCache(requestId, onStatusChanged);
    
    // 2. Premier appel immédiat
    _pollStatus(requestId, onStatusChanged, apiEndpoint);
    
    // 3. Démarrer le polling périodique
    _startPeriodicPolling(requestId, onStatusChanged, apiEndpoint);
  }

  /// Vérifier le cache local
  Future<void> _checkLocalCache(
    String requestId,
    Function(String status) onStatusChanged,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStatus = prefs.getString('status_$requestId');
      final cachedTime = prefs.getInt('status_time_$requestId') ?? 0;
      
      // Si le cache a moins de 30 secondes, l'utiliser
      final now = DateTime.now().millisecondsSinceEpoch;
      if (cachedStatus != null && (now - cachedTime) < 30000) {
        debugPrint('💾 PollingService: Statut depuis cache: $cachedStatus');
        _lastStatus = cachedStatus;
        onStatusChanged(cachedStatus);
      }
    } catch (e) {
      debugPrint('⚠️ PollingService: Erreur lecture cache: $e');
    }
  }

  /// Démarrer le polling périodique
  void _startPeriodicPolling(
    String requestId,
    Function(String status) onStatusChanged,
    String apiEndpoint,
  ) {
    if (_pollingTimer != null && _pollingTimer!.isActive) {
      return; // Déjà en cours
    }

    _pollingTimer = Timer.periodic(
      Duration(seconds: _currentPollingInterval),
      (timer) => _pollStatus(requestId, onStatusChanged, apiEndpoint),
    );
  }

  /// Effectuer un appel API pour récupérer le statut
  Future<void> _pollStatus(
    String requestId,
    Function(String status) onStatusChanged,
    String apiEndpoint,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      if (token.isEmpty) {
        debugPrint('⚠️ PollingService: Token manquant');
        return;
      }

      // Remplacer {id} par le requestId dans l'endpoint
      final url = apiEndpoint.replaceAll('{id}', requestId);
      
      final response = await _dioProvider.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Extraire le statut selon la structure de réponse
        String? status;
        
        // Essayer différentes structures de réponse
        if (data['data'] != null) {
          status = data['data']['moov_money_status']?.toString() ??
                   data['data']['status']?.toString() ??
                   data['data']['is_trip_start']?.toString();
        } else {
          status = data['moov_money_status']?.toString() ??
                   data['status']?.toString();
        }
        
        status ??= 'pending';
        
        debugPrint('📡 PollingService: Statut reçu: $status');
        _handleStatusUpdate(requestId, status, onStatusChanged);
        
        // Ajuster l'intervalle selon le statut
        _adjustPollingInterval(status);
      }
    } catch (e) {
      debugPrint('❌ PollingService: Erreur polling: $e');
      
      // Augmenter l'intervalle en cas d'erreur (backoff exponentiel)
      _currentPollingInterval = (_currentPollingInterval * 1.5).toInt();
      if (_currentPollingInterval > _maxPollingInterval) {
        _currentPollingInterval = _maxPollingInterval;
      }
      
      debugPrint('⏰ PollingService: Nouvel intervalle: ${_currentPollingInterval}s');
      
      // Redémarrer le timer avec le nouvel intervalle
      _restartPolling(requestId, onStatusChanged, apiEndpoint);
    }
  }

  /// Ajuster l'intervalle de polling selon le statut
  void _adjustPollingInterval(String status) {
    // Statuts actifs : polling plus fréquent
    if (status == 'pending' || status == 'assigned' || status == 'processing') {
      _currentPollingInterval = _initialPollingInterval;
    } 
    // Statuts en cours : polling normal
    else if (status == 'arrived' || status == 'in_progress') {
      _currentPollingInterval = _normalPollingInterval;
    }
    // Statuts finaux : arrêter le polling
    else if (status == 'completed' || status == 'cancelled' || status == 'failed') {
      // Le polling sera arrêté dans _handleStatusUpdate
      _currentPollingInterval = _normalPollingInterval;
    }
  }

  /// Gérer la mise à jour du statut
  void _handleStatusUpdate(
    String requestId,
    String status,
    Function(String status) onStatusChanged,
  ) {
    // Éviter les notifications en double
    if (_lastStatus == status) {
      return;
    }
    
    _lastStatus = status;
    
    debugPrint('✅ PollingService: Nouveau statut: $status');
    
    // Sauvegarder dans le cache
    _saveToCache(requestId, status);
    
    // Notifier l'appelant
    onStatusChanged(status);
    
    // Si complété, arrêter le polling
    if (status == 'completed' || status == 'cancelled' || status == 'failed') {
      debugPrint('🛑 PollingService: Statut final atteint, arrêt polling');
      stopPolling();
    }
  }

  /// Sauvegarder le statut dans le cache local
  Future<void> _saveToCache(String requestId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('status_$requestId', status);
      await prefs.setInt(
        'status_time_$requestId',
        DateTime.now().millisecondsSinceEpoch,
      );
      debugPrint('💾 PollingService: Statut sauvegardé dans cache');
    } catch (e) {
      debugPrint('⚠️ PollingService: Erreur sauvegarde cache: $e');
    }
  }

  /// Redémarrer le polling avec un nouvel intervalle
  void _restartPolling(
    String requestId,
    Function(String status) onStatusChanged,
    String apiEndpoint,
  ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _startPeriodicPolling(requestId, onStatusChanged, apiEndpoint);
  }

  /// Arrêter le polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentPollingInterval = _initialPollingInterval;
    debugPrint('🛑 PollingService: Polling arrêté');
  }

  /// Vérifier si le polling est actif
  bool get isPollingActive => _pollingTimer != null && _pollingTimer!.isActive;

  /// Obtenir le dernier statut connu
  String? get lastStatus => _lastStatus;

  /// Dispose - Nettoyer les ressources
  void dispose() {
    stopPolling();
  }
}
