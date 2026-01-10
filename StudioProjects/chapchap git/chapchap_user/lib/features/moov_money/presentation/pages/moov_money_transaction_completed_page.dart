import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/local_data.dart';

class MoovMoneyTransactionCompletedPage extends StatefulWidget {
  final String requestId;

  const MoovMoneyTransactionCompletedPage({
    Key? key,
    required this.requestId,
  }) : super(key: key);

  @override
  State<MoovMoneyTransactionCompletedPage> createState() => _MoovMoneyTransactionCompletedPageState();
}

class _MoovMoneyTransactionCompletedPageState extends State<MoovMoneyTransactionCompletedPage> {
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
          'Transaction Terminée',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
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
                      _buildSuccessHeader(),
                      const SizedBox(height: 24),
                      _buildTransactionSummary(),
                      const SizedBox(height: 16),
                      _buildAgentInfo(),
                      const SizedBox(height: 16),
                      _buildTimelineInfo(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSuccessHeader() {
    final type = (_transaction!['moov_money_type'] ?? _transaction!['type'] ?? 'deposit').toString();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
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
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Transaction Réussie !',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre ${type == 'deposit' ? 'dépôt' : 'retrait'} a été effectué avec succès',
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

  Widget _buildTransactionSummary() {
    final type = (_transaction!['moov_money_type'] ?? _transaction!['type'] ?? 'deposit').toString();
    final amount = _transaction!['moov_money_amount'] ?? _transaction!['amount'] ?? 0;
    final requestNumber = _transaction!['request_number'] ?? 'N/A';
    final phoneNumber = _transaction!['moov_money_phone_number'] ?? _transaction!['phone_number'] ?? 'N/A';
    final completedAt = _transaction!['completed_at'] ?? _transaction!['updated_at'] ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de la Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              Icons.payments,
              'Montant ${type == 'deposit' ? 'déposé' : 'retiré'}',
              '$amount FCFA',
              Colors.green,
              isLarge: true,
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
              Icons.access_time,
              'Date de complétion',
              _formatDateTime(completedAt),
              Colors.purple,
            ),
            const Divider(height: 32),
            _buildInfoRow(
              Icons.check_circle_outline,
              'Statut',
              'Terminé',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color, {bool isLarge = false}) {
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
                style: TextStyle(
                  fontSize: isLarge ? 24 : 16,
                  fontWeight: isLarge ? FontWeight.bold : FontWeight.w600,
                  color: isLarge ? color : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentInfo() {
    final driverName = _transaction!['driver_name'] ?? 'N/A';
    final driverPhone = _transaction!['driver_mobile'] ?? 'N/A';
    final vehicleNumber = _transaction!['vehicle_number'] ?? 'N/A';

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
                    color: AppColors.moovColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.moovColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Informations Agent',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSimpleInfoRow(Icons.person_outline, 'Nom', driverName),
            const SizedBox(height: 12),
            _buildSimpleInfoRow(Icons.phone_outlined, 'Téléphone', driverPhone),
            const SizedBox(height: 12),
            _buildSimpleInfoRow(Icons.directions_bike, 'Véhicule', vehicleNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineInfo() {
    final createdAt = _transaction!['created_at'] ?? '';
    final acceptedAt = _transaction!['accepted_at'] ?? '';
    final arrivedAt = _transaction!['arrived_at'] ?? '';
    final completedAt = _transaction!['completed_at'] ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chronologie',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTimelineItem(
              'Demande créée',
              _formatDateTime(createdAt),
              Icons.add_circle_outline,
              Colors.blue,
              isFirst: true,
            ),
            _buildTimelineItem(
              'Agent assigné',
              _formatDateTime(acceptedAt),
              Icons.person_add_outlined,
              Colors.orange,
            ),
            _buildTimelineItem(
              'Agent arrivé',
              _formatDateTime(arrivedAt),
              Icons.location_on_outlined,
              Colors.purple,
            ),
            _buildTimelineItem(
              'Transaction terminée',
              _formatDateTime(completedAt),
              Icons.check_circle_outline,
              Colors.green,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, IconData icon, Color color, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey[300],
              ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 8 : 0, bottom: isLast ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
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
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cette transaction a été validée et complétée avec succès.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[900],
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
