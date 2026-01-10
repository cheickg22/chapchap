import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/moov_money_stats.dart';

/// Widget pour afficher les statistiques
class StatsCard extends StatelessWidget {
  final MoovMoneyStats stats;

  const StatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '📊 Statistiques',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Première ligne
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  stats.totalTransactions.toString(),
                  Icons.receipt_long,
                ),
                _buildStatItem(
                  'Complétés',
                  stats.totalCompleted.toString(),
                  Icons.check_circle,
                ),
                _buildStatItem(
                  'Annulés',
                  stats.totalCancelled.toString(),
                  Icons.cancel,
                ),
              ],
            ),
            const Divider(color: Colors.white54, height: 32),
            // Deuxième ligne
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Dépôts',
                  stats.totalDeposits.toString(),
                  Icons.arrow_upward,
                ),
                _buildStatItem(
                  'Retraits',
                  stats.totalWithdrawals.toString(),
                  Icons.arrow_downward,
                ),
              ],
            ),
            const Divider(color: Colors.white54, height: 32),
            // Commission totale
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Commission: ${_formatAmount(stats.totalCommission)} FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(amount);
  }
}
