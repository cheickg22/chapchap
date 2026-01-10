import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/moov_balance_widget.dart';
import '../../data/services/moov_balance_service.dart';
import '../../data/models/moov_balance_model.dart';
import '../../../../common/app_colors.dart';

/// Page de tableau de bord Moov Money avec le solde et les transactions
class MoovMoneyDashboardPage extends StatefulWidget {
  const MoovMoneyDashboardPage({Key? key}) : super(key: key);

  @override
  State<MoovMoneyDashboardPage> createState() => _MoovMoneyDashboardPageState();
}

class _MoovMoneyDashboardPageState extends State<MoovMoneyDashboardPage> {
  final MoovBalanceService _balanceService = MoovBalanceService();
  List<TransactionSummary> _transactions = [];
  bool _isLoadingTransactions = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoadingTransactions = true;
    });

    final transactions = await _balanceService.getTransactionHistory();
    
    if (mounted) {
      setState(() {
        _transactions = transactions;
        _isLoadingTransactions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Moov Money'),
        backgroundColor: AppColors.moovColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Naviguer vers l'historique complet
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Naviguer vers les paramètres
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadTransactions();
        },
        child: CustomScrollView(
          slivers: [
            // Solde en haut
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MoovBalanceWidget(
                  onRefresh: _loadTransactions,
                  onTap: () {
                    // Afficher les détails du solde
                    _showBalanceDetails();
                  },
                ),
              ),
            ),

            // Actions rapides
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.arrow_downward,
                        label: 'Dépôt',
                        color: Colors.green,
                        onTap: () {
                          Navigator.pushNamed(context, '/moov-money/deposit');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.arrow_upward,
                        label: 'Retrait',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pushNamed(context, '/moov-money/withdrawal');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Titre des transactions récentes
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Transactions récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Liste des transactions
            if (_isLoadingTransactions)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_transactions.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucune transaction',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = _transactions[index];
                    return _buildTransactionItem(transaction);
                  },
                  childCount: _transactions.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionSummary transaction) {
    final isDeposit = transaction.type == 'deposit';
    final statusColor = _getStatusColor(transaction.status);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDeposit ? Colors.green : Colors.orange).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isDeposit ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description ?? (isDeposit ? 'Dépôt' : 'Retrait'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDate(transaction.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusLabel(transaction.status),
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isDeposit ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} XOF',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDeposit ? Colors.green : Colors.orange,
          ),
        ),
        onTap: () {
          // Afficher les détails de la transaction
          _showTransactionDetails(transaction);
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Complété';
      case 'pending':
        return 'En attente';
      case 'failed':
        return 'Échoué';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showBalanceDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Détails du solde',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Ajouter les détails du solde ici
            ],
          ),
        );
      },
    );
  }

  void _showTransactionDetails(TransactionSummary transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Détails de la transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('ID', transaction.id),
              _buildDetailRow('Type', transaction.type == 'deposit' ? 'Dépôt' : 'Retrait'),
              _buildDetailRow('Montant', '${transaction.amount.toStringAsFixed(0)} XOF'),
              _buildDetailRow('Statut', _getStatusLabel(transaction.status)),
              _buildDetailRow('Date', _formatDate(transaction.date)),
              if (transaction.description != null)
                _buildDetailRow('Description', transaction.description!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
