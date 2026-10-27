import 'package:drift/drift.dart';
import 'package:meusaldo/shared/data/local/app_database.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Mapeamentos bidirecionais entre a entidade do Core [Transaction]
/// e a linha da tabela do Drift [TransactionRow] / [TransactionsTableCompanion].
extension TransactionRowMapper on TransactionRow {
  Transaction toDomain() {
    return Transaction(
      id: id,
      type: type,
      amount: amount,
      date: date,
      description: description,
      status: status,
      accountId: accountId,
      destinationAccountId: destinationAccountId,
      categoryId: categoryId,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension TransactionCompanionMapper on Transaction {
  TransactionsTableCompanion toCompanion() {
    return TransactionsTableCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      date: Value(date),
      description: Value(description),
      status: Value(status),
      accountId: Value(accountId),
      destinationAccountId: Value(destinationAccountId),
      categoryId: Value(categoryId),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
