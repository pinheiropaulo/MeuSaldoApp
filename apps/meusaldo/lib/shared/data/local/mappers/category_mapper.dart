import 'package:drift/drift.dart';
import 'package:meusaldo/shared/data/local/app_database.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Mapeamentos bidirecionais entre a entidade do Core [Category]
/// e a linha da tabela do Drift [CategoryRow] / [CategoriesTableCompanion].
extension CategoryRowMapper on CategoryRow {
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      type: type,
      iconKey: iconKey,
      colorHex: colorHex,
      description: description,
      isArchived: isArchived,
    );
  }
}

extension CategoryCompanionMapper on Category {
  CategoriesTableCompanion toCompanion() {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      iconKey: Value(iconKey),
      colorHex: Value(colorHex),
      description: Value(description),
      isArchived: Value(isArchived),
    );
  }
}
