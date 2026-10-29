import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('CreditCard Domain Tests', () {
    test('criação válida com cálculo de limite disponível e porcentagens', () {
      final card = CreditCard.create(
        id: 'card-nubank',
        name: 'Nubank Ultravioleta',
        totalLimit: const Money.fromCents(1200000), // R$ 12.000,00
        usedLimit: const Money.fromCents(555000), // R$ 5.550,00
        closingDay: 3,
        dueDay: 10,
        colorHex: '#6D1834',
        lastFourDigits: '8842',
        isDefault: true,
      );

      expect(card.id, equals('card-nubank'));
      expect(card.name, equals('Nubank Ultravioleta'));
      expect(card.totalLimit, equals(const Money.fromCents(1200000)));
      expect(card.usedLimit, equals(const Money.fromCents(555000)));
      expect(card.availableLimit, equals(const Money.fromCents(645000))); // R$ 6.450,00
      expect(card.closingDay, equals(3));
      expect(card.dueDay, equals(10));
      expect(card.lastFourDigits, equals('8842'));
      expect(card.isDefault, isTrue);
      expect(card.usedPercentage, equals(46)); // 555000 / 1200000 = 46.25% -> 46
      expect(card.freePercentage, equals(54));
    });

    test('rejeita identificador ou nome vazios', () {
      expect(
        () => CreditCard.create(
          id: ' ',
          name: 'Cartão',
          totalLimit: const Money.fromCents(100000),
          closingDay: 1,
          dueDay: 10,
        ),
        throwsArgumentError,
      );

      expect(
        () => CreditCard.create(
          id: 'c1',
          name: '',
          totalLimit: const Money.fromCents(100000),
          closingDay: 1,
          dueDay: 10,
        ),
        throwsArgumentError,
      );
    });

    test('rejeita limite total zero ou negativo e limite utilizado negativo', () {
      expect(
        () => CreditCard.create(
          id: 'c1',
          name: 'Cartão',
          totalLimit: const Money.zero(),
          closingDay: 1,
          dueDay: 10,
        ),
        throwsArgumentError,
      );

      expect(
        () => CreditCard.create(
          id: 'c1',
          name: 'Cartão',
          totalLimit: const Money.fromCents(10000),
          usedLimit: const Money.fromCents(-500),
          closingDay: 1,
          dueDay: 10,
        ),
        throwsArgumentError,
      );
    });

    test('rejeita dias de fechamento e vencimento inválidos', () {
      expect(
        () => CreditCard.create(
          id: 'c1',
          name: 'Cartão',
          totalLimit: const Money.fromCents(10000),
          closingDay: 0,
          dueDay: 10,
        ),
        throwsArgumentError,
      );

      expect(
        () => CreditCard.create(
          id: 'c1',
          name: 'Cartão',
          totalLimit: const Money.fromCents(10000),
          closingDay: 10,
          dueDay: 32,
        ),
        throwsArgumentError,
      );
    });

    test('copyWith preserva atributos e permite alterações', () {
      final card = CreditCard.create(
        id: 'c1',
        name: 'Cartão 1',
        totalLimit: const Money.fromCents(500000),
        closingDay: 5,
        dueDay: 15,
      );

      final updated = card.copyWith(
        usedLimit: const Money.fromCents(200000),
        isDefault: true,
      );

      expect(updated.id, equals('c1'));
      expect(updated.usedLimit, equals(const Money.fromCents(200000)));
      expect(updated.availableLimit, equals(const Money.fromCents(300000)));
      expect(updated.isDefault, isTrue);
    });
  });

  group('Invoice Domain Tests', () {
    test('criação válida e cálculo de valor restante', () {
      final invoice = Invoice.create(
        id: 'inv-1',
        cardId: 'card-nubank',
        month: 11,
        year: 2026,
        closingDate: DateTime(2026, 11, 3),
        dueDate: DateTime(2026, 11, 10),
        totalAmount: const Money.fromCents(234870), // R$ 2.348,70
        status: InvoiceStatus.open,
      );

      expect(invoice.id, equals('inv-1'));
      expect(invoice.totalAmount.cents, equals(234870));
      expect(invoice.remainingAmount.cents, equals(234870));
      expect(invoice.isOpen, isTrue);
      expect(invoice.isPaid, isFalse);

      final partiallyPaid = invoice.copyWith(
        paidAmount: const Money.fromCents(100000),
      );
      expect(partiallyPaid.remainingAmount.cents, equals(134870));
    });

    test('rejeita mês inválido ou valores negativos', () {
      expect(
        () => Invoice.create(
          id: 'inv-1',
          cardId: 'card-1',
          month: 13,
          year: 2026,
          closingDate: DateTime.now(),
          dueDate: DateTime.now(),
          totalAmount: const Money.fromCents(1000),
        ),
        throwsArgumentError,
      );

      expect(
        () => Invoice.create(
          id: 'inv-1',
          cardId: 'card-1',
          month: 5,
          year: 2026,
          closingDate: DateTime.now(),
          dueDate: DateTime.now(),
          totalAmount: const Money.fromCents(-100),
        ),
        throwsArgumentError,
      );
    });
  });

  group('CardExpense Domain Tests', () {
    test('criação válida para compra parcelada e cálculo de saldo restante', () {
      final expense = CardExpense.create(
        id: 'exp-notebook',
        cardId: 'card-nubank',
        description: 'Notebook Dell',
        amount: const Money.fromCents(38990), // R$ 389,90 por mês
        date: DateTime(2026, 7, 15),
        currentInstallment: 4,
        totalInstallments: 10,
        categoryId: 'cat-lazer',
      );

      expect(expense.isInstallment, isTrue);
      expect(expense.installmentLabel, equals('Parcela 4/10'));
      expect(expense.remainingInstallments, equals(7)); // 10 - 4 + 1 = 7 parcelas restantes
      expect(expense.remainingAmount, equals(const Money.fromCents(38990 * 7))); // R$ 2.729,30
    });

    test('compra à vista não é considerada parcelada', () {
      final expense = CardExpense.create(
        id: 'exp-padaria',
        cardId: 'card-nubank',
        description: 'Padaria',
        amount: const Money.fromCents(2500),
        date: DateTime(2026, 10, 28),
      );

      expect(expense.isInstallment, isFalse);
      expect(expense.installmentLabel, isNull);
      expect(expense.remainingInstallments, equals(0));
      expect(expense.remainingAmount, equals(const Money.fromCents(2500)));
    });

    test('rejeita parcelas inválidas', () {
      expect(
        () => CardExpense.create(
          id: 'e1',
          cardId: 'c1',
          description: 'Teste',
          amount: const Money.fromCents(1000),
          date: DateTime.now(),
          currentInstallment: 5,
          totalInstallments: 3, // atual maior que total
        ),
        throwsArgumentError,
      );
    });
  });
}
