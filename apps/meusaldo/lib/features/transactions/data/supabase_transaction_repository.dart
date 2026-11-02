import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

/// Implementação remota de [TransactionRepository] conectada à tabela `transactions` no Supabase.
class SupabaseTransactionRepository implements TransactionRepository {
  final sp.SupabaseClient _client;

  SupabaseTransactionRepository({sp.SupabaseClient? client})
      : _client = client ?? sp.Supabase.instance.client;

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  Future<Result<List<Transaction>, Failure>> getAllTransactions() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      final data = await _client
          .from('transactions')
          .select()
          .order('date', ascending: false);

      final list = (data as List<dynamic>)
          .map((row) => _mapFromRow(row as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(
        BusinessRuleFailure('Erro ao carregar transações: $e'),
      );
    }
  }

  @override
  Future<Result<List<Transaction>, Failure>> getTransactionsByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      final data = await _client
          .from('transactions')
          .select()
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String())
          .order('date', ascending: false);

      final list = (data as List<dynamic>)
          .map((row) => _mapFromRow(row as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(
        BusinessRuleFailure('Erro ao filtrar transações: $e'),
      );
    }
  }

  @override
  Future<Result<List<Transaction>, Failure>> getTransactionsByAccount(
    String accountId,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      final data = await _client
          .from('transactions')
          .select()
          .or(
            'source_account_id.eq.$accountId,destination_account_id.eq.$accountId',
          )
          .order('date', ascending: false);

      final list = (data as List<dynamic>)
          .map((row) => _mapFromRow(row as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao filtrar por conta: $e'));
    }
  }

  @override
  Future<Result<Transaction, Failure>> getTransactionById(String id) async {
    try {
      final row = await _client
          .from('transactions')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (row == null) {
        return Result.failure(
          NotFoundFailure('Transação com id "$id" não encontrada.'),
        );
      }

      return Result.success(_mapFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao buscar transação: $e'));
    }
  }

  @override
  Future<Result<Transaction, Failure>> saveTransaction(
    Transaction transaction,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      final payload = _mapToRow(transaction, userId: user.id);
      final row = await _client
          .from('transactions')
          .insert(payload)
          .select()
          .single();

      return Result.success(_mapFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao salvar transação: $e'));
    }
  }

  @override
  Future<Result<Transaction, Failure>> updateTransaction(
    Transaction transaction,
  ) async {
    try {
      final payload = _mapToRow(transaction);
      final row = await _client
          .from('transactions')
          .update(payload)
          .eq('id', transaction.id)
          .select()
          .single();

      return Result.success(_mapFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(
        BusinessRuleFailure('Erro ao atualizar transação: $e'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> deleteTransaction(String id) async {
    try {
      await _client.from('transactions').delete().eq('id', id);
      return const Result.success(null);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao excluir transação: $e'));
    }
  }

  Transaction _mapFromRow(Map<String, dynamic> row) {
    return Transaction(
      id: row['id'] as String,
      type: TransactionType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: Money.fromCents((row['amount_cents'] as num).toInt()),
      date: DateTime.parse(row['date'] as String),
      description: row['description'] as String,
      status: TransactionStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => TransactionStatus.completed,
      ),
      accountId: (row['source_account_id'] as String?) ?? '',
      destinationAccountId: row['destination_account_id'] as String?,
      categoryId: row['category_id'] as String?,
      cardId: row['card_id'] as String?,
      installments: row['total_installments'] as int?,
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> _mapToRow(
    Transaction transaction, {
    String? userId,
  }) {
    final isValidUuid = _uuidRegex.hasMatch(transaction.id);
    final isValidSourceAccount = _uuidRegex.hasMatch(transaction.accountId);
    final isValidDestAccount = transaction.destinationAccountId != null &&
        _uuidRegex.hasMatch(transaction.destinationAccountId!);
    final isValidCategory = transaction.categoryId != null &&
        _uuidRegex.hasMatch(transaction.categoryId!);
    final isValidCard =
        transaction.cardId != null && _uuidRegex.hasMatch(transaction.cardId!);

    return {
      if (isValidUuid) 'id': transaction.id,
      'user_id': ?userId,
      'description': transaction.description,
      'amount_cents': transaction.amount.cents,
      'date': transaction.date.toIso8601String(),
      'type': transaction.type.name,
      'status': transaction.status.name,
      'source_account_id': isValidSourceAccount ? transaction.accountId : null,
      'destination_account_id':
          isValidDestAccount ? transaction.destinationAccountId : null,
      'category_id': isValidCategory ? transaction.categoryId : null,
      'card_id': isValidCard ? transaction.cardId : null,
      'total_installments': ?transaction.installments,
      'notes': ?transaction.notes,
    };
  }
}
