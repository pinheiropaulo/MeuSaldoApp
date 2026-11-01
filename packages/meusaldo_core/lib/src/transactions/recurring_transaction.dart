import 'package:meusaldo_core/src/shared/failures.dart';
import 'package:meusaldo_core/src/shared/money.dart';
import 'package:meusaldo_core/src/transactions/transaction_type.dart';

/// Categoria da recorrência financeira.
enum RecurrenceCategory {
  /// Assinaturas de serviços e streaming (ex: Netflix, Spotify).
  subscription,

  /// Despesas fixas essenciais de moradia e utilidades (ex: Aluguel, Fibra).
  fixedExpense,

  /// Receitas recorrentes (ex: Salário mensal, pensão, pró-labore).
  income;

  String get label {
    switch (this) {
      case RecurrenceCategory.subscription:
        return 'Assinaturas & Streaming';
      case RecurrenceCategory.fixedExpense:
        return 'Despesas Fixas Essenciais';
      case RecurrenceCategory.income:
        return 'Receitas Recorrentes';
    }
  }
}

/// Frequência de repetição da cobrança recorrente.
enum RecurrenceFrequency {
  monthly,
  yearly,
  weekly;

  String get label {
    switch (this) {
      case RecurrenceFrequency.monthly:
        return 'Mensal';
      case RecurrenceFrequency.yearly:
        return 'Anual';
      case RecurrenceFrequency.weekly:
        return 'Semanal';
    }
  }
}

/// Entidade de domínio para lançamentos fixos e assinaturas recorrentes.
class RecurringTransaction {
  final String id;
  final String description;
  final Money amount;
  final TransactionType type;
  final RecurrenceCategory category;
  final RecurrenceFrequency frequency;
  final int billingDay;
  final String? billingDayDescription;
  final String? paymentMethod;
  final String? accountId;
  final String? categoryId;
  final bool isActive;
  final String? iconKey;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecurringTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.frequency,
    required this.billingDay,
    this.billingDayDescription,
    this.paymentMethod,
    this.accountId,
    this.categoryId,
    this.isActive = true,
    this.iconKey,
    required this.createdAt,
    this.updatedAt,
  });

  /// Construtor fábrica com validações de invariantes de negócio.
  factory RecurringTransaction.create({
    required String id,
    required String description,
    required Money amount,
    required TransactionType type,
    required RecurrenceCategory category,
    RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
    required int billingDay,
    String? billingDayDescription,
    String? paymentMethod,
    String? accountId,
    String? categoryId,
    bool isActive = true,
    String? iconKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (id.trim().isEmpty) {
      throw const ValidationFailure('O ID da recorrência não pode ser vazio.');
    }
    if (description.trim().isEmpty) {
      throw const ValidationFailure('A descrição da recorrência não pode ser vazia.');
    }
    if (amount.isNegative) {
      throw const ValidationFailure('O valor da recorrência não pode ser negativo.');
    }
    if (billingDay < 1 || billingDay > 31) {
      throw const ValidationFailure('O dia da cobrança deve estar entre 1 e 31.');
    }

    return RecurringTransaction(
      id: id,
      description: description.trim(),
      amount: amount,
      type: type,
      category: category,
      frequency: frequency,
      billingDay: billingDay,
      billingDayDescription: billingDayDescription,
      paymentMethod: paymentMethod,
      accountId: accountId,
      categoryId: categoryId,
      isActive: isActive,
      iconKey: iconKey,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  RecurringTransaction copyWith({
    String? id,
    String? description,
    Money? amount,
    TransactionType? type,
    RecurrenceCategory? category,
    RecurrenceFrequency? frequency,
    int? billingDay,
    String? billingDayDescription,
    String? paymentMethod,
    String? accountId,
    String? categoryId,
    bool? isActive,
    String? iconKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      billingDay: billingDay ?? this.billingDay,
      billingDayDescription: billingDayDescription ?? this.billingDayDescription,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      iconKey: iconKey ?? this.iconKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  RecurringTransaction toggleActive() {
    return copyWith(
      isActive: !isActive,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
