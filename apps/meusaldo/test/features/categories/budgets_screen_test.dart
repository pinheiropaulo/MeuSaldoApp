import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meusaldo/features/categories/data/in_memory_category_repository.dart';
import 'package:meusaldo/features/categories/presentation/screens/budgets_screen.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/set_budget_sheet.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('BudgetsScreen renderiza resumo geral, filtros e categorias orçadas', (tester) async {
    final catRepo = InMemoryCategoryRepository(
      initialCategories: [
        Category.create(
          id: 'cat-lazer',
          name: 'Lazer & Restaurantes',
          type: CategoryType.expense,
          iconKey: 'sports_esports',
          colorHex: '#9B51E0',
          monthlyBudget: const Money.fromCents(20000), // R$ 200,00
        ),
      ],
    );

    final txRepo = InMemoryTransactionRepository(
      initialTransactions: [
        Transaction.create(
          id: 'tx-1',
          type: TransactionType.expense,
          amount: const Money.fromCents(25000), // R$ 250,00 (125% -> estourado)
          date: DateTime(2026, 11, 10),
          description: 'Cinema e Jantar',
          status: TransactionStatus.completed,
          accountId: 'acc-1',
          categoryId: 'cat-lazer',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(catRepo),
          transactionRepositoryProvider.overrideWithValue(txRepo),
        ],
        child: const MaterialApp(
          home: BudgetsScreen(),
        ),
      ),
    );

    final container = ProviderScope.containerOf(tester.element(find.byType(BudgetsScreen)));
    container.read(selectedBudgetMonthProvider.notifier).setMonth(DateTime(2026, 11));

    await tester.pumpAndSettle();

    // Valida Header
    expect(find.text('Orçamento Mensal'), findsOneWidget);
    expect(find.byKey(const Key('budgets_new_limit_button')), findsOneWidget);

    // Valida Hero Card de Orçamento
    expect(find.text('GASTOS VS. TETO PLANEJADO'), findsOneWidget);
    expect(find.text('125% do teto'), findsOneWidget);

    // Valida Card da Categoria Estourada
    expect(find.text('Lazer & Restaurantes'), findsOneWidget);
    expect(find.text('125% (Estourado)'), findsOneWidget);

    // Abre o modal de Novo Limite
    await tester.tap(find.byKey(const Key('budgets_new_limit_button')));
    await tester.pumpAndSettle();

    expect(find.byType(SetBudgetSheet), findsOneWidget);
  });
}
