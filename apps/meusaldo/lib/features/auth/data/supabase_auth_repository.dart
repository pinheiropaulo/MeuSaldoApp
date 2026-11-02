import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

/// Implementação remota de [AuthRepository] utilizando Supabase Auth.
class SupabaseAuthRepository implements AuthRepository {
  final sp.SupabaseClient _client;

  SupabaseAuthRepository({sp.SupabaseClient? client})
      : _client = client ?? sp.Supabase.instance.client;

  @override
  Future<Result<User, Failure>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final spUser = response.user;
      if (spUser == null) {
        return const Result.failure(
          ValidationFailure('Usuário ou senha incorretos.', code: 'AUTH_INVALID_CREDENTIALS'),
        );
      }
      return Result.success(_mapSupabaseUser(spUser));
    } on sp.AuthException catch (e) {
      return Result.failure(ValidationFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao autenticar: $e'));
    }
  }

  @override
  Future<Result<User, Failure>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );
      final spUser = response.user;
      if (spUser == null) {
        return const Result.failure(
          ValidationFailure('Não foi possível concluir o cadastro.', code: 'AUTH_SIGNUP_FAILED'),
        );
      }
      return Result.success(
        _mapSupabaseUser(spUser, fallbackName: name.trim()),
      );
    } on sp.AuthException catch (e) {
      return Result.failure(ValidationFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao cadastrar usuário: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      await _client.auth.signOut();
      return const Result.success(null);
    } on sp.AuthException catch (e) {
      return Result.failure(ValidationFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao encerrar sessão: $e'));
    }
  }

  @override
  Future<Result<User?, Failure>> getCurrentUser() async {
    try {
      final spUser = _client.auth.currentUser;
      if (spUser == null) {
        return const Result.success(null);
      }

      try {
        final profile = await _client
            .from('profiles')
            .select()
            .eq('id', spUser.id)
            .maybeSingle();

        if (profile != null) {
          final fullName = (profile['full_name'] as String?)?.trim();
          final userEmail = (profile['email'] as String?)?.trim();
          return Result.success(
            User.create(
              id: spUser.id,
              name: (fullName != null && fullName.isNotEmpty)
                  ? fullName
                  : (spUser.userMetadata?['full_name'] as String? ?? 'Usuário'),
              email: (userEmail != null && userEmail.isNotEmpty)
                  ? userEmail
                  : (spUser.email ?? 'usuario@meusaldo.app'),
              photoUrl: profile['avatar_url'] as String?,
            ),
          );
        }
      } catch (_) {
        // Fallback para metadados se a tabela profiles ainda estiver inacessível
      }

      return Result.success(_mapSupabaseUser(spUser));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao obter usuário atual: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> resetPassword({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return const Result.success(null);
    } on sp.AuthException catch (e) {
      return Result.failure(ValidationFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao redefinir senha: $e'));
    }
  }

  @override
  Future<Result<User, Failure>> updateProfile({
    required String name,
    String? photoUrl,
    String? phone,
  }) async {
    try {
      final spUser = _client.auth.currentUser;
      if (spUser == null) {
        return const Result.failure(
          NotFoundFailure('Nenhum usuário autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      await _client.auth.updateUser(
        sp.UserAttributes(
          data: {
            'full_name': name.trim(),
            'avatar_url': ?photoUrl,
          },
        ),
      );

      await _client.from('profiles').upsert({
        'id': spUser.id,
        'full_name': name.trim(),
        'email': spUser.email ?? '',
        'avatar_url': ?photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return Result.success(
        User.create(
          id: spUser.id,
          name: name.trim(),
          email: spUser.email ?? 'usuario@meusaldo.app',
          photoUrl: photoUrl,
          phone: phone,
        ),
      );
    } on sp.AuthException catch (e) {
      return Result.failure(ValidationFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao atualizar perfil: $e'));
    }
  }

  User _mapSupabaseUser(sp.User spUser, {String? fallbackName}) {
    final metadata = spUser.userMetadata ?? {};
    final fullName = (metadata['full_name'] as String?)?.trim() ??
        fallbackName ??
        (spUser.email?.split('@').first ?? 'Usuário');

    final safeName = fullName.isNotEmpty ? fullName : 'Usuário';
    final safeEmail = (spUser.email != null && spUser.email!.isNotEmpty)
        ? spUser.email!
        : 'usuario@meusaldo.app';

    return User.create(
      id: spUser.id,
      name: safeName,
      email: safeEmail,
      photoUrl: metadata['avatar_url'] as String?,
    );
  }
}
