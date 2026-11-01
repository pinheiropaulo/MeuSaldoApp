import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_details_providers.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_visuals.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card hero de saldo com identificação institucional, alternador de privacidade e ações rápidas.
class AccountHeroCard extends ConsumerWidget {
  final FinancialAccount account;

  const AccountHeroCard({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(accountBalanceVisibilityProvider);
    final iconColor = AccountVisuals.colorForAccount(account);
    final iconData = AccountVisuals.iconForType(account.type);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Avatar + Nome da Conta + Badge de Tipo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.type.displayName} • MeuSaldo',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 13,
                      color: AppColors.income,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      account.type.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bloco Monetário + Botão Ocultar/Exibir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo disponível',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: () =>
                    ref.read(accountBalanceVisibilityProvider.notifier).toggle(),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        isVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isVisible ? 'Ocultar' : 'Exibir',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'R\$ ',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.transfer,
                ),
              ),
              Text(
                isVisible
                    ? account.currentBalance.format(includeSymbol: false)
                    : '••••••',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.transfer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.sync, size: 14, color: AppColors.income),
              SizedBox(width: 4),
              Text(
                'Atualizado em tempo real',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.outline, height: 1),
          const SizedBox(height: 14),

          // Grade de Ações: + Movimentação | Transferir
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: AppColors.primaryHighlight,
                    ),
                    label: const Text(
                      '+ Movimentação',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => TransactionFormSheet.show(
                      context,
                      initialAccountId: account.id,
                      initialType: TransactionType.expense,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.surfaceElevated,
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text(
                      'Transferir',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => TransactionFormSheet.show(
                      context,
                      initialAccountId: account.id,
                      initialType: TransactionType.transfer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
