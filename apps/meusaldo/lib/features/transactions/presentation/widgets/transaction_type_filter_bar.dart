import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Barra horizontal de chips para filtragem por tipo de movimentação financeira.
class TransactionTypeFilterBar extends StatelessWidget {
  /// Tipo de movimentação selecionado, ou `null` para exibir todos.
  final TransactionType? selectedType;

  /// Callback acionado ao alternar o filtro de tipo.
  final ValueChanged<TransactionType?> onTypeSelected;

  const TransactionTypeFilterBar({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, 'Todos'),
      (TransactionType.income, 'Receitas'),
      (TransactionType.expense, 'Despesas'),
      (TransactionType.transfer, 'Transferências'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((item) {
          final (type, label) = item;
          final isSelected = selectedType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(label),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.brandPrimary,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryHighlight.withValues(alpha: 0.5)
                    : AppColors.outline,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              onSelected: (_) => onTypeSelected(type),
            ),
          );
        }).toList(),
      ),
    );
  }
}
