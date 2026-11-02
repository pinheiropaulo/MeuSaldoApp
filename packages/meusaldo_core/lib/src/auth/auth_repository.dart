import 'package:meusaldo_core/src/auth/user.dart';
import 'package:meusaldo_core/src/shared/failures.dart';
import 'package:meusaldo_core/src/shared/result.dart';

/// Contrato para serviços de autenticação e sessão do usuário.
abstract interface class AuthRepository {
  /// Realiza login utilizando e-mail e senha.
  Future<Result<User, Failure>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Cadastra um novo usuário no sistema.
  Future<Result<User, Failure>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Encerra a sessão atual do usuário.
  Future<Result<void, Failure>> logout();

  /// Retorna o usuário autenticado na sessão atual, se houver.
  Future<Result<User?, Failure>> getCurrentUser();

  /// Envia e-mail de recuperação/redefinição de senha.
  Future<Result<void, Failure>> resetPassword({
    required String email,
  });

  /// Atualiza o perfil do usuário logado.
  Future<Result<User, Failure>> updateProfile({
    required String name,
    String? photoUrl,
    String? phone,
  });
}
