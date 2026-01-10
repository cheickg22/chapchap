import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/models/moov_money_request_model.dart';
import '../../../../core/services/moov_money_driver_service.dart';
import '../../../../core/services/moov_money_firebase_service.dart';
import '../../../../core/services/hybrid_status_service.dart';
import '../../../../core/network/dio_provider_impl.dart';

/// Page de traitement d'un retrait Moov Money
class MoovMoneyWithdrawalProcessPage extends StatefulWidget {
  final MoovMoneyRequest request;

  const MoovMoneyWithdrawalProcessPage({
    super.key,
    required this.request,
  });

  @override
  State<MoovMoneyWithdrawalProcessPage> createState() =>
      _MoovMoneyWithdrawalProcessPageState();
}

class _MoovMoneyWithdrawalProcessPageState
    extends State<MoovMoneyWithdrawalProcessPage> {
  late MoovMoneyDriverService _moovMoneyService;
  late MoovMoneyFirebaseService _firebaseService;
  late HybridStatusService _hybridService;
  
  StreamSubscription? _firebaseListener;
  
  bool _isProcessing = false;
  bool _waitingForConfirmation = false;
  bool _completionDialogShown = false; // Flag pour éviter d'afficher le dialog plusieurs fois

  @override
  void initState() {
    super.initState();
    _moovMoneyService = MoovMoneyDriverService(DioProviderImpl.dioClient);
    _firebaseService = MoovMoneyFirebaseService();
    _hybridService = HybridStatusService();
    _listenToFirebaseChanges();
  }

  @override
  void dispose() {
    _firebaseListener?.cancel();
    _firebaseService.dispose();
    _hybridService.dispose();
    super.dispose();
  }

  void _listenToFirebaseChanges() {
    // Utiliser le service hybride (Firebase + Polling API)
    _hybridService.startListening(
      requestId: widget.request.id,
      onStatusChanged: (status) {
        debugPrint('📱 Retrait: Statut changé: $status');
        if (status == 'completed' && mounted && !_completionDialogShown) {
          _showCompletionDialog();
        }
      },
      apiEndpoint: 'https://chapchap-livraison.com/api/v1/driver/moov-money/request/{id}',
    );
    
    debugPrint('🔄 Service hybride démarré (Firebase + Polling)');
    debugPrint('   - Firebase: Temps réel si connexion OK');
    debugPrint('   - Polling API: Backup toutes les 5s si Firebase lent');
  }

  void _showCompletionDialog() {
    // Marquer le dialog comme affiché
    setState(() {
      _completionDialogShown = true;
      _waitingForConfirmation = false;
    });
    
    // Annuler le listener Firebase pour éviter les notifications multiples
    _firebaseListener?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.blue, size: 32),
            SizedBox(width: 12),
            Text('Retrait complété'),
          ],
        ),
        content: const Text(
          'Le retrait Moov Money a été complété avec succès!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Retour à la page précédente
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _processWithdrawal() async {
    setState(() => _isProcessing = true);

    try {
      await _moovMoneyService.processWithdrawal(
        requestId: widget.request.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('USSD envoyé au client'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _isProcessing = false;
          _waitingForConfirmation = true;
        });
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

  Future<void> _confirmTransaction() async {
    setState(() => _isProcessing = true);
    
    try {
      // 1. Appeler l'API backend pour compléter la transaction et déclencher le paiement
      await _moovMoneyService.completeTransaction(widget.request.id);
      
      // 2. Mettre à jour Firebase pour synchroniser le statut
      await FirebaseDatabase.instance
          .ref('moov_money_requests')
          .child(widget.request.id)
          .update({
        'status': 'completed',
        'completed_at': ServerValue.timestamp,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction complétée! Passage au paiement...'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Retourner à la page d'accueil après un court délai
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la confirmation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Retrait Moov Money', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF6B00),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Montant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${_formatAmount(widget.request.amount)} FCFA',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B00),
                    ),
                  ),
                  if (widget.request.commission != null)
                    Text(
                      'Commission: ${_formatAmount(widget.request.commission!)} FCFA',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Infos client
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person_outline, 'Client', widget.request.userName),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.phone_outlined, 'Téléphone', widget.request.userPhone),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.account_balance_wallet_outlined, 'Moov', widget.request.phone),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Zone d'action
            if (_waitingForConfirmation) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'En attente de confirmation du client...',
                        style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _confirmTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirmer le retrait', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Envoyer USSD au client', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(amount);
  }
}
