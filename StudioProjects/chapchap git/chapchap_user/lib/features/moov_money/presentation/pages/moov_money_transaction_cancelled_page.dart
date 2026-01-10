import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/local_data.dart';

class MoovMoneyTransactionCancelledPage extends StatefulWidget {
  final String requestId;

  const MoovMoneyTransactionCancelledPage({
    Key? key,
    required this.requestId,
  }) : super(key: key);

  @override
  State<MoovMoneyTransactionCancelledPage> createState() => _MoovMoneyTransactionCancelledPageState();
}

class _MoovMoneyTransactionCancelledPageState extends State<MoovMoneyTransactionCancelledPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _transaction;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final dio = Dio();
      final token = await AppSharedPreference.getToken();

      if (token.isEmpty) {
        throw Exception('Token non disponible');
      }

      final response = await dio.get(
        'https://chapchap-livraison.com/api/v1/moov-money/requests/${widget.requestId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _transaction = response.data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur lors du chargement');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
      return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Transaction Annulée',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTransactionDetails,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCancelledHeader(),
                      const SizedBox(height: 24),
                      _buildTransactionInfo(),
                      const SizedBox(height: 16),
                      _buildCancellationDetails(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCancelledHeader() {
    final type = (_transaction!['moov_money_type'] ?? _transaction!['type'] ?? 'deposit').toString();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[400]!, Colors.red[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel,
              color: Colors.red,
              size: 64,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Transaction Annulée',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre demande de ${type == 'deposit' ? 'dépôt' : 'retrait'} a été annulée',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    final type = (_transaction!['moov_money_type'] ?? _transaction!['type'] ?? 'deposit').toString();
    final amount = _transaction!['moov_money_amount'] ?? _transaction!['amount'] ?? 0;
    final requestNumber = _transaction!['request_number'] ?? 'N/A';
    final phoneNumber = _transaction!['moov_money_phone_number'] ?? _transaction!['phone_number'] ?? 'N/A';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de la Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              Icons.payments,
              'Montant',
              '$amount FCFA',
              Colors.grey,
            ),
            const Divider(height: 32),
            _buildInfoRow(
              Icons.receipt_long,
              'Numéro de transaction',
              requestNumber,
              Colors.blue,
            ),
            const Divider(height: 32),
            _buildInfoRow(
              Icons.phone,
              'Numéro MoovMoney',
              phoneNumber,
              Colors.orange,
            ),
            const Divider(height: 32),
            _buildInfoRow(
              Icons.category,
              'Type',
              type == 'deposit' ? 'Dépôt' : 'Retrait',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationDetails() {
    final cancelledAt = _transaction!['cancelled_at'] ?? _transaction!['updated_at'] ?? '';
    final cancelReason = _transaction!['cancel_reason'] ?? 'Raison non spécifiée';
    final cancelledBy = _transaction!['cancelled_by'] ?? 'Utilisateur';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Détails de l\'Annulation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSimpleInfoRow(Icons.access_time, 'Date d\'annulation', _formatDateTime(cancelledAt)),
            const SizedBox(height: 12),
            _buildSimpleInfoRow(Icons.person_outline, 'Annulée par', cancelledBy),
            const SizedBox(height: 12),
            _buildSimpleInfoRow(Icons.comment_outlined, 'Raison', cancelReason),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text(
              'Retour à l\'historique',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.moovColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cette transaction a été annulée et ne sera pas traitée.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
