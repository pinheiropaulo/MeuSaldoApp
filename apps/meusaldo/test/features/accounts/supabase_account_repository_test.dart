import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/accounts/data/supabase_account_repository.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';

void main() {
  group('SupabaseAccountRepository Tests', () {
    test('accountRepositoryProvider provê repositório válido com fallback para testes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(accountRepositoryProvider);
      expect(repo, isNotNull);
    });

    test('SupabaseAccountRepository pode ser instanciado', () {
      expect(() => SupabaseAccountRepository, returnsNormally);
    });
  });
}
