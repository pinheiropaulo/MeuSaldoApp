import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/reports/presentation/state/report_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Gráfico visual em barras da evolução semanal dos gastos do mês.
class WeeklySpendingChart extends StatelessWidget {
  final MonthlyReportData data;

  const WeeklySpendingChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    final dailyAvgStr = currencyFmt.format(data.dailyAverage.cents / 100).trim();

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Evolução dos Gastos por Semana',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Média diária: R\$ $dailyAvgStr/dia',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Icon(Icons.bar_chart, color: AppColors.primaryHighlight, size: 20),
            ],
          ),
          const SizedBox(height: 16),

          // Barras das 4 semanas
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < data.weeklyExpenses.length; i++) ...[
                  Expanded(
                    child: _buildBar(data.weeklyExpenses[i]),
                  ),
                  if (i < data.weeklyExpenses.length - 1) const SizedBox(width: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(WeeklyExpenseItem item) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    final amountFormatted = currencyFmt.format(item.amount.cents / 100).trim();
    final barColor = item.isPeak ? AppColors.primaryHighlight : AppColors.primary;
    final textColor = item.isPeak ? AppColors.primaryHighlight : AppColors.textSecondary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          amountFormatted,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: item.isPeak ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: item.heightFactor.clamp(0.08, 1.0),
              widthFactor: 0.85,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 10,
            color: item.isPeak ? AppColors.primaryHighlight : AppColors.textSecondary,
            fontWeight: item.isPeak ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
