import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/screens/edit_account_screen.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_details_providers.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/details/account_bento_stats.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/details/account_empty_transactions_card.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/details/account_hero_card.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_details_sheet.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Tela orquestradora de detalhes da conta bancária e extrato individual cronológico.
class AccountDetailsScreen extends ConsumerWidget {
  final String accountId;

  const AccountDetailsScreen({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountByIdProvider(accountId));
    final transactions = ref.watch(accountTransactionsProvider(accountId));
    final stats = ref.watch(accountMonthlyStatsProvider(accountId));
    final categories = ref.watch(categoriesListProvider).value ?? const [];

    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conta')),
        body: const Center(
          child: Text(
            'Conta não encontrada.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conta Bancária',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              account.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            tooltip: 'Editar conta',
            onPressed: () {
              try {
                context.push('/accounts/${account.id}/edit');
              } catch (_) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EditAccountScreen(account: account),
                ));
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          AccountHeroCard(account: account),
          const SizedBox(height: 12),
          AccountBentoStats(stats: stats),
          const SizedBox(height: 16),
          _buildTransactionsSectionHeader(transactions.length),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            AccountEmptyTransactionsCard(accountId: account.id)
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < transactions.length; i++) ...[
                    if (i > 0)
                      const Divider(color: AppColors.outline, height: 1),
                    TransactionListItem(
                      transaction: transactions[i],
                      accountName: account.name,
                      categoryName: categories
                          .where((c) => c.id == transactions[i].categoryId)
                          .map((c) => c.name)
                          .firstOrNull,
                      onTap: () => TransactionDetailsSheet.show(
                        context,
                        transactions[i],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTransactionsSectionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Movimentações',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.outline),
          ),
          child: Text(
            '$count ${count == 1 ? 'registro' : 'registros'}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
