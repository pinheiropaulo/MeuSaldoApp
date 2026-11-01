import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/shared/formatters/currency_input_formatter.dart';

void main() {
  group('CurrencyInputFormatter Tests', () {
    const formatter = CurrencyInputFormatter();

    test('formata digitação sequencial de centavos para reais', () {
      var val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '2'),
      );
      expect(val.text, '0,02');

      val = formatter.formatEditUpdate(val, const TextEditingValue(text: '0020'));
      expect(val.text, '0,20');

      val = formatter.formatEditUpdate(val, const TextEditingValue(text: '00200'));
      expect(val.text, '2,00');

      val = formatter.formatEditUpdate(val, const TextEditingValue(text: '00200000'));
      expect(val.text, '2.000,00');
    });

    test('formata corretamente ao apagar dígitos', () {
      final val = formatter.formatEditUpdate(
        const TextEditingValue(text: '2.000,00'),
        const TextEditingValue(text: '2.000,0'),
      );
      expect(val.text, '200,00');
    });

    test('quando o campo fica vazio, retorna 0,00', () {
      final val = formatter.formatEditUpdate(
        const TextEditingValue(text: '0,05'),
        TextEditingValue.empty,
      );
      expect(val.text, '0,00');
    });

    test('ignora caracteres não numéricos e formata o valor', () {
      final val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'abc 125,50 xyz'),
      );
      expect(val.text, '125,50');
    });
  });
}
