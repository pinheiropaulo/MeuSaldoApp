import 'package:meusaldo_core/meusaldo_core.dart';

/// Implementação em memória do [AuthRepository] para validação ágil da autenticação.
class InMemoryAuthRepository implements AuthRepository {
  User? _currentUser;

  InMemoryAuthRepository({User? initialUser}) {
    _currentUser = initialUser;
  }

  @override
  Future<Result<User, Failure>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.contains('@') || password.length < 6) {
      return const Result.failure(
        ValidationFailure(
          'E-mail ou senha incorretos. Verifique seus dados e tente novamente.',
        ),
      );
    }

    final displayName = cleanEmail == 'paulo@meusaldo.app'
        ? 'Paulo Pinheiro'
        : cleanEmail.split('@').first;

    _currentUser = User.create(
      id: 'usr-${cleanEmail.hashCode.abs()}',
      name: displayName,
      email: cleanEmail,
    );

    return Result.success(_currentUser!);
  }

  @override
  Future<Result<User, Failure>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return const Result.failure(ValidationFailure('O nome é obrigatório.'));
    }

    if (!cleanEmail.contains('@')) {
      return const Result.failure(ValidationFailure('Informe um e-mail válido.'));
    }

    if (password.length < 6) {
      return const Result.failure(
        ValidationFailure('A senha deve possuir no mínimo 6 caracteres.'),
      );
    }

    _currentUser = User.create(
      id: 'usr-${cleanEmail.hashCode.abs()}',
      name: cleanName,
      email: cleanEmail,
    );

    return Result.success(_currentUser!);
  }

  @override
  Future<Result<void, Failure>> logout() async {
    _currentUser = null;
    return const Result.success(null);
  }

  @override
  Future<Result<User?, Failure>> getCurrentUser() async {
    return Result.success(_currentUser);
  }
}
