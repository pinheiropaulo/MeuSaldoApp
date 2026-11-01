import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:test/test.dart';

void main() {
  group('User Domain Tests', () {
    test('criação válida com normalização de e-mail', () {
      final user = User.create(
        id: 'u-1',
        name: 'Paulo Pinheiro',
        email: ' Paulo.Pinheiro@Email.Com ',
      );

      expect(user.id, equals('u-1'));
      expect(user.name, equals('Paulo Pinheiro'));
      expect(user.email, equals('paulo.pinheiro@email.com'));
      expect(user.createdAt, isNotNull);
    });

    test('rejeita id, nome ou email vazios ou sem arroba', () {
      expect(
        () => User.create(id: ' ', name: 'Paulo', email: 'paulo@teste.com'),
        throwsArgumentError,
      );

      expect(
        () => User.create(id: 'u1', name: '  ', email: 'paulo@teste.com'),
        throwsArgumentError,
      );

      expect(
        () => User.create(id: 'u1', name: 'Paulo', email: 'emailinvalido.com'),
        throwsArgumentError,
      );
    });
  });
}
