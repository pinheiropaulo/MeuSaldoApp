import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/data/in_memory_account_repository.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_details_sheet.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

Widget _buildTestApp({
  required AccountRepository accountRepo,
  required TransactionRepository txRepo,
}) {
  return ProviderScope(
    overrides: [
      accountRepositoryProvider.overrideWithValue(accountRepo),
      transactionRepositoryProvider.overrideWithValue(txRepo),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: const TransactionsScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  group('Future Transactions & Balance Conciliation Tests', () {
    testWidgets(
        'lançamento com data no futuro nasce como pendente e NÃO altera o saldo da conta',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final initialBalance = Money.fromReais(2500);
      final testAccount = FinancialAccount.create(
        id: 'acc_nubank_test',
        name: 'Nubank Principal',
        type: AccountType.checking,
        initialBalance: initialBalance,
      );

      final accountRepo =
          InMemoryAccountRepository(initialAccounts: [testAccount]);
      final txRepo =
          InMemoryTransactionRepository(initialTransactions: const []);

      await tester.pumpWidget(
        _buildTestApp(accountRepo: accountRepo, txRepo: txRepo),
      );
      await tester.pumpAndSettle();

      // Saldo inicial é R$ 2.500,00
      final accBefore = (await accountRepo.getAccountById('acc_nubank_test'))
          .valueOrNull!;
      expect(accBefore.currentBalance, equals(initialBalance));

      // Cadastra despesa com data no futuro diretamente via notifier
      final futureDate = DateTime.now().add(const Duration(days: 7));
      final futureTx = Transaction.create(
        id: 'tx_future_expense',
        description: 'Boleto Faculdade Futuro',
        amount: Money.fromReais(500),
        date: futureDate,
        type: TransactionType.expense,
        status: TransactionStatus.pending, // Pendente por ser futura
        accountId: 'acc_nubank_test',
      );

      final notifier = ProviderScope.containerOf(
        tester.element(find.byType(TransactionsScreen)),
      ).read(transactionsListProvider.notifier);

      await notifier.addTransaction(futureTx);
      await tester.pumpAndSettle();

      // O saldo da conta bancária DEVE continuar rigorosamente R$ 2.500,00
      final accAfter = (await accountRepo.getAccountById('acc_nubank_test'))
          .valueOrNull!;
      expect(accAfter.currentBalance, equals(initialBalance));
    });

    testWidgets(
        'receita com data no futuro nasce pendente e NÃO credita saldo da conta',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final initialBalance = Money.fromReais(1000);
      final testAccount = FinancialAccount.create(
        id: 'acc_nubank_test',
        name: 'Nubank Principal',
        type: AccountType.checking,
        initialBalance: initialBalance,
      );

      final accountRepo =
          InMemoryAccountRepository(initialAccounts: [testAccount]);
      final txRepo =
          InMemoryTransactionRepository(initialTransactions: const []);

      await tester.pumpWidget(
        _buildTestApp(accountRepo: accountRepo, txRepo: txRepo),
      );
      await tester.pumpAndSettle();

      // Receita no futuro
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final futureIncome = Transaction.create(
        id: 'tx_future_income',
        description: 'Adiantamento 13º Salário',
        amount: Money.fromReais(3000),
        date: futureDate,
        type: TransactionType.income,
        status: TransactionStatus.pending,
        accountId: 'acc_nubank_test',
      );

      final notifier = ProviderScope.containerOf(
        tester.element(find.byType(TransactionsScreen)),
      ).read(transactionsListProvider.notifier);

      await notifier.addTransaction(futureIncome);
      await tester.pumpAndSettle();

      // Saldo da conta permanece R$ 1.000,00
      final accAfter = (await accountRepo.getAccountById('acc_nubank_test'))
          .valueOrNull!;
      expect(accAfter.currentBalance, equals(initialBalance));
    });

    testWidgets(
        'confirmar recebimento de receita no modal de detalhes credita a conta com precisão',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final initialBalance = Money.fromReais(1000);
      final testAccount = FinancialAccount.create(
        id: 'acc_nubank_test',
        name: 'Nubank Principal',
        type: AccountType.checking,
        initialBalance: initialBalance,
      );

      final pendingIncome = Transaction.create(
        id: 'tx_pending_freela',
        description: 'Projeto Freelance Mobile',
        amount: Money.fromReais(1500),
        date: DateTime.now(),
        type: TransactionType.income,
        status: TransactionStatus.pending,
        accountId: 'acc_nubank_test',
      );

      final accountRepo =
          InMemoryAccountRepository(initialAccounts: [testAccount]);
      final txRepo =
          InMemoryTransactionRepository(initialTransactions: [pendingIncome]);

      await tester.pumpWidget(
        _buildTestApp(accountRepo: accountRepo, txRepo: txRepo),
      );
      await tester.pumpAndSettle();

      // Abre detalhes do lançamento
      await tester.tap(find.text('Projeto Freelance Mobile'));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDetailsSheet), findsOneWidget);
      expect(find.byKey(const Key('details_confirm_completion_button')),
          findsOneWidget);
      expect(find.text('Confirmar recebimento'), findsOneWidget);

      // Toca em Confirmar recebimento
      await tester.tap(find.byKey(const Key('details_confirm_completion_button')));
      await tester.pumpAndSettle();

      // Confirma no diálogo
      await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Confirmar recebimento'),
      ));
      await tester.pumpAndSettle();

      // Sheet fecha
      expect(find.byType(TransactionDetailsSheet), findsNothing);

      // Saldo da conta agora DEVE ter recebido os R$ 1.500,00 -> total R$ 2.500,00
      final accUpdated = (await accountRepo.getAccountById('acc_nubank_test'))
          .valueOrNull!;
      expect(accUpdated.currentBalance, equals(Money.fromReais(2500)));

      // Transação no repositório agora está efetivada
      final txUpdated =
          (await txRepo.getTransactionById('tx_pending_freela')).valueOrNull!;
      expect(txUpdated.isCompleted, isTrue);
    });

    testWidgets(
        'confirmar pagamento de despesa no modal de detalhes debita a conta com precisão',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final initialBalance = Money.fromReais(1000);
      final testAccount = FinancialAccount.create(
        id: 'acc_nubank_test',
        name: 'Nubank Principal',
        type: AccountType.checking,
        initialBalance: initialBalance,
      );

      final pendingExpense = Transaction.create(
        id: 'tx_pending_aluguel',
        description: 'Aluguel Apartamento',
        amount: Money.fromReais(600),
        date: DateTime.now(),
        type: TransactionType.expense,
        status: TransactionStatus.pending,
        accountId: 'acc_nubank_test',
      );

      final accountRepo =
          InMemoryAccountRepository(initialAccounts: [testAccount]);
      final txRepo =
          InMemoryTransactionRepository(initialTransactions: [pendingExpense]);

      await tester.pumpWidget(
        _buildTestApp(accountRepo: accountRepo, txRepo: txRepo),
      );
      await tester.pumpAndSettle();

      // Abre detalhes do lançamento
      await tester.tap(find.text('Aluguel Apartamento'));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDetailsSheet), findsOneWidget);
      expect(find.text('Confirmar pagamento'), findsOneWidget);

      // Toca em Confirmar pagamento
      await tester.tap(find.byKey(const Key('details_confirm_completion_button')));
      await tester.pumpAndSettle();

      // Confirma no diálogo
      await tester.tap(find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Confirmar pagamento'),
      ));
      await tester.pumpAndSettle();

      // Saldo da conta agora DEVE ter sido debitado de R$ 600,00 -> total R$ 400,00
      final accUpdated = (await accountRepo.getAccountById('acc_nubank_test'))
          .valueOrNull!;
      expect(accUpdated.currentBalance, equals(Money.fromReais(400)));

      // Transação no repositório agora está efetivada
      final txUpdated =
          (await txRepo.getTransactionById('tx_pending_aluguel')).valueOrNull!;
      expect(txUpdated.isCompleted, isTrue);
    });

    testWidgets(
        'TransactionFormSheet exibe toggle de status e permite criar despesa pendente sem debitar conta',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final initialBalance = Money.fromReais(5000);
      final testAccount = FinancialAccount.create(
        id: 'acc_nubank_test',
        name: 'Nubank Principal',
        type: AccountType.checking,
        initialBalance: initialBalance,
      );

      final accountRepo =
          InMemoryAccountRepository(initialAccounts: [testAccount]);
      final txRepo =
          InMemoryTransactionRepository(initialTransactions: const []);

      await tester.pumpWidget(
        _buildTestApp(accountRepo: accountRepo, txRepo: txRepo),
      );
      await tester.pumpAndSettle();

      // Clica em + Novo
      await tester.tap(find.text('+ Novo'));
      await tester.pumpAndSettle();

      // Digita valor e descrição
      await tester.enterText(find.byType(TextField).first, '750,00');
      await tester.enterText(find.byType(TextField).at(1), 'Curso de Flutter');
      await tester.pumpAndSettle();

      // Toggle de status está presente
      expect(find.byKey(const Key('transaction_status_switch')), findsOneWidget);
      expect(find.text('Despesa já paga?'), findsOneWidget);
      expect(find.text('Efetivado'), findsOneWidget);

      // Desmarca para registrar como Pendente
      await tester.ensureVisible(find.byKey(const Key('transaction_status_switch')));
      await tester.tap(find.byKey(const Key('transaction_status_switch')));
      await tester.pumpAndSettle();

      expect(find.text('Pendente'), findsOneWidget);

      // Salva
      await tester.ensureVisible(find.text('Salvar despesa'));
      await tester.tap(find.text('Salvar despesa'));
      await tester.pumpAndSettle();

      // Verifica se aparece no extrato com badge Pendente
      expect(find.text('Curso de Flutter'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);

      // Saldo da conta DEVE continuar intacto em R$ 5.000,00
      final acc = (await accountRepo.getAccountById('acc_nubank_test')).valueOrNull!;
      expect(acc.currentBalance, equals(initialBalance));

      // Transação no repositório está com status pending
      final allTx = (await txRepo.getAllTransactions()).valueOrNull!;
      expect(allTx.length, 1);
      expect(allTx.first.status, equals(TransactionStatus.pending));
    });
  });
}
