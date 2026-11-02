import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/categories/data/in_memory_category_repository.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  group('Category Analytics and Budget Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(
            InMemoryCategoryRepository(
              initialCategories: [
                Category.create(
                  id: 'cat-alimentacao',
                  name: 'Alimentação',
                  type: CategoryType.expense,
                  monthlyBudget: const Money.fromCents(100000), // R$ 1.000,00
                ),
                Category.create(
                  id: 'cat-lazer',
                  name: 'Lazer',
                  type: CategoryType.expense,
                  monthlyBudget: const Money.fromCents(20000), // R$ 200,00
                ),
                Category.create(
                  id: 'cat-sem-teto',
                  name: 'Diversos',
                  type: CategoryType.expense,
                ),
              ],
            ),
          ),
          transactionRepositoryProvider.overrideWithValue(
            InMemoryTransactionRepository(
              initialTransactions: [
                Transaction.create(
                  id: 'tx-1',
                  type: TransactionType.expense,
                  amount: const Money.fromCents(50000), // R$ 500,00 (50% do teto)
                  date: DateTime(2026, 11, 5),
                  description: 'Mercado',
                  status: TransactionStatus.completed,
                  accountId: 'acc-1',
                  categoryId: 'cat-alimentacao',
                ),
                Transaction.create(
                  id: 'tx-2',
                  type: TransactionType.expense,
                  amount: const Money.fromCents(25000), // R$ 250,00 (125% do teto -> estourado)
                  date: DateTime(2026, 11, 10),
                  description: 'Restaurante e Bar',
                  status: TransactionStatus.completed,
                  accountId: 'acc-1',
                  categoryId: 'cat-lazer',
                ),
                Transaction.create(
                  id: 'tx-prev',
                  type: TransactionType.expense,
                  amount: const Money.fromCents(40000), // R$ 400,00 no mês anterior
                  date: DateTime(2026, 10, 15),
                  description: 'Mercado Outubro',
                  status: TransactionStatus.completed,
                  accountId: 'acc-1',
                  categoryId: 'cat-alimentacao',
                ),
              ],
            ),
          ),
        ],
      );

      // Define mês fixo: Novembro de 2026
      container
          .read(selectedBudgetMonthProvider.notifier)
          .setMonth(DateTime(2026, 11));
    });

    tearDown(() {
      container.dispose();
    });

    test('calcula relatórios de orçamento individuais por categoria corretamente', () async {
      // Garante carregamento das listas
      await container.read(categoriesListProvider.future);
      await container.read(transactionsListProvider.future);

      final reports = container.read(categoryBudgetReportsProvider);
      expect(reports.length, equals(2)); // Apenas as com teto definido

      final lazerReport = reports.firstWhere((r) => r.category.id == 'cat-lazer');
      expect(lazerReport.status, equals(CategoryBudgetStatus.exceeded));
      expect(lazerReport.spent, equals(const Money.fromCents(25000)));
      expect(lazerReport.budget, equals(const Money.fromCents(20000)));
      expect(lazerReport.exceededAmount, equals(const Money.fromCents(5000)));

      final alimentacaoReport =
          reports.firstWhere((r) => r.category.id == 'cat-alimentacao');
      expect(alimentacaoReport.status, equals(CategoryBudgetStatus.ok));
      expect(alimentacaoReport.spent, equals(const Money.fromCents(50000)));
      expect(alimentacaoReport.budget, equals(const Money.fromCents(100000)));
      expect(alimentacaoReport.remaining, equals(const Money.fromCents(50000)));
    });

    test('calcula resumo orçamentário geral consolidado com contadores de alerta', () async {
      await container.read(categoriesListProvider.future);
      await container.read(transactionsListProvider.future);

      final summary = container.read(overallBudgetSummaryProvider);
      expect(summary.totalBudget, equals(const Money.fromCents(120000))); // 1000 + 200
      expect(summary.totalSpent, equals(const Money.fromCents(75000))); // 500 + 250
      expect(summary.remaining, equals(const Money.fromCents(45000)));
      expect(summary.exceededCount, equals(1));
      expect(summary.okCount, equals(1));
    });

    test('calcula detalhes analíticos mensais da categoria com comparativo vs mês anterior', () async {
      await container.read(categoriesListProvider.future);
      await container.read(transactionsListProvider.future);

      final details = container.read(categoryMonthDetailsProvider('cat-alimentacao'));
      expect(details, isNotNull);
      expect(details!.spentInMonth, equals(const Money.fromCents(50000)));
      expect(details.spentPreviousMonth, equals(const Money.fromCents(40000)));
      expect(details.growthVsPreviousMonth, equals(25.0)); // de 400 para 500 = +25%
      expect(details.transactionsCount, equals(1));
      expect(details.budgetReport, isNotNull);
      expect(details.budgetReport!.percentage, equals(0.5));
    });
  });
}
