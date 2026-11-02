import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Notifier que gerencia o mês selecionado para acompanhamento de orçamentos e detalhes de categoria.
class SelectedBudgetMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime month) => state = month;
  void nextMonth() => state = DateTime(state.year, state.month + 1);
  void prevMonth() => state = DateTime(state.year, state.month - 1);
}

/// Provedor do mês selecionado.
final selectedBudgetMonthProvider =
    NotifierProvider<SelectedBudgetMonthNotifier, DateTime>(
  SelectedBudgetMonthNotifier.new,
);

/// Status de conformidade do orçamento da categoria.
enum CategoryBudgetStatus {
  ok, // < 80% do teto consumido
  warning, // >= 80% e <= 100% do teto consumido
  exceeded, // > 100% do teto consumido
}

/// Relatório de orçamento de uma categoria em um mês específico.
class CategoryBudgetReport {
  final Category category;
  final Money budget;
  final Money spent;
  final double percentage; // 0.0 a 1.0+
  final CategoryBudgetStatus status;
  final Money remaining;
  final Money exceededAmount;

  const CategoryBudgetReport({
    required this.category,
    required this.budget,
    required this.spent,
    required this.percentage,
    required this.status,
    required this.remaining,
    required this.exceededAmount,
  });

  factory CategoryBudgetReport.compute({
    required Category category,
    required Money spent,
  }) {
    final budget = category.monthlyBudget ?? const Money.zero();
    if (budget.isZero) {
      return CategoryBudgetReport(
        category: category,
        budget: const Money.zero(),
        spent: spent,
        percentage: 0.0,
        status: CategoryBudgetStatus.ok,
        remaining: const Money.zero(),
        exceededAmount: const Money.zero(),
      );
    }

    final double pct = spent.cents / budget.cents;
    final CategoryBudgetStatus status;
    final Money remaining;
    final Money exceeded;

    if (spent.cents > budget.cents) {
      status = CategoryBudgetStatus.exceeded;
      remaining = const Money.zero();
      exceeded = Money.fromCents(spent.cents - budget.cents);
    } else {
      if (pct >= 0.8) {
        status = CategoryBudgetStatus.warning;
      } else {
        status = CategoryBudgetStatus.ok;
      }
      remaining = Money.fromCents(budget.cents - spent.cents);
      exceeded = const Money.zero();
    }

    return CategoryBudgetReport(
      category: category,
      budget: budget,
      spent: spent,
      percentage: pct,
      status: status,
      remaining: remaining,
      exceededAmount: exceeded,
    );
  }
}

/// Resumo consolidado de todos os orçamentos no mês selecionado.
class OverallBudgetSummary {
  final Money totalBudget;
  final Money totalSpent;
  final double percentage;
  final Money remaining;
  final int exceededCount;
  final int warningCount;
  final int okCount;
  final List<CategoryBudgetReport> reports;

  const OverallBudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.percentage,
    required this.remaining,
    required this.exceededCount,
    required this.warningCount,
    required this.okCount,
    required this.reports,
  });
}

/// Provedor da lista de relatórios de orçamento para o mês selecionado.
final categoryBudgetReportsProvider =
    Provider<List<CategoryBudgetReport>>((ref) {
  final categoriesAsync = ref.watch(categoriesListProvider);
  final transactionsAsync = ref.watch(transactionsListProvider);
  final month = ref.watch(selectedBudgetMonthProvider);

  final categories = categoriesAsync.value ?? [];
  final transactions = transactionsAsync.value ?? [];

  // Considera apenas categorias que possuem teto orçamentário definido
  final budgetedCategories = categories
      .where((cat) => cat.monthlyBudget != null && !cat.monthlyBudget!.isZero)
      .toList();

  final List<CategoryBudgetReport> reports = [];

  for (final category in budgetedCategories) {
    final categoryExpenses = transactions.where((tx) {
      return tx.type == TransactionType.expense &&
          tx.categoryId == category.id &&
          tx.date.year == month.year &&
          tx.date.month == month.month;
    });

    int totalCents = 0;
    for (final tx in categoryExpenses) {
      totalCents += tx.amount.cents;
    }

    reports.add(
      CategoryBudgetReport.compute(
        category: category,
        spent: Money.fromCents(totalCents),
      ),
    );
  }

  // Ordena por criticidade: estourados primeiro, depois alertas, depois ok
  reports.sort((a, b) => b.percentage.compareTo(a.percentage));
  return reports;
});

/// Provedor do resumo orçamentário geral consolidado.
final overallBudgetSummaryProvider = Provider<OverallBudgetSummary>((ref) {
  final reports = ref.watch(categoryBudgetReportsProvider);

  int totalBudgetCents = 0;
  int totalSpentCents = 0;
  int exceeded = 0;
  int warning = 0;
  int ok = 0;

  for (final r in reports) {
    totalBudgetCents += r.budget.cents;
    totalSpentCents += r.spent.cents;
    switch (r.status) {
      case CategoryBudgetStatus.exceeded:
        exceeded++;
      case CategoryBudgetStatus.warning:
        warning++;
      case CategoryBudgetStatus.ok:
        ok++;
    }
  }

  final double pct = totalBudgetCents > 0
      ? (totalSpentCents / totalBudgetCents)
      : 0.0;
  final remainingCents = totalBudgetCents > totalSpentCents
      ? (totalBudgetCents - totalSpentCents)
      : 0;

  return OverallBudgetSummary(
    totalBudget: Money.fromCents(totalBudgetCents),
    totalSpent: Money.fromCents(totalSpentCents),
    percentage: pct,
    remaining: Money.fromCents(remainingCents),
    exceededCount: exceeded,
    warningCount: warning,
    okCount: ok,
    reports: reports,
  );
});

/// Detalhes analíticos de uma categoria específica para o mês selecionado.
class CategoryMonthDetails {
  final Category category;
  final DateTime month;
  final Money spentInMonth;
  final Money totalExpensesInMonth;
  final double percentageOfTotalExpenses;
  final int transactionsCount;
  final Money dailyAverage;
  final Money spentPreviousMonth;
  final double? growthVsPreviousMonth;
  final Money differenceVsPreviousMonth;
  final CategoryBudgetReport? budgetReport;
  final List<Transaction> transactions;

  const CategoryMonthDetails({
    required this.category,
    required this.month,
    required this.spentInMonth,
    required this.totalExpensesInMonth,
    required this.percentageOfTotalExpenses,
    required this.transactionsCount,
    required this.dailyAverage,
    required this.spentPreviousMonth,
    required this.growthVsPreviousMonth,
    required this.differenceVsPreviousMonth,
    required this.budgetReport,
    required this.transactions,
  });
}

/// Provedor dos detalhes analíticos mensais de uma categoria informada.
final categoryMonthDetailsProvider =
    Provider.family<CategoryMonthDetails?, String>((ref, categoryId) {
  final categories = ref.watch(categoriesListProvider).value ?? [];
  final allTransactions = ref.watch(transactionsListProvider).value ?? [];
  final month = ref.watch(selectedBudgetMonthProvider);

  final category = categories.cast<Category?>().firstWhere(
        (c) => c?.id == categoryId,
        orElse: () => null,
      );

  if (category == null) return null;

  // Transações da categoria no mês atual
  final categoryTxs = allTransactions.where((tx) {
    return tx.type == TransactionType.expense &&
        tx.categoryId == category.id &&
        tx.date.year == month.year &&
        tx.date.month == month.month;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  int categorySpentCents = 0;
  for (final tx in categoryTxs) {
    categorySpentCents += tx.amount.cents;
  }

  // Total geral de despesas no mês (todas as categorias)
  int allExpensesCents = 0;
  for (final tx in allTransactions) {
    if (tx.type == TransactionType.expense &&
        tx.date.year == month.year &&
        tx.date.month == month.month) {
      allExpensesCents += tx.amount.cents;
    }
  }

  final double percentageOfTotal = allExpensesCents > 0
      ? (categorySpentCents / allExpensesCents)
      : 0.0;

  // Média diária
  final now = DateTime.now();
  final isCurrentMonth = now.year == month.year && now.month == month.month;
  final daysCount = isCurrentMonth
      ? now.day
      : DateTime(month.year, month.month + 1, 0).day;
  final dailyAvgCents = daysCount > 0 ? (categorySpentCents ~/ daysCount) : 0;

  // Gastos no mês anterior
  final previousMonth = DateTime(month.year, month.month - 1);
  final previousTxs = allTransactions.where((tx) {
    return tx.type == TransactionType.expense &&
        tx.categoryId == category.id &&
        tx.date.year == previousMonth.year &&
        tx.date.month == previousMonth.month;
  });

  int previousSpentCents = 0;
  for (final tx in previousTxs) {
    previousSpentCents += tx.amount.cents;
  }

  double? growthPct;
  if (previousSpentCents > 0) {
    growthPct =
        ((categorySpentCents - previousSpentCents) / previousSpentCents) * 100;
  }

  final diffCents = (categorySpentCents - previousSpentCents).abs();

  // Relatório de orçamento (se a categoria tiver limite definido)
  CategoryBudgetReport? budgetReport;
  if (category.monthlyBudget != null && !category.monthlyBudget!.isZero) {
    budgetReport = CategoryBudgetReport.compute(
      category: category,
      spent: Money.fromCents(categorySpentCents),
    );
  }

  return CategoryMonthDetails(
    category: category,
    month: month,
    spentInMonth: Money.fromCents(categorySpentCents),
    totalExpensesInMonth: Money.fromCents(allExpensesCents),
    percentageOfTotalExpenses: percentageOfTotal,
    transactionsCount: categoryTxs.length,
    dailyAverage: Money.fromCents(dailyAvgCents),
    spentPreviousMonth: Money.fromCents(previousSpentCents),
    growthVsPreviousMonth: growthPct,
    differenceVsPreviousMonth: Money.fromCents(diffCents),
    budgetReport: budgetReport,
    transactions: categoryTxs,
  );
});
