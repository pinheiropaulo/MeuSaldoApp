import 'package:meusaldo_core/src/shared/money.dart';
import 'package:meusaldo_core/src/transactions/transaction_status.dart';
import 'package:meusaldo_core/src/transactions/transaction_type.dart';

/// Representa uma movimentação financeira (receita, despesa ou transferência).
class Transaction {
  /// Identificador único da transação.
  final String id;

  /// Tipo de movimentação: receita, despesa ou transferência.
  final TransactionType type;

  /// Valor monetário da movimentação (sempre positivo).
  final Money amount;

  /// Data de competência da movimentação.
  final DateTime date;

  /// Descrição resumida da movimentação (ex: "Supermercado Pão de Açúcar").
  final String description;

  /// Estado de efetivação da transação.
  final TransactionStatus status;

  /// Identificador da conta de origem (ou conta onde a receita/despesa ocorre).
  final String accountId;

  /// Identificador da conta de destino (obrigatório exclusivamente para transferências).
  final String? destinationAccountId;

  /// Identificador da categoria financeira associada.
  final String? categoryId;

  /// Observações ou anotações adicionais.
  final String? notes;

  /// Data de registro no sistema.
  final DateTime createdAt;

  /// Data da última alteração.
  final DateTime? updatedAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.status,
    required this.accountId,
    this.destinationAccountId,
    this.categoryId,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Construtor de fábrica com validação de invariantes financeiras.
  factory Transaction.create({
    required String id,
    required TransactionType type,
    required Money amount,
    required DateTime date,
    required String description,
    TransactionStatus status = TransactionStatus.completed,
    required String accountId,
    String? destinationAccountId,
    String? categoryId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    if (!amount.isPositive) {
      throw ArgumentError.value(
        amount,
        'amount',
        'O valor da movimentação deve ser estritamente maior que zero.',
      );
    }

    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'A descrição da movimentação não pode ser vazia.',
      );
    }

    if (accountId.trim().isEmpty) {
      throw ArgumentError.value(
        accountId,
        'accountId',
        'A conta de origem é obrigatória.',
      );
    }

    if (type == TransactionType.transfer) {
      if (destinationAccountId == null || destinationAccountId.trim().isEmpty) {
        throw ArgumentError.value(
          destinationAccountId,
          'destinationAccountId',
          'A conta de destino é obrigatória para transferências.',
        );
      }
      if (destinationAccountId.trim() == accountId.trim()) {
        throw ArgumentError(
          'A conta de origem e a conta de destino não podem ser iguais em uma transferência.',
        );
      }
    }

    return Transaction(
      id: id,
      type: type,
      amount: amount,
      date: date,
      description: trimmedDescription,
      status: status,
      accountId: accountId.trim(),
      destinationAccountId: type == TransactionType.transfer
          ? destinationAccountId?.trim()
          : null,
      categoryId: categoryId?.trim(),
      notes: notes?.trim(),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  /// Indica se a transação já está efetivada no saldo disponível.
  bool get isCompleted => status == TransactionStatus.completed;

  /// Indica se a transação é uma despesa.
  bool get isExpense => type == TransactionType.expense;

  /// Indica se a transação é uma receita.
  bool get isIncome => type == TransactionType.income;

  /// Indica se a transação é uma transferência.
  bool get isTransfer => type == TransactionType.transfer;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    Money? amount,
    DateTime? date,
    String? description,
    TransactionStatus? status,
    String? accountId,
    String? destinationAccountId,
    String? categoryId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final effectiveType = type ?? this.type;
    return Transaction.create(
      id: id ?? this.id,
      type: effectiveType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      status: status ?? this.status,
      accountId: accountId ?? this.accountId,
      destinationAccountId: effectiveType == TransactionType.transfer
          ? (destinationAccountId ?? this.destinationAccountId)
          : null,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          amount == other.amount &&
          date == other.date &&
          description == other.description &&
          status == other.status &&
          accountId == other.accountId &&
          destinationAccountId == other.destinationAccountId &&
          categoryId == other.categoryId;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    amount,
    date,
    description,
    status,
    accountId,
    destinationAccountId,
    categoryId,
  );

  @override
  String toString() =>
      'Transaction(id: $id, type: ${type.name}, amount: $amount, status: ${status.name})';
}
