import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Cabeçalho delimitador de grupo diário de lançamentos com o total líquido do dia.
class TransactionGroupHeader extends StatelessWidget {
  /// Data do agrupamento.
  final DateTime date;

  /// Lançamentos associados a este dia para cálculo do total.
  final List<Transaction> transactions;

  const TransactionGroupHeader({
    super.key,
    required this.date,
    required this.transactions,
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

  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final monthStr = _monthNames[date.month - 1];

    if (target == today) {
      return 'Hoje, ${date.day} de $monthStr';
    }
    if (target == today.subtract(const Duration(days: 1))) {
      return 'Ontem, ${date.day} de $monthStr';
    }
    return '${date.day} de $monthStr';
  }

  Money _calculateDailyNetTotal() {
    int totalCents = 0;
    for (final tx in transactions) {
      if (!tx.isCompleted) continue;
      if (tx.isIncome) {
        totalCents += tx.amount.cents;
      } else if (tx.isExpense) {
        totalCents -= tx.amount.cents;
      }
    }
    return Money.fromCents(totalCents);
  }

  @override
  Widget build(BuildContext context) {
    final netTotal = _calculateDailyNetTotal();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDate(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
          ),
          if (!netTotal.isZero)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: MoneyDisplay(
                money: netTotal,
                showPositiveSign: true,
                color: netTotal.isNegative
                    ? AppColors.expense
                    : AppColors.income,
                style: AppTypography.currencyRow(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
