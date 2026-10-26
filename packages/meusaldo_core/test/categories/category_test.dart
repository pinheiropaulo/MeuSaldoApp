import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('Category', () {
    test('criação válida e compatibilidade de tipos', () {
      final catExpense = Category.create(
        id: 'cat-1',
        name: 'Alimentação',
        type: CategoryType.expense,
        iconKey: 'restaurant',
        colorHex: '#F04444',
      );

      expect(catExpense.id, equals('cat-1'));
      expect(catExpense.name, equals('Alimentação'));
      expect(catExpense.isCompatibleWith(TransactionType.expense), isTrue);
      expect(catExpense.isCompatibleWith(TransactionType.income), isFalse);

      final catIncome = Category.create(
        id: 'cat-2',
        name: 'Salário',
        type: CategoryType.income,
      );
      expect(catIncome.isCompatibleWith(TransactionType.income), isTrue);
      expect(catIncome.isCompatibleWith(TransactionType.expense), isFalse);

      final catBoth = Category.create(
        id: 'cat-3',
        name: 'Ajuste',
        type: CategoryType.both,
      );
      expect(catBoth.isCompatibleWith(TransactionType.income), isTrue);
      expect(catBoth.isCompatibleWith(TransactionType.expense), isTrue);
    });

    test('rejeita nome ou id vazio na criação e no copyWith', () {
      expect(
        () => Category.create(
          id: 'cat-inv',
          name: '',
          type: CategoryType.expense,
        ),
        throwsArgumentError,
      );

      final cat = Category.create(
        id: 'cat-1',
        name: 'Saúde',
        type: CategoryType.expense,
      );

      expect(() => cat.copyWith(name: ''), throwsArgumentError);
      expect(() => cat.copyWith(name: '   '), throwsArgumentError);
      expect(() => cat.copyWith(id: ''), throwsArgumentError);
      expect(() => cat.copyWith(id: '   '), throwsArgumentError);

      final updated = cat.copyWith(name: 'Saúde & Bem-estar');
      expect(updated.name, equals('Saúde & Bem-estar'));
    });
  });
}
