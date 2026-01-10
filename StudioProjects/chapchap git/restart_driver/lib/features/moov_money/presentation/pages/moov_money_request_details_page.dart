import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/moov_money_request_model.dart';
import '../../../../core/services/moov_money_driver_service.dart';
import '../../../../core/network/dio_provider_impl.dart';
import 'moov_money_ride_page.dart';

/// Page de détails d'une requête Moov Money avec boutons Accepter/Refuser
class MoovMoneyRequestDetailsPage extends StatefulWidget {
  final MoovMoneyRequest request;

  const MoovMoneyRequestDetailsPage({
    super.key,
    required this.request,
  });

  @override
  State<MoovMoneyRequestDetailsPage> createState() =>
      _MoovMoneyRequestDetailsPageState();
}

class _MoovMoneyRequestDetailsPageState
    extends State<MoovMoneyRequestDetailsPage> {
  late MoovMoneyDriverService _moovMoneyService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _moovMoneyService = MoovMoneyDriverService(DioProviderImpl.dioClient);
  }

  Future<void> _acceptRequest() async {
    setState(() => _isProcessing = true);

    try {
      // Appeler l'API pour accepter la requête
      await _moovMoneyService.acceptRequest(widget.request.id);

      if (mounted) {
        // Naviguer vers la page de ride avec carte et boutons Arriver/Traiter
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MoovMoneyRidePage(
              request: widget.request,
            ),
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

  Future<void> _rejectRequest() async {
    final reason = await _showRejectDialog();
    if (reason == null || reason.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      await _moovMoneyService.rejectRequest(
        requestId: widget.request.id,
        reason: reason,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Requête refusée'),
            backgroundColor: Colors.orange,
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

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la requête'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pourquoi refusez-vous cette requête ?'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Raison du refus',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la requête'),
        backgroundColor: widget.request.isDeposit ? Colors.green : Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type et montant
            _buildHeaderCard(),
            const SizedBox(height: 16),
            
            // Informations client
            _buildSectionCard(
              'Informations Client',
              [
                _buildInfoRow('Nom', widget.request.userName),
                _buildInfoRow('Téléphone', widget.request.userPhone),
                if (widget.request.userAddress != null)
                  _buildInfoRow('Adresse', widget.request.userAddress!),
              ],
            ),
            const SizedBox(height: 16),
            
            // Informations transaction
            _buildSectionCard(
              'Informations Transaction',
              [
                _buildInfoRow('N° Requête', widget.request.requestNumber),
                _buildInfoRow('Type', widget.request.typeLabel),
                _buildInfoRow('Montant', '${_formatAmount(widget.request.amount)} FCFA'),
                _buildInfoRow('Téléphone Moov', widget.request.phone),
                if (widget.request.commission != null)
                  _buildInfoRow('Commission', '${_formatAmount(widget.request.commission!)} FCFA'),
                _buildInfoRow('Date', _formatDateTime(widget.request.createdAt)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Boutons d'action
            if (widget.request.isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _rejectRequest,
                      icon: const Icon(Icons.close),
                      label: const Text('Refuser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _acceptRequest,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isProcessing ? 'Traitement...' : 'Accepter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.request.isDeposit
                ? [Colors.green, Colors.teal]
                : [Colors.blue, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              widget.request.isDeposit
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              widget.request.typeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatAmount(widget.request.amount)} FCFA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.request.commission != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Commission: ${_formatAmount(widget.request.commission!)} FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
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

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
