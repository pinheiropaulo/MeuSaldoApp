import 'package:meusaldo_core/src/shared/money.dart';

/// Representa uma despesa no cartão de crédito (à vista ou parcelada).
class CardExpense {
  /// Identificador único da despesa no cartão.
  final String id;

  /// Identificador do cartão utilizado.
  final String cardId;

  /// Identificador da fatura em que esta parcela/compra está lançada.
  final String? invoiceId;

  /// Descrição da compra (ex: "Notebook Dell", "Supermercado").
  final String description;

  /// Valor da parcela (ou valor integral se for à vista).
  final Money amount;

  /// Data de realização da compra.
  final DateTime date;

  /// Número da parcela atual (ex: 4). Nulo se for compra à vista.
  final int? currentInstallment;

  /// Quantidade total de parcelas (ex: 10). Nulo se for compra à vista.
  final int? totalInstallments;

  /// Categoria financeira associada à despesa.
  final String? categoryId;

  /// Data de criação do registro no sistema.
  final DateTime createdAt;

  const CardExpense({
    required this.id,
    required this.cardId,
    this.invoiceId,
    required this.description,
    required this.amount,
    required this.date,
    this.currentInstallment,
    this.totalInstallments,
    this.categoryId,
    required this.createdAt,
  });

  /// Construtor de fábrica com validação de dados da compra e parcelamento.
  factory CardExpense.create({
    required String id,
    required String cardId,
    String? invoiceId,
    required String description,
    required Money amount,
    required DateTime date,
    int? currentInstallment,
    int? totalInstallments,
    String? categoryId,
    DateTime? createdAt,
  }) {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'O identificador da despesa não pode ser vazio.');
    }

    final trimmedCardId = cardId.trim();
    if (trimmedCardId.isEmpty) {
      throw ArgumentError.value(cardId, 'cardId', 'O identificador do cartão não pode ser vazio.');
    }

    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'A descrição da despesa não pode ser vazia.',
      );
    }

    if (!amount.isPositive) {
      throw ArgumentError.value(
        amount,
        'amount',
        'O valor da despesa deve ser estritamente maior que zero.',
      );
    }

    if (totalInstallments != null && totalInstallments < 1) {
      throw ArgumentError.value(
        totalInstallments,
        'totalInstallments',
        'O total de parcelas deve ser no mínimo 1.',
      );
    }

    if (currentInstallment != null) {
      if (currentInstallment < 1) {
        throw ArgumentError.value(
          currentInstallment,
          'currentInstallment',
          'A parcela atual deve ser no mínimo 1.',
        );
      }
      if (totalInstallments != null && currentInstallment > totalInstallments) {
        throw ArgumentError.value(
          currentInstallment,
          'currentInstallment',
          'A parcela atual não pode ser maior que o total de parcelas.',
        );
      }
    }

    return CardExpense(
      id: trimmedId,
      cardId: trimmedCardId,
      invoiceId: invoiceId?.trim(),
      description: trimmedDescription,
      amount: amount,
      date: date,
      currentInstallment: currentInstallment,
      totalInstallments: totalInstallments,
      categoryId: categoryId?.trim(),
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Indica se esta despesa é parcelada.
  bool get isInstallment =>
      totalInstallments != null && totalInstallments! > 1 && currentInstallment != null;

  /// Quantidade de parcelas pendentes (incluindo a atual).
  int get remainingInstallments {
    if (!isInstallment) return 0;
    return totalInstallments! - currentInstallment! + 1;
  }

  /// Saldo restante a pagar deste parcelamento.
  Money get remainingAmount {
    if (!isInstallment) return amount;
    return amount * remainingInstallments;
  }

  /// Rótulo formatado do parcelamento (ex: "Parcela 4/10").
  String? get installmentLabel {
    if (!isInstallment) return null;
    return 'Parcela $currentInstallment/$totalInstallments';
  }

  CardExpense copyWith({
    String? id,
    String? cardId,
    String? invoiceId,
    String? description,
    Money? amount,
    DateTime? date,
    int? currentInstallment,
    int? totalInstallments,
    String? categoryId,
    DateTime? createdAt,
  }) {
    return CardExpense.create(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardExpense &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cardId == other.cardId &&
          invoiceId == other.invoiceId &&
          description == other.description &&
          amount == other.amount &&
          date == other.date &&
          currentInstallment == other.currentInstallment &&
          totalInstallments == other.totalInstallments &&
          categoryId == other.categoryId;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        id,
        cardId,
        invoiceId,
        description,
        amount,
        date,
        currentInstallment,
        totalInstallments,
        categoryId,
      );

  @override
  String toString() =>
      'CardExpense(id: $id, desc: $description, amount: $amount, installment: $installmentLabel)';
}
