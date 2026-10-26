import 'package:meusaldo_core/src/accounts/financial_account.dart';
import 'package:meusaldo_core/src/shared/money.dart';
import 'package:meusaldo_core/src/transactions/transaction.dart';

/// Utilitário e motor de cálculo de saldos financeiros e conciliação de contas.
class BalanceCalculator {
  const BalanceCalculator();

  /// Calcula o saldo atualizado de uma conta a partir do seu saldo inicial
  /// e de todas as transações que afetam essa conta.
  ///
  /// Se [includePending] for `false` (padrão), apenas transações com status
  /// `completed` alteram o saldo.
  Money calculateAccountBalance({
    required FinancialAccount account,
    required Iterable<Transaction> transactions,
    bool includePending = false,
  }) {
    var balance = account.initialBalance;

    for (final tx in transactions) {
      if (!includePending && !tx.isCompleted) {
        continue;
      }

      final isOrigin = tx.accountId == account.id;
      final isDestination = tx.destinationAccountId == account.id;

      if (!isOrigin && !isDestination) {
        continue;
      }

      if (tx.isExpense && isOrigin) {
        balance = balance - tx.amount;
      } else if (tx.isIncome && isOrigin) {
        balance = balance + tx.amount;
      } else if (tx.isTransfer) {
        if (isOrigin) {
          balance = balance - tx.amount;
        }
        if (isDestination) {
          balance = balance + tx.amount;
        }
      }
    }

    return balance;
  }

  /// Calcula o saldo consolidado de todas as contas ativas do usuário.
  Money calculateConsolidatedBalance(Iterable<FinancialAccount> accounts) {
    return accounts.fold<Money>(
      const Money.zero(),
      (total, account) => total + account.currentBalance,
    );
  }

  /// Calcula o total de receitas efetivadas em um determinado conjunto de transações.
  Money calculateTotalIncome(Iterable<Transaction> transactions) {
    return transactions
        .where((tx) => tx.isIncome && tx.isCompleted)
        .fold<Money>(
          const Money.zero(),
          (total, tx) => total + tx.amount,
        );
  }

  /// Calcula o total de despesas efetivadas em um determinado conjunto de transações.
  Money calculateTotalExpenses(Iterable<Transaction> transactions) {
    return transactions
        .where((tx) => tx.isExpense && tx.isCompleted)
        .fold<Money>(
          const Money.zero(),
          (total, tx) => total + tx.amount,
        );
  }

  /// Aplica o efeito de uma movimentação efetivada sobre a conta.
  ///
  /// - Despesa: debita da conta.
  /// - Receita: credita na conta.
  FinancialAccount applyTransaction({
    required FinancialAccount account,
    required Transaction transaction,
  }) {
    if (!transaction.isCompleted) {
      return account;
    }

    final isOrigin = transaction.accountId == account.id;
    final isDestination = transaction.destinationAccountId == account.id;

    if (transaction.isExpense && isOrigin) {
      return account.applyDebit(transaction.amount);
    } else if (transaction.isIncome && isOrigin) {
      return account.applyCredit(transaction.amount);
    } else if (transaction.isTransfer) {
      if (isOrigin) {
        return account.applyDebit(transaction.amount);
      } else if (isDestination) {
        return account.applyCredit(transaction.amount);
      }
    }

    return account;
  }

  /// Reverte o efeito de uma movimentação efetivada (ex: ao excluir uma transação).
  ///
  /// - Despesa revertida: devolve o valor (credita).
  /// - Receita revertida: estorna o valor (debita).
  FinancialAccount revertTransaction({
    required FinancialAccount account,
    required Transaction transaction,
  }) {
    if (!transaction.isCompleted) {
      return account;
    }

    final isOrigin = transaction.accountId == account.id;
    final isDestination = transaction.destinationAccountId == account.id;

    if (transaction.isExpense && isOrigin) {
      return account.applyCredit(transaction.amount);
    } else if (transaction.isIncome && isOrigin) {
      return account.applyDebit(transaction.amount);
    } else if (transaction.isTransfer) {
      if (isOrigin) {
        return account.applyCredit(transaction.amount);
      } else if (isDestination) {
        return account.applyDebit(transaction.amount);
      }
    }

    return account;
  }
}
