import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/accounts/data/in_memory_account_repository.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/categories/data/in_memory_category_repository.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/edit_transaction_sheet.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testAccount = FinancialAccount.create(
    id: 'acc-1',
    name: 'Nubank',
    type: AccountType.checking,
    initialBalance: Money.fromCents(100000),
  );

  final testCategory = Category.create(
    id: 'cat-1',
    name: 'Alimentação',
    iconKey: 'restaurant',
    colorHex: '#22A06B',
    type: CategoryType.expense,
  );

  final testExpense = Transaction.create(
    id: 'tx-1',
    type: TransactionType.expense,
    amount: Money.fromCents(34280),
    date: DateTime(2024, 10, 24),
    description: 'Supermercado Pão de Açúcar',
    accountId: testAccount.id,
    categoryId: testCategory.id,
    notes: 'Compra do mês',
  );

  Widget buildSheet({
    required Transaction transaction,
    InMemoryTransactionRepository? txRepo,
    InMemoryAccountRepository? accRepo,
  }) {
    final effectiveTxRepo = txRepo ?? InMemoryTransactionRepository(initialTransactions: [transaction]);
    final effectiveAccRepo = accRepo ?? InMemoryAccountRepository(initialAccounts: [testAccount]);
    final effectiveCatRepo = InMemoryCategoryRepository(initialCategories: [testCategory]);

    return ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(effectiveTxRepo),
        accountRepositoryProvider.overrideWithValue(effectiveAccRepo),
        categoryRepositoryProvider.overrideWithValue(effectiveCatRepo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => EditTransactionSheet.show(context, transaction: transaction),
                child: const Text('Abrir Edição'),
              );
            },
          ),
        ),
      ),
    );
  }

  group('EditTransactionSheet Tests', () {
    testWidgets('exibe cabeçalho, campos preenchidos e banner informativo', (tester) async {
      await tester.pumpWidget(buildSheet(transaction: testExpense));
      await tester.tap(find.text('Abrir Edição'));
      await tester.pumpAndSettle();

      expect(find.text('Editar lançamento'), findsOneWidget);
      expect(find.text('Supermercado Pão de Açúcar'), findsOneWidget);
      expect(find.text('342,80'), findsOneWidget);
      expect(find.text('Alterações recalculam imediatamente o saldo da conta e a fatura relacionada.'), findsOneWidget);
      expect(find.byKey(const Key('edit_transaction_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('edit_transaction_delete_button')), findsOneWidget);
    });

    testWidgets('permite alterar a descrição e salvar o lançamento com sucesso', (tester) async {
      final txRepo = InMemoryTransactionRepository(initialTransactions: [testExpense]);
      await tester.pumpWidget(buildSheet(transaction: testExpense, txRepo: txRepo));
      await tester.tap(find.text('Abrir Edição'));
      await tester.pumpAndSettle();

      // Altera a descrição
      await tester.enterText(
        find.byKey(const Key('edit_transaction_desc_field')),
        'Supermercado Extra Atualizado',
      );
      await tester.pumpAndSettle();

      // Rola até o botão de salvar e clica
      await tester.ensureVisible(find.byKey(const Key('edit_transaction_submit_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit_transaction_submit_button')));
      await tester.pumpAndSettle();

      // Modal fechou
      expect(find.byType(EditTransactionSheet), findsNothing);

      // Transação no repositório foi atualizada
      final updated = (await txRepo.getTransactionById(testExpense.id)).valueOrNull;
      expect(updated?.description, 'Supermercado Extra Atualizado');
    });

    testWidgets('exclui o lançamento através do botão de lixeira no cabeçalho após confirmação', (tester) async {
      final txRepo = InMemoryTransactionRepository(initialTransactions: [testExpense]);
      await tester.pumpWidget(buildSheet(transaction: testExpense, txRepo: txRepo));
      await tester.tap(find.text('Abrir Edição'));
      await tester.pumpAndSettle();

      // Clica no ícone de lixeira no cabeçalho
      await tester.tap(find.byKey(const Key('edit_transaction_delete_button')));
      await tester.pumpAndSettle();

      // Diálogo de confirmação surge
      expect(find.text('Excluir lançamento?'), findsOneWidget);

      // Confirma exclusão
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      // Modal fechou
      expect(find.byType(EditTransactionSheet), findsNothing);

      // Transação não existe mais no repositório
      final check = await txRepo.getTransactionById(testExpense.id);
      expect(check.isFailure, isTrue);
    });
  });
}
