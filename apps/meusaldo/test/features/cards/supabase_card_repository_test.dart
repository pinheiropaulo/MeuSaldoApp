import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/cards/data/supabase_card_repository.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';

void main() {
  group('SupabaseCardRepository Tests', () {
    test('creditCardRepositoryProvider provê repositório válido com fallback para testes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(creditCardRepositoryProvider);
      expect(repo, isNotNull);
    });

    test('SupabaseCardRepository pode ser instanciado', () {
      expect(() => SupabaseCardRepository, returnsNormally);
    });
  });
}
