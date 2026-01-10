import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import '../../domain/models/moov_money_request_model.dart';
import '../../../../core/services/moov_money_firebase_service.dart';
import '../../../../core/services/moov_money_driver_service.dart';
import '../../../../core/network/dio_provider_impl.dart';
import 'moov_money_deposit_process_page.dart';
import 'moov_money_withdrawal_process_page.dart';

/// Page de "ride" Moov Money avec carte et boutons Arriver/Traiter
class MoovMoneyRidePage extends StatefulWidget {
  final MoovMoneyRequest request;

  const MoovMoneyRidePage({
    super.key,
    required this.request,
  });

  @override
  State<MoovMoneyRidePage> createState() => _MoovMoneyRidePageState();
}

class _MoovMoneyRidePageState extends State<MoovMoneyRidePage> {
  late MoovMoneyFirebaseService _firebaseService;
  late MoovMoneyDriverService _moovMoneyService;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  GoogleMapController? _mapController;
  StreamSubscription? _firebaseListener;
  
  bool _hasArrived = false;
  bool _isProcessing = false;
  
  // Position du client
  late LatLng _clientPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _firebaseService = MoovMoneyFirebaseService();
    _moovMoneyService = MoovMoneyDriverService(DioProviderImpl.dioClient);
    
    // Position du client
    _clientPosition = LatLng(
      widget.request.userLatitude ?? 0.0,
      widget.request.userLongitude ?? 0.0,
    );
    
    _setupMarkers();
    _listenToFirebaseChanges();
  }

  @override
  void dispose() {
    _firebaseListener?.cancel();
    _firebaseService.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _setupMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('client'),
        position: _clientPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          widget.request.isDeposit ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: widget.request.userName,
          snippet: widget.request.userAddress ?? 'Client',
        ),
      ),
    };
  }

  void _listenToFirebaseChanges() {
    _firebaseListener = _firebaseService.listenToMoovMoneyStatus(
      requestId: widget.request.id,
      onStatusChanged: (status) {
        debugPrint('📱 Ride: Statut changé: $status');
        if (status == 'completed' && mounted) {
          _showCompletionDialog();
        }
      },
      onTransactionCompleted: () {
        if (mounted) {
          _showCompletionDialog();
        }
      },
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: widget.request.isDeposit ? Colors.green : Colors.blue,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Transaction complétée'),
          ],
        ),
        content: const Text(
          'La transaction Moov Money a été complétée avec succès!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Retour à la page précédente
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.request.isDeposit ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsArrived() async {
    setState(() => _isProcessing = true);

    try {
      // NOUVEAU : Appeler l'API backend pour signaler l'arrivée
      // Cela ne déclenche PAS l'envoi du USSD
      await _moovMoneyService.signalArrival(widget.request.id);
      
      // Mettre à jour Firebase aussi pour la synchronisation temps réel
      // NE PAS mettre is_driver_arrived car cela déclenche la complétion côté user
      await _database.ref('requests').child(widget.request.id).update({
        'moov_money_status': 'driver_at_location',  // Statut spécifique pour Moov Money
        'driver_arrived_at': DateTime.now().toIso8601String(),
        'is_moov_money': true,
        // Retirer is_driver_arrived pour éviter la complétion automatique
      });

      if (mounted) {
        setState(() {
          _hasArrived = true;
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous êtes arrivé chez le client'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startProcessing() async {
    setState(() => _isProcessing = true);

    try {
      // Mettre à jour le statut dans Firebase
      await _database.ref('requests').child(widget.request.id).update({
        'moov_money_status': 'processing',
        'processing_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        // Naviguer vers la page de traitement appropriée
        if (widget.request.isDeposit) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MoovMoneyDepositProcessPage(
                request: widget.request,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MoovMoneyWithdrawalProcessPage(
                request: widget.request,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.request.typeLabel} Moov Money'),
        backgroundColor: widget.request.isDeposit ? Colors.green : Colors.blue,
      ),
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _clientPosition,
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          
          // Informations en haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildInfoCard(),
          ),
          
          // Boutons en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête avec type et montant
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.request.isDeposit
                    ? [Colors.green, Colors.teal]
                    : [Colors.blue, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.request.isDeposit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.typeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${_formatAmount(widget.request.amount)} FCFA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.request.commission != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${_formatAmount(widget.request.commission!)} FCFA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Informations client
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.person, 'Client', widget.request.userName),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, 'Téléphone', widget.request.userPhone),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone_android, 'N° Moov', widget.request.phone),
                if (widget.request.userAddress != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, 'Adresse', widget.request.userAddress!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    // Debug: Afficher l'état des boutons
    debugPrint('🔘 MoovMoneyRidePage - État des boutons:');
    debugPrint('   _hasArrived: $_hasArrived');
    debugPrint('   _isProcessing: $_isProcessing');
    debugPrint('   Bouton affiché: ${!_hasArrived ? "Arriver" : "Traiter"}');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_hasArrived)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _markAsArrived,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.location_on),
                  label: Text(
                    _isProcessing ? 'Traitement...' : 'Arriver',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_hasArrived)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _startProcessing,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    _isProcessing ? 'Traitement...' : 'Traiter',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.request.isDeposit ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(amount);
  }
}
