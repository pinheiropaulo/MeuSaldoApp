import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/auth/data/in_memory_auth_repository.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Provedor do repositório de autenticação.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return InMemoryAuthRepository();
});

/// Notifier do estado da sessão do usuário autenticado.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final result = await repo.getCurrentUser();
    return result.when(
      onSuccess: (user) => user,
      onFailure: (_) => null,
    );
  }

  /// Realiza login com e-mail e senha.
  Future<Result<User, Failure>> login({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.loginWithEmail(email: email, password: password);
    if (result.isSuccess) {
      state = AsyncData(result.valueOrNull);
    }
    return result;
  }

  /// Cadastra um novo usuário.
  Future<Result<User, Failure>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.register(name: name, email: email, password: password);
    if (result.isSuccess) {
      state = AsyncData(result.valueOrNull);
    }
    return result;
  }

  /// Encerra a sessão atual.
  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }
}

/// Provedor do estado reativo da autenticação.
final authStateProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

/// Provedor simplificado para checar se o usuário está logado.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  return user != null;
});
