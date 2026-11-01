import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/state/recurring_transaction_providers.dart';

/// Barra de filtros horizontais para alternar visualizações de recorrências.
class RecurringFilterChips extends StatelessWidget {
  final RecurringFilterType selectedFilter;
  final ValueChanged<RecurringFilterType> onFilterSelected;
  final Map<RecurringFilterType, int> counts;

  const RecurringFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: RecurringFilterType.values.map((filter) {
          final count = counts[filter] ?? 0;
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildChip(
              label: '${filter.label} ($count)',
              isSelected: isSelected,
              onTap: () => onFilterSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryHighlight : AppColors.outline,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primaryHighlight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
