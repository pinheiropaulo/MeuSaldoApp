import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Seção com listagem de compras parceladas ativas e resumo de comprometimento mensal.
class CardInstallmentsSection extends StatelessWidget {
  final List<CardExpense> installments;
  final Money monthlyTotal;
  final VoidCallback? onViewAllTap;

  const CardInstallmentsSection({
    super.key,
    required this.installments,
    required this.monthlyTotal,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (installments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Compras Parceladas Ativas',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (onViewAllTap != null)
              TextButton(
                onPressed: onViewAllTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryHighlight,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: installments.length,
            separatorBuilder: (_, _) => const Divider(
              color: AppColors.outline,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final expense = installments[index];
              final icon = _getExpenseIcon(expense.description);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  expense.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (expense.installmentLabel != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.transfer.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.transfer.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    expense.installmentLabel!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.transfer,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Text(
                                'Restante: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              MoneyDisplay(
                                money: expense.remainingAmount,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MoneyDisplay(
                          money: expense.amount,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          '/mês',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Card de comprometimento mensal
        AppCard(
          color: AppColors.surfaceElevated,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    color: AppColors.primaryHighlight,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comprometimento Mensal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Total em parcelas ativas',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              MoneyDisplay(
                money: monthlyTotal,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryHighlight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getExpenseIcon(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('notebook') || lower.contains('dell') || lower.contains('celular') || lower.contains('iphone')) {
      return Icons.devices;
    }
    if (lower.contains('mercado') || lower.contains('supermercado') || lower.contains('compra')) {
      return Icons.shopping_cart_outlined;
    }
    if (lower.contains('curso') || lower.contains('faculdade') || lower.contains('livro')) {
      return Icons.school_outlined;
    }
    return Icons.credit_card;
  }
}
