import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_visuals.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Seção resumida das contas financeiras ativas com atalho para a listagem completa.
class HomeAccountsSection extends StatelessWidget {
  /// Lista de contas financeiras ativas.
  final List<FinancialAccount> accounts;

  /// Indica se os valores de saldo estão visíveis ou ocultos.
  final bool isVisible;

  /// Callback para navegar para a aba completa de Contas.
  final VoidCallback onViewAll;

  /// Callback ao tocar em uma conta específica.
  final ValueChanged<FinancialAccount>? onAccountTap;

  const HomeAccountsSection({
    super.key,
    required this.accounts,
    required this.isVisible,
    required this.onViewAll,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    // Exibe no máximo as 3 primeiras contas ativas no dashboard
    final previewAccounts = accounts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minhas contas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  color: AppColors.primaryHighlight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (previewAccounts.isEmpty)
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline, width: 1),
              ),
              child: const Center(
                child: Text(
                  'Nenhuma conta cadastrada. Toque para cadastrar.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
        else
          ...previewAccounts.map((account) {
            final color = AccountVisuals.colorForAccount(account);
            final icon = AccountVisuals.iconForType(account.type);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline, width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (onAccountTap != null) {
                      onAccountTap!(account);
                    } else {
                      onViewAll();
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                account.type.displayName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isVisible)
                          MoneyDisplay(
                            money: account.currentBalance,
                            color: account.currentBalance.isNegative
                                ? AppColors.expense
                                : AppColors.transfer,
                            style: AppTypography.currencyRow(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          const Text(
                            '••••••',
                            style: TextStyle(
                              color: AppColors.transfer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
