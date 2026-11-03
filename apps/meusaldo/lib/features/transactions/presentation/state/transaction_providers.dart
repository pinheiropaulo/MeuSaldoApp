import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/config/app_config.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/data/supabase_transaction_repository.dart';
import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

/// Provedor do repositório de lançamentos financeiros.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  if (AppConfig.isSupabaseConfigured) {
    try {
      final client = sp.Supabase.instance.client;
      return SupabaseTransactionRepository(client: client);
    } catch (_) {
      // Supabase não inicializado (ex: testes de widget isolados)
      return InMemoryTransactionRepository.withDemoData();
    }
  }
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

    // Se for despesa no cartão de crédito, reflete na fatura e no limite do cartão
    if (tx.isCardExpense) {
      final cardRepo = ref.read(creditCardRepositoryProvider);
      final installmentsCount = tx.installments ?? 1;
      final installmentAmount = installmentsCount > 1
          ? Money.fromCents((tx.amount.cents / installmentsCount).round())
          : tx.amount;

      final cardExpense = CardExpense.create(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        cardId: tx.cardId!,
        description: tx.description,
        amount: installmentAmount,
        date: tx.date,
        currentInstallment: installmentsCount > 1 ? 1 : null,
        totalInstallments: installmentsCount > 1 ? installmentsCount : null,
        categoryId: tx.categoryId,
      );
      await cardRepo.addExpense(cardExpense);
      ref.invalidate(cardsListProvider);
    } else if (tx.isCompleted) {
      // Se efetivada em conta bancária, reflete no saldo da conta
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

  /// Atualiza os dados de um lançamento existente e recalcula os saldos das contas impactadas.
  Future<Result<Transaction, Failure>> updateTransaction(Transaction updatedTransaction) async {
    final txRepo = ref.read(transactionRepositoryProvider);
    final accountRepo = ref.read(accountRepositoryProvider);

    final oldTxResult = await txRepo.getTransactionById(updatedTransaction.id);
    if (oldTxResult.isFailure) {
      return oldTxResult;
    }

    final oldTx = oldTxResult.valueOrNull!;
    const calculator = BalanceCalculator();

    // 1. Reverte o efeito da transação antiga se ela estava completada
    if (oldTx.isCompleted) {
      final oldAccountResult = await accountRepo.getAccountById(oldTx.accountId);
      if (oldAccountResult.isSuccess) {
        final reverted = calculator.revertTransaction(
          account: oldAccountResult.valueOrNull!,
          transaction: oldTx,
        );
        await accountRepo.updateAccount(reverted);
      }

      if (oldTx.isTransfer && oldTx.destinationAccountId != null) {
        final oldDestResult = await accountRepo.getAccountById(oldTx.destinationAccountId!);
        if (oldDestResult.isSuccess) {
          final revertedDest = calculator.revertTransaction(
            account: oldDestResult.valueOrNull!,
            transaction: oldTx,
          );
          await accountRepo.updateAccount(revertedDest);
        }
      }
    }

    // 2. Aplica o efeito da nova transação se ela estiver completada
    if (updatedTransaction.isCompleted) {
      final newAccountResult = await accountRepo.getAccountById(updatedTransaction.accountId);
      if (newAccountResult.isSuccess) {
        final applied = calculator.applyTransaction(
          account: newAccountResult.valueOrNull!,
          transaction: updatedTransaction,
        );
        await accountRepo.updateAccount(applied);
      }

      if (updatedTransaction.isTransfer && updatedTransaction.destinationAccountId != null) {
        final newDestResult = await accountRepo.getAccountById(updatedTransaction.destinationAccountId!);
        if (newDestResult.isSuccess) {
          final appliedDest = calculator.applyTransaction(
            account: newDestResult.valueOrNull!,
            transaction: updatedTransaction,
          );
          await accountRepo.updateAccount(appliedDest);
        }
      }
    }

    ref.invalidate(accountsListProvider);

    // 3. Salva a transação atualizada no repositório
    final result = await txRepo.updateTransaction(updatedTransaction);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
    return result;
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
