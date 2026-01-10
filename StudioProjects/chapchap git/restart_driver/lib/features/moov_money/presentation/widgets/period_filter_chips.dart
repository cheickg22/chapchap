import 'package:flutter/material.dart';

/// Widget pour les filtres de période
class PeriodFilterChips extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodSelected;

  const PeriodFilterChips({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip('today', 'Aujourd\'hui'),
          const SizedBox(width: 8),
          _buildChip('week', 'Semaine'),
          const SizedBox(width: 8),
          _buildChip('month', 'Mois'),
          const SizedBox(width: 8),
          _buildChip('year', 'Année'),
        ],
      ),
    );
  }

  Widget _buildChip(String period, String label) {
    final isSelected = selectedPeriod == period;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onPeriodSelected(period);
        }
      },
      selectedColor: Colors.orange,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
