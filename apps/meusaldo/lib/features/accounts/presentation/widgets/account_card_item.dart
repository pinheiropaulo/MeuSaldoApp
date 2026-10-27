import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_visuals.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Item de lista para exibição resumida e acionamento de uma conta financeira.
class AccountCardItem extends StatelessWidget {
  /// Conta financeira a ser renderizada.
  final FinancialAccount account;

  /// Ação executada ao tocar no card (ex: abrir edição/detalhes).
  final VoidCallback? onTap;

  const AccountCardItem({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accountColor = AccountVisuals.colorForAccount(account);
    final iconData = AccountVisuals.iconForType(account.type);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          // Ícone e avatar da instituição / tipo de conta
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accountColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accountColor.withValues(alpha: 0.38),
                width: 1,
              ),
            ),
            child: Icon(
              iconData,
              color: accountColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Informações textuais (Nome e Badge do Tipo)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    account.type.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Saldo da conta e indicador de navegação
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoneyDisplay(
                money: account.currentBalance,
                color: account.currentBalance.isNegative
                    ? AppColors.expense
                    : AppColors.transfer,
                style: AppTypography.currencyRow(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
