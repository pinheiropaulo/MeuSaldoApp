import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meusaldo/features/categories/data/in_memory_category_repository.dart';
import 'package:meusaldo/features/categories/presentation/screens/category_details_screen.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('CategoryDetailsScreen renderiza dados da categoria, métricas e lançamentos', (tester) async {
    final catRepo = InMemoryCategoryRepository(
      initialCategories: [
        Category.create(
          id: 'cat-alimentacao',
          name: 'Alimentação & Bebidas',
          type: CategoryType.expense,
          iconKey: 'restaurant',
          colorHex: '#F04444',
          description: 'Mercado e compras',
          monthlyBudget: const Money.fromCents(150000), // R$ 1.500,00
        ),
      ],
    );

    final txRepo = InMemoryTransactionRepository(
      initialTransactions: [
        Transaction.create(
          id: 'tx-1',
          type: TransactionType.expense,
          amount: const Money.fromCents(45000), // R$ 450,00
          date: DateTime(2026, 11, 8),
          description: 'Supermercado Pão de Açúcar',
          status: TransactionStatus.completed,
          accountId: 'acc-1',
          categoryId: 'cat-alimentacao',
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
          home: CategoryDetailsScreen(categoryId: 'cat-alimentacao'),
        ),
      ),
    );

    // Ajusta o mês selecionado para Novembro de 2026
    final container = ProviderScope.containerOf(tester.element(find.byType(CategoryDetailsScreen)));
    container.read(selectedBudgetMonthProvider.notifier).setMonth(DateTime(2026, 11));

    await tester.pumpAndSettle();

    // Valida AppBar
    expect(find.text('Alimentação & Bebidas'), findsOneWidget);
    expect(find.text('Mercado e compras'), findsOneWidget);
    expect(find.byKey(const Key('category_details_edit_button')), findsOneWidget);

    // Valida Hero Card de Consumo
    expect(find.text('GASTO TOTAL NO MÊS'), findsOneWidget);
    expect(find.text('450,00'), findsOneWidget);

    // Valida Card de Teto Orçamentário
    expect(find.text('Teto sob Controle (30% consumido)'), findsOneWidget);
    expect(find.byKey(const Key('category_adjust_budget_button')), findsOneWidget);

    // Valida Lançamento listado
    expect(find.text('Supermercado Pão de Açúcar'), findsOneWidget);
  });
}
