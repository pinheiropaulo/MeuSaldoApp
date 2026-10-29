import 'package:meusaldo_core/src/cards/invoice_status.dart';
import 'package:meusaldo_core/src/shared/money.dart';

/// Representa a fatura mensal de um cartão de crédito.
class Invoice {
  /// Identificador único da fatura.
  final String id;

  /// Identificador do cartão ao qual esta fatura pertence.
  final String cardId;

  /// Mês de referência da fatura (1 a 12).
  final int month;

  /// Ano de referência da fatura (ex: 2026).
  final int year;

  /// Data exata de fechamento da fatura.
  final DateTime closingDate;

  /// Data de vencimento da fatura.
  final DateTime dueDate;

  /// Valor consolidado total da fatura.
  final Money totalAmount;

  /// Status atual da fatura (open, closed, paid, overdue).
  final InvoiceStatus status;

  /// Valor já amortizado ou pago nesta fatura.
  final Money paidAmount;

  const Invoice({
    required this.id,
    required this.cardId,
    required this.month,
    required this.year,
    required this.closingDate,
    required this.dueDate,
    required this.totalAmount,
    required this.status,
    this.paidAmount = const Money.zero(),
  });

  /// Construtor com validação de dados da fatura.
  factory Invoice.create({
    required String id,
    required String cardId,
    required int month,
    required int year,
    required DateTime closingDate,
    required DateTime dueDate,
    required Money totalAmount,
    InvoiceStatus status = InvoiceStatus.open,
    Money paidAmount = const Money.zero(),
  }) {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'O identificador da fatura não pode ser vazio.');
    }

    final trimmedCardId = cardId.trim();
    if (trimmedCardId.isEmpty) {
      throw ArgumentError.value(cardId, 'cardId', 'O identificador do cartão não pode ser vazio.');
    }

    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'O mês da fatura deve estar entre 1 e 12.');
    }

    if (totalAmount.isNegative) {
      throw ArgumentError.value(
        totalAmount,
        'totalAmount',
        'O valor total da fatura não pode ser negativo.',
      );
    }

    if (paidAmount.isNegative) {
      throw ArgumentError.value(
        paidAmount,
        'paidAmount',
        'O valor pago da fatura não pode ser negativo.',
      );
    }

    return Invoice(
      id: trimmedId,
      cardId: trimmedCardId,
      month: month,
      year: year,
      closingDate: closingDate,
      dueDate: dueDate,
      totalAmount: totalAmount,
      status: status,
      paidAmount: paidAmount,
    );
  }

  /// Valor pendente de quitação da fatura.
  Money get remainingAmount {
    final diff = totalAmount - paidAmount;
    return diff.isNegative ? const Money.zero() : diff;
  }

  /// Indica se a fatura ainda está aberta para novos lançamentos.
  bool get isOpen => status == InvoiceStatus.open;

  /// Indica se a fatura já foi fechada para compras e aguarda quitação.
  bool get isClosed => status == InvoiceStatus.closed;

  /// Indica se a fatura foi quitada integralmente.
  bool get isPaid => status == InvoiceStatus.paid;

  /// Indica se a fatura está vencida sem pagamento integral.
  bool get isOverdue => status == InvoiceStatus.overdue;

  Invoice copyWith({
    String? id,
    String? cardId,
    int? month,
    int? year,
    DateTime? closingDate,
    DateTime? dueDate,
    Money? totalAmount,
    InvoiceStatus? status,
    Money? paidAmount,
  }) {
    return Invoice.create(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      month: month ?? this.month,
      year: year ?? this.year,
      closingDate: closingDate ?? this.closingDate,
      dueDate: dueDate ?? this.dueDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invoice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cardId == other.cardId &&
          month == other.month &&
          year == other.year &&
          closingDate == other.closingDate &&
          dueDate == other.dueDate &&
          totalAmount == other.totalAmount &&
          status == other.status &&
          paidAmount == other.paidAmount;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        id,
        cardId,
        month,
        year,
        closingDate,
        dueDate,
        totalAmount,
        status,
        paidAmount,
      );

  @override
  String toString() =>
      'Invoice(id: $id, cardId: $cardId, month: $month/$year, total: $totalAmount, status: ${status.name})';
}
