import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/state/recurring_transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/recurring/add_recurring_sheet.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/recurring/recurring_filter_chips.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/recurring/recurring_group_section.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/recurring/recurring_summary_card.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/empty_state_widget.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Tela orquestradora de gestão de lançamentos recorrentes e assinaturas fixas.
class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(recurringSummaryProvider);
    final counts = ref.watch(recurringCountsProvider);
    final selectedFilter = ref.watch(recurringFilterProvider);
    final filteredItems = ref.watch(filteredRecurringListProvider);

    final subscriptions = filteredItems
        .where((it) => it.category == RecurrenceCategory.subscription)
        .toList();
    final fixedExpenses = filteredItems
        .where((it) => it.category == RecurrenceCategory.fixedExpense)
        .toList();
    final incomes = filteredItems
        .where((it) => it.category == RecurrenceCategory.income)
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recorrências',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              'Assinaturas e despesas fixas',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppButton(
              label: '+ Nova',
              fullWidth: false,
              onPressed: () => AddRecurringSheet.show(context),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          RecurringSummaryCard(summary: summary),
          const SizedBox(height: 14),
          RecurringFilterChips(
            selectedFilter: selectedFilter,
            counts: counts,
            onFilterSelected: (f) =>
                ref.read(recurringFilterProvider.notifier).selectFilter(f),
          ),
          const SizedBox(height: 14),
          if (filteredItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: EmptyStateWidget(
                title: 'Nenhuma recorrência encontrada',
                description:
                    'Cadastre assinaturas e despesas fixas para monitorar seu comprometimento mensal.',
                icon: Icons.repeat,
              ),
            )
          else ...[
            if (subscriptions.isNotEmpty)
              RecurringGroupSection(
                category: RecurrenceCategory.subscription,
                items: subscriptions,
                onToggleItem: (id) =>
                    ref.read(recurringListProvider.notifier).toggleActive(id),
              ),
            if (fixedExpenses.isNotEmpty) ...[
              const SizedBox(height: 12),
              RecurringGroupSection(
                category: RecurrenceCategory.fixedExpense,
                items: fixedExpenses,
                onToggleItem: (id) =>
                    ref.read(recurringListProvider.notifier).toggleActive(id),
              ),
            ],
            if (incomes.isNotEmpty) ...[
              const SizedBox(height: 12),
              RecurringGroupSection(
                category: RecurrenceCategory.income,
                items: incomes,
                onToggleItem: (id) =>
                    ref.read(recurringListProvider.notifier).toggleActive(id),
              ),
            ],
          ],
        ],
      ),
      bottomSheet: Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AppButton(
          label: 'Adicionar Nova Recorrência',
          icon: Icons.add_circle_outline,
          onPressed: () => AddRecurringSheet.show(context),
        ),
      ),
    );
  }
}
