import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('TransferService', () {
    const service = TransferService();

    final accountOrigin = FinancialAccount.create(
      id: 'acc-origem',
      name: 'Conta Corrente',
      type: AccountType.checking,
      initialBalance: const Money.fromCents(100000), // R$ 1.000,00
    );

    final accountDest = FinancialAccount.create(
      id: 'acc-destino',
      name: 'Poupança Reserva',
      type: AccountType.savings,
      initialBalance: const Money.fromCents(20000), // R$ 200,00
    );

    test('executa transferência válida mantendo conservação estrita de saldo consolidado', () {
      final totalBefore = accountOrigin.currentBalance + accountDest.currentBalance;

      final result = service.executeTransfer(
        transactionId: 'tf-1',
        sourceAccount: accountOrigin,
        destinationAccount: accountDest,
        amount: const Money.fromCents(30000), // R$ 300,00
        date: DateTime.now(),
      );

      expect(result.isSuccess, isTrue);
      final execution = result.valueOrNull!;

      // Conta de origem: 1000 - 300 = 700
      expect(execution.sourceAccount.currentBalance.cents, equals(70000));
      // Conta de destino: 200 + 300 = 500
      expect(execution.destinationAccount.currentBalance.cents, equals(50000));

      // Invariante de conservação do saldo consolidado
      final totalAfter =
          execution.sourceAccount.currentBalance + execution.destinationAccount.currentBalance;
      expect(totalAfter, equals(totalBefore));

      expect(execution.transaction.type, equals(TransactionType.transfer));
      expect(execution.transaction.accountId, equals('acc-origem'));
      expect(execution.transaction.destinationAccountId, equals('acc-destino'));
    });

    test('transferência pendente não debita nem credita saldos imediatamente', () {
      final result = service.executeTransfer(
        transactionId: 'tf-pending',
        sourceAccount: accountOrigin,
        destinationAccount: accountDest,
        amount: const Money.fromCents(10000),
        date: DateTime.now(),
        status: TransactionStatus.pending,
      );

      expect(result.isSuccess, isTrue);
      final execution = result.valueOrNull!;
      expect(execution.sourceAccount.currentBalance, equals(accountOrigin.currentBalance));
      expect(
        execution.destinationAccount.currentBalance,
        equals(accountDest.currentBalance),
      );
      expect(execution.transaction.status, equals(TransactionStatus.pending));
    });

    test('rejeita transferência entre a mesma conta', () {
      final result = service.executeTransfer(
        transactionId: 'tf-err',
        sourceAccount: accountOrigin,
        destinationAccount: accountOrigin,
        amount: const Money.fromCents(5000),
        date: DateTime.now(),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('rejeita valor de transferência zero ou negativo', () {
      final result = service.executeTransfer(
        transactionId: 'tf-err',
        sourceAccount: accountOrigin,
        destinationAccount: accountDest,
        amount: const Money.zero(),
        date: DateTime.now(),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejeita transferência com conta inativa', () {
      final inactiveAccount = accountOrigin.copyWith(isActive: false);

      final result = service.executeTransfer(
        transactionId: 'tf-err',
        sourceAccount: inactiveAccount,
        destinationAccount: accountDest,
        amount: const Money.fromCents(1000),
        date: DateTime.now(),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<BusinessRuleFailure>());
    });
  });
}
