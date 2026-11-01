import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/accounts/data/in_memory_account_repository.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/categories/data/in_memory_category_repository.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/screens/bill_schedule_screen.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testAccount = FinancialAccount.create(
    id: 'acc-nubank',
    name: 'Nubank Principal',
    type: AccountType.checking,
    initialBalance: Money.fromCents(384050),
  );

  final testCategory = Category.create(
    id: 'cat-moradia',
    name: 'Moradia & Contas',
    iconKey: 'home',
    colorHex: '#FF8C42',
    type: CategoryType.expense,
  );

  final now = DateTime.now();

  final overdueBill = Transaction.create(
    id: 'tx-overdue',
    type: TransactionType.expense,
    amount: Money.fromCents(13990),
    date: now.subtract(const Duration(days: 5)),
    description: 'Enel Energia Elétrica',
    status: TransactionStatus.pending,
    accountId: testAccount.id,
    categoryId: testCategory.id,
  );

  final upcomingBill = Transaction.create(
    id: 'tx-upcoming',
    type: TransactionType.expense,
    amount: Money.fromCents(45000),
    date: now.add(const Duration(days: 3)),
    description: 'Condomínio Residencial',
    status: TransactionStatus.pending,
    accountId: testAccount.id,
    categoryId: testCategory.id,
  );

  final paidBill = Transaction.create(
    id: 'tx-paid',
    type: TransactionType.expense,
    amount: Money.fromCents(180000),
    date: DateTime(now.year, now.month, 1),
    description: 'Aluguel do Apartamento',
    status: TransactionStatus.completed,
    accountId: testAccount.id,
    categoryId: testCategory.id,
  );

  Widget buildScreen({InMemoryTransactionRepository? txRepo}) {
    final effectiveTxRepo = txRepo ??
        InMemoryTransactionRepository(
          initialTransactions: [overdueBill, upcomingBill, paidBill],
        );
    final effectiveAccRepo = InMemoryAccountRepository(initialAccounts: [testAccount]);
    final effectiveCatRepo = InMemoryCategoryRepository(initialCategories: [testCategory]);

    return ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(effectiveTxRepo),
        accountRepositoryProvider.overrideWithValue(effectiveAccRepo),
        categoryRepositoryProvider.overrideWithValue(effectiveCatRepo),
      ],
      child: const MaterialApp(
        home: BillScheduleScreen(),
      ),
    );
  }

  group('BillScheduleScreen Widget Tests', () {
    testWidgets('exibe resumo, alerta de conta atrasada e grupos de contas', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Agenda de Contas'), findsOneWidget);
      expect(find.text('Próximos vencimentos'), findsOneWidget);
      expect(find.text('CONTAS PENDENTES NO MÊS'), findsOneWidget);
      expect(find.text('JÁ PAGAS'), findsOneWidget);
      expect(find.text('1 conta atrasada'), findsOneWidget);

      expect(find.text('Contas Vencidas'), findsOneWidget);
      expect(find.text('Enel Energia Elétrica'), findsOneWidget);

      expect(find.text('Próximos Vencimentos'), findsOneWidget);
      expect(find.text('Condomínio Residencial'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Contas Pagas no Mês'), findsOneWidget);
      expect(find.text('Aluguel do Apartamento'), findsOneWidget);
    });

    testWidgets('filtra contas ao tocar no chip de filtro Atrasadas', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Toca no chip Atrasadas (1)
      await tester.tap(find.text('Atrasadas (1)'));
      await tester.pumpAndSettle();

      // Apenas a conta atrasada deve estar visível
      expect(find.text('Enel Energia Elétrica'), findsOneWidget);
      expect(find.text('Condomínio Residencial'), findsNothing);
      expect(find.text('Aluguel do Apartamento'), findsNothing);
    });

    testWidgets('permite dar baixa na conta atrasada após confirmação', (tester) async {
      final txRepo = InMemoryTransactionRepository(
        initialTransactions: [overdueBill, upcomingBill, paidBill],
      );
      await tester.pumpWidget(buildScreen(txRepo: txRepo));
      await tester.pumpAndSettle();

      // Clica em Registrar Baixa da conta atrasada
      await tester.tap(find.byKey(Key('dar_baixa_${overdueBill.id}')));
      await tester.pumpAndSettle();

      // Modal de confirmação
      expect(find.text('Dar baixa na conta?'), findsOneWidget);
      await tester.tap(find.text('Confirmar Pagamento'));
      await tester.pumpAndSettle();

      // Transação agora está completada
      final updated = (await txRepo.getTransactionById(overdueBill.id)).valueOrNull;
      expect(updated?.isCompleted, isTrue);
    });
  });
}
