import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Provedor do repositório de lançamentos financeiros.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return InMemoryTransactionRepository();
});

/// Notifier reativo para lançamentos com sincronização automática de saldos de contas.
class TransactionsListNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  FutureOr<List<Transaction>> build() async {
    final repo = ref.watch(transactionRepositoryProvider);
    final result = await repo.getAllTransactions();
    return result.when(
      onSuccess: (transactions) => transactions,
      onFailure: (failure) => throw Exception(failure.message),
    );
  }

  /// Adiciona uma movimentação e reflete o impacto financeiro na conta associada.
  Future<Result<Transaction, Failure>> addTransaction(Transaction tx) async {
    final txRepo = ref.read(transactionRepositoryProvider);
    final accountRepo = ref.read(accountRepositoryProvider);

    // Salva a transação
    final saveResult = await txRepo.saveTransaction(tx);
    if (saveResult.isFailure) {
      return saveResult;
    }

    // Se efetivada, reflete no saldo da conta
    if (tx.isCompleted) {
      const calculator = BalanceCalculator();
      final accountResult = await accountRepo.getAccountById(tx.accountId);
      if (accountResult.isSuccess) {
        final currentAccount = accountResult.valueOrNull!;
        final updatedAccount = calculator.applyTransaction(
          account: currentAccount,
          transaction: tx,
        );
        await accountRepo.updateAccount(updatedAccount);
        ref.invalidate(accountsListProvider);
      }
    }

    ref.invalidateSelf();
    return saveResult;
  }

  /// Executa uma transferência atômica entre contas via [TransferService].
  Future<Result<TransferExecution, Failure>> executeTransfer({
    required String transactionId,
    required String sourceAccountId,
    required String destinationAccountId,
    required Money amount,
    required DateTime date,
    String? description,
    TransactionStatus status = TransactionStatus.completed,
    String? notes,
  }) async {
    final accountRepo = ref.read(accountRepositoryProvider);
    final txRepo = ref.read(transactionRepositoryProvider);

    final sourceResult = await accountRepo.getAccountById(sourceAccountId);
    if (sourceResult.isFailure) {
      return Result.failure(sourceResult.failureOrNull!);
    }

    final destResult = await accountRepo.getAccountById(destinationAccountId);
    if (destResult.isFailure) {
      return Result.failure(destResult.failureOrNull!);
    }

    const service = TransferService();
    final transferResult = service.executeTransfer(
      transactionId: transactionId,
      sourceAccount: sourceResult.valueOrNull!,
      destinationAccount: destResult.valueOrNull!,
      amount: amount,
      date: date,
      description: description,
      status: status,
      notes: notes,
    );

    if (transferResult.isFailure) {
      return transferResult;
    }

    final execution = transferResult.valueOrNull!;
    // Grava transação de transferência
    await txRepo.saveTransaction(execution.transaction);
    // Atualiza ambas as contas de forma atômica
    await accountRepo.updateAccount(execution.sourceAccount);
    await accountRepo.updateAccount(execution.destinationAccount);

    ref.invalidate(accountsListProvider);
    ref.invalidateSelf();

    return transferResult;
  }

  /// Exclui um lançamento e reverte o seu impacto no saldo da conta.
  Future<Result<void, Failure>> deleteTransaction(String id) async {
    final txRepo = ref.read(transactionRepositoryProvider);
    final accountRepo = ref.read(accountRepositoryProvider);

    final txResult = await txRepo.getTransactionById(id);
    if (txResult.isFailure) {
      return Result.failure(txResult.failureOrNull!);
    }

    final tx = txResult.valueOrNull!;
    if (tx.isCompleted) {
      const calculator = BalanceCalculator();
      final accountResult = await accountRepo.getAccountById(tx.accountId);
      if (accountResult.isSuccess) {
        final revertedAccount = calculator.revertTransaction(
          account: accountResult.valueOrNull!,
          transaction: tx,
        );
        await accountRepo.updateAccount(revertedAccount);
      }

      if (tx.isTransfer && tx.destinationAccountId != null) {
        final destResult = await accountRepo.getAccountById(tx.destinationAccountId!);
        if (destResult.isSuccess) {
          final revertedDest = calculator.revertTransaction(
            account: destResult.valueOrNull!,
            transaction: tx,
          );
          await accountRepo.updateAccount(revertedDest);
        }
      }
      ref.invalidate(accountsListProvider);
    }

    final deleteResult = await txRepo.deleteTransaction(id);
    ref.invalidateSelf();
    return deleteResult;
  }
}

/// Provedor da lista reativa de lançamentos.
final transactionsListProvider =
    AsyncNotifierProvider<TransactionsListNotifier, List<Transaction>>(
  TransactionsListNotifier.new,
);

/// Lançamentos do mês e ano correntes.
final currentMonthTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactionsAsync = ref.watch(transactionsListProvider);
  final now = DateTime.now();

  return transactionsAsync.maybeWhen(
    data: (list) => list.where((tx) {
      return tx.date.year == now.year && tx.date.month == now.month;
    }).toList(),
    orElse: () => const [],
  );
});

/// Total de receitas efetivadas no mês corrente.
final currentMonthIncomeTotalProvider = Provider<Money>((ref) {
  final monthlyTx = ref.watch(currentMonthTransactionsProvider);
  const calculator = BalanceCalculator();
  return calculator.calculateTotalIncome(monthlyTx);
});

/// Total de despesas efetivadas no mês corrente.
final currentMonthExpensesTotalProvider = Provider<Money>((ref) {
  final monthlyTx = ref.watch(currentMonthTransactionsProvider);
  const calculator = BalanceCalculator();
  return calculator.calculateTotalExpenses(monthlyTx);
});
