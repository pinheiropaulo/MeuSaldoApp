import 'package:drift/drift.dart';
import 'package:meusaldo/shared/data/local/converters/money_converter.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Definição da tabela de contas financeiras (`accounts`) no SQLite.
@DataClassName('AccountRow')
class AccountsTable extends Table {
  @override
  String get tableName => 'accounts';

  /// Identificador único da conta.
  TextColumn get id => text()();

  /// Nome de exibição da conta (ex: Nubank, Carteira).
  TextColumn get name => text()();

  /// Tipo de conta financeira.
  TextColumn get type => textEnum<AccountType>()();

  /// Saldo inicial registrado na criação (em centavos).
  IntColumn get initialBalance => integer().map(const MoneyConverter())();

  /// Saldo atual calculado e mantido (em centavos).
  IntColumn get currentBalance => integer().map(const MoneyConverter())();

  /// Flag que indica se a conta está ativa para lançamentos.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Cor personalizada em hexadecimal (ex: #6D1834).
  TextColumn get colorHex => text().nullable()();

  /// Chave de identificação do ícone.
  TextColumn get iconKey => text().nullable()();

  /// Data de criação da conta.
  DateTimeColumn get createdAt => dateTime()();

  /// Data da última alteração.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
