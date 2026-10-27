import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Seletor segmentado para alternar entre Despesa, Receita e Transferência.
class TransactionTypeSegmentedTab extends StatelessWidget {
  /// Tipo de movimentação atualmente selecionado.
  final TransactionType selectedType;

  /// Callback disparado ao selecionar um tipo.
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeSegmentedTab({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Despesa',
            icon: Icons.arrow_downward,
            color: AppColors.expense,
            isSelected: selectedType == TransactionType.expense,
            onTap: () => onTypeChanged(TransactionType.expense),
          ),
          _TabItem(
            label: 'Receita',
            icon: Icons.arrow_upward,
            color: AppColors.income,
            isSelected: selectedType == TransactionType.income,
            onTap: () => onTypeChanged(TransactionType.income),
          ),
          _TabItem(
            label: 'Transferir',
            icon: Icons.swap_horiz,
            color: AppColors.transfer,
            isSelected: selectedType == TransactionType.transfer,
            onTap: () => onTypeChanged(TransactionType.transfer),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
