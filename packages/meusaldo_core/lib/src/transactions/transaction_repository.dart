import 'package:meusaldo_core/src/shared/failures.dart';
import 'package:meusaldo_core/src/shared/result.dart';
import 'package:meusaldo_core/src/transactions/transaction.dart';

/// Contrato para persistência e recuperação de lançamentos financeiros.
abstract interface class TransactionRepository {
  /// Retorna todos os lançamentos financeiros cadastrados.
  Future<Result<List<Transaction>, Failure>> getAllTransactions();

  /// Retorna os lançamentos contidos em um determinado intervalo de datas (inclusive).
  Future<Result<List<Transaction>, Failure>> getTransactionsByDateRange({
    required DateTime start,
    required DateTime end,
  });

  /// Retorna os lançamentos associados a uma conta específica (origem ou destino).
  Future<Result<List<Transaction>, Failure>> getTransactionsByAccount(String accountId);

  /// Busca um lançamento pelo seu identificador único [id].
  Future<Result<Transaction, Failure>> getTransactionById(String id);

  /// Salva uma nova movimentação financeira.
  Future<Result<Transaction, Failure>> saveTransaction(Transaction transaction);

  /// Atualiza os dados de uma movimentação financeira existente.
  Future<Result<Transaction, Failure>> updateTransaction(Transaction transaction);

  /// Remove uma movimentação financeira pelo seu [id].
  Future<Result<void, Failure>> deleteTransaction(String id);
}
