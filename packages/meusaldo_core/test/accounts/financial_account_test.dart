import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('FinancialAccount', () {
    test('criação válida com saldo inicial', () {
      final account = FinancialAccount.create(
        id: 'acc-1',
        name: 'Nubank Principal',
        type: AccountType.checking,
        initialBalance: const Money.fromCents(50000), // R$ 500,00
        colorHex: '#6D1834',
        iconKey: 'account_balance',
      );

      expect(account.id, equals('acc-1'));
      expect(account.name, equals('Nubank Principal'));
      expect(account.type, equals(AccountType.checking));
      expect(account.initialBalance.cents, equals(50000));
      expect(account.currentBalance.cents, equals(50000));
      expect(account.isActive, isTrue);
    });

    test('rejeita nome vazio', () {
      expect(
        () => FinancialAccount.create(
          id: 'acc-2',
          name: '   ',
          type: AccountType.savings,
        ),
        throwsArgumentError,
      );
    });

    test('aplicação de crédito e débito', () {
      final account = FinancialAccount.create(
        id: 'acc-1',
        name: 'Carteira',
        type: AccountType.cash,
        initialBalance: const Money.fromCents(10000), // R$ 100,00
      );

      final credited = account.applyCredit(const Money.fromCents(2500));
      expect(credited.currentBalance.cents, equals(12500));
      expect(credited.initialBalance.cents, equals(10000));

      final debited = credited.applyDebit(const Money.fromCents(5000));
      expect(debited.currentBalance.cents, equals(7500));

      expect(
        () => account.applyCredit(const Money.fromCents(-100)),
        throwsArgumentError,
      );
      expect(
        () => account.applyDebit(const Money.fromCents(-100)),
        throwsArgumentError,
      );
    });

    test('copyWith preserva valores não alterados e valida campos obrigatórios', () {
      final account = FinancialAccount.create(
        id: 'acc-1',
        name: 'Itaú',
        type: AccountType.checking,
        initialBalance: const Money.fromCents(1000),
      );

      final updated = account.copyWith(name: 'Itaú Unibanco', isActive: false);
      expect(updated.id, equals('acc-1'));
      expect(updated.name, equals('Itaú Unibanco'));
      expect(updated.isActive, isFalse);
      expect(updated.currentBalance.cents, equals(1000));

      expect(() => account.copyWith(name: ''), throwsArgumentError);
      expect(() => account.copyWith(name: '   '), throwsArgumentError);
      expect(() => account.copyWith(id: ''), throwsArgumentError);
      expect(() => account.copyWith(id: '   '), throwsArgumentError);
    });
  });
}
