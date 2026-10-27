import 'package:drift/drift.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Definição da tabela de categorias (`categories`) no SQLite.
@DataClassName('CategoryRow')
class CategoriesTable extends Table {
  @override
  String get tableName => 'categories';

  /// Identificador único da categoria.
  TextColumn get id => text()();

  /// Nome de exibição da categoria (ex: Alimentação).
  TextColumn get name => text()();

  /// Tipo de operação compatível (expense, income, both).
  TextColumn get type => textEnum<CategoryType>()();

  /// Chave de identificação do ícone.
  TextColumn get iconKey => text().nullable()();

  /// Cor associada em hexadecimal (ex: #22A06B).
  TextColumn get colorHex => text().nullable()();

  /// Descrição detalhada da categoria.
  TextColumn get description => text().nullable()();

  /// Flag que indica se a categoria foi arquivada.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
