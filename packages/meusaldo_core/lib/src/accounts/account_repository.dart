import 'package:meusaldo_core/src/accounts/financial_account.dart';
import 'package:meusaldo_core/src/shared/failures.dart';
import 'package:meusaldo_core/src/shared/result.dart';

/// Contrato para persistência e recuperação de contas financeiras.
abstract interface class AccountRepository {
  /// Retorna todas as contas financeiras.
  ///
  /// Se [includeInactive] for `false` (padrão), retorna apenas contas ativas.
  Future<Result<List<FinancialAccount>, Failure>> getAllAccounts({
    bool includeInactive = false,
  });

  /// Busca uma conta financeira pelo seu identificador único [id].
  Future<Result<FinancialAccount, Failure>> getAccountById(String id);

  /// Salva uma nova conta financeira.
  Future<Result<FinancialAccount, Failure>> saveAccount(FinancialAccount account);

  /// Atualiza os dados de uma conta financeira existente.
  Future<Result<FinancialAccount, Failure>> updateAccount(FinancialAccount account);

  /// Remove ou desativa uma conta financeira pelo seu [id].
  Future<Result<void, Failure>> deleteAccount(String id);
}
