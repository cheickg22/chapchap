import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../features/moov_money/domain/models/moov_money_request_model.dart';

/// Service pour gérer les notifications et l'écoute des requêtes Moov Money
class MoovMoneyNotificationHandler {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  StreamSubscription<DatabaseEvent>? _requestsListener;
  
  /// Callback appelé quand une nouvelle requête arrive
  Function(MoovMoneyRequest)? onNewRequest;
  
  /// Callback appelé quand une requête est mise à jour
  Function(MoovMoneyRequest)? onRequestUpdated;
  
  /// Callback appelé quand une requête est annulée
  Function(String requestId)? onRequestCancelled;

  /// Écouter les nouvelles requêtes Moov Money assignées au driver
  /// Utilise request-meta comme pour les delivery
  StreamSubscription<DatabaseEvent>? listenToMoovMoneyRequests({
    required String driverId,
    required Function(MoovMoneyRequest) onNewRequest,
    Function(MoovMoneyRequest)? onRequestUpdated,
    Function(String)? onRequestCancelled,
  }) {
    this.onNewRequest = onNewRequest;
    this.onRequestUpdated = onRequestUpdated;
    this.onRequestCancelled = onRequestCancelled;

    debugPrint('🔔 Moov Money: Démarrage écoute requêtes pour driver $driverId');

    // Écouter request-meta filtré par driver_id et is_moov_money
    final requestsRef = _database
        .ref('request-meta')
        .orderByChild('driver_id')
        .equalTo(driverId);

    _requestsListener = requestsRef.onChildAdded.listen((DatabaseEvent event) {
      try {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          
          // Vérifier si c'est une requête Moov Money
          final isMoovMoney = data['is_moov_money'] == true || 
                             data['is_moov_money'] == 1 ||
                             data['is_moov_money'] == '1';
          
          if (isMoovMoney) {
            final request = MoovMoneyRequest.fromFirebase(data);
            debugPrint('🔔 Moov Money: Nouvelle requête ${request.requestNumber}');
            this.onNewRequest?.call(request);
          }
        }
      } catch (e) {
        debugPrint('🔔 Moov Money: Erreur parsing requête: $e');
      }
    });

    // Écouter les modifications
    requestsRef.onChildChanged.listen((DatabaseEvent event) {
      try {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          
          final isMoovMoney = data['is_moov_money'] == true || 
                             data['is_moov_money'] == 1 ||
                             data['is_moov_money'] == '1';
          
          if (isMoovMoney) {
            final request = MoovMoneyRequest.fromFirebase(data);
            debugPrint('🔔 Moov Money: Requête mise à jour ${request.requestNumber}');
            this.onRequestUpdated?.call(request);
          }
        }
      } catch (e) {
        debugPrint('🔔 Moov Money: Erreur parsing mise à jour: $e');
      }
    });

    // Écouter les suppressions
    requestsRef.onChildRemoved.listen((DatabaseEvent event) {
      try {
        final requestId = event.snapshot.key;
        if (requestId != null) {
          debugPrint('🔔 Moov Money: Requête supprimée $requestId');
          this.onRequestCancelled?.call(requestId);
        }
      } catch (e) {
        debugPrint('🔔 Moov Money: Erreur suppression: $e');
      }
    });

    return _requestsListener;
  }

  /// Récupérer une requête spécifique depuis Firebase
  Future<MoovMoneyRequest?> getRequest(String requestId) async {
    try {
      final snapshot = await _database.ref('requests').child(requestId).get();
      
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return MoovMoneyRequest.fromFirebase(data);
      }
      
      return null;
    } catch (e) {
      debugPrint('🔔 Moov Money: Erreur récupération requête: $e');
      return null;
    }
  }

  /// Mettre à jour le statut d'une requête dans Firebase
  Future<bool> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    try {
      await _database.ref('requests').child(requestId).update({
        'moov_money_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      debugPrint('🔔 Moov Money: Statut mis à jour pour $requestId: $status');
      return true;
    } catch (e) {
      debugPrint('🔔 Moov Money: Erreur mise à jour statut: $e');
      return false;
    }
  }

  /// Accepter une requête Moov Money
  Future<bool> acceptRequest(String requestId) async {
    try {
      await _database.ref('requests').child(requestId).update({
        'moov_money_status': 'accepted',
        'accepted_at': DateTime.now().toIso8601String(),
      });
      
      debugPrint('🔔 Moov Money: Requête acceptée $requestId');
      return true;
    } catch (e) {
      debugPrint('🔔 Moov Money: Erreur acceptation: $e');
      return false;
    }
  }

  /// Refuser une requête Moov Money
  Future<bool> rejectRequest(String requestId, String reason) async {
    try {
      await _database.ref('requests').child(requestId).update({
        'moov_money_status': 'rejected',
        'cancel_reason': reason,
        'cancelled_at': DateTime.now().toIso8601String(),
      });
      
      // Supprimer de request-meta
      await _database.ref('request-meta').child(requestId).remove();
      
      debugPrint('🔔 Moov Money: Requête refusée $requestId');
      return true;
    } catch (e) {
      debugPrint('🔔 Moov Money: Erreur refus: $e');
      return false;
    }
  }

  /// Annuler l'écoute des requêtes
  void stopListening() {
    _requestsListener?.cancel();
    _requestsListener = null;
    debugPrint('🔔 Moov Money: Arrêt écoute requêtes');
  }

  /// Nettoyer les ressources
  void dispose() {
    stopListening();
    onNewRequest = null;
    onRequestUpdated = null;
    onRequestCancelled = null;
  }
}
