import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Barra segmentada de alternância entre categorias de Despesas e Receitas.
class CategoryTypeSegmentedBar extends StatelessWidget {
  final CategoryType selectedType;
  final int expenseCount;
  final int incomeCount;
  final ValueChanged<CategoryType> onTypeChanged;

  const CategoryTypeSegmentedBar({
    super.key,
    required this.selectedType,
    required this.expenseCount,
    required this.incomeCount,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          // Aba Despesas
          Expanded(
            child: _buildTabButton(
              key: const Key('categories_tab_expense'),
              label: 'Despesas ($expenseCount)',
              icon: Icons.trending_down,
              iconColor: AppColors.expense,
              isSelected: selectedType == CategoryType.expense,
              onTap: () => onTypeChanged(CategoryType.expense),
            ),
          ),
          const SizedBox(width: 4),

          // Aba Receitas
          Expanded(
            child: _buildTabButton(
              key: const Key('categories_tab_income'),
              label: 'Receitas ($incomeCount)',
              icon: Icons.trending_up,
              iconColor: AppColors.income,
              isSelected: selectedType == CategoryType.income,
              onTap: () => onTypeChanged(CategoryType.income),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required Key key,
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppColors.primaryHighlight.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : iconColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
