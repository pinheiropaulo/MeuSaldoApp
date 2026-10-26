import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    test('criação a partir de centavos e zero', () {
      const zero = Money.zero();
      expect(zero.cents, equals(0));
      expect(zero.isZero, isTrue);
      expect(zero.isPositive, isFalse);
      expect(zero.isNegative, isFalse);

      const m1 = Money.fromCents(1050);
      expect(m1.cents, equals(1050));
      expect(m1.isZero, isFalse);
      expect(m1.isPositive, isTrue);
      expect(m1.isNegative, isFalse);
      expect(m1.reais, equals(10));
      expect(m1.centavosRemainder, equals(50));
    });

    test('criação a partir de reais e centavos', () {
      final m1 = Money.fromReais(15, 75);
      expect(m1.cents, equals(1575));

      final mNegative = Money.fromReais(-20, 50);
      expect(mNegative.cents, equals(-2050));
      expect(mNegative.isNegative, isTrue);
      expect(mNegative.reais, equals(-20));
      expect(mNegative.centavosRemainder, equals(50));

      expect(() => Money.fromReais(10, 100), throwsRangeError);
      expect(() => Money.fromReais(10, -1), throwsRangeError);
    });

    test('operações aritméticas sem ponto flutuante', () {
      final a = Money.fromCents(1000); // R$ 10,00
      final b = Money.fromCents(350); // R$ 3,50

      expect((a + b).cents, equals(1350));
      expect((a - b).cents, equals(650));
      expect((-b).cents, equals(-350));
      expect((b * 3).cents, equals(1050));
      expect((a ~/ 2).cents, equals(500));
      expect((a % 3).cents, equals(1)); // 1000 % 3 = 1 centavo
      expect(() => a ~/ 0, throwsArgumentError);
    });

    test('comparações e ordenação', () {
      final m10 = Money.fromCents(1000);
      final m20 = Money.fromCents(2000);
      final m10Duplicate = Money.fromCents(1000);

      expect(m10 < m20, isTrue);
      expect(m20 > m10, isTrue);
      expect(m10 <= m10Duplicate, isTrue);
      expect(m10 >= m10Duplicate, isTrue);
      expect(m10 == m10Duplicate, isTrue);
      expect(m10.hashCode, equals(m10Duplicate.hashCode));

      final list = [m20, m10];
      list.sort();
      expect(list, equals([m10, m20]));
    });

    test('parsing de strings no padrão brasileiro e formatos comuns', () {
      expect(Money.tryParse('10,50')?.cents, equals(1050));
      expect(Money.tryParse('R\$ 10,50')?.cents, equals(1050));
      expect(Money.tryParse('1.234,56')?.cents, equals(123456));
      expect(Money.tryParse('R\$ 1.234,56')?.cents, equals(123456));
      expect(Money.tryParse('- R\$ 150,00')?.cents, equals(-15000));
      expect(Money.tryParse('-150,00')?.cents, equals(-15000));
      expect(Money.tryParse('10.50')?.cents, equals(1050));
      expect(Money.tryParse('0')?.cents, equals(0));
      expect(Money.tryParse('0,00')?.cents, equals(0));
      expect(Money.tryParse(null), isNull);
      expect(Money.tryParse(''), isNull);
      expect(Money.tryParse('invalido'), isNull);

      expect(Money.parse('50,25').cents, equals(5025));
      expect(() => Money.parse('invalido'), throwsFormatException);
    });

    test('formatação padrão Dark Burgundy e pt-BR', () {
      expect(Money.fromCents(0).formatted, equals('R\$ 0,00'));
      expect(Money.fromCents(1050).formatted, equals('R\$ 10,50'));
      expect(Money.fromCents(123456).formatted, equals('R\$ 1.234,56'));
      expect(Money.fromCents(100000000).formatted, equals('R\$ 1.000.000,00'));

      // Conforme DESIGN_SYSTEM.md: negativos usam sinal antes da moeda "- R$ 150,00"
      expect(Money.fromCents(-15000).formatted, equals('- R\$ 150,00'));
      expect(
        Money.fromCents(-15000).format(includeSymbol: false),
        equals('- 150,00'),
      );
      expect(
        Money.fromCents(1050).format(includeSymbol: false),
        equals('10,50'),
      );
    });
  });
}
