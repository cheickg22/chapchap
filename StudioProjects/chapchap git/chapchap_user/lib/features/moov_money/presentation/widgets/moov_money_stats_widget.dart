import 'package:flutter/material.dart';
import '../../data/services/moov_money_stats_storage.dart';

/// Widget pour afficher les statistiques de l'historique MoovMoney
class MoovMoneyStatsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> requests;

  const MoovMoneyStatsWidget({
    Key? key,
    required this.requests,
  }) : super(key: key);

  @override
  State<MoovMoneyStatsWidget> createState() => _MoovMoneyStatsWidgetState();
}

class _MoovMoneyStatsWidgetState extends State<MoovMoneyStatsWidget> {
  Map<String, dynamic>? _cachedStats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCachedStats();
  }

  @override
  void didUpdateWidget(MoovMoneyStatsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requests != widget.requests) {
      _calculateAndCacheStats();
    }
  }

  Future<void> _loadCachedStats() async {
    setState(() => _isLoading = true);
    try {
      final cached = await MoovMoneyStatsStorage.getStats();
      if (cached != null && mounted) {
        setState(() => _cachedStats = cached);
      }
    } catch (e) {
      debugPrint('Erreur chargement stats cache: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _calculateAndCacheStats() async {
    final stats = _calculateStats();
    
    // Sauvegarder en cache
    try {
      await MoovMoneyStatsStorage.saveStats(
        stats['total'],
        stats['completed'], 
        stats['active'],
        stats['totalAmount'],
      );
      
      if (mounted) {
        setState(() => _cachedStats = stats);
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    final stats = _cachedStats ?? _calculateStats();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Statistiques',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'En temps réel',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Première ligne - Total et Terminées
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    stats['total'].toString(),
                    Icons.receipt_long_rounded,
                    Colors.white,
                    isLarge: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Terminées',
                    stats['completed'].toString(),
                    Icons.check_circle_rounded,
                    Colors.green.shade300,
                    isLarge: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Deuxième ligne - En cours et Montant
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'En cours',
                    stats['active'].toString(),
                    Icons.sync_rounded,
                    Colors.orange.shade300,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Montant total',
                    '${_formatAmount(stats['totalAmount'])}',
                    Icons.account_balance_wallet_rounded,
                    Colors.amber.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des statistiques...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor, {
    bool isLarge = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 16 : 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: isLarge ? 20 : 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLarge ? 28 : 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M F';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K F';
    }
    return '$amount F';
  }

  Map<String, dynamic> _calculateStats() {
    int total = widget.requests.length;
    int completed = 0;
    int active = 0;
    double totalAmount = 0;

    debugPrint('📊 Calcul des statistiques pour ${widget.requests.length} demandes');
    
    for (var request in widget.requests) {
      final status = request['status']?.toString().toLowerCase() ?? '';
      final moovStatus = request['moov_money_status']?.toString().toLowerCase() ?? '';
      final amount = request['amount'] ?? request['moov_money_amount'] ?? 0;
      final id = request['id'];
      
      debugPrint('   📋 ID: $id, Status: $status, MoovStatus: $moovStatus, Amount: $amount');
      
      // Utiliser moov_money_status en priorité si présent, sinon status
      final effectiveStatus = moovStatus.isNotEmpty ? moovStatus : status;
      
      if (effectiveStatus == 'completed') {
        completed++;
        final numericAmount = amount is int ? amount.toDouble() : 
                            (amount is String ? double.tryParse(amount) ?? 0 : 
                            (amount is double ? amount : 0.0));
        totalAmount += numericAmount;
        debugPrint('     ✅ Compté comme terminé - Montant ajouté: $numericAmount');
      } else if (effectiveStatus != 'cancelled' && effectiveStatus != 'failed') {
        active++;
        debugPrint('     🔄 Compté comme actif');
      } else {
        debugPrint('     ❌ Non compté (annulé/échoué)');
      }
    }

    final result = {
      'total': total,
      'completed': completed,
      'active': active,
      'totalAmount': totalAmount.toInt(),
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
    
    debugPrint('📈 Statistiques finales: $result');
    return result;
  }
}
