import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../domain/models/moov_money_request_model.dart';
import '../../../../core/services/moov_money_driver_service.dart';
import '../../../../core/services/moov_money_firebase_service.dart';
import '../../../../core/services/hybrid_status_service.dart';
import '../../../../core/network/dio_provider_impl.dart';
import 'moov_money_security_code_display_page.dart';

/// Page de traitement d'un dépôt Moov Money
class MoovMoneyDepositProcessPage extends StatefulWidget {
  final MoovMoneyRequest request;

  const MoovMoneyDepositProcessPage({
    super.key,
    required this.request,
  });

  @override
  State<MoovMoneyDepositProcessPage> createState() =>
      _MoovMoneyDepositProcessPageState();
}

class _MoovMoneyDepositProcessPageState
    extends State<MoovMoneyDepositProcessPage> {
  late MoovMoneyDriverService _moovMoneyService;
  late MoovMoneyFirebaseService _firebaseService;
  late HybridStatusService _hybridService;
  
  StreamSubscription? _firebaseListener;
  
  bool _isProcessing = false;
  bool _waitingForConfirmation = false;
  bool _completionDialogShown = false; // Flag pour éviter d'afficher le dialog plusieurs fois
  final TextEditingController _securityCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    _securityCodeController.dispose();
    super.dispose();
  }


  void _listenToFirebaseChanges() {
    // Utiliser le service hybride (Firebase + Polling API)
    _hybridService.startListening(
      requestId: widget.request.id,
      onStatusChanged: (status) {
        debugPrint('📱 Dépôt: Statut changé: $status');
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
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Dépôt complété'),
          ],
        ),
        content: const Text(
          'Le dépôt Moov Money a été complété avec succès!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Retour à la page précédente
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _processDeposit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await _moovMoneyService.processDeposit(
        requestId: widget.request.id,
        securityCode: _securityCodeController.text,
      );

      if (mounted) {
        // Afficher un message indiquant que le traitement est en cours
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dépôt en cours de traitement... En attente de confirmation du client.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Ne pas retourner immédiatement - attendre la confirmation Firebase
        // Le listener Firebase (_listenToFirebaseChanges) affichera le dialog de complétion
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
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dépôt Moov Money'),
        backgroundColor: Colors.green,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountCard(),
            const SizedBox(height: 24),
            _buildClientInfoCard(),
            const SizedBox(height: 24),
            if (_waitingForConfirmation) _buildWaitingCard(),
            if (_waitingForConfirmation) const SizedBox(height: 24),
            if (!_waitingForConfirmation) _buildSecurityCodeInput(),
            if (!_waitingForConfirmation) const SizedBox(height: 32),
            if (!_waitingForConfirmation) _buildProcessButton(),
          ],
        ),
      ),
    );
  }


  Widget _buildWaitingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'En attente de confirmation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Le client doit confirmer le paiement dans son application.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Veuillez patienter...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.arrow_upward, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            const Text(
              'Montant à déposer',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatAmount(widget.request.amount)} FCFA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.request.commission != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Votre commission: ${_formatAmount(widget.request.commission!)} FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCodeInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Code de Sécurité',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Demandez le code de sécurité (6 chiffres) au client et entrez-le ci-dessous:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _securityCodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '000000',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le code de sécurité';
                }
                if (value.length != 6) {
                  return 'Le code doit contenir 6 chiffres';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Le code doit contenir uniquement des chiffres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations Client',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Nom', widget.request.userName),
            _buildInfoRow('Téléphone', widget.request.userPhone),
            _buildInfoRow('N° Moov Money', widget.request.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _processDeposit,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle),
        label: Text(
          _isProcessing ? 'Validation en cours...' : 'Valider le dépôt',
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(amount);
  }
}
