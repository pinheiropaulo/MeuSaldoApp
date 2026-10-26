import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('Transaction', () {
    test('criação válida de despesa e receita', () {
      final now = DateTime.now();
      final expense = Transaction.create(
        id: 'tx-1',
        type: TransactionType.expense,
        amount: const Money.fromCents(14590), // R$ 145,90
        date: now,
        description: 'Supermercado Pão de Açúcar',
        accountId: 'acc-1',
        categoryId: 'cat-alimentacao',
      );

      expect(expense.isExpense, isTrue);
      expect(expense.isIncome, isFalse);
      expect(expense.isTransfer, isFalse);
      expect(expense.isCompleted, isTrue);
      expect(expense.amount.cents, equals(14590));
      expect(expense.destinationAccountId, isNull);

      final income = Transaction.create(
        id: 'tx-2',
        type: TransactionType.income,
        amount: const Money.fromCents(350000), // R$ 3.500,00
        date: now,
        description: 'Salário Mensal',
        status: TransactionStatus.completed,
        accountId: 'acc-1',
        categoryId: 'cat-salario',
      );
      expect(income.isIncome, isTrue);
    });

    test('criação válida de transferência com origem e destino distintos', () {
      final transfer = Transaction.create(
        id: 'tx-3',
        type: TransactionType.transfer,
        amount: const Money.fromCents(20000), // R$ 200,00
        date: DateTime.now(),
        description: 'Transferência para Poupança',
        accountId: 'acc-checking',
        destinationAccountId: 'acc-savings',
      );

      expect(transfer.isTransfer, isTrue);
      expect(transfer.accountId, equals('acc-checking'));
      expect(transfer.destinationAccountId, equals('acc-savings'));
    });

    test('rejeita valor zero ou negativo', () {
      expect(
        () => Transaction.create(
          id: 'tx-inv',
          type: TransactionType.expense,
          amount: const Money.zero(),
          date: DateTime.now(),
          description: 'Inválido',
          accountId: 'acc-1',
        ),
        throwsArgumentError,
      );

      expect(
        () => Transaction.create(
          id: 'tx-inv2',
          type: TransactionType.expense,
          amount: const Money.fromCents(-100),
          date: DateTime.now(),
          description: 'Inválido',
          accountId: 'acc-1',
        ),
        throwsArgumentError,
      );
    });

    test('rejeita descrição vazia ou conta de origem vazia', () {
      expect(
        () => Transaction.create(
          id: 'tx-inv',
          type: TransactionType.expense,
          amount: const Money.fromCents(100),
          date: DateTime.now(),
          description: '   ',
          accountId: 'acc-1',
        ),
        throwsArgumentError,
      );

      expect(
        () => Transaction.create(
          id: 'tx-inv',
          type: TransactionType.expense,
          amount: const Money.fromCents(100),
          date: DateTime.now(),
          description: 'Teste',
          accountId: '',
        ),
        throwsArgumentError,
      );
    });

    test('rejeita transferência sem destino ou com destino igual à origem', () {
      expect(
        () => Transaction.create(
          id: 'tx-inv',
          type: TransactionType.transfer,
          amount: const Money.fromCents(100),
          date: DateTime.now(),
          description: 'Transferência',
          accountId: 'acc-1',
          destinationAccountId: null,
        ),
        throwsArgumentError,
      );

      expect(
        () => Transaction.create(
          id: 'tx-inv',
          type: TransactionType.transfer,
          amount: const Money.fromCents(100),
          date: DateTime.now(),
          description: 'Transferência',
          accountId: 'acc-1',
          destinationAccountId: 'acc-1',
        ),
        throwsArgumentError,
      );
    });
  });
}
