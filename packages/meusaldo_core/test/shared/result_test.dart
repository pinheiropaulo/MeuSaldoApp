import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('criação de Success e Failure', () {
      const Result<int, Failure> success = Result.success(42);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.valueOrNull, equals(42));
      expect(success.failureOrNull, isNull);

      const failure = ValidationFailure('Campo obrigatório');
      const Result<int, Failure> error = Result.failure(failure);
      expect(error.isSuccess, isFalse);
      expect(error.isFailure, isTrue);
      expect(error.valueOrNull, isNull);
      expect(error.failureOrNull, equals(failure));
    });

    test('método when', () {
      const Result<String, Failure> s = Result.success('OK');
      final r1 = s.when(
        onSuccess: (val) => 'Resultado: $val',
        onFailure: (err) => 'Erro: ${err.message}',
      );
      expect(r1, equals('Resultado: OK'));

      const Result<String, Failure> f = Result.failure(
        BusinessRuleFailure('Saldo insuficiente'),
      );
      final r2 = f.when(
        onSuccess: (val) => 'Resultado: $val',
        onFailure: (err) => 'Erro: ${err.message}',
      );
      expect(r2, equals('Erro: Saldo insuficiente'));
    });

    test('map e flatMap', () {
      const Result<int, Failure> s = Result.success(10);
      final mapped = s.map((v) => v * 2);
      expect(mapped.valueOrNull, equals(20));

      final flatMapped = s.flatMap((v) => Result<String, Failure>.success('$v reais'));
      expect(flatMapped.valueOrNull, equals('10 reais'));

      const Result<int, Failure> f = Result.failure(ValidationFailure('Erro'));
      final mappedF = f.map((v) => v * 2);
      expect(mappedF.isFailure, isTrue);
    });
  });
}
