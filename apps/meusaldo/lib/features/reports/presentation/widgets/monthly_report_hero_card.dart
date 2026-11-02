import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/reports/presentation/state/report_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card hero com balanço do mês, resultado líquido, taxa de poupança e bento grid de receitas vs despesas.
class MonthlyReportHeroCard extends StatelessWidget {
  final MonthlyReportData data;

  const MonthlyReportHeroCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    final isPositive = data.netBalance.cents >= 0;
    final color = isPositive ? AppColors.income : AppColors.expense;
    final sign = isPositive ? '+' : '-';
    final absBalanceCents = data.netBalance.cents.abs();
    final balanceFormatted = currencyFmt.format(absBalanceCents / 100).trim();

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESULTADO LÍQUIDO DO MÊS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$sign R\$ ',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                balanceFormatted,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isPositive
                    ? 'Economia de ${data.savingsRate.toStringAsFixed(1)}% da sua renda total'
                    : 'Déficit de ${data.savingsRate.abs().toStringAsFixed(1)}% além da receita',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bento Grid: Receitas vs Despesas
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_downward, color: AppColors.income, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Receitas Totais',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+ R\$ ${currencyFmt.format(data.totalIncome.cents / 100).trim()}',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.income,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Salário + Extras',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_upward, color: AppColors.expense, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Despesas Totais',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '- R\$ ${currencyFmt.format(data.totalExpense.cents / 100).trim()}',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.expense,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Fixas + Variáveis',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
