import 'package:flutter/material.dart';
import '../../../../core/utils/custom_text.dart';
import '../../application/cash_service_bloc.dart';

class CashRequestFilterBar extends StatelessWidget {
  final String? currentFilter;
  final CashRequestSortCriteria currentSort;
  final Function(String?) onFilterChanged;
  final Function(CashRequestSortCriteria) onSortChanged;

  const CashRequestFilterBar({
    Key? key,
    this.currentFilter,
    required this.currentSort,
    required this.onFilterChanged,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Filtres par type
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Tous',
                    value: null,
                    icon: Icons.all_inclusive,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Retraits',
                    value: 'withdrawal',
                    icon: Icons.arrow_upward,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Dépôts',
                    value: 'deposit',
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Bouton de tri
          _buildSortButton(context),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required IconData icon,
    Color? color,
  }) {
    final isSelected = currentFilter == value;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? Colors.white
                : (color ?? Colors.grey[600]),
          ),
          const SizedBox(width: 4),
          MyText(
            text: label,
            textStyle: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Colors.white
                  : (color ?? Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        onFilterChanged(selected ? value : null);
      },
      selectedColor: color ?? Colors.blue,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected
            ? (color ?? Colors.blue)
            : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    return PopupMenuButton<CashRequestSortCriteria>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sort,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            MyText(
              text: _getSortLabel(currentSort),
              textStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      onSelected: onSortChanged,
      itemBuilder: (context) => [
        _buildSortMenuItem(
          CashRequestSortCriteria.distance,
          'Distance',
          Icons.location_on,
        ),
        _buildSortMenuItem(
          CashRequestSortCriteria.amount,
          'Montant',
          Icons.attach_money,
        ),
        _buildSortMenuItem(
          CashRequestSortCriteria.commission,
          'Commission',
          Icons.trending_up,
        ),
        _buildSortMenuItem(
          CashRequestSortCriteria.requestedAt,
          'Date',
          Icons.access_time,
        ),
      ],
    );
  }

  PopupMenuItem<CashRequestSortCriteria> _buildSortMenuItem(
    CashRequestSortCriteria criteria,
    String label,
    IconData icon,
  ) {
    final isSelected = currentSort == criteria;
    
    return PopupMenuItem<CashRequestSortCriteria>(
      value: criteria,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 8),
          MyText(
            text: label,
            textStyle: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (isSelected)
            const Icon(
              Icons.check,
              size: 18,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  String _getSortLabel(CashRequestSortCriteria criteria) {
    switch (criteria) {
      case CashRequestSortCriteria.distance:
        return 'Distance';
      case CashRequestSortCriteria.amount:
        return 'Montant';
      case CashRequestSortCriteria.commission:
        return 'Commission';
      case CashRequestSortCriteria.requestedAt:
        return 'Date';
    }
  }
}
