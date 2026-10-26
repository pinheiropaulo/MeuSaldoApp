import 'package:meusaldo_core/src/accounts/financial_account.dart';
import 'package:meusaldo_core/src/shared/failures.dart';
import 'package:meusaldo_core/src/shared/money.dart';
import 'package:meusaldo_core/src/shared/result.dart';
import 'package:meusaldo_core/src/transactions/transaction.dart';
import 'package:meusaldo_core/src/transactions/transaction_status.dart';
import 'package:meusaldo_core/src/transactions/transaction_type.dart';

/// Resultado atômico de uma operação de transferência entre contas.
class TransferExecution {
  /// Conta de origem com o débito aplicado (se efetivada).
  final FinancialAccount sourceAccount;

  /// Conta de destino com o crédito aplicado (se efetivada).
  final FinancialAccount destinationAccount;

  /// Registro de transação de transferência gerado.
  final Transaction transaction;

  const TransferExecution({
    required this.sourceAccount,
    required this.destinationAccount,
    required this.transaction,
  });
}

/// Serviço responsável por coordenar a operação atômica de transferência entre contas.
class TransferService {
  const TransferService();

  /// Executa uma transferência atômica entre duas contas financeiras.
  ///
  /// Invariante fundamental: A soma dos saldos de origem e destino permanece
  /// rigorosamente inalterada antes e após a transferência.
  Result<TransferExecution, Failure> executeTransfer({
    required String transactionId,
    required FinancialAccount sourceAccount,
    required FinancialAccount destinationAccount,
    required Money amount,
    required DateTime date,
    String? description,
    TransactionStatus status = TransactionStatus.completed,
    String? notes,
  }) {
    if (!amount.isPositive) {
      return const Result.failure(
        ValidationFailure('O valor da transferência deve ser maior que zero.'),
      );
    }

    if (sourceAccount.id == destinationAccount.id) {
      return const Result.failure(
        ValidationFailure(
          'A conta de origem e a conta de destino não podem ser a mesma conta.',
        ),
      );
    }

    if (!sourceAccount.isActive) {
      return Result.failure(
        BusinessRuleFailure('A conta de origem "${sourceAccount.name}" está inativa.'),
      );
    }

    if (!destinationAccount.isActive) {
      return Result.failure(
        BusinessRuleFailure('A conta de destino "${destinationAccount.name}" está inativa.'),
      );
    }

    final effectiveDescription = description?.trim().isNotEmpty == true
        ? description!.trim()
        : 'Transferência de ${sourceAccount.name} para ${destinationAccount.name}';

    final transaction = Transaction.create(
      id: transactionId,
      type: TransactionType.transfer,
      amount: amount,
      date: date,
      description: effectiveDescription,
      status: status,
      accountId: sourceAccount.id,
      destinationAccountId: destinationAccount.id,
      notes: notes,
    );

    FinancialAccount updatedSource = sourceAccount;
    FinancialAccount updatedDestination = destinationAccount;

    if (status == TransactionStatus.completed) {
      updatedSource = sourceAccount.applyDebit(amount);
      updatedDestination = destinationAccount.applyCredit(amount);

      // Verificação estrita da invariante de conservação de saldo
      final totalBefore = sourceAccount.currentBalance + destinationAccount.currentBalance;
      final totalAfter = updatedSource.currentBalance + updatedDestination.currentBalance;

      if (totalBefore != totalAfter) {
        return const Result.failure(
          BusinessRuleFailure(
            'Violação crítica de domínio: inconsistência na conservação do saldo consolidado.',
          ),
        );
      }
    }

    return Result.success(
      TransferExecution(
        sourceAccount: updatedSource,
        destinationAccount: updatedDestination,
        transaction: transaction,
      ),
    );
  }
}
