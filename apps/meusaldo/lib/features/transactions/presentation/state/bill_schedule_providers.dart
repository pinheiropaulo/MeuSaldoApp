import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Filtros de visualização para a agenda de contas a vencer.
enum BillScheduleFilter {
  all,
  overdue,
  thisWeek,
  paid,
}

/// Notifier do filtro de visualização da agenda.
class BillScheduleFilterNotifier extends Notifier<BillScheduleFilter> {
  @override
  BillScheduleFilter build() => BillScheduleFilter.all;

  void selectFilter(BillScheduleFilter filter) => state = filter;
}

/// Provedor do filtro selecionado na agenda de contas.
final billScheduleFilterProvider = NotifierProvider<BillScheduleFilterNotifier, BillScheduleFilter>(
  BillScheduleFilterNotifier.new,
);

/// Provedor de todas as contas/despesas da agenda (pendentes ou pagas no mês).
final allScheduleBillsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsListProvider).value ?? const [];
  return transactions.where((tx) => tx.isExpense).toList();
});

/// Contas atrasadas (pendentes com data anterior a hoje).
final overdueBillsProvider = Provider<List<Transaction>>((ref) {
  final bills = ref.watch(allScheduleBillsProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  return bills.where((tx) {
    return tx.isPending && tx.date.isBefore(todayStart);
  }).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

/// Próximos vencimentos (pendentes com data a partir de hoje).
final upcomingBillsProvider = Provider<List<Transaction>>((ref) {
  final bills = ref.watch(allScheduleBillsProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  return bills.where((tx) {
    return tx.isPending && !tx.date.isBefore(todayStart);
  }).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

/// Contas já pagas (efetivadas no mês corrente).
final paidBillsProvider = Provider<List<Transaction>>((ref) {
  final bills = ref.watch(allScheduleBillsProvider);
  final now = DateTime.now();

  return bills.where((tx) {
    return tx.isCompleted && tx.date.year == now.year && tx.date.month == now.month;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

/// Classe de dados com o resumo consolidado da agenda.
class BillScheduleSummary {
  final Money totalPending;
  final int pendingCount;
  final Money totalPaid;
  final Money totalOverdue;
  final int overdueCount;

  const BillScheduleSummary({
    required this.totalPending,
    required this.pendingCount,
    required this.totalPaid,
    required this.totalOverdue,
    required this.overdueCount,
  });
}

/// Provedor do resumo monetário e quantitativo da agenda.
final billScheduleSummaryProvider = Provider<BillScheduleSummary>((ref) {
  final overdue = ref.watch(overdueBillsProvider);
  final upcoming = ref.watch(upcomingBillsProvider);
  final paid = ref.watch(paidBillsProvider);

  var totalPendingCents = 0;
  for (final tx in overdue) {
    totalPendingCents += tx.amount.cents;
  }
  for (final tx in upcoming) {
    totalPendingCents += tx.amount.cents;
  }

  var totalOverdueCents = 0;
  for (final tx in overdue) {
    totalOverdueCents += tx.amount.cents;
  }

  var totalPaidCents = 0;
  for (final tx in paid) {
    totalPaidCents += tx.amount.cents;
  }

  return BillScheduleSummary(
    totalPending: Money.fromCents(totalPendingCents),
    pendingCount: overdue.length + upcoming.length,
    totalPaid: Money.fromCents(totalPaidCents),
    totalOverdue: Money.fromCents(totalOverdueCents),
    overdueCount: overdue.length,
  );
});
