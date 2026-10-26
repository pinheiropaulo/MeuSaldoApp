import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('Bank', () {
    test('lista pré-registrada de bancos brasileiros contém 12 instituições', () {
      final banks = Bank.defaultBrazilianBanks;
      expect(banks.length, equals(12));

      final nubank = banks.firstWhere((b) => b.name == 'Nubank');
      expect(nubank.type, equals('Digital'));
      expect(nubank.focus, contains('Cartões de crédito'));

      final itau = banks.firstWhere((b) => b.name == 'Itaú Unibanco');
      expect(itau.type, equals('Tradicional / Privado'));
    });

    test('conversão de e para JSON com chaves em português', () {
      final json = {
        'nome': 'Banco do Brasil',
        'tipo': 'Tradicional / Público',
        'foco': 'Varejo, agronegócio e setor público',
      };

      final bank = Bank.fromJson(json);
      expect(bank.name, equals('Banco do Brasil'));
      expect(bank.type, equals('Tradicional / Público'));
      expect(bank.focus, equals('Varejo, agronegócio e setor público'));

      expect(bank.toJson(), equals(json));
    });
  });
}
