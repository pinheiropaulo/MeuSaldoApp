import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

import '../fakes/fake_account_repository.dart';
import '../fakes/fake_category_repository.dart';
import '../fakes/fake_transaction_repository.dart';

void main() {
  group('Repository Contracts', () {
    test('AccountRepository CRUD e busca de ativas', () async {
      final AccountRepository repo = FakeAccountRepository();

      final acc1 = FinancialAccount.create(
        id: 'acc-1',
        name: 'Nubank',
        type: AccountType.checking,
        initialBalance: const Money.fromCents(10000),
      );
      final acc2 = FinancialAccount.create(
        id: 'acc-2',
        name: 'Inativa',
        type: AccountType.savings,
        isActive: false,
      );

      await repo.saveAccount(acc1);
      await repo.saveAccount(acc2);

      final activeOnly = await repo.getAllAccounts(includeInactive: false);
      expect(activeOnly.valueOrNull?.length, equals(1));
      expect(activeOnly.valueOrNull?.first.name, equals('Nubank'));

      final all = await repo.getAllAccounts(includeInactive: true);
      expect(all.valueOrNull?.length, equals(2));

      final updated = acc1.copyWith(name: 'Nubank Principal');
      await repo.updateAccount(updated);
      final fetched = await repo.getAccountById('acc-1');
      expect(fetched.valueOrNull?.name, equals('Nubank Principal'));

      await repo.deleteAccount('acc-1');
      final notFound = await repo.getAccountById('acc-1');
      expect(notFound.isFailure, isTrue);
      expect(notFound.failureOrNull, isA<NotFoundFailure>());
    });

    test('CategoryRepository CRUD e filtro por tipo', () async {
      final CategoryRepository repo = FakeCategoryRepository();

      final cExpense = Category.create(
        id: 'cat-exp',
        name: 'Mercado',
        type: CategoryType.expense,
      );
      final cIncome = Category.create(
        id: 'cat-inc',
        name: 'Salário',
        type: CategoryType.income,
      );
      final cBoth = Category.create(
        id: 'cat-both',
        name: 'Outros',
        type: CategoryType.both,
      );

      await repo.saveCategory(cExpense);
      await repo.saveCategory(cIncome);
      await repo.saveCategory(cBoth);

      final expenses = await repo.getCategoriesByType(CategoryType.expense);
      expect(expenses.valueOrNull?.length, equals(2)); // cExpense + cBoth

      final incomes = await repo.getCategoriesByType(CategoryType.income);
      expect(incomes.valueOrNull?.length, equals(2)); // cIncome + cBoth
    });

    test('TransactionRepository CRUD e filtro por data e conta', () async {
      final TransactionRepository repo = FakeTransactionRepository();

      final now = DateTime(2026, 10, 25, 12, 0);
      final tx1 = Transaction.create(
        id: 'tx-1',
        type: TransactionType.expense,
        amount: const Money.fromCents(5000),
        date: now,
        description: 'Mercado',
        accountId: 'acc-1',
      );
      final tx2 = Transaction.create(
        id: 'tx-2',
        type: TransactionType.transfer,
        amount: const Money.fromCents(2000),
        date: now.add(const Duration(days: 1)),
        description: 'Transferência',
        accountId: 'acc-1',
        destinationAccountId: 'acc-2',
      );
      final txPast = Transaction.create(
        id: 'tx-past',
        type: TransactionType.income,
        amount: const Money.fromCents(10000),
        date: now.subtract(const Duration(days: 30)),
        description: 'Salário antigo',
        accountId: 'acc-2',
      );

      await repo.saveTransaction(tx1);
      await repo.saveTransaction(tx2);
      await repo.saveTransaction(txPast);

      final range = await repo.getTransactionsByDateRange(
        start: now.subtract(const Duration(hours: 1)),
        end: now.add(const Duration(days: 2)),
      );
      expect(range.valueOrNull?.length, equals(2));

      final byAcc1 = await repo.getTransactionsByAccount('acc-1');
      expect(byAcc1.valueOrNull?.length, equals(2));

      final byAcc2 = await repo.getTransactionsByAccount('acc-2');
      expect(byAcc2.valueOrNull?.length, equals(2)); // tx2 (destino) + txPast (origem)
    });
  });
}
