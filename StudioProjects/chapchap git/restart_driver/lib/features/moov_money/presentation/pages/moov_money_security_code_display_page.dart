import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../core/services/moov_money_firebase_service.dart';

/// Page d'affichage du code de sécurité pour un dépôt
class MoovMoneySecurityCodeDisplayPage extends StatefulWidget {
  final String requestId;
  final String securityCode;
  final int amount;
  final String phone;

  const MoovMoneySecurityCodeDisplayPage({
    super.key,
    required this.requestId,
    required this.securityCode,
    required this.amount,
    required this.phone,
  });

  @override
  State<MoovMoneySecurityCodeDisplayPage> createState() =>
      _MoovMoneySecurityCodeDisplayPageState();
}

class _MoovMoneySecurityCodeDisplayPageState
    extends State<MoovMoneySecurityCodeDisplayPage> {
  late MoovMoneyFirebaseService _firebaseService;
  StreamSubscription? _firebaseListener;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _firebaseService = MoovMoneyFirebaseService();
    _listenToFirebaseChanges();
  }

  @override
  void dispose() {
    _firebaseListener?.cancel();
    _firebaseService.dispose();
    super.dispose();
  }

  void _listenToFirebaseChanges() {
    _firebaseListener = _firebaseService.listenToMoovMoneyStatus(
      requestId: widget.requestId,
      onStatusChanged: (status) {
        debugPrint('📱 Code sécurité: Statut changé: $status');
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
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Dépôt complété'),
          ],
        ),
        content: const Text(
          'Le dépôt Moov Money a été complété avec succès!\n\nLe client a validé le code de sécurité.',
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

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.securityCode));
    setState(() => _isCopied = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copié dans le presse-papiers'),
        duration: Duration(seconds: 2),
      ),
    );

    // Reset après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code de sécurité'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            _buildInstructionCard(),
            const SizedBox(height: 32),
            _buildCodeCard(),
            const SizedBox(height: 32),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildWaitingCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Communiquez ce code au client',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Le client doit entrer ce code dans son application pour valider le dépôt',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              'CODE DE SÉCURITÉ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.securityCode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _copyCode,
              icon: Icon(_isCopied ? Icons.check : Icons.copy),
              label: Text(_isCopied ? 'Copié!' : 'Copier le code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails du dépôt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Montant', '${_formatAmount(widget.amount)} FCFA'),
            _buildInfoRow('N° Moov Money', widget.phone),
            _buildInfoRow('N° Requête', widget.requestId.substring(0, 8)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'En attente de validation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Le client doit entrer le code pour compléter la transaction',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
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
            width: 120,
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

  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(amount);
  }
}
