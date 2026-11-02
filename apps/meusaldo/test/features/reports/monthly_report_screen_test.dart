import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meusaldo/features/categories/data/in_memory_category_repository.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/reports/presentation/screens/monthly_report_screen.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('MonthlyReportScreen renderiza resultado líquido, comparativo, evolução semanal e categorias', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final catRepo = InMemoryCategoryRepository(
      initialCategories: [
        Category.create(
          id: 'cat-alimentacao',
          name: 'Alimentação & Mercado',
          type: CategoryType.expense,
          colorHex: '#F2C94C',
        ),
        Category.create(
          id: 'cat-salario',
          name: 'Salário & Extras',
          type: CategoryType.income,
          colorHex: '#22A06B',
        ),
      ],
    );

    final txRepo = InMemoryTransactionRepository(
      initialTransactions: [
        Transaction.create(
          id: 'tx-inc',
          type: TransactionType.income,
          amount: const Money.fromCents(650000), // R$ 6.500,00
          date: DateTime(2026, 11, 5),
          description: 'Salário',
          status: TransactionStatus.completed,
          accountId: 'acc-1',
          categoryId: 'cat-salario',
        ),
        Transaction.create(
          id: 'tx-exp-1',
          type: TransactionType.expense,
          amount: const Money.fromCents(138000), // R$ 1.380,00 (Semana 1)
          date: DateTime(2026, 11, 6),
          description: 'Mercado Mensal',
          status: TransactionStatus.completed,
          accountId: 'acc-1',
          categoryId: 'cat-alimentacao',
        ),
        Transaction.create(
          id: 'tx-prev-exp',
          type: TransactionType.expense,
          amount: const Money.fromCents(175000), // R$ 1.750,00 em Outubro
          date: DateTime(2026, 10, 15),
          description: 'Mercado Outubro',
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
          home: MonthlyReportScreen(),
        ),
      ),
    );

    final container = ProviderScope.containerOf(tester.element(find.byType(MonthlyReportScreen)));
    container.read(selectedBudgetMonthProvider.notifier).setMonth(DateTime(2026, 11));

    await tester.pumpAndSettle();

    // Valida Header
    expect(find.text('Relatório Mensal'), findsOneWidget);
    expect(find.text('Balanço & Análise de Gastos'), findsOneWidget);

    // Valida Hero Card: Resultado Líquido (+ R$ 5.120,00)
    expect(find.text('RESULTADO LÍQUIDO DO MÊS'), findsOneWidget);
    expect(find.text('5.120,00'), findsOneWidget);
    expect(find.text('Receitas Totais'), findsOneWidget);
    expect(find.text('Despesas Totais'), findsOneWidget);

    // Valida Card de Comparação com mês anterior (Despesas em queda)
    expect(find.text('Despesas em Queda'), findsOneWidget);

    // Valida Gráfico Semanal
    expect(find.text('Evolução dos Gastos por Semana'), findsOneWidget);
    expect(find.text('Sem 1'), findsOneWidget);
    expect(find.text('Sem 2'), findsOneWidget);

    // Valida Distribuição de Categorias
    expect(find.text('Distribuição por Categoria'), findsOneWidget);
    expect(find.text('Alimentação & Mercado'), findsOneWidget);
  });
}
