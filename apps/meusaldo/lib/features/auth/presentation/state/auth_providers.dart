import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/config/app_config.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/auth/data/in_memory_auth_repository.dart';
import 'package:meusaldo/features/auth/data/supabase_auth_repository.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/home/presentation/state/home_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/recurring_transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

/// Provedor do repositório de autenticação.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.isSupabaseConfigured) {
    try {
      final client = sp.Supabase.instance.client;
      return SupabaseAuthRepository(client: client);
    } catch (_) {
      // Supabase não inicializado (ex: em testes de widget isolados)
    }
  }
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
      _clearUserSessionData();
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
      // Se houver sessão ativa (auto-confirmação habilitada ou ambiente mock),
      // autentica o usuário e limpa o cache anterior. Se a confirmação de e-mail
      // for obrigatória no Supabase (session == null), mantém estado unauthenticated
      // para permitir exibir o diálogo de confirmação sem GoRouter redirecionar.
      if (AppConfig.isSupabaseConfigured) {
        try {
          final session = sp.Supabase.instance.client.auth.currentSession;
          if (session != null) {
            _clearUserSessionData();
            state = AsyncData(result.valueOrNull);
          }
        } catch (_) {
          _clearUserSessionData();
          state = AsyncData(result.valueOrNull);
        }
      } else {
        _clearUserSessionData();
        state = AsyncData(result.valueOrNull);
      }
    }
    return result;
  }

  /// Envia e-mail de recuperação de senha.
  Future<Result<void, Failure>> resetPassword({required String email}) async {
    final repo = ref.read(authRepositoryProvider);
    return repo.resetPassword(email: email);
  }

  /// Atualiza os dados do perfil do usuário autenticado.
  Future<Result<User, Failure>> updateProfile({
    required String name,
    String? photoUrl,
    String? phone,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.updateProfile(
      name: name,
      photoUrl: photoUrl,
      phone: phone,
    );
    if (result.isSuccess) {
      state = AsyncData(result.valueOrNull);
    }
    return result;
  }

  /// Encerra a sessão atual e expurga qualquer dado em memória do usuário anterior.
  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    _clearUserSessionData();
    state = const AsyncData(null);
  }

  /// Invalida e limpa todos os provedores em memória dependentes de sessão do usuário.
  void _clearUserSessionData() {
    ref.invalidate(accountsListProvider);
    ref.invalidate(categoriesListProvider);
    ref.invalidate(transactionsListProvider);
    ref.invalidate(cardsListProvider);
    ref.invalidate(recurringListProvider);
    ref.invalidate(homeUpcomingAlertProvider);
  }
}

/// Provedor do estado reativo da autenticação.
final authStateProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

/// Provedor simplificado para checar se o usuário está logado.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  return user != null;
});
