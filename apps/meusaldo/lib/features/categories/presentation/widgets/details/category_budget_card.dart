import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card de monitoramento do teto de gastos da categoria no mês.
class CategoryBudgetCard extends StatelessWidget {
  final CategoryBudgetReport? report;
  final VoidCallback onAdjustBudget;

  const CategoryBudgetCard({
    super.key,
    required this.report,
    required this.onAdjustBudget,
  });

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.track_changes, color: AppColors.primaryHighlight, size: 20),
                SizedBox(width: 8),
                Text(
                  'Orçamento & Teto de Gastos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Esta categoria ainda não possui um teto mensal. Defina um limite para acompanhar os gastos e receber alertas preventivos.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            AppButton(
              key: const Key('category_define_budget_button'),
              label: 'Definir Teto Mensal',
              variant: AppButtonVariant.outlined,
              onPressed: onAdjustBudget,
            ),
          ],
        ),
      );
    }

    final rep = report!;
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
    final pctInt = (rep.percentage * 100).toInt();

    final Color statusColor;
    final IconData statusIcon;
    final String statusTitle;

    switch (rep.status) {
      case CategoryBudgetStatus.exceeded:
        statusColor = AppColors.expense;
        statusIcon = Icons.error_outline;
        statusTitle = 'Teto Estourado ($pctInt% consumido)';
      case CategoryBudgetStatus.warning:
        statusColor = AppColors.alert;
        statusIcon = Icons.warning_amber_rounded;
        statusTitle = 'Teto em Atenção ($pctInt% consumido)';
      case CategoryBudgetStatus.ok:
        statusColor = AppColors.income;
        statusIcon = Icons.check_circle_outline;
        statusTitle = 'Teto sob Controle ($pctInt% consumido)';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    statusTitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                key: const Key('category_adjust_budget_button'),
                onTap: onAdjustBudget,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'Ajustar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryHighlight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Barra de Progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rep.percentage.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gasto: ${currencyFmt.format(rep.spent.cents / 100)}',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Teto: ${currencyFmt.format(rep.budget.cents / 100)}',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Text(
            rep.status == CategoryBudgetStatus.exceeded
                ? 'Estourou em ${currencyFmt.format(rep.exceededAmount.cents / 100)} do limite planejado'
                : 'Restam ${currencyFmt.format(rep.remaining.cents / 100)} para gastar neste mês',
            style: TextStyle(
              fontSize: 11,
              color: rep.status == CategoryBudgetStatus.exceeded
                  ? AppColors.expense
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
