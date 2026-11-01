import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('RecurringTransaction', () {
    test('creates valid recurring transaction with defaults', () {
      final item = RecurringTransaction.create(
        id: 'rec-1',
        description: 'Netflix Brasil',
        amount: const Money.fromCents(5590),
        type: TransactionType.expense,
        category: RecurrenceCategory.subscription,
        billingDay: 20,
        paymentMethod: 'Cartão Nubank',
        iconKey: 'movie',
      );

      expect(item.id, equals('rec-1'));
      expect(item.description, equals('Netflix Brasil'));
      expect(item.amount.cents, equals(5590));
      expect(item.type, equals(TransactionType.expense));
      expect(item.category, equals(RecurrenceCategory.subscription));
      expect(item.frequency, equals(RecurrenceFrequency.monthly));
      expect(item.billingDay, equals(20));
      expect(item.paymentMethod, equals('Cartão Nubank'));
      expect(item.isActive, isTrue);
    });

    test('validates required fields and ranges', () {
      expect(
        () => RecurringTransaction.create(
          id: '',
          description: 'Teste',
          amount: const Money.fromCents(100),
          type: TransactionType.expense,
          category: RecurrenceCategory.fixedExpense,
          billingDay: 10,
        ),
        throwsA(isA<ValidationFailure>()),
      );

      expect(
        () => RecurringTransaction.create(
          id: 'rec-1',
          description: '',
          amount: const Money.fromCents(100),
          type: TransactionType.expense,
          category: RecurrenceCategory.fixedExpense,
          billingDay: 10,
        ),
        throwsA(isA<ValidationFailure>()),
      );

      expect(
        () => RecurringTransaction.create(
          id: 'rec-1',
          description: 'Teste',
          amount: const Money.fromCents(100),
          type: TransactionType.expense,
          category: RecurrenceCategory.fixedExpense,
          billingDay: 32,
        ),
        throwsA(isA<ValidationFailure>()),
      );

      expect(
        () => RecurringTransaction.create(
          id: 'rec-1',
          description: 'Teste',
          amount: const Money.fromCents(100),
          type: TransactionType.expense,
          category: RecurrenceCategory.fixedExpense,
          billingDay: 0,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('toggleActive toggles isActive and updates timestamp', () {
      final item = RecurringTransaction.create(
        id: 'rec-1',
        description: 'Spotify Premium',
        amount: const Money.fromCents(2190),
        type: TransactionType.expense,
        category: RecurrenceCategory.subscription,
        billingDay: 12,
      );

      expect(item.isActive, isTrue);
      final paused = item.toggleActive();
      expect(paused.isActive, isFalse);
      expect(paused.updatedAt, isNotNull);

      final resumed = paused.toggleActive();
      expect(resumed.isActive, isTrue);
    });
  });
}
