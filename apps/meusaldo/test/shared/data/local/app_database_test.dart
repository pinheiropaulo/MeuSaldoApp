import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/shared/data/demo_data.dart';
import 'package:meusaldo/shared/data/local/app_database.dart';
import 'package:meusaldo/shared/data/local/mappers/account_mapper.dart';
import 'package:meusaldo/shared/data/local/mappers/category_mapper.dart';
import 'package:meusaldo/shared/data/local/mappers/transaction_mapper.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift AppDatabase Tests', () {
    test('pré-carrega banco com DemoData ao criar pela primeira vez', () async {
      final accounts = await db.select(db.accountsTable).get();
      final categories = await db.select(db.categoriesTable).get();
      final transactions = await db.select(db.transactionsTable).get();

      expect(accounts.length, equals(DemoData.accounts.length));
      expect(categories.length, equals(DemoData.categories.length));
      expect(transactions.length, equals(DemoData.getTransactions().length));

      // Validação de integridade do Money persistido em centavos
      final nubank = accounts.firstWhere((a) => a.id == 'acc-nubank');
      expect(nubank.name, equals('Nubank Principal'));
      expect(nubank.type, equals(AccountType.checking));
      expect(nubank.initialBalance.cents, equals(384050));
      expect(nubank.currentBalance.cents, equals(384050));
    });

    test('mapeia AccountRow para FinancialAccount e vice-versa', () async {
      final account = FinancialAccount.create(
        id: 'acc-test',
        name: 'Conta Teste',
        type: AccountType.investment,
        initialBalance: const Money.fromCents(50000),
        colorHex: '#6D1834',
        iconKey: 'trending_up',
      );

      await db.into(db.accountsTable).insert(account.toCompanion());

      final row = await (db.select(db.accountsTable)
            ..where((tbl) => tbl.id.equals('acc-test')))
          .getSingle();

      final domainAccount = row.toDomain();
      expect(domainAccount.id, equals('acc-test'));
      expect(domainAccount.name, equals('Conta Teste'));
      expect(domainAccount.type, equals(AccountType.investment));
      expect(domainAccount.initialBalance, equals(const Money.fromCents(50000)));
      expect(domainAccount.colorHex, equals('#6D1834'));
      expect(domainAccount.iconKey, equals('trending_up'));
    });

    test('mapeia CategoryRow para Category e vice-versa', () async {
      final category = Category.create(
        id: 'cat-test',
        name: 'Categoria Teste',
        type: CategoryType.expense,
        colorHex: '#F04444',
        iconKey: 'star',
        description: 'Descrição de teste',
      );

      await db.into(db.categoriesTable).insert(category.toCompanion());

      final row = await (db.select(db.categoriesTable)
            ..where((tbl) => tbl.id.equals('cat-test')))
          .getSingle();

      final domainCategory = row.toDomain();
      expect(domainCategory.id, equals('cat-test'));
      expect(domainCategory.name, equals('Categoria Teste'));
      expect(domainCategory.type, equals(CategoryType.expense));
      expect(domainCategory.colorHex, equals('#F04444'));
      expect(domainCategory.iconKey, equals('star'));
      expect(domainCategory.description, equals('Descrição de teste'));
      expect(domainCategory.isArchived, isFalse);
    });

    test('mapeia TransactionRow para Transaction e vice-versa', () async {
      final tx = Transaction.create(
        id: 'tx-test',
        type: TransactionType.expense,
        amount: const Money.fromCents(15000),
        date: DateTime(2026, 10, 26),
        description: 'Despesa de teste',
        status: TransactionStatus.completed,
        accountId: 'acc-nubank',
        categoryId: 'cat-alimentacao',
        notes: 'Nota explicativa',
      );

      await db.into(db.transactionsTable).insert(tx.toCompanion());

      final row = await (db.select(db.transactionsTable)
            ..where((tbl) => tbl.id.equals('tx-test')))
          .getSingle();

      final domainTx = row.toDomain();
      expect(domainTx.id, equals('tx-test'));
      expect(domainTx.type, equals(TransactionType.expense));
      expect(domainTx.amount, equals(const Money.fromCents(15000)));
      expect(domainTx.description, equals('Despesa de teste'));
      expect(domainTx.status, equals(TransactionStatus.completed));
      expect(domainTx.accountId, equals('acc-nubank'));
      expect(domainTx.categoryId, equals('cat-alimentacao'));
      expect(domainTx.notes, equals('Nota explicativa'));
    });
  });
}
