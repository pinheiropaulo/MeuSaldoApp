import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card hero com métricas de consumo mensal da categoria: total gasto,
/// proporção sobre as despesas gerais, média diária e comparativo vs mês anterior.
class CategoryDetailsHeroCard extends StatelessWidget {
  final CategoryMonthDetails details;

  const CategoryDetailsHeroCard({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    final spentFormatted = currencyFmt.format(details.spentInMonth.cents / 100).trim();
    final pctOfTotal = (details.percentageOfTotalExpenses * 100).toStringAsFixed(1);
    final dailyAvgFormatted = currencyFmt.format(details.dailyAverage.cents / 100).trim();

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GASTO TOTAL NO MÊS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'R\$ ',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                spentFormatted,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '$pctOfTotal% de todas as suas despesas no mês',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Grade comparativa de 2 colunas
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Média Diária',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'R\$ $dailyAvgFormatted/dia',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${details.transactionsCount} compras',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'vs. Mês Anterior',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      if (details.growthVsPreviousMonth != null) ...[
                        Text(
                          '${details.growthVsPreviousMonth! >= 0 ? '+' : ''}${details.growthVsPreviousMonth!.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: details.growthVsPreviousMonth! > 0
                                ? AppColors.expense
                                : AppColors.income,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'R\$ ${currencyFmt.format(details.differenceVsPreviousMonth.cents / 100).trim()} ${details.growthVsPreviousMonth! >= 0 ? 'a mais' : 'a menos'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: details.growthVsPreviousMonth! > 0
                                ? AppColors.expense
                                : AppColors.income,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Sem dados',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Primeiro registro',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
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
