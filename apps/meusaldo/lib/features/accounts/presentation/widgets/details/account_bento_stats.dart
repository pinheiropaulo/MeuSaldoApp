import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_details_providers.dart';

/// Cards bento com o somatório de entradas e saídas do mês da conta financeira.
class AccountBentoStats extends StatelessWidget {
  final AccountMonthlyStats stats;

  const AccountBentoStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Entradas no mês
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entradas no mês',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+ ${stats.monthlyIncome.format()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.income,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.income.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    size: 18,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Saídas no mês
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saídas no mês',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '- ${stats.monthlyExpense.format()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.expense.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.trending_down,
                    size: 18,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
