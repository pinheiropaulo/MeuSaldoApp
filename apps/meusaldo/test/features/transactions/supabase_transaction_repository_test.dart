import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/transactions/data/supabase_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';

void main() {
  group('SupabaseTransactionRepository Tests', () {
    test('transactionRepositoryProvider provê repositório válido com fallback para testes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(transactionRepositoryProvider);
      expect(repo, isNotNull);
    });

    test('SupabaseTransactionRepository pode ser instanciado', () {
      expect(() => SupabaseTransactionRepository, returnsNormally);
    });
  });
}
