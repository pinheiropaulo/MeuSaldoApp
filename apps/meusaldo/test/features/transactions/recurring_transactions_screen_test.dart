import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/transactions/presentation/screens/recurring_transactions_screen.dart';
import 'package:meusaldo/features/transactions/presentation/state/recurring_transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

class _TestRecurringListNotifier extends RecurringListNotifier {
  final List<RecurringTransaction> _initial;

  _TestRecurringListNotifier(this._initial);

  @override
  List<RecurringTransaction> build() => _initial;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final initialItems = [
    RecurringTransaction.create(
      id: 'rec-netflix',
      description: 'Netflix Brasil',
      amount: const Money.fromCents(5590),
      type: TransactionType.expense,
      category: RecurrenceCategory.subscription,
      billingDay: 20,
      billingDayDescription: 'Todo dia 20 • Cartão Nubank',
      paymentMethod: 'Cartão Nubank',
      iconKey: 'movie',
    ),
    RecurringTransaction.create(
      id: 'rec-aluguel',
      description: 'Aluguel do Apartamento',
      amount: const Money.fromCents(180000),
      type: TransactionType.expense,
      category: RecurrenceCategory.fixedExpense,
      billingDay: 10,
      billingDayDescription: 'Vence todo dia 10 • NuConta',
      paymentMethod: 'NuConta',
      iconKey: 'key',
    ),
    RecurringTransaction.create(
      id: 'rec-salario',
      description: 'Salário Mensal CLT',
      amount: const Money.fromCents(650000),
      type: TransactionType.income,
      category: RecurrenceCategory.income,
      billingDay: 5,
      billingDayDescription: 'Todo 5º dia útil • NuConta',
      paymentMethod: 'NuConta',
      iconKey: 'account_balance_wallet',
    ),
  ];

  Widget buildScreen({List<RecurringTransaction>? items}) {
    return ProviderScope(
      overrides: [
        if (items != null)
          recurringListProvider.overrideWith(
            () => _TestRecurringListNotifier(items),
          ),
      ],
      child: const MaterialApp(
        home: RecurringTransactionsScreen(),
      ),
    );
  }

  group('RecurringTransactionsScreen Widget Tests', () {
    testWidgets('exibe cabeçalho, resumo hero e seções agrupadas de recorrências',
        (tester) async {
      await tester.pumpWidget(buildScreen(items: initialItems));
      await tester.pumpAndSettle();

      expect(find.text('Recorrências'), findsOneWidget);
      expect(find.text('Assinaturas e despesas fixas'), findsOneWidget);
      expect(find.text('+ Nova'), findsOneWidget);

      expect(find.text('TOTAL DE GASTOS FIXOS POR MÊS'), findsOneWidget);
      expect(find.text('Assinaturas de Streaming'), findsWidgets);
      expect(find.text('Receita Recorrente'), findsWidgets);

      expect(find.text('Netflix Brasil'), findsOneWidget);
      expect(find.text('Aluguel do Apartamento'), findsOneWidget);
      expect(find.text('Salário Mensal CLT'), findsOneWidget);
    });

    testWidgets('filtra recorrências ao clicar nos chips', (tester) async {
      await tester.pumpWidget(buildScreen(items: initialItems));
      await tester.pumpAndSettle();

      // Clica em 'Assinaturas'
      final chipAssinaturas = find.text('Assinaturas (1)');
      expect(chipAssinaturas, findsOneWidget);
      await tester.tap(chipAssinaturas);
      await tester.pumpAndSettle();

      expect(find.text('Netflix Brasil'), findsOneWidget);
      expect(find.text('Aluguel do Apartamento'), findsNothing);
      expect(find.text('Salário Mensal CLT'), findsNothing);

      // Clica em 'Receitas'
      final chipReceitas = find.text('Receitas (1)');
      expect(chipReceitas, findsOneWidget);
      await tester.tap(chipReceitas);
      await tester.pumpAndSettle();

      expect(find.text('Salário Mensal CLT'), findsOneWidget);
      expect(find.text('Netflix Brasil'), findsNothing);
    });

    testWidgets('pausa e ativa uma recorrência pelo botão rápido', (tester) async {
      await tester.pumpWidget(buildScreen(items: initialItems));
      await tester.pumpAndSettle();

      expect(find.text('Ativa'), findsNWidgets(3));
      final pausarButtons = find.text('Pausar');
      expect(pausarButtons, findsWidgets);

      // Clica no primeiro botão Pausar (Netflix)
      await tester.tap(pausarButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Pausada'), findsOneWidget);
      expect(find.text('Ativar'), findsOneWidget);
    });

    testWidgets('abre o modal de nova recorrência pelo botão do cabeçalho',
        (tester) async {
      await tester.pumpWidget(buildScreen(items: initialItems));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+ Nova'));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar Recorrência'), findsOneWidget);
      expect(find.text('Descrição do Lançamento'), findsOneWidget);
      expect(find.text('Salvar Recorrência'), findsOneWidget);
    });
  });
}
