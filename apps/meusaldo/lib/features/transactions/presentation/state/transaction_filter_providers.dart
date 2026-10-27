import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Notifier que controla o período mensal selecionado para exibição do extrato.
class SelectedPeriodNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  /// Recua um mês no calendário.
  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  /// Avança um mês no calendário.
  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  /// Define um período específico.
  void setPeriod(DateTime period) {
    state = DateTime(period.year, period.month);
  }
}

/// Provedor do período mensal atualmente selecionado.
final selectedPeriodProvider =
    NotifierProvider<SelectedPeriodNotifier, DateTime>(
  SelectedPeriodNotifier.new,
);

/// Notifier que controla o filtro de tipo de movimentação (Todos, Receitas, Despesas, Transferências).
class SelectedTypeFilterNotifier extends Notifier<TransactionType?> {
  @override
  TransactionType? build() => null; // null representa "Todos"

  /// Altera o filtro de tipo selecionado.
  void selectType(TransactionType? type) {
    state = type;
  }
}

/// Provedor do filtro de tipo de lançamento selecionado.
final selectedTypeFilterProvider =
    NotifierProvider<SelectedTypeFilterNotifier, TransactionType?>(
  SelectedTypeFilterNotifier.new,
);

/// Provedor dos lançamentos filtrados pelo período e tipo, ordenados por data decrescente.
final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final allAsync = ref.watch(transactionsListProvider);
  final period = ref.watch(selectedPeriodProvider);
  final typeFilter = ref.watch(selectedTypeFilterProvider);

  final list = allAsync.value ?? const [];
  final filtered = list.where((tx) {
    final matchesPeriod =
        tx.date.year == period.year && tx.date.month == period.month;
    if (!matchesPeriod) return false;
    if (typeFilter != null && tx.type != typeFilter) return false;
    return true;
  }).toList();

  filtered.sort((a, b) => b.date.compareTo(a.date));
  return filtered;
});

/// Provedor dos lançamentos agrupados por dia (data sem horário).
final groupedTransactionsProvider =
    Provider<Map<DateTime, List<Transaction>>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  final groups = <DateTime, List<Transaction>>{};

  for (final tx in transactions) {
    final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
    groups.putIfAbsent(dateKey, () => []).add(tx);
  }

  return groups;
});
