import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/moov_money_driver_service.dart';
import '../../../../core/network/dio_provider_impl.dart';
import '../../domain/models/moov_money_transaction.dart';
import '../../domain/models/moov_money_stats.dart';
import '../widgets/transaction_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/period_filter_chips.dart';

/// Page d'historique des transactions Moov Money
class MoovMoneyHistoryPage extends StatefulWidget {
  const MoovMoneyHistoryPage({super.key});

  @override
  State<MoovMoneyHistoryPage> createState() => _MoovMoneyHistoryPageState();
}

class _MoovMoneyHistoryPageState extends State<MoovMoneyHistoryPage> {
  late MoovMoneyDriverService _moovMoneyService;
  
  bool _isLoading = true;
  String? _error;
  
  List<MoovMoneyTransaction> _transactions = [];
  MoovMoneyStats _stats = MoovMoneyStats.empty();
  
  String _selectedPeriod = 'today';
  String? _selectedType;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _moovMoneyService = MoovMoneyDriverService(DioProviderImpl.dioClient);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final params = <String, String>{
        'period': _selectedPeriod,
      };
      
      if (_selectedType != null) {
        params['type'] = _selectedType!;
      }
      
      if (_selectedStatus != null) {
        params['status'] = _selectedStatus!;
      }

      final response = await _moovMoneyService.getHistory(params);

      if (mounted) {
        setState(() {
          // Parse transactions
          final transactionsList = response['transactions'] as List<dynamic>? ?? [];
          _transactions = transactionsList
              .map((json) => MoovMoneyTransaction.fromJson(json as Map<String, dynamic>))
              .toList();

          // Parse stats
          final statsJson = response['stats'] as Map<String, dynamic>? ?? {};
          _stats = MoovMoneyStats.fromJson(statsJson);

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterDialog(
        selectedType: _selectedType,
        selectedStatus: _selectedStatus,
        onApply: (type, status) {
          setState(() {
            _selectedType = type;
            _selectedStatus = status;
          });
          _loadHistory();
        },
      ),
    );
  }

  void _showTransactionDetails(MoovMoneyTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique Moov Money'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        // Filtres de période
        PeriodFilterChips(
          selectedPeriod: _selectedPeriod,
          onPeriodSelected: (period) {
            setState(() => _selectedPeriod = period);
            _loadHistory();
          },
        ),
        const SizedBox(height: 16),
        // Statistiques
        StatsCard(stats: _stats),
        const SizedBox(height: 8),
        // Liste des transactions
        Expanded(
          child: _transactions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      onTap: () => _showTransactionDetails(transaction),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune transaction trouvée pour cette période',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Dialog de filtres
class _FilterDialog extends StatefulWidget {
  final String? selectedType;
  final String? selectedStatus;
  final Function(String?, String?) onApply;

  const _FilterDialog({
    required this.selectedType,
    required this.selectedStatus,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  String? _type;
  String? _status;

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _status = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtres',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Type
          const Text('Type', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tous'),
                selected: _type == null,
                onSelected: (selected) {
                  setState(() => _type = null);
                },
              ),
              ChoiceChip(
                label: const Text('Dépôts'),
                selected: _type == 'deposit',
                onSelected: (selected) {
                  setState(() => _type = selected ? 'deposit' : null);
                },
              ),
              ChoiceChip(
                label: const Text('Retraits'),
                selected: _type == 'withdrawal',
                onSelected: (selected) {
                  setState(() => _type = selected ? 'withdrawal' : null);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Statut
          const Text('Statut', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tous'),
                selected: _status == null,
                onSelected: (selected) {
                  setState(() => _status = null);
                },
              ),
              ChoiceChip(
                label: const Text('Complétés'),
                selected: _status == 'completed',
                onSelected: (selected) {
                  setState(() => _status = selected ? 'completed' : null);
                },
              ),
              ChoiceChip(
                label: const Text('Annulés'),
                selected: _status == 'cancelled',
                onSelected: (selected) {
                  setState(() => _status = selected ? 'cancelled' : null);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _type = null;
                      _status = null;
                    });
                  },
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_type, _status);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sheet de détails de transaction
class _TransactionDetailsSheet extends StatelessWidget {
  final MoovMoneyTransaction transaction;

  const _TransactionDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Détails de la transaction',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('N° Demande', transaction.requestNumber),
              _buildDetailRow('Type', transaction.typeLabel),
              _buildDetailRow('Montant', '${_formatAmount(transaction.amount)} FCFA'),
              _buildDetailRow('Téléphone', transaction.phone),
              _buildDetailRow('Statut', transaction.statusLabel),
              if (transaction.commission != null)
                _buildDetailRow('Commission', '${_formatAmount(transaction.commission!)} FCFA'),
              _buildDetailRow('Date', _formatDateTime(transaction.createdAt)),
              if (transaction.completedAt != null)
                _buildDetailRow('Complété le', _formatDateTime(transaction.completedAt!)),
              if (transaction.cancelReason != null)
                _buildDetailRow('Raison d\'annulation', transaction.cancelReason!),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
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
