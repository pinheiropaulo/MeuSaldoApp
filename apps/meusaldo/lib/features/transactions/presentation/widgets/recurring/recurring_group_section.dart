import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/recurring/recurring_item_card.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Seção visual que agrupa os lançamentos de uma categoria recorrente específica.
class RecurringGroupSection extends StatelessWidget {
  final RecurrenceCategory category;
  final List<RecurringTransaction> items;
  final void Function(String id) onToggleItem;

  const RecurringGroupSection({
    super.key,
    required this.category,
    required this.items,
    required this.onToggleItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isIncome = category == RecurrenceCategory.income;
    var totalCents = 0;
    for (final it in items) {
      if (it.isActive) {
        totalCents += it.amount.cents;
      }
    }
    final totalMoney = Money.fromCents(totalCents);
    final prefix = isIncome ? '+ ' : '- ';
    final totalColor = isIncome ? AppColors.income : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_getCategoryIcon(), size: 16, color: _getCategoryIconColor()),
                  const SizedBox(width: 6),
                  Text(
                    category.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '$prefix${totalMoney.format()}/mês',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: totalColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  const Divider(color: AppColors.outline, height: 1),
                RecurringItemCard(
                  item: items[i],
                  onToggle: () => onToggleItem(items[i].id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon() {
    switch (category) {
      case RecurrenceCategory.subscription:
        return Icons.subscriptions_outlined;
      case RecurrenceCategory.fixedExpense:
        return Icons.home_outlined;
      case RecurrenceCategory.income:
        return Icons.payments_outlined;
    }
  }

  Color _getCategoryIconColor() {
    switch (category) {
      case RecurrenceCategory.subscription:
        return AppColors.primaryHighlight;
      case RecurrenceCategory.fixedExpense:
        return AppColors.transfer;
      case RecurrenceCategory.income:
        return AppColors.income;
    }
  }
}
