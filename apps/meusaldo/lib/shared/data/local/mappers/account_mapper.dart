import 'package:drift/drift.dart';
import 'package:meusaldo/shared/data/local/app_database.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Mapeamentos bidirecionais entre a entidade do Core [FinancialAccount]
/// e a linha da tabela do Drift [AccountRow] / [AccountsTableCompanion].
extension AccountRowMapper on AccountRow {
  FinancialAccount toDomain() {
    return FinancialAccount(
      id: id,
      name: name,
      type: type,
      initialBalance: initialBalance,
      currentBalance: currentBalance,
      isActive: isActive,
      colorHex: colorHex,
      iconKey: iconKey,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension FinancialAccountCompanionMapper on FinancialAccount {
  AccountsTableCompanion toCompanion() {
    return AccountsTableCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      initialBalance: Value(initialBalance),
      currentBalance: Value(currentBalance),
      isActive: Value(isActive),
      colorHex: Value(colorHex),
      iconKey: Value(iconKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
