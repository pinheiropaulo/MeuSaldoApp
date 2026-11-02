import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';

/// Navegador mensal com setas para alternar o período analisado.
class CategoryMonthNavigator extends ConsumerWidget {
  const CategoryMonthNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedBudgetMonthProvider);
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    final monthName =
        DateFormat('MMMM yyyy', 'pt_BR').format(selectedMonth);
    final capitalizedMonth =
        monthName[0].toUpperCase() + monthName.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            key: const Key('category_month_prev_button'),
            icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            onPressed: () {
              ref.read(selectedBudgetMonthProvider.notifier).prevMonth();
            },
          ),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primaryHighlight,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                capitalizedMonth,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isCurrentMonth) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.primaryHighlight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Atual',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryHighlight,
                    ),
                  ),
                ),
              ],
            ],
          ),
          IconButton(
            key: const Key('category_month_next_button'),
            icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onPressed: () {
              ref.read(selectedBudgetMonthProvider.notifier).nextMonth();
            },
          ),
        ],
      ),
    );
  }
}
