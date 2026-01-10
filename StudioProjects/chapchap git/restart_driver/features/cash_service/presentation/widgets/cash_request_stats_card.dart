import 'package:flutter/material.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/functions.dart';

class CashRequestStatsCard extends StatelessWidget {
  final int totalRequests;
  final double totalCommissions;
  final int withdrawalCount;
  final int depositCount;

  const CashRequestStatsCard({
    Key? key,
    required this.totalRequests,
    required this.totalCommissions,
    required this.withdrawalCount,
    required this.depositCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[600]!,
            Colors.blue[400]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Titre
          const Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              MyText(
                text: 'Demandes disponibles',
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Statistiques principales
          Row(
            children: [
              // Total des demandes
              Expanded(
                child: _buildStatItem(
                  icon: Icons.list_alt,
                  label: 'Total',
                  value: totalRequests.toString(),
                  color: Colors.white,
                ),
              ),
              
              // Séparateur
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              
              // Total des commissions
              Expanded(
                child: _buildStatItem(
                  icon: Icons.attach_money,
                  label: 'Commissions',
                  value: '${Functions.formatCurrency(totalCommissions)} XOF',
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Répartition par type
          Row(
            children: [
              // Retraits
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: Colors.red[200],
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          const MyText(
                            text: 'Retraits',
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: withdrawalCount.toString(),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Dépôts
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Colors.green[200],
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          const MyText(
                            text: 'Dépôts',
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: depositCount.toString(),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color.withValues(alpha: 0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        MyText(
          text: label,
          textStyle: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 2),
        MyText(
          text: value,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
