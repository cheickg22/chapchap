import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

/// Service pour écouter les mises à jour en temps réel des transactions MoovMoney
class MoovMoneyRealtimeService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  StreamSubscription<DatabaseEvent>? _statusSubscription;

  /// Écoute les changements de statut d'une demande MoovMoney
  Stream<Map<String, dynamic>> listenToRequestStatus(String requestId) {
    final ref = _database.ref('requests/$requestId/status');
    
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) {
        return <String, dynamic>{};
      }
      
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      
      // Si c'est juste une valeur string (le statut)
      return <String, dynamic>{'status': data.toString()};
    });
  }

  /// Écoute toutes les données d'une demande MoovMoney
  Stream<Map<String, dynamic>> listenToRequest(String requestId) {
    final ref = _database.ref('requests/$requestId');
    
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) {
        return <String, dynamic>{};
      }
      
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      
      return <String, dynamic>{};
    });
  }

  /// Écoute les changements de statut avec callback
  void subscribeToStatusChanges(
    String requestId,
    Function(String status, Map<String, dynamic> data) onStatusChanged,
  ) {
    final ref = _database.ref('requests/$requestId');
    
    _statusSubscription = ref.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final requestData = Map<String, dynamic>.from(data);
        final status = requestData['status']?.toString() ?? 'pending';
        onStatusChanged(status, requestData);
      }
    });
  }

  /// Annule l'abonnement aux changements
  void unsubscribe() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
  }

  /// Dispose des ressources
  void dispose() {
    unsubscribe();
  }
}
