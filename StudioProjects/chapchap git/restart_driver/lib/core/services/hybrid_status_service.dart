import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_provider_impl.dart';

/// Service hybride pour écouter les changements de statut
/// Combine Firebase (temps réel) + Polling API (backup) + Cache local
/// Optimisé pour les zones à faible connectivité
class HybridStatusService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final DioProviderImpl _dioProvider = DioProviderImpl();
  
  StreamSubscription<DatabaseEvent>? _firebaseListener;
  Timer? _pollingTimer;
  Timer? _fallbackTimer;
  
  bool _firebaseConnected = false;
  bool _statusReceived = false;
  String? _lastStatus;
  
  // Configuration optimisée pour Mali (connexion Firebase instable)
  static const int _firebaseFallbackDelay = 2; // secondes (réduit de 10s à 2s)
  static const int _pollingInterval = 3; // secondes (réduit de 5s à 3s)
  static const int _maxPollingInterval = 15; // secondes (réduit de 30s à 15s)
  int _currentPollingInterval = 3;
  
  // Mode Mali : démarrer polling immédiatement sans attendre Firebase
  static const bool _enableMaliMode = true; // Mettre à false si Firebase fonctionne bien

  /// Démarrer l'écoute hybride (Firebase + Polling)
  /// 
  /// [requestId] - ID de la requête à surveiller
  /// [onStatusChanged] - Callback appelé quand le statut change
  /// [apiEndpoint] - Endpoint API pour le polling (ex: '/api/v1/driver/moov-money/request/{id}')
  /// [firebaseStatusField] - Champ Firebase à écouter (défaut: 'moov_money_status')
  ///   - MoovMoney: 'moov_money_status'
  ///   - Taxi/Delivery: 'is_trip_start' ou utiliser la requête complète
  void startListening({
    required String requestId,
    required Function(String status) onStatusChanged,
    required String apiEndpoint,
    String firebaseStatusField = 'moov_money_status',
  }) {
    debugPrint('🔄 HybridService: Démarrage écoute pour $requestId');
    debugPrint('   Firebase field: $firebaseStatusField');
    debugPrint('   Mode Mali: $_enableMaliMode');
    
    // 1. Vérifier le cache local d'abord
    _checkLocalCache(requestId, onStatusChanged);
    
    // 2. Démarrer l'écoute Firebase (prioritaire)
    _startFirebaseListener(requestId, onStatusChanged, firebaseStatusField);
    
    // 3. MODE MALI : Démarrer polling immédiatement en parallèle
    if (_enableMaliMode) {
      debugPrint('🇲🇱 Mode Mali activé : Polling démarré immédiatement');
      _startPolling(requestId, onStatusChanged, apiEndpoint);
    } else {
      // Mode normal : attendre le fallback
      _startFallbackTimer(requestId, onStatusChanged, apiEndpoint);
    }
  }

  /// Vérifier le cache local pour un statut récent
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
        debugPrint('💾 HybridService: Statut depuis cache: $cachedStatus');
        _lastStatus = cachedStatus;
        onStatusChanged(cachedStatus);
      }
    } catch (e) {
      debugPrint('⚠️ HybridService: Erreur lecture cache: $e');
    }
  }

  /// Démarrer l'écoute Firebase (temps réel)
  void _startFirebaseListener(
    String requestId,
    Function(String status) onStatusChanged,
    String firebaseStatusField,
  ) {
    try {
      final statusRef = _database
          .ref('requests')
          .child(requestId)
          .child(firebaseStatusField);

      _firebaseListener = statusRef.onValue.listen(
        (DatabaseEvent event) {
          if (event.snapshot.value != null) {
            final status = event.snapshot.value.toString();
            
            // Marquer Firebase comme connecté
            if (!_firebaseConnected) {
              _firebaseConnected = true;
              debugPrint('✅ HybridService: Firebase connecté');
              
              // En mode Mali, garder le polling actif même si Firebase fonctionne
              // pour assurer la redondance
              if (!_enableMaliMode) {
                _cancelPolling();
              } else {
                debugPrint('🇲🇱 Mode Mali : Polling maintenu pour redondance');
              }
            }
            
            _handleStatusUpdate(requestId, status, onStatusChanged);
          }
        },
        onError: (error) {
          debugPrint('❌ HybridService: Erreur Firebase: $error');
          _firebaseConnected = false;
        },
      );
      
      debugPrint('🔥 HybridService: Listener Firebase démarré');
    } catch (e) {
      debugPrint('❌ HybridService: Impossible de démarrer Firebase: $e');
      _firebaseConnected = false;
    }
  }

  /// Démarrer le timer de fallback vers polling
  void _startFallbackTimer(
    String requestId,
    Function(String status) onStatusChanged,
    String apiEndpoint,
  ) {
    _fallbackTimer = Timer(Duration(seconds: _firebaseFallbackDelay), () {
      if (!_statusReceived && !_firebaseConnected) {
        debugPrint('⏰ HybridService: Firebase lent, démarrage polling');
        _startPolling(requestId, onStatusChanged, apiEndpoint);
      }
    });
  }

  /// Démarrer le polling API (backup)
  void _startPolling(
    String requestId,
    Function(String status) onStatusChanged,
    String apiEndpoint,
  ) {
    if (_pollingTimer != null && _pollingTimer!.isActive) {
      return; // Déjà en cours
    }

    debugPrint('🔄 HybridService: Polling démarré (intervalle: ${_currentPollingInterval}s)');
    
    _pollingTimer = Timer.periodic(
      Duration(seconds: _currentPollingInterval),
      (timer) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token') ?? '';
          
          if (token.isEmpty) {
            debugPrint('⚠️ HybridService: Token manquant');
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
            final responseData = response.data;
            String status = 'pending';
            
            // Gérer différents formats de réponse
            if (responseData is Map<String, dynamic>) {
              final data = responseData['data'];
              if (data is Map<String, dynamic>) {
                status = data['moov_money_status']?.toString() ??
                        data['status']?.toString() ??
                        'pending';
              } else if (data is List && data.isNotEmpty && data[0] is Map) {
                // Si data est une liste, prendre le premier élément
                status = data[0]['moov_money_status']?.toString() ??
                        data[0]['status']?.toString() ??
                        'pending';
              }
            }
            
            debugPrint('📡 HybridService: Statut depuis API: $status');
            _handleStatusUpdate(requestId, status, onStatusChanged);
            
            // Réduire l'intervalle de polling si succès
            _currentPollingInterval = _pollingInterval;
          }
        } catch (e) {
          debugPrint('❌ HybridService: Erreur polling: $e');
          
          // Augmenter l'intervalle en cas d'erreur (backoff exponentiel)
          _currentPollingInterval = (_currentPollingInterval * 1.5).toInt();
          if (_currentPollingInterval > _maxPollingInterval) {
            _currentPollingInterval = _maxPollingInterval;
          }
          
          debugPrint('⏰ HybridService: Nouvel intervalle: ${_currentPollingInterval}s');
        }
      },
    );
  }

  /// Gérer la mise à jour du statut (depuis Firebase ou API)
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
    _statusReceived = true;
    
    debugPrint('✅ HybridService: Nouveau statut: $status');
    
    // Sauvegarder dans le cache
    _saveToCache(requestId, status);
    
    // Notifier l'appelant
    onStatusChanged(status);
    
    // Si complété, arrêter l'écoute
    if (status == 'completed' || status == 'cancelled' || status == 'failed') {
      debugPrint('🛑 HybridService: Statut final atteint, arrêt écoute');
      stopListening();
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
      debugPrint('💾 HybridService: Statut sauvegardé dans cache');
    } catch (e) {
      debugPrint('⚠️ HybridService: Erreur sauvegarde cache: $e');
    }
  }

  /// Annuler le polling
  void _cancelPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('🛑 HybridService: Polling annulé');
  }

  /// Arrêter toute l'écoute (Firebase + Polling)
  void stopListening() {
    _firebaseListener?.cancel();
    _firebaseListener = null;
    
    _pollingTimer?.cancel();
    _pollingTimer = null;
    
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    
    _firebaseConnected = false;
    _statusReceived = false;
    _currentPollingInterval = _pollingInterval;
    
    debugPrint('🛑 HybridService: Écoute arrêtée');
  }

  /// Forcer le polling (utile pour tester)
  void forcePolling(
    String requestId,
    Function(String status) onStatusChanged,
    String apiEndpoint,
  ) {
    debugPrint('🔧 HybridService: Polling forcé');
    _cancelPolling();
    _startPolling(requestId, onStatusChanged, apiEndpoint);
  }

  /// Vérifier si Firebase est connecté
  bool get isFirebaseConnected => _firebaseConnected;

  /// Vérifier si le polling est actif
  bool get isPollingActive => _pollingTimer != null && _pollingTimer!.isActive;

  /// Obtenir le dernier statut connu
  String? get lastStatus => _lastStatus;

  /// Dispose - Nettoyer les ressources
  void dispose() {
    stopListening();
  }
}
