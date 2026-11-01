import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/bill_schedule_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/bill_schedule/bill_schedule_filter_chips.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/bill_schedule/bill_schedule_item_card.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/bill_schedule/bill_schedule_summary_card.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Tela orquestradora da Agenda de Contas e Próximos Vencimentos.
class BillScheduleScreen extends ConsumerWidget {
  const BillScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(billScheduleSummaryProvider);
    final overdueBills = ref.watch(overdueBillsProvider);
    final upcomingBills = ref.watch(upcomingBillsProvider);
    final paidBills = ref.watch(paidBillsProvider);
    final selectedFilter = ref.watch(billScheduleFilterProvider);
    final accounts = ref.watch(accountsListProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agenda de Contas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Próximos vencimentos', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppButton(
              label: '+ Adicionar',
              icon: Icons.add,
              fullWidth: false,
              onPressed: () => TransactionFormSheet.show(context, initialType: TransactionType.expense),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryHighlight,
        backgroundColor: AppColors.surface,
        onRefresh: () async => ref.invalidate(transactionsListProvider),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            BillScheduleSummaryCard(
              summary: summary,
              oldestOverdue: overdueBills.isNotEmpty ? overdueBills.first : null,
            ),
            const SizedBox(height: 12),
            BillScheduleFilterChips(
              selectedFilter: selectedFilter,
              onFilterSelected: (f) => ref.read(billScheduleFilterProvider.notifier).selectFilter(f),
              totalCount: overdueBills.length + upcomingBills.length + paidBills.length,
              overdueCount: overdueBills.length,
              upcomingCount: upcomingBills.length,
              paidCount: paidBills.length,
            ),
            const SizedBox(height: 16),
            if ((selectedFilter == BillScheduleFilter.all || selectedFilter == BillScheduleFilter.overdue) && overdueBills.isNotEmpty) ...[
              _buildSectionHeader('Contas Vencidas', Icons.error_outline, AppColors.expense, overdueBills),
              ...overdueBills.map((b) => _buildItem(context, ref, b, accounts)),
              const SizedBox(height: 12),
            ],
            if ((selectedFilter == BillScheduleFilter.all || selectedFilter == BillScheduleFilter.thisWeek) && upcomingBills.isNotEmpty) ...[
              _buildSectionHeader('Próximos Vencimentos', Icons.schedule, AppColors.alert, upcomingBills),
              ...upcomingBills.map((b) => _buildItem(context, ref, b, accounts)),
              const SizedBox(height: 12),
            ],
            if ((selectedFilter == BillScheduleFilter.all || selectedFilter == BillScheduleFilter.paid) && paidBills.isNotEmpty) ...[
              _buildSectionHeader('Contas Pagas no Mês', Icons.check_circle_outline, AppColors.income, paidBills),
              ...paidBills.map((b) => _buildItem(context, ref, b, accounts)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, List<Transaction> items) {
    var totalCents = 0;
    for (final it in items) { totalCents += it.amount.cents; }
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color))]),
          Text(Money.fromCents(totalCents).format(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, WidgetRef ref, Transaction bill, List<FinancialAccount> accounts) {
    final account = accounts.where((a) => a.id == bill.accountId).firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: BillScheduleItemCard(
        bill: bill,
        accountName: account?.name,
        onDarBaixa: () => _handleDarBaixa(context, ref, bill),
      ),
    );
  }

  Future<void> _handleDarBaixa(BuildContext context, WidgetRef ref, Transaction bill) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Dar baixa na conta?',
      message: 'Confirmar o pagamento de "${bill.description}" no valor de ${bill.amount.format()}?',
      confirmLabel: 'Confirmar Pagamento',
    );
    if (confirmed == true) {
      final updated = bill.copyWith(status: TransactionStatus.completed, date: DateTime.now());
      await ref.read(transactionsListProvider.notifier).updateTransaction(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Baixa registrada para ${bill.description}.'), duration: const Duration(seconds: 2)));
      }
    }
  }
}
