import 'package:drift/drift.dart';
import 'package:meusaldo/shared/data/local/converters/money_converter.dart';
import 'package:meusaldo/shared/data/local/tables/accounts_table.dart';
import 'package:meusaldo/shared/data/local/tables/categories_table.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Definição da tabela de lançamentos (`transactions`) no SQLite.
@DataClassName('TransactionRow')
class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';

  /// Identificador único da transação.
  TextColumn get id => text()();

  /// Tipo de movimentação: expense, income, transfer.
  TextColumn get type => textEnum<TransactionType>()();

  /// Valor da transação em centavos inteiros (sempre positivo).
  IntColumn get amount => integer().map(const MoneyConverter())();

  /// Data de competência da movimentação.
  DateTimeColumn get date => dateTime()();

  /// Descrição resumida da movimentação.
  TextColumn get description => text()();

  /// Status da movimentação: completed ou pending.
  TextColumn get status => textEnum<TransactionStatus>()();

  /// Identificador da conta de origem.
  @ReferenceName('originTransactions')
  TextColumn get accountId => text().references(AccountsTable, #id)();

  /// Identificador da conta de destino (apenas para transferências).
  @ReferenceName('destinationTransactions')
  TextColumn get destinationAccountId =>
      text().nullable().references(AccountsTable, #id)();

  /// Identificador da categoria financeira associada.
  TextColumn get categoryId =>
      text().nullable().references(CategoriesTable, #id)();

  /// Observações adicionais do lançamento.
  TextColumn get notes => text().nullable()();

  /// Data de criação do registro.
  DateTimeColumn get createdAt => dateTime()();

  /// Data da última alteração do registro.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
