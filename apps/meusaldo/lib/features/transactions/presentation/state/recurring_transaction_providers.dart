import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/shared/data/demo_data.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Filtros de visualização para lançamentos recorrentes.
enum RecurringFilterType {
  all,
  subscriptions,
  fixedExpenses,
  income;

  String get label {
    switch (this) {
      case RecurringFilterType.all:
        return 'Todas';
      case RecurringFilterType.subscriptions:
        return 'Assinaturas';
      case RecurringFilterType.fixedExpenses:
        return 'Despesas Fixas';
      case RecurringFilterType.income:
        return 'Receitas';
    }
  }
}

/// Notifier do filtro de recorrências selecionado.
class RecurringFilterNotifier extends Notifier<RecurringFilterType> {
  @override
  RecurringFilterType build() => RecurringFilterType.all;

  void selectFilter(RecurringFilterType filter) {
    state = filter;
  }
}

final recurringFilterProvider =
    NotifierProvider<RecurringFilterNotifier, RecurringFilterType>(
  RecurringFilterNotifier.new,
);

/// Notifier reativo para gestão de lançamentos recorrentes.
class RecurringListNotifier extends Notifier<List<RecurringTransaction>> {
  @override
  List<RecurringTransaction> build() {
    return DemoData.getRecurringTransactions();
  }

  /// Alterna o status ativo/pausado de uma recorrência.
  void toggleActive(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.toggleActive() else item,
    ];
  }

  /// Adiciona uma nova recorrência à lista.
  void addRecurring(RecurringTransaction item) {
    state = [item, ...state];
  }

  /// Remove uma recorrência da lista.
  void removeRecurring(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final recurringListProvider =
    NotifierProvider<RecurringListNotifier, List<RecurringTransaction>>(
  RecurringListNotifier.new,
);

/// Modelo de resumo consolidado de impacto financeiro mensal das recorrências.
class RecurringSummary {
  final Money totalFixedExpenses;
  final int commitmentPercentage;
  final Money subscriptionsTotal;
  final int activeSubscriptionsCount;
  final Money incomeTotal;
  final int incomeCount;

  const RecurringSummary({
    required this.totalFixedExpenses,
    required this.commitmentPercentage,
    required this.subscriptionsTotal,
    required this.activeSubscriptionsCount,
    required this.incomeTotal,
    required this.incomeCount,
  });
}

/// Provedor do cálculo consolidado de impacto financeiro mensal.
final recurringSummaryProvider = Provider<RecurringSummary>((ref) {
  final items = ref.watch(recurringListProvider);
  final activeItems = items.where((it) => it.isActive);

  var totalExpenseCents = 0;
  var subExpenseCents = 0;
  var subActiveCount = 0;
  var totalIncomeCents = 0;
  var incCount = 0;

  for (final item in activeItems) {
    if (item.type == TransactionType.expense) {
      totalExpenseCents += item.amount.cents;
      if (item.category == RecurrenceCategory.subscription) {
        subExpenseCents += item.amount.cents;
        subActiveCount++;
      }
    } else if (item.type == TransactionType.income) {
      totalIncomeCents += item.amount.cents;
      incCount++;
    }
  }

  final commitment = totalIncomeCents > 0
      ? ((totalExpenseCents / totalIncomeCents) * 100).round()
      : 0;

  return RecurringSummary(
    totalFixedExpenses: Money.fromCents(totalExpenseCents),
    commitmentPercentage: commitment,
    subscriptionsTotal: Money.fromCents(subExpenseCents),
    activeSubscriptionsCount: subActiveCount,
    incomeTotal: Money.fromCents(totalIncomeCents),
    incomeCount: incCount,
  );
});

/// Provedor com as contagens dinâmicas de cada filtro.
final recurringCountsProvider = Provider<Map<RecurringFilterType, int>>((ref) {
  final items = ref.watch(recurringListProvider);
  return {
    RecurringFilterType.all: items.length,
    RecurringFilterType.subscriptions: items
        .where((it) => it.category == RecurrenceCategory.subscription)
        .length,
    RecurringFilterType.fixedExpenses: items
        .where((it) => it.category == RecurrenceCategory.fixedExpense)
        .length,
    RecurringFilterType.income: items
        .where((it) => it.category == RecurrenceCategory.income)
        .length,
  };
});

/// Provedor da lista filtrada pelo chip ativo.
final filteredRecurringListProvider =
    Provider<List<RecurringTransaction>>((ref) {
  final filter = ref.watch(recurringFilterProvider);
  final items = ref.watch(recurringListProvider);

  switch (filter) {
    case RecurringFilterType.all:
      return items;
    case RecurringFilterType.subscriptions:
      return items
          .where((it) => it.category == RecurrenceCategory.subscription)
          .toList();
    case RecurringFilterType.fixedExpenses:
      return items
          .where((it) => it.category == RecurrenceCategory.fixedExpense)
          .toList();
    case RecurringFilterType.income:
      return items
          .where((it) => it.category == RecurrenceCategory.income)
          .toList();
  }
});
