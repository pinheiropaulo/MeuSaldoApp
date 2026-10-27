import 'package:meusaldo/shared/data/demo_data.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Implementação em memória do [AccountRepository] para desenvolvimento ágil e testes.
class InMemoryAccountRepository implements AccountRepository {
  final Map<String, FinancialAccount> _accounts = {};

  InMemoryAccountRepository({List<FinancialAccount>? initialAccounts}) {
    final seed = initialAccounts ?? DemoData.accounts;
    for (final acc in seed) {
      _accounts[acc.id] = acc;
    }
  }

  @override
  Future<Result<List<FinancialAccount>, Failure>> getAllAccounts({
    bool includeInactive = false,
  }) async {
    final list = _accounts.values
        .where((acc) => includeInactive || acc.isActive)
        .toList();
    return Result.success(list);
  }

  @override
  Future<Result<FinancialAccount, Failure>> getAccountById(String id) async {
    final account = _accounts[id];
    if (account == null) {
      return Result.failure(NotFoundFailure('Conta com ID "$id" não encontrada.'));
    }
    return Result.success(account);
  }

  @override
  Future<Result<FinancialAccount, Failure>> saveAccount(FinancialAccount account) async {
    if (_accounts.containsKey(account.id)) {
      return Result.failure(
        ValidationFailure('Já existe uma conta com o ID "${account.id}".'),
      );
    }
    _accounts[account.id] = account;
    return Result.success(account);
  }

  @override
  Future<Result<FinancialAccount, Failure>> updateAccount(FinancialAccount account) async {
    if (!_accounts.containsKey(account.id)) {
      return Result.failure(
        NotFoundFailure('Conta com ID "${account.id}" não encontrada para atualização.'),
      );
    }
    _accounts[account.id] = account;
    return Result.success(account);
  }

  @override
  Future<Result<void, Failure>> deleteAccount(String id) async {
    final account = _accounts[id];
    if (account == null) {
      return Result.failure(NotFoundFailure('Conta com ID "$id" não encontrada.'));
    }
    // Desativa a conta para preservar histórico de transações
    _accounts[id] = account.copyWith(isActive: false);
    return const Result.success(null);
  }
}
