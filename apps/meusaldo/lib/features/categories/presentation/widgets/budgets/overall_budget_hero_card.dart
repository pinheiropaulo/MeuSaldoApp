import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card hero com visão consolidada dos gastos totais versus o teto global planejado.
class OverallBudgetHeroCard extends StatelessWidget {
  final OverallBudgetSummary summary;

  const OverallBudgetHeroCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
    final pctInt = (summary.percentage * 100).toInt();

    final Color statusColor;
    if (summary.percentage > 1.0) {
      statusColor = AppColors.expense;
    } else if (summary.percentage >= 0.8) {
      statusColor = AppColors.alert;
    } else {
      statusColor = AppColors.income;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GASTOS VS. TETO PLANEJADO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$pctInt% do teto',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currencyFmt.format(summary.totalSpent.cents / 100),
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${currencyFmt.format(summary.totalBudget.cents / 100)}',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            summary.totalSpent.cents > summary.totalBudget.cents
                ? 'Estourou em ${currencyFmt.format((summary.totalSpent.cents - summary.totalBudget.cents) / 100)} do teto'
                : 'Restam ${currencyFmt.format(summary.remaining.cents / 100)} para gastar no mês',
            style: TextStyle(
              fontSize: 12,
              color: summary.totalSpent.cents > summary.totalBudget.cents
                  ? AppColors.expense
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Barra de Progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: summary.percentage.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          // Alertas de estouro e atenção (se houver)
          if (summary.exceededCount > 0 || summary.warningCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  if (summary.exceededCount > 0)
                    Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: AppColors.expense),
                        const SizedBox(width: 6),
                        Text(
                          '${summary.exceededCount} ${summary.exceededCount == 1 ? 'categoria estourada' : 'categorias estouradas'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  if (summary.exceededCount > 0 && summary.warningCount > 0)
                    const SizedBox(height: 4),
                  if (summary.warningCount > 0)
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.alert),
                        const SizedBox(width: 6),
                        Text(
                          '${summary.warningCount} ${summary.warningCount == 1 ? 'categoria em alerta' : 'categorias em alerta'} (>=80%)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.alert,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
