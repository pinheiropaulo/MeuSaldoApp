import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_filter_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_group_card.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_group_header.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_period_selector.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_type_filter_bar.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/empty_state_widget.dart';

/// Tela orquestradora de histórico e gestão de lançamentos financeiros.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final selectedType = ref.watch(selectedTypeFilterProvider);
    final groupedTransactions = ref.watch(groupedTransactionsProvider);
    final accounts = ref.watch(accountsListProvider).value ?? const [];
    final categories = ref.watch(categoriesListProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.receipt_long,
                color: AppColors.primaryHighlight, size: 24),
            SizedBox(width: 8),
            Text('Lançamentos'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppButton(
              label: '+ Novo',
              fullWidth: false,
              onPressed: () => TransactionFormSheet.show(context),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryHighlight,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(transactionsListProvider);
          ref.invalidate(accountsListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            TransactionPeriodSelector(
              selectedPeriod: period,
              onPreviousMonth: () =>
                  ref.read(selectedPeriodProvider.notifier).previousMonth(),
              onNextMonth: () =>
                  ref.read(selectedPeriodProvider.notifier).nextMonth(),
            ),
            const SizedBox(height: 12),
            TransactionTypeFilterBar(
              selectedType: selectedType,
              onTypeSelected: (type) => ref
                  .read(selectedTypeFilterProvider.notifier)
                  .selectType(type),
            ),
            const SizedBox(height: 12),
            if (groupedTransactions.isEmpty) ...[
              const SizedBox(height: 36),
              EmptyStateWidget(
                icon: Icons.receipt_long,
                title: 'Nenhum lançamento no período',
                description:
                    'Não foram encontradas movimentações para o filtro selecionado.',
                actionLabel: '+ Novo lançamento',
                onActionPressed: () => TransactionFormSheet.show(context),
              ),
            ] else
              ...groupedTransactions.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TransactionGroupHeader(
                      date: entry.key,
                      transactions: entry.value,
                    ),
                    TransactionGroupCard(
                      transactions: entry.value,
                      accounts: accounts,
                      categories: categories,
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
