import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_card_item.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_form_sheet.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/accounts_header_section.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/empty_state_widget.dart';

/// Tela orquestradora de listagem e gestão de contas financeiras.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsListProvider);
    final consolidatedBalance = ref.watch(consolidatedBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet,
                color: AppColors.primaryHighlight, size: 24),
            SizedBox(width: 8),
            Text('Contas'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppButton(
              label: '+ Nova conta',
              fullWidth: false,
              onPressed: () => AccountFormSheet.show(context),
            ),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryHighlight),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erro ao carregar contas: $err',
              style: const TextStyle(color: AppColors.expense),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: EmptyStateWidget(
                  icon: Icons.account_balance,
                  title: 'Nenhuma conta cadastrada',
                  description:
                      'Cadastre suas contas bancárias, poupança, carteiras digitais ou dinheiro em espécie para acompanhar seus saldos e histórico.',
                  actionLabel: 'Cadastrar primeira conta',
                  onActionPressed: () => AccountFormSheet.show(context),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryHighlight,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.refresh(accountsListProvider.future),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                AccountsHeaderSection(
                  consolidatedBalance: consolidatedBalance,
                  accountsCount: accounts.length,
                ),
                ...accounts.map(
                  (acc) => AccountCardItem(
                    account: acc,
                    onTap: () => AccountFormSheet.show(context, account: acc),
                  ),
                ),
                const SizedBox(height: 8),
                AppButton.outlined(
                  label: '+ Adicionar nova conta',
                  icon: Icons.add_circle_outline,
                  onPressed: () => AccountFormSheet.show(context),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Saldos individuais e protegidos. Toque em uma conta para ver o histórico ou editá-la.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
