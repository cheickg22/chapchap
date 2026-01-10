import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Service Firebase pour écouter les changements de statut des transactions Moov Money
/// Utilise la même structure Firebase que les delivery: 'requests/{requestId}'
class MoovMoneyFirebaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  StreamSubscription<DatabaseEvent>? _requestListener;
  StreamSubscription<DatabaseEvent>? _statusListener;

  /// Écouter la suppression de la requête (transaction complétée)
  /// Utilise le même chemin Firebase que les delivery: 'requests/{requestId}'
  /// Retourne un StreamSubscription qui peut être annulé
  StreamSubscription<DatabaseEvent> listenToRequestDeletion({
    required String requestId,
    required VoidCallback onTransactionCompleted,
  }) {
    // Utiliser le même chemin que les delivery
    final requestRef = _database.ref('requests').child(requestId);

    _requestListener = requestRef.onValue.listen((DatabaseEvent event) {
      // Si la requête n'existe plus dans Firebase, elle a été complétée
      if (event.snapshot.value == null) {
        debugPrint('🔥 Moov Money: Requête $requestId supprimée - Transaction complétée');
        onTransactionCompleted();
      }
    });

    return _requestListener!;
  }

  /// Écouter les changements de statut de la transaction Moov Money
  /// Utilise le même chemin Firebase que les delivery: 'requests/{requestId}/moov_money_status'
  /// Retourne un StreamSubscription qui peut être annulé
  StreamSubscription<DatabaseEvent> listenToMoovMoneyStatus({
    required String requestId,
    required Function(String status) onStatusChanged,
    required VoidCallback onTransactionCompleted,
  }) {
    // Utiliser le même chemin que les delivery
    final statusRef = _database.ref('requests').child(requestId).child('moov_money_status');

    _statusListener = statusRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final status = event.snapshot.value.toString();
        debugPrint('🔥 Moov Money: Statut changé pour $requestId: $status');
        onStatusChanged(status);

        // Si le statut est "completed", la transaction est terminée
        if (status == 'completed' || status == 'success') {
          debugPrint('🔥 Moov Money: Transaction $requestId complétée avec succès');
          onTransactionCompleted();
        }
      }
    });

    return _statusListener!;
  }

  /// Écouter les changements de la requête complète
  /// Utilise le même chemin Firebase que les delivery: 'requests/{requestId}'
  /// Utile pour détecter plusieurs types de changements
  StreamSubscription<DatabaseEvent> listenToRequestChanges({
    required String requestId,
    required Function(Map<String, dynamic>? data) onRequestChanged,
  }) {
    // Utiliser le même chemin que les delivery
    final requestRef = _database.ref('requests').child(requestId);

    return requestRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          debugPrint('🔥 Moov Money: Requête $requestId mise à jour');
          onRequestChanged(data);
        } catch (e) {
          debugPrint('🔥 Moov Money: Erreur parsing requête: $e');
          onRequestChanged(null);
        }
      } else {
        debugPrint('🔥 Moov Money: Requête $requestId supprimée');
        onRequestChanged(null);
      }
    });
  }

  /// Vérifier si une requête existe dans Firebase
  /// Utilise le même chemin Firebase que les delivery: 'requests/{requestId}'
  Future<bool> requestExists(String requestId) async {
    try {
      final snapshot = await _database.ref('requests').child(requestId).get();
      return snapshot.exists;
    } catch (e) {
      debugPrint('🔥 Moov Money: Erreur vérification requête: $e');
      return false;
    }
  }

  /// Récupérer le statut actuel d'une transaction Moov Money
  /// Utilise le même chemin Firebase que les delivery: 'requests/{requestId}/moov_money_status'
  Future<String?> getMoovMoneyStatus(String requestId) async {
    try {
      final snapshot = await _database.ref('requests').child(requestId).child('moov_money_status').get();
      if (snapshot.exists) {
        return snapshot.value.toString();
      }
      return null;
    } catch (e) {
      debugPrint('🔥 Moov Money: Erreur récupération statut: $e');
      return null;
    }
  }

  /// Annuler tous les listeners actifs
  void cancelAllListeners() {
    _requestListener?.cancel();
    _statusListener?.cancel();
    _requestListener = null;
    _statusListener = null;
    debugPrint('🔥 Moov Money: Tous les listeners Firebase annulés');
  }

  /// Annuler un listener spécifique
  void cancelListener(StreamSubscription<DatabaseEvent>? subscription) {
    subscription?.cancel();
    debugPrint('🔥 Moov Money: Listener Firebase annulé');
  }

  /// Dispose - Nettoyer les ressources
  void dispose() {
    cancelAllListeners();
  }
}
