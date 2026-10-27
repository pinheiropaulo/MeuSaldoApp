import 'package:drift/drift.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Conversor customizado para persistir o Value Object [Money] estritamente
/// como um número inteiro de centavos (`int`) no banco SQLite.
class MoneyConverter extends TypeConverter<Money, int> {
  const MoneyConverter();

  @override
  Money fromSql(int fromDb) => Money.fromCents(fromDb);

  @override
  int toSql(Money value) => value.cents;
}
