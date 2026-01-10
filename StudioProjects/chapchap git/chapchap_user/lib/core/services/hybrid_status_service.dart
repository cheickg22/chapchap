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
  
  // Configuration - Optimisé pour connexion faible
  static const int _firebaseFallbackDelay = 5; // secondes (réduit de 10 à 5)
  static const int _pollingInterval = 10; // secondes (augmenté de 5 à 10 pour économiser data)
  static const int _maxPollingInterval = 60; // secondes (augmenté de 30 à 60)
  int _currentPollingInterval = 10;

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
    print('🔄 HybridService: Démarrage écoute pour $requestId');
    print('   Firebase field: $firebaseStatusField');
    
    // 1. Vérifier le cache local d'abord
    _checkLocalCache(requestId, onStatusChanged);
    
    // 2. Démarrer l'écoute Firebase (prioritaire)
    _startFirebaseListener(requestId, onStatusChanged, firebaseStatusField);
    
    // 3. Démarrer le timer de fallback vers polling
    _startFallbackTimer(requestId, onStatusChanged, apiEndpoint);
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
      
      // Si le cache a moins de 2 minutes, l'utiliser (augmenté pour connexion faible)
      final now = DateTime.now().millisecondsSinceEpoch;
      if (cachedStatus != null && (now - cachedTime) < 120000) {
        print('💾 HybridService: Statut depuis cache: $cachedStatus (${((now - cachedTime) / 1000).toInt()}s)');
        _lastStatus = cachedStatus;
        onStatusChanged(cachedStatus);
      }
    } catch (e) {
      print('⚠️ HybridService: Erreur lecture cache: $e');
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
          print('🔥 HybridService: Événement Firebase reçu');
          print('   Snapshot exists: ${event.snapshot.exists}');
          print('   Snapshot value: ${event.snapshot.value}');
          
          if (event.snapshot.value != null) {
            final status = event.snapshot.value.toString();
            print('   📊 Statut Firebase: $status');
            
            // Marquer Firebase comme connecté
            if (!_firebaseConnected) {
              _firebaseConnected = true;
              print('✅ HybridService: Firebase connecté');
              
              // Annuler le polling si Firebase fonctionne
              _cancelPolling();
            }
            
            _handleStatusUpdate(requestId, status, onStatusChanged);
          } else {
            print('⚠️ HybridService: Snapshot Firebase null');
          }
        },
        onError: (error) {
          print('❌ HybridService: Erreur Firebase: $error');
          _firebaseConnected = false;
        },
      );
      
      print('🔥 HybridService: Listener Firebase démarré');
    } catch (e) {
      print('❌ HybridService: Impossible de démarrer Firebase: $e');
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
        print('⏰ HybridService: Firebase lent, démarrage polling');
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

    print('🔄 HybridService: Polling démarré (intervalle: ${_currentPollingInterval}s)');
    
    _pollingTimer = Timer.periodic(
      Duration(seconds: _currentPollingInterval),
      (timer) async {
        try {
          print('🔄 HybridService: Polling API en cours...');
          
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token') ?? '';
          
          if (token.isEmpty) {
            print('⚠️ HybridService: Token manquant');
            return;
          }

          // Remplacer {id} par le requestId dans l'endpoint
          final url = apiEndpoint.replaceAll('{id}', requestId);
          print('   📡 URL: $url');
          
          final response = await _dioProvider.get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

          print('   📊 Status Code: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            final data = response.data;
            print('   📦 Data: ${data.toString().substring(0, data.toString().length > 200 ? 200 : data.toString().length)}...');
            
            final status = data['data']?['moov_money_status']?.toString() ??
                          data['data']?['status']?.toString() ??
                          'pending';
            
            print('   ✅ Statut depuis API: $status');
            _handleStatusUpdate(requestId, status, onStatusChanged);
            
            // Réduire l'intervalle de polling si succès
            _currentPollingInterval = _pollingInterval;
          } else {
            print('   ⚠️ Status Code non-200: ${response.statusCode}');
          }
        } catch (e) {
          print('❌ HybridService: Erreur polling: $e');
          print('   Stack: ${e.toString()}');
          
          // Augmenter l'intervalle en cas d'erreur (backoff exponentiel)
          _currentPollingInterval = (_currentPollingInterval * 1.5).toInt();
          if (_currentPollingInterval > _maxPollingInterval) {
            _currentPollingInterval = _maxPollingInterval;
          }
          
          print('⏰ HybridService: Nouvel intervalle: ${_currentPollingInterval}s');
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
    print('🔔 HybridService: _handleStatusUpdate appelé');
    print('   Ancien statut: $_lastStatus');
    print('   Nouveau statut: $status');
    
    // Éviter les notifications en double
    if (_lastStatus == status) {
      print('   ⏭️ Statut identique, ignoré');
      return;
    }
    
    _lastStatus = status;
    _statusReceived = true;
    
    print('✅ HybridService: Changement de statut détecté!');
    print('   🔄 $_lastStatus → $status');
    
    // Sauvegarder dans le cache
    _saveToCache(requestId, status);
    
    // Notifier l'appelant
    print('📢 HybridService: Notification du callback...');
    onStatusChanged(status);
    
    // Si complété, arrêter l'écoute
    if (status == 'completed' || status == 'cancelled' || status == 'failed') {
      print('🛑 HybridService: Statut final atteint, arrêt écoute');
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
      print('💾 HybridService: Statut sauvegardé dans cache');
    } catch (e) {
      print('⚠️ HybridService: Erreur sauvegarde cache: $e');
    }
  }

  /// Annuler le polling
  void _cancelPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    print('🛑 HybridService: Polling annulé');
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
    
    print('🛑 HybridService: Écoute arrêtée');
  }

  /// Forcer le polling (utile pour tester)
  void forcePolling(
    String requestId,
    Function(String status) onStatusChanged,
    String apiEndpoint,
  ) {
    print('🔧 HybridService: Polling forcé');
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
