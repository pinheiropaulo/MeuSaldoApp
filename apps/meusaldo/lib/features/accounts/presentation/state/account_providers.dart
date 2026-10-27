import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/accounts/data/in_memory_account_repository.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Provedor do repositório de contas financeiras.
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return InMemoryAccountRepository();
});

/// Notifier reativo para listagem e manipulação de contas financeiras.
class AccountsListNotifier extends AsyncNotifier<List<FinancialAccount>> {
  @override
  FutureOr<List<FinancialAccount>> build() async {
    final repo = ref.watch(accountRepositoryProvider);
    final result = await repo.getAllAccounts();
    return result.when(
      onSuccess: (accounts) => accounts,
      onFailure: (failure) => throw Exception(failure.message),
    );
  }

  /// Adiciona uma nova conta financeira e atualiza o estado reativo.
  Future<Result<FinancialAccount, Failure>> addAccount(FinancialAccount account) async {
    final repo = ref.read(accountRepositoryProvider);
    final result = await repo.saveAccount(account);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
    return result;
  }

  /// Atualiza uma conta existente e reflete nas telas.
  Future<Result<FinancialAccount, Failure>> updateAccount(FinancialAccount account) async {
    final repo = ref.read(accountRepositoryProvider);
    final result = await repo.updateAccount(account);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
    return result;
  }

  /// Remove (desativa) uma conta financeira.
  Future<Result<void, Failure>> deleteAccount(String id) async {
    final repo = ref.read(accountRepositoryProvider);
    final result = await repo.deleteAccount(id);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
    return result;
  }
}

/// Provedor da lista reativa de contas financeiras.
final accountsListProvider =
    AsyncNotifierProvider<AccountsListNotifier, List<FinancialAccount>>(
  AccountsListNotifier.new,
);

/// Provedor do saldo consolidado de todas as contas ativas do usuário.
final consolidatedBalanceProvider = Provider<Money>((ref) {
  final accountsAsync = ref.watch(accountsListProvider);
  return accountsAsync.maybeWhen(
    data: (accounts) {
      const calculator = BalanceCalculator();
      return calculator.calculateConsolidatedBalance(accounts);
    },
    orElse: () => const Money.zero(),
  );
});
