import 'package:meusaldo_core/meusaldo_core.dart';

class FakeTransactionRepository implements TransactionRepository {
  final Map<String, Transaction> _transactions = {};

  @override
  Future<Result<List<Transaction>, Failure>> getAllTransactions() async {
    final list = _transactions.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return Result.success(list);
  }

  @override
  Future<Result<List<Transaction>, Failure>> getTransactionsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final list = _transactions.values.where((tx) {
      final isAfterOrEqual = tx.date.isAfter(start) || tx.date.isAtSameMomentAs(start);
      final isBeforeOrEqual = tx.date.isBefore(end) || tx.date.isAtSameMomentAs(end);
      return isAfterOrEqual && isBeforeOrEqual;
    }).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return Result.success(list);
  }

  @override
  Future<Result<List<Transaction>, Failure>> getTransactionsByAccount(String accountId) async {
    final list = _transactions.values
        .where((tx) => tx.accountId == accountId || tx.destinationAccountId == accountId)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return Result.success(list);
  }

  @override
  Future<Result<Transaction, Failure>> getTransactionById(String id) async {
    final tx = _transactions[id];
    if (tx == null) {
      return Result.failure(NotFoundFailure('Transação com ID "$id" não encontrada.'));
    }
    return Result.success(tx);
  }

  @override
  Future<Result<Transaction, Failure>> saveTransaction(Transaction transaction) async {
    if (_transactions.containsKey(transaction.id)) {
      return Result.failure(
        ValidationFailure('Já existe uma transação com o ID "${transaction.id}".'),
      );
    }
    _transactions[transaction.id] = transaction;
    return Result.success(transaction);
  }

  @override
  Future<Result<Transaction, Failure>> updateTransaction(Transaction transaction) async {
    if (!_transactions.containsKey(transaction.id)) {
      return Result.failure(
        NotFoundFailure('Transação com ID "${transaction.id}" não encontrada para atualização.'),
      );
    }
    _transactions[transaction.id] = transaction;
    return Result.success(transaction);
  }

  @override
  Future<Result<void, Failure>> deleteTransaction(String id) async {
    if (!_transactions.containsKey(id)) {
      return Result.failure(NotFoundFailure('Transação com ID "$id" não encontrada.'));
    }
    _transactions.remove(id);
    return const Result.success(null);
  }
}
