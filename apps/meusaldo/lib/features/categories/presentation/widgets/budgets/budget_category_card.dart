import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_visuals.dart';

/// Card individual de uma categoria orçada exibindo percentual e progresso de consumo.
class BudgetCategoryCard extends StatelessWidget {
  final CategoryBudgetReport report;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const BudgetCategoryCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
    final pctInt = (report.percentage * 100).toInt();

    final Color statusColor;
    final String badgeText;

    switch (report.status) {
      case CategoryBudgetStatus.exceeded:
        statusColor = AppColors.expense;
        badgeText = '$pctInt% (Estourado)';
      case CategoryBudgetStatus.warning:
        statusColor = AppColors.alert;
        badgeText = '$pctInt%';
      case CategoryBudgetStatus.ok:
        statusColor = AppColors.income;
        badgeText = '$pctInt%';
    }

    final catColor = CategoryVisuals.colorForCategory(report.category);
    final catIcon = CategoryVisuals.iconForCategory(report.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: report.status == CategoryBudgetStatus.exceeded
                  ? AppColors.expense.withValues(alpha: 0.5)
                  : AppColors.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: catColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(catIcon, color: catColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.category.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          report.status == CategoryBudgetStatus.exceeded
                              ? 'Estourou em ${currencyFmt.format(report.exceededAmount.cents / 100)}'
                              : 'Restam ${currencyFmt.format(report.remaining.cents / 100)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: report.status == CategoryBudgetStatus.exceeded
                                ? AppColors.expense
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Barra de Progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: report.percentage.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gasto: ${currencyFmt.format(report.spent.cents / 100)}',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Teto: ${currencyFmt.format(report.budget.cents / 100)}',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
