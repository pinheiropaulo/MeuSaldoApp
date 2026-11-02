import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

/// Implementação remota de [CreditCardRepository] conectada às tabelas `credit_cards` e `invoices` no Supabase.
class SupabaseCardRepository implements CreditCardRepository {
  final sp.SupabaseClient _client;

  SupabaseCardRepository({sp.SupabaseClient? client})
      : _client = client ?? sp.Supabase.instance.client;

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  Future<Result<List<CreditCard>, Failure>> getAll() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      final data = await _client
          .from('credit_cards')
          .select()
          .eq('is_active', true)
          .order('name');

      final list = (data as List<dynamic>)
          .map((row) => _mapCardFromRow(row as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao listar cartões: $e'));
    }
  }

  @override
  Future<Result<CreditCard, Failure>> getById(String id) async {
    try {
      final row = await _client
          .from('credit_cards')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (row == null) {
        return Result.failure(
          NotFoundFailure('Cartão com ID "$id" não encontrado.'),
        );
      }

      return Result.success(_mapCardFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao buscar cartão: $e'));
    }
  }

  @override
  Future<Result<Invoice, Failure>> getCurrentInvoice(String cardId) async {
    try {
      final now = DateTime.now();
      final row = await _client
          .from('invoices')
          .select()
          .eq('card_id', cardId)
          .eq('is_closed', false)
          .order('year', ascending: false)
          .order('month', ascending: false)
          .maybeSingle();

      if (row != null) {
        return Result.success(_mapInvoiceFromRow(row));
      }

      final cardRes = await getById(cardId);
      if (cardRes.isFailure) {
        return Result.failure(cardRes.failureOrNull!);
      }
      final card = cardRes.valueOrNull!;

      final closingDate = DateTime(now.year, now.month, card.closingDay);
      final dueDate = DateTime(now.year, now.month, card.dueDay);

      final newInvRow = await _client
          .from('invoices')
          .insert({
            'user_id': _client.auth.currentUser!.id,
            'card_id': cardId,
            'month': now.month,
            'year': now.year,
            'closing_date': closingDate.toIso8601String().split('T').first,
            'due_date': dueDate.toIso8601String().split('T').first,
            'total_cents': 0,
            'is_closed': false,
            'is_paid': false,
          })
          .select()
          .single();

      return Result.success(_mapInvoiceFromRow(newInvRow));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(
        BusinessRuleFailure('Erro ao obter fatura atual: $e'),
      );
    }
  }

  @override
  Future<Result<List<Invoice>, Failure>> getInvoices(String cardId) async {
    try {
      final data = await _client
          .from('invoices')
          .select()
          .eq('card_id', cardId)
          .order('year', ascending: false)
          .order('month', ascending: false);

      final list = (data as List<dynamic>)
          .map((row) => _mapInvoiceFromRow(row as Map<String, dynamic>))
          .toList();

      return Result.success(list);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao listar faturas: $e'));
    }
  }

  @override
  Future<Result<List<CardExpense>, Failure>> getActiveInstallments(
    String cardId,
  ) async {
    try {
      final data = await _client
          .from('transactions')
          .select()
          .eq('card_id', cardId)
          .not('total_installments', 'is', null)
          .gt('total_installments', 1)
          .order('date', ascending: false);

      final list = (data as List<dynamic>).map((row) {
        final totalInst = (row['total_installments'] as num?)?.toInt() ?? 1;
        final currentInst = (row['installment_number'] as num?)?.toInt() ?? 1;
        return CardExpense.create(
          id: row['id'] as String,
          cardId: cardId,
          description: row['description'] as String,
          amount: Money.fromCents((row['amount_cents'] as num).toInt()),
          date: DateTime.parse(row['date'] as String),
          currentInstallment: currentInst,
          totalInstallments: totalInst,
        );
      }).toList();

      return Result.success(list);
    } on sp.PostgrestException catch (e) {
      return Result.failure(
        BusinessRuleFailure(e.message, code: e.code),
      );
    } catch (e) {
      return Result.failure(
        BusinessRuleFailure('Erro ao buscar parcelamentos: $e'),
      );
    }
  }

  @override
  Future<Result<List<CardExpense>, Failure>> getExpenses(String cardId) async {
    try {
      final data = await _client
          .from('transactions')
          .select()
          .eq('card_id', cardId)
          .order('date', ascending: false);

      final list = (data as List<dynamic>).map((row) {
        final totalInst = (row['total_installments'] as num?)?.toInt() ?? 1;
        final currentInst = (row['installment_number'] as num?)?.toInt() ?? 1;
        return CardExpense.create(
          id: row['id'] as String,
          cardId: cardId,
          description: row['description'] as String,
          amount: Money.fromCents((row['amount_cents'] as num).toInt()),
          date: DateTime.parse(row['date'] as String),
          currentInstallment: currentInst,
          totalInstallments: totalInst,
        );
      }).toList();

      return Result.success(list);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(
        BusinessRuleFailure('Erro ao listar despesas do cartão: $e'),
      );
    }
  }

  @override
  Future<Result<CardExpense, Failure>> addExpense(CardExpense expense) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      await _client.from('transactions').insert({
        'user_id': user.id,
        'description': expense.description,
        'amount_cents': expense.amount.cents,
        'date': expense.date.toIso8601String(),
        'type': 'expense',
        'status': 'completed',
        'card_id': expense.cardId,
        'installment_number': expense.currentInstallment,
        'total_installments': expense.totalInstallments,
      });

      return Result.success(expense);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(
        BusinessRuleFailure('Erro ao adicionar despesa no cartão: $e'),
      );
    }
  }

  @override
  Future<Result<Invoice, Failure>> payInvoice({
    required String invoiceId,
    required Money amount,
    DateTime? paidDate,
  }) async {
    try {
      final date = paidDate ?? DateTime.now();
      final row = await _client
          .from('invoices')
          .update({
            'is_paid': true,
            'is_closed': true,
            'paid_date': date.toIso8601String().split('T').first,
          })
          .eq('id', invoiceId)
          .select()
          .single();

      return Result.success(_mapInvoiceFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao liquidar fatura: $e'));
    }
  }

  @override
  Future<Result<CreditCard, Failure>> create(CreditCard card) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      final isValidUuid = _uuidRegex.hasMatch(card.id);
      final payload = {
        if (isValidUuid) 'id': card.id,
        'user_id': user.id,
        'name': card.name,
        'limit_cents': card.totalLimit.cents,
        'closing_day': card.closingDay,
        'due_day': card.dueDay,
        'color_hex': card.colorHex ?? '#6D1834',
        'brand': card.lastFourDigits != null
            ? 'final ${card.lastFourDigits}'
            : 'mastercard',
        'is_active': true,
      };

      final row = await _client
          .from('credit_cards')
          .insert(payload)
          .select()
          .single();
      return Result.success(_mapCardFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao cadastrar cartão: $e'));
    }
  }

  @override
  Future<Result<CreditCard, Failure>> update(CreditCard card) async {
    try {
      final payload = {
        'name': card.name,
        'limit_cents': card.totalLimit.cents,
        'closing_day': card.closingDay,
        'due_day': card.dueDay,
        'color_hex': card.colorHex ?? '#6D1834',
      };

      final row = await _client
          .from('credit_cards')
          .update(payload)
          .eq('id', card.id)
          .select()
          .single();

      return Result.success(_mapCardFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao atualizar cartão: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> delete(String id) async {
    try {
      await _client.from('credit_cards').delete().eq('id', id);
      return const Result.success(null);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao excluir cartão: $e'));
    }
  }

  CreditCard _mapCardFromRow(Map<String, dynamic> row) {
    return CreditCard(
      id: row['id'] as String,
      name: row['name'] as String,
      totalLimit: Money.fromCents((row['limit_cents'] as num).toInt()),
      usedLimit: const Money.zero(),
      closingDay: (row['closing_day'] as num).toInt(),
      dueDay: (row['due_day'] as num).toInt(),
      colorHex: row['color_hex'] as String?,
      lastFourDigits: null,
      isDefault: false,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }

  Invoice _mapInvoiceFromRow(Map<String, dynamic> row) {
    final isPaid = (row['is_paid'] as bool?) ?? false;
    final isClosed = (row['is_closed'] as bool?) ?? false;
    final status = isPaid
        ? InvoiceStatus.paid
        : isClosed
            ? InvoiceStatus.closed
            : InvoiceStatus.open;

    return Invoice(
      id: row['id'] as String,
      cardId: row['card_id'] as String,
      month: (row['month'] as num).toInt(),
      year: (row['year'] as num).toInt(),
      closingDate: DateTime.parse(row['closing_date'] as String),
      dueDate: DateTime.parse(row['due_date'] as String),
      totalAmount: Money.fromCents((row['total_cents'] as num).toInt()),
      status: status,
      paidAmount: isPaid
          ? Money.fromCents((row['total_cents'] as num).toInt())
          : const Money.zero(),
      paidDate: row['paid_date'] != null
          ? DateTime.parse(row['paid_date'] as String)
          : null,
    );
  }
}
