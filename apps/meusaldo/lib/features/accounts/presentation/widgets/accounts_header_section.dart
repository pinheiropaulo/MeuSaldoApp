import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Seção superior da tela de contas com saldo consolidado e contagem de contas.
class AccountsHeaderSection extends StatelessWidget {
  /// Saldo financeiro consolidado de todas as contas ativas.
  final Money consolidatedBalance;

  /// Quantidade total de contas cadastradas.
  final int accountsCount;

  const AccountsHeaderSection({
    super.key,
    required this.consolidatedBalance,
    required this.accountsCount,
  });

  @override
  Widget build(BuildContext context) {
    final countLabel = accountsCount == 1
        ? '1 conta cadastrada'
        : '$accountsCount contas cadastradas';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card de Saldo Consolidado
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo total consolidado',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 18,
                    color: AppColors.primaryHighlight,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              MoneyDisplay.hero(
                money: consolidatedBalance,
                color: consolidatedBalance.isNegative
                    ? AppColors.expense
                    : AppColors.transfer,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Barra de metadados (Contagem e Ordem)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance,
                    size: 16,
                    color: AppColors.primaryHighlight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    countLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.swap_vert,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ordem: Tipo ou Saldo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
