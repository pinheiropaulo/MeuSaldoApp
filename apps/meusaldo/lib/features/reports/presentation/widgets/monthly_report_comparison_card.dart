import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/reports/presentation/state/report_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card comparativo de despesas em relação ao mês anterior.
class MonthlyReportComparisonCard extends StatelessWidget {
  final MonthlyReportData data;

  const MonthlyReportComparisonCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
    final previousMonthName = DateFormat('MMMM', 'pt_BR')
        .format(DateTime(data.month.year, data.month.month - 1));
    final prevMonthCapitalized =
        previousMonthName[0].toUpperCase() + previousMonthName.substring(1);

    final growth = data.expenseGrowthPreviousMonth;
    final bool isFalling = growth != null && growth < 0;
    final Color color = growth == null
        ? AppColors.textSecondary
        : (isFalling ? AppColors.income : AppColors.expense);

    final String title = growth == null
        ? 'Comparativo Mensal'
        : (isFalling ? 'Despesas em Queda' : 'Despesas em Alta');

    final String description = growth == null
        ? 'Primeiro mês com movimentações registradas.'
        : (isFalling
            ? 'Você gastou ${currencyFmt.format(data.expenseDiffPreviousMonth.cents / 100)} a menos que em $prevMonthCapitalized'
            : 'Você gastou ${currencyFmt.format(data.expenseDiffPreviousMonth.cents / 100)} a mais que em $prevMonthCapitalized');

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(
              isFalling ? Icons.savings_outlined : Icons.trending_up,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (growth != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
