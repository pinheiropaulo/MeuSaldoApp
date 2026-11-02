import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Dados de gasto de uma semana do mês.
class WeeklyExpenseItem {
  final String label; // "Sem 1", "Sem 2", etc.
  final Money amount;
  final double heightFactor; // Proporcional ao maior gasto da semana (0.0 a 1.0)
  final bool isPeak;

  const WeeklyExpenseItem({
    required this.label,
    required this.amount,
    required this.heightFactor,
    required this.isPeak,
  });
}

/// Participação de uma categoria no total de despesas do mês.
class CategoryExpenseShare {
  final Category category;
  final Money spent;
  final double percentage; // 0.0 a 1.0

  const CategoryExpenseShare({
    required this.category,
    required this.spent,
    required this.percentage,
  });
}

/// Dados consolidados do relatório financeiro mensal.
class MonthlyReportData {
  final DateTime month;
  final Money totalIncome;
  final Money totalExpense;
  final Money netBalance;
  final double savingsRate; // % de economia sobre a receita
  final Money expenseDiffPreviousMonth;
  final double? expenseGrowthPreviousMonth;
  final Money dailyAverage;
  final List<WeeklyExpenseItem> weeklyExpenses;
  final List<CategoryExpenseShare> categoryShares;

  const MonthlyReportData({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.savingsRate,
    required this.expenseDiffPreviousMonth,
    required this.expenseGrowthPreviousMonth,
    required this.dailyAverage,
    required this.weeklyExpenses,
    required this.categoryShares,
  });
}

/// Provedor reativo de dados para o relatório mensal baseado no mês selecionado.
final monthlyReportProvider = Provider<MonthlyReportData>((ref) {
  final month = ref.watch(selectedBudgetMonthProvider);
  final allTransactions = ref.watch(transactionsListProvider).value ?? [];
  final allCategories = ref.watch(categoriesListProvider).value ?? [];

  // Transações do mês selecionado
  final currentMonthTxs = allTransactions.where((tx) {
    return tx.date.year == month.year && tx.date.month == month.month;
  }).toList();

  int totalIncomeCents = 0;
  int totalExpenseCents = 0;
  final Map<String, int> expenseByCategoryCents = {};

  int sem1Cents = 0;
  int sem2Cents = 0;
  int sem3Cents = 0;
  int sem4Cents = 0;

  for (final tx in currentMonthTxs) {
    if (tx.type == TransactionType.income) {
      totalIncomeCents += tx.amount.cents;
    } else if (tx.type == TransactionType.expense) {
      totalExpenseCents += tx.amount.cents;
      final catId = tx.categoryId ?? 'sem_categoria';
      expenseByCategoryCents[catId] =
          (expenseByCategoryCents[catId] ?? 0) + tx.amount.cents;

      // Distribuição semanal
      final day = tx.date.day;
      if (day <= 7) {
        sem1Cents += tx.amount.cents;
      } else if (day <= 14) {
        sem2Cents += tx.amount.cents;
      } else if (day <= 21) {
        sem3Cents += tx.amount.cents;
      } else {
        sem4Cents += tx.amount.cents;
      }
    }
  }

  // Mês anterior para cálculo comparativo
  final previousMonth = DateTime(month.year, month.month - 1);
  int previousExpenseCents = 0;
  for (final tx in allTransactions) {
    if (tx.type == TransactionType.expense &&
        tx.date.year == previousMonth.year &&
        tx.date.month == previousMonth.month) {
      previousExpenseCents += tx.amount.cents;
    }
  }

  // Resultado Líquido & Taxa de Poupança
  final netBalanceCents = totalIncomeCents - totalExpenseCents;
  final double savingsRate = totalIncomeCents > 0
      ? (netBalanceCents / totalIncomeCents) * 100
      : 0.0;

  // Comparativo com mês anterior
  final diffExpenseCents = (totalExpenseCents - previousExpenseCents).abs();
  double? growthPct;
  if (previousExpenseCents > 0) {
    growthPct =
        ((totalExpenseCents - previousExpenseCents) / previousExpenseCents) *
            100;
  }

  // Média Diária
  final now = DateTime.now();
  final isCurrentMonth = now.year == month.year && now.month == month.month;
  final daysCount = isCurrentMonth
      ? now.day
      : DateTime(month.year, month.month + 1, 0).day;
  final dailyAvgCents = daysCount > 0 ? (totalExpenseCents ~/ daysCount) : 0;

  // Semanas
  final weekAmounts = [sem1Cents, sem2Cents, sem3Cents, sem4Cents];
  int maxWeekCents = 1;
  for (final val in weekAmounts) {
    if (val > maxWeekCents) maxWeekCents = val;
  }

  final weeklyItems = [
    WeeklyExpenseItem(
      label: 'Sem 1',
      amount: Money.fromCents(sem1Cents),
      heightFactor: (sem1Cents / maxWeekCents).clamp(0.1, 1.0),
      isPeak: sem1Cents == maxWeekCents && sem1Cents > 0,
    ),
    WeeklyExpenseItem(
      label: 'Sem 2',
      amount: Money.fromCents(sem2Cents),
      heightFactor: (sem2Cents / maxWeekCents).clamp(0.1, 1.0),
      isPeak: sem2Cents == maxWeekCents && sem2Cents > 0,
    ),
    WeeklyExpenseItem(
      label: 'Sem 3',
      amount: Money.fromCents(sem3Cents),
      heightFactor: (sem3Cents / maxWeekCents).clamp(0.1, 1.0),
      isPeak: sem3Cents == maxWeekCents && sem3Cents > 0,
    ),
    WeeklyExpenseItem(
      label: 'Sem 4',
      amount: Money.fromCents(sem4Cents),
      heightFactor: (sem4Cents / maxWeekCents).clamp(0.1, 1.0),
      isPeak: sem4Cents == maxWeekCents && sem4Cents > 0,
    ),
  ];

  // Distribuição por Categoria
  final List<CategoryExpenseShare> shares = [];
  for (final entry in expenseByCategoryCents.entries) {
    final cat = allCategories.cast<Category?>().firstWhere(
          (c) => c?.id == entry.key,
          orElse: () => Category.create(
            id: entry.key,
            name: 'Outros',
            type: CategoryType.expense,
          ),
        );

    final double pct = totalExpenseCents > 0
        ? entry.value / totalExpenseCents
        : 0.0;

    shares.add(
      CategoryExpenseShare(
        category: cat!,
        spent: Money.fromCents(entry.value),
        percentage: pct,
      ),
    );
  }

  shares.sort((a, b) => b.spent.cents.compareTo(a.spent.cents));

  return MonthlyReportData(
    month: month,
    totalIncome: Money.fromCents(totalIncomeCents),
    totalExpense: Money.fromCents(totalExpenseCents),
    netBalance: Money.fromCents(netBalanceCents),
    savingsRate: savingsRate,
    expenseDiffPreviousMonth: Money.fromCents(diffExpenseCents),
    expenseGrowthPreviousMonth: growthPct,
    dailyAverage: Money.fromCents(dailyAvgCents),
    weeklyExpenses: weeklyItems,
    categoryShares: shares,
  );
});
