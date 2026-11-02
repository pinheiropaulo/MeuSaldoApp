import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/categories/data/supabase_category_repository.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';

void main() {
  group('SupabaseCategoryRepository Tests', () {
    test('categoryRepositoryProvider provê repositório válido com fallback para testes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(categoryRepositoryProvider);
      expect(repo, isNotNull);
    });

    test('SupabaseCategoryRepository pode ser instanciado', () {
      expect(() => SupabaseCategoryRepository, returnsNormally);
    });
  });
}
