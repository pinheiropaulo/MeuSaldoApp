import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

/// Implementação remota de [AccountRepository] conectada à tabela `accounts` no Supabase.
class SupabaseAccountRepository implements AccountRepository {
  final sp.SupabaseClient _client;

  SupabaseAccountRepository({sp.SupabaseClient? client})
      : _client = client ?? sp.Supabase.instance.client;

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  Future<Result<List<FinancialAccount>, Failure>> getAllAccounts({
    bool includeInactive = false,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      var query = _client.from('accounts').select();
      if (!includeInactive) {
        query = query.eq('is_active', true);
      }

      final data = await query.order('name');
      final accounts = (data as List<dynamic>)
          .map((row) => _mapFromRow(row as Map<String, dynamic>))
          .toList();

      return Result.success(accounts);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao carregar contas: $e'));
    }
  }

  @override
  Future<Result<FinancialAccount, Failure>> getAccountById(String id) async {
    try {
      final row = await _client
          .from('accounts')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (row == null) {
        return Result.failure(
          NotFoundFailure('Conta financeira com id "$id" não encontrada.'),
        );
      }

      return Result.success(_mapFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao buscar conta: $e'));
    }
  }

  @override
  Future<Result<FinancialAccount, Failure>> saveAccount(
    FinancialAccount account,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      final payload = _mapToRow(account, userId: user.id);
      final row = await _client
          .from('accounts')
          .insert(payload)
          .select()
          .single();

      return Result.success(_mapFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao salvar conta: $e'));
    }
  }

  @override
  Future<Result<FinancialAccount, Failure>> updateAccount(
    FinancialAccount account,
  ) async {
    try {
      final payload = _mapToRow(account);
      final row = await _client
          .from('accounts')
          .update(payload)
          .eq('id', account.id)
          .select()
          .single();

      return Result.success(_mapFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao atualizar conta: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> deleteAccount(String id) async {
    try {
      await _client.from('accounts').delete().eq('id', id);
      return const Result.success(null);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao excluir conta: $e'));
    }
  }

  FinancialAccount _mapFromRow(Map<String, dynamic> row) {
    return FinancialAccount(
      id: row['id'] as String,
      name: row['name'] as String,
      type: AccountType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => AccountType.checking,
      ),
      initialBalance: Money.fromCents((row['initial_balance_cents'] as num).toInt()),
      currentBalance: Money.fromCents((row['current_balance_cents'] as num).toInt()),
      isActive: (row['is_active'] as bool?) ?? true,
      colorHex: row['color_hex'] as String?,
      iconKey: row['bank_code'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> _mapToRow(
    FinancialAccount account, {
    String? userId,
  }) {
    final isValidUuid = _uuidRegex.hasMatch(account.id);
    return {
      if (isValidUuid) 'id': account.id,
      'user_id': ?userId,
      'name': account.name,
      'type': account.type.name,
      'initial_balance_cents': account.initialBalance.cents,
      'current_balance_cents': account.currentBalance.cents,
      'is_active': account.isActive,
      'color_hex': account.colorHex ?? '#6D1834',
      'bank_code': account.iconKey,
    };
  }
}
