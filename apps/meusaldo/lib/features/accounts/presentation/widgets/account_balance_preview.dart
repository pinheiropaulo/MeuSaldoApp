import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Exibição somente leitura do saldo atual de uma conta em processo de edição.
class AccountBalancePreview extends StatelessWidget {
  /// Saldo atual calculado da conta.
  final Money balance;

  const AccountBalancePreview({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saldo atual',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MoneyDisplay(
                money: balance,
                color: AppColors.transfer,
                style: AppTypography.currencyRow(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text(
                    'Somente leitura',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'O saldo atual é calculado automaticamente a partir do histórico de movimentações.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}
