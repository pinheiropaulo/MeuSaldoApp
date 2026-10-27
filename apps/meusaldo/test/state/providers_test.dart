import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  group('Riverpod Providers & In-Memory State', () {
    test('carrega contas iniciais e calcula saldo consolidado', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final accounts = await container.read(accountsListProvider.future);
      expect(accounts.length, equals(3));

      final totalBalance = container.read(consolidatedBalanceProvider);
      // Nubank (3840,50) + Itaú (12500,00) + Carteira (180,00) = 16520,50
      expect(totalBalance.cents, equals(1652050));
    });

    test('carrega categorias e filtra por tipo', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final categories = await container.read(categoriesListProvider.future);
      expect(categories.isNotEmpty, isTrue);

      final expenseCats = container.read(expenseCategoriesProvider);
      expect(expenseCats.any((c) => c.name.contains('Alimentação')), isTrue);

      final incomeCats = container.read(incomeCategoriesProvider);
      expect(incomeCats.any((c) => c.name.contains('Salário')), isTrue);
    });

    test('adicionar movimentação atualiza saldo da conta correspondente', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(accountsListProvider.future);
      final initialNubank = (await container.read(accountsListProvider.future))
          .firstWhere((a) => a.id == 'acc-nubank');
      final initialBalance = initialNubank.currentBalance;

      // Adiciona uma despesa de R$ 100,00 na conta Nubank
      final expenseTx = Transaction.create(
        id: 'tx-test-despesa',
        type: TransactionType.expense,
        amount: const Money.fromCents(10000), // R$ 100,00
        date: DateTime.now(),
        description: 'Jantar',
        status: TransactionStatus.completed,
        accountId: 'acc-nubank',
      );

      final notifier = container.read(transactionsListProvider.notifier);
      final result = await notifier.addTransaction(expenseTx);
      expect(result.isSuccess, isTrue);

      // Saldo da conta Nubank deve ter reduzido em R$ 100,00
      final updatedAccounts = await container.read(accountsListProvider.future);
      final updatedNubank = updatedAccounts.firstWhere((a) => a.id == 'acc-nubank');
      expect(updatedNubank.currentBalance, equals(initialBalance - const Money.fromCents(10000)));
    });

    test('transferência atualiza ambas as contas conservando total consolidado', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(accountsListProvider.future);
      final totalBefore = container.read(consolidatedBalanceProvider);

      final notifier = container.read(transactionsListProvider.notifier);
      final result = await notifier.executeTransfer(
        transactionId: 'tf-teste-1',
        sourceAccountId: 'acc-nubank',
        destinationAccountId: 'acc-itau',
        amount: const Money.fromCents(50000), // R$ 500,00
        date: DateTime.now(),
        description: 'Transferência para poupança',
      );

      expect(result.isSuccess, isTrue);

      final updatedAccounts = await container.read(accountsListProvider.future);
      final totalAfter = container.read(consolidatedBalanceProvider);

      // O saldo consolidado total deve ser idêntico
      expect(totalAfter, equals(totalBefore));

      final nubank = updatedAccounts.firstWhere((a) => a.id == 'acc-nubank');
      final itau = updatedAccounts.firstWhere((a) => a.id == 'acc-itau');
      expect(nubank.currentBalance.cents, lessThan(384050));
      expect(itau.currentBalance.cents, greaterThan(1250000));
    });

    test('exclusão de transação reverte impacto no saldo', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(accountsListProvider.future);
      final initialNubank = (await container.read(accountsListProvider.future))
          .firstWhere((a) => a.id == 'acc-nubank');

      final tx = Transaction.create(
        id: 'tx-para-excluir',
        type: TransactionType.expense,
        amount: const Money.fromCents(25000), // R$ 250,00
        date: DateTime.now(),
        description: 'Compra passageira',
        status: TransactionStatus.completed,
        accountId: 'acc-nubank',
      );

      final notifier = container.read(transactionsListProvider.notifier);
      await notifier.addTransaction(tx);

      // Exclui
      final deleteResult = await notifier.deleteTransaction('tx-para-excluir');
      expect(deleteResult.isSuccess, isTrue);

      // Saldo deve ter retornado ao valor inicial
      final restoredAccounts = await container.read(accountsListProvider.future);
      final restoredNubank = restoredAccounts.firstWhere((a) => a.id == 'acc-nubank');
      expect(restoredNubank.currentBalance, equals(initialNubank.currentBalance));
    });
  });
}
