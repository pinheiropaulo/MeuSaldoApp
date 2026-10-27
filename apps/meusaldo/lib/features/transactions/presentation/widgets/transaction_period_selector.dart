import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Barra seletora de período mensal com navegação anterior/próximo e indicador central.
class TransactionPeriodSelector extends StatelessWidget {
  /// Período atualmente selecionado (ano e mês).
  final DateTime selectedPeriod;

  /// Callback ao acionar navegação para o mês anterior.
  final VoidCallback onPreviousMonth;

  /// Callback ao acionar navegação para o próximo mês.
  final VoidCallback onNextMonth;

  const TransactionPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  static const _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  String _formatPeriod() {
    final monthIndex = selectedPeriod.month - 1;
    final month = (monthIndex >= 0 && monthIndex < _monthNames.length)
        ? _monthNames[monthIndex]
        : '';
    return '$month, ${selectedPeriod.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: AppColors.textSecondary,
            tooltip: 'Mês anterior',
            onPressed: onPreviousMonth,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primaryHighlight,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatPeriod(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: AppColors.textSecondary,
            tooltip: 'Próximo mês',
            onPressed: onNextMonth,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
