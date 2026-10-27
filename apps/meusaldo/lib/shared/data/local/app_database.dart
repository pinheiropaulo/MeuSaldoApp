import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:meusaldo/shared/data/demo_data.dart';
import 'package:meusaldo/shared/data/local/converters/money_converter.dart';
import 'package:meusaldo/shared/data/local/tables/accounts_table.dart';
import 'package:meusaldo/shared/data/local/tables/categories_table.dart';
import 'package:meusaldo/shared/data/local/tables/transactions_table.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

part 'app_database.g.dart';

/// Banco de dados local tipado SQLite do MeuSaldo utilizando Drift.
@DriftDatabase(tables: [AccountsTable, CategoriesTable, TransactionsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDemoData();
    },
  );

  /// Pré-carrega o banco de dados local com os dados de demonstração na primeira execução.
  Future<void> _seedDemoData() async {
    await batch((b) {
      // Inserir categorias pré-definidas
      for (final cat in DemoData.categories) {
        b.insert(
          categoriesTable,
          CategoriesTableCompanion.insert(
            id: cat.id,
            name: cat.name,
            type: cat.type,
            iconKey: Value(cat.iconKey),
            colorHex: Value(cat.colorHex),
            description: Value(cat.description),
            isArchived: Value(cat.isArchived),
          ),
        );
      }

      // Inserir contas pré-definidas
      for (final acc in DemoData.accounts) {
        b.insert(
          accountsTable,
          AccountsTableCompanion.insert(
            id: acc.id,
            name: acc.name,
            type: acc.type,
            initialBalance: acc.initialBalance,
            currentBalance: acc.currentBalance,
            isActive: Value(acc.isActive),
            colorHex: Value(acc.colorHex),
            iconKey: Value(acc.iconKey),
            createdAt: acc.createdAt,
            updatedAt: Value(acc.updatedAt),
          ),
        );
      }

      // Inserir transações de exemplo
      for (final tx in DemoData.getTransactions()) {
        b.insert(
          transactionsTable,
          TransactionsTableCompanion.insert(
            id: tx.id,
            type: tx.type,
            amount: tx.amount,
            date: tx.date,
            description: tx.description,
            status: tx.status,
            accountId: tx.accountId,
            destinationAccountId: Value(tx.destinationAccountId),
            categoryId: Value(tx.categoryId),
            notes: Value(tx.notes),
            createdAt: tx.createdAt,
            updatedAt: Value(tx.updatedAt),
          ),
        );
      }
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'meusaldo_db');
  }
}
