import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';

enum BudgetFilter { all, alert, ok }

/// Barra de chips de filtragem de categorias orçadas por nível de alerta.
class BudgetFilterBar extends StatelessWidget {
  final BudgetFilter currentFilter;
  final OverallBudgetSummary summary;
  final int totalCount;
  final ValueChanged<BudgetFilter> onFilterChanged;

  const BudgetFilterBar({
    super.key,
    required this.currentFilter,
    required this.summary,
    required this.totalCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Todas ($totalCount)', BudgetFilter.all),
          const SizedBox(width: 8),
          _buildChip(
            'Atenção & Estouro (${summary.exceededCount + summary.warningCount})',
            BudgetFilter.alert,
            indicatorColor: AppColors.expense,
          ),
          const SizedBox(width: 8),
          _buildChip(
            'Dentro do Teto (${summary.okCount})',
            BudgetFilter.ok,
            indicatorColor: AppColors.income,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, BudgetFilter filter, {Color? indicatorColor}) {
    final isSelected = currentFilter == filter;
    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => onFilterChanged(filter),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (indicatorColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primaryHighlight : AppColors.outline,
      ),
    );
  }
}
