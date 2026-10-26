import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('BalanceCalculator', () {
    const calculator = BalanceCalculator();

    final accountA = FinancialAccount.create(
      id: 'acc-a',
      name: 'Conta A',
      type: AccountType.checking,
      initialBalance: const Money.fromCents(10000), // R$ 100,00
    );

    final accountB = FinancialAccount.create(
      id: 'acc-b',
      name: 'Conta B',
      type: AccountType.savings,
      initialBalance: const Money.fromCents(5000), // R$ 50,00
    );

    test('calcula saldo com receitas e despesas efetivadas', () {
      final transactions = [
        Transaction.create(
          id: 'tx-1',
          type: TransactionType.income,
          amount: const Money.fromCents(5000), // + R$ 50,00
          date: DateTime.now(),
          description: 'Pix recebido',
          accountId: 'acc-a',
        ),
        Transaction.create(
          id: 'tx-2',
          type: TransactionType.expense,
          amount: const Money.fromCents(3000), // - R$ 30,00
          date: DateTime.now(),
          description: 'Almoço',
          accountId: 'acc-a',
        ),
        Transaction.create(
          id: 'tx-3',
          type: TransactionType.expense,
          amount: const Money.fromCents(2000), // R$ 20,00 pendente
          date: DateTime.now(),
          description: 'Boleto futuro',
          status: TransactionStatus.pending,
          accountId: 'acc-a',
        ),
      ];

      final balanceCompleted = calculator.calculateAccountBalance(
        account: accountA,
        transactions: transactions,
        includePending: false,
      );
      // 100 + 50 - 30 = 120,00 (12000 cents)
      expect(balanceCompleted.cents, equals(12000));

      final balanceWithPending = calculator.calculateAccountBalance(
        account: accountA,
        transactions: transactions,
        includePending: true,
      );
      // 120 - 20 = 100,00 (10000 cents)
      expect(balanceWithPending.cents, equals(10000));
    });

    test('calcula saldo com transferências recebidas e enviadas', () {
      final transactions = [
        Transaction.create(
          id: 'tx-tf-1',
          type: TransactionType.transfer,
          amount: const Money.fromCents(4000), // R$ 40,00 de A para B
          date: DateTime.now(),
          description: 'Reserva',
          accountId: 'acc-a',
          destinationAccountId: 'acc-b',
        ),
      ];

      final balanceA = calculator.calculateAccountBalance(
        account: accountA,
        transactions: transactions,
      );
      expect(balanceA.cents, equals(6000)); // 100 - 40 = 60

      final balanceB = calculator.calculateAccountBalance(
        account: accountB,
        transactions: transactions,
      );
      expect(balanceB.cents, equals(9000)); // 50 + 40 = 90
    });

    test('calcula saldo consolidado total das contas', () {
      final total = calculator.calculateConsolidatedBalance([accountA, accountB]);
      expect(total.cents, equals(15000)); // 100 + 50 = 150
    });

    test('calcula totais agregados de receitas e despesas', () {
      final transactions = [
        Transaction.create(
          id: 'tx-1',
          type: TransactionType.income,
          amount: const Money.fromCents(5000),
          date: DateTime.now(),
          description: 'Receita',
          accountId: 'acc-a',
        ),
        Transaction.create(
          id: 'tx-2',
          type: TransactionType.expense,
          amount: const Money.fromCents(1500),
          date: DateTime.now(),
          description: 'Despesa 1',
          accountId: 'acc-a',
        ),
        Transaction.create(
          id: 'tx-3',
          type: TransactionType.expense,
          amount: const Money.fromCents(2500),
          date: DateTime.now(),
          description: 'Despesa 2',
          accountId: 'acc-a',
        ),
      ];

      expect(calculator.calculateTotalIncome(transactions).cents, equals(5000));
      expect(calculator.calculateTotalExpenses(transactions).cents, equals(4000));
    });

    test('applyTransaction e revertTransaction atualizam saldo de forma espelhada', () {
      final expenseTx = Transaction.create(
        id: 'tx-exp',
        type: TransactionType.expense,
        amount: const Money.fromCents(2500),
        date: DateTime.now(),
        description: 'Mercado',
        accountId: 'acc-a',
      );

      final debited = calculator.applyTransaction(
        account: accountA,
        transaction: expenseTx,
      );
      expect(debited.currentBalance.cents, equals(7500));

      final reverted = calculator.revertTransaction(
        account: debited,
        transaction: expenseTx,
      );
      expect(reverted.currentBalance.cents, equals(accountA.currentBalance.cents));
    });
  });
}
