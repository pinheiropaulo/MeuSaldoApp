import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/data/in_memory_account_repository.dart';
import 'package:meusaldo/features/accounts/presentation/screens/account_details_screen.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/details/account_bento_stats.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/details/account_empty_transactions_card.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/details/account_hero_card.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_details_sheet.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

Widget _buildTestApp({
  required String accountId,
  AccountRepository? accountRepo,
  TransactionRepository? transactionRepo,
}) {
  return ProviderScope(
    overrides: [
      if (accountRepo != null)
        accountRepositoryProvider.overrideWithValue(accountRepo),
      if (transactionRepo != null)
        transactionRepositoryProvider.overrideWithValue(transactionRepo),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: AccountDetailsScreen(accountId: accountId),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testAccount = FinancialAccount.create(
    id: 'acc_nubank_1',
    name: 'Nubank Principal',
    type: AccountType.checking,
    initialBalance: Money.fromReais(2500),
  );

  final testExpense = Transaction.create(
    id: 'tx_supermercado',
    description: 'Compras Pão de Açúcar',
    amount: Money.fromReais(350),
    type: TransactionType.expense,
    date: DateTime.now(),
    accountId: testAccount.id,
    categoryId: 'cat_mercado',
  );

  final testIncome = Transaction.create(
    id: 'tx_salario',
    description: 'Salário Mensal',
    amount: Money.fromReais(4000),
    type: TransactionType.income,
    date: DateTime.now(),
    accountId: testAccount.id,
    categoryId: 'cat_salario',
  );

  group('AccountDetailsScreen Widget Tests', () {
    testWidgets('exibe hero card, bento stats e extrato com movimentações',
        (tester) async {
      final accountRepo = InMemoryAccountRepository(
        initialAccounts: [testAccount],
      );
      final txRepo = InMemoryTransactionRepository(
        initialTransactions: [testExpense, testIncome],
      );

      await tester.pumpWidget(
        _buildTestApp(
          accountId: testAccount.id,
          accountRepo: accountRepo,
          transactionRepo: txRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Top bar e hero card
      expect(find.text('Conta Bancária'), findsOneWidget);
      expect(find.text('Nubank Principal'), findsWidgets);
      expect(find.byType(AccountHeroCard), findsOneWidget);
      expect(find.text('Saldo disponível'), findsOneWidget);
      expect(find.text('+ Movimentação'), findsOneWidget);
      expect(find.text('Transferir'), findsOneWidget);

      // Bento stats
      expect(find.byType(AccountBentoStats), findsOneWidget);
      expect(find.text('Entradas no mês'), findsOneWidget);
      expect(find.text('Saídas no mês'), findsOneWidget);

      // Extrato de movimentações
      expect(find.text('Movimentações'), findsOneWidget);
      expect(find.text('Compras Pão de Açúcar'), findsOneWidget);
      expect(find.text('Salário Mensal'), findsOneWidget);
    });

    testWidgets('permite alternar visibilidade do saldo entre ocultar e exibir',
        (tester) async {
      final accountRepo = InMemoryAccountRepository(
        initialAccounts: [testAccount],
      );

      await tester.pumpWidget(
        _buildTestApp(
          accountId: testAccount.id,
          accountRepo: accountRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Saldo visível inicialmente
      expect(find.text('Ocultar'), findsOneWidget);

      // Toca em ocultar
      await tester.tap(find.text('Ocultar'));
      await tester.pumpAndSettle();

      expect(find.text('••••••'), findsOneWidget);
      expect(find.text('Exibir'), findsOneWidget);

      // Toca em exibir novamente
      await tester.tap(find.text('Exibir'));
      await tester.pumpAndSettle();

      expect(find.text('Ocultar'), findsOneWidget);
    });

    testWidgets('exibe estado vazio quando não há movimentações registradas',
        (tester) async {
      final accountRepo = InMemoryAccountRepository(
        initialAccounts: [testAccount],
      );
      final txRepo = InMemoryTransactionRepository(
        initialTransactions: const [],
      );

      await tester.pumpWidget(
        _buildTestApp(
          accountId: testAccount.id,
          accountRepo: accountRepo,
          transactionRepo: txRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AccountEmptyTransactionsCard), findsOneWidget);
      expect(find.text('Nenhuma movimentação nesta conta'), findsOneWidget);
      expect(find.text('+ Adicionar primeira movimentação'), findsOneWidget);
    });

    testWidgets('abre bottom sheet de detalhes ao tocar em um lançamento',
        (tester) async {
      final accountRepo = InMemoryAccountRepository(
        initialAccounts: [testAccount],
      );
      final txRepo = InMemoryTransactionRepository(
        initialTransactions: [testExpense],
      );

      await tester.pumpWidget(
        _buildTestApp(
          accountId: testAccount.id,
          accountRepo: accountRepo,
          transactionRepo: txRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Compras Pão de Açúcar'));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionDetailsSheet), findsOneWidget);
      expect(find.text('Detalhes do lançamento'), findsOneWidget);
    });
  });
}
