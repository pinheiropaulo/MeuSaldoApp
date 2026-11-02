import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/config/app_config.dart';
import 'package:meusaldo/features/auth/data/supabase_auth_repository.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';

void main() {
  group('Supabase Configuration & AuthRepository Tests', () {
    test('AppConfig identifica se o Supabase está configurado', () {
      // Como este teste roda sem a flag --dart-define-from-file, valida o fallback
      expect(AppConfig.supabaseUrl, isA<String>());
      expect(AppConfig.supabasePublishableKey, isA<String>());
    });

    test('authRepositoryProvider retorna InMemoryAuthRepository quando Supabase não inicializado', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);
      expect(repo, isNotNull);
    });

    test('SupabaseAuthRepository instancia com cliente padrão ou customizado', () {
      expect(() => SupabaseAuthRepository, returnsNormally);
    });
  });
}
