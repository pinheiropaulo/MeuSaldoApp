import 'package:meusaldo/shared/data/demo_data.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Implementação em memória do [CreditCardRepository] para desenvolvimento ágil e testes.
class InMemoryCreditCardRepository implements CreditCardRepository {
  final Map<String, CreditCard> _cards = {};
  final List<Invoice> _invoices = [];
  final List<CardExpense> _expenses = [];

  InMemoryCreditCardRepository({
    List<CreditCard>? initialCards,
    List<Invoice>? initialInvoices,
    List<CardExpense>? initialExpenses,
  }) {
    final seedCards = initialCards ?? const [];
    for (final card in seedCards) {
      _cards[card.id] = card;
    }

    _invoices.addAll(initialInvoices ?? const []);
    _expenses.addAll(initialExpenses ?? const []);
  }

  /// Construtor de demonstração para testes que necessitam de dados mockados prévios.
  factory InMemoryCreditCardRepository.withDemoData() {
    return InMemoryCreditCardRepository(
      initialCards: DemoData.creditCards,
      initialInvoices: DemoData.getInvoices(),
      initialExpenses: DemoData.getCardExpenses(),
    );
  }

  @override
  Future<Result<List<CreditCard>, Failure>> getAll() async {
    return Result.success(_cards.values.toList());
  }

  @override
  Future<Result<CreditCard, Failure>> getById(String id) async {
    final card = _cards[id];
    if (card == null) {
      return Result.failure(
        NotFoundFailure('Cartão com ID "$id" não encontrado.'),
      );
    }
    return Result.success(card);
  }

  @override
  Future<Result<Invoice, Failure>> getCurrentInvoice(String cardId) async {
    final matches = _invoices.where((inv) => inv.cardId == cardId).toList();
    if (matches.isEmpty) {
      return Result.failure(
        NotFoundFailure('Nenhuma fatura encontrada para o cartão "$cardId".'),
      );
    }
    // Retorna a fatura aberta ou a mais recente
    final current = matches.firstWhere(
      (inv) => inv.status == InvoiceStatus.open,
      orElse: () => matches.last,
    );
    return Result.success(current);
  }

  @override
  Future<Result<List<Invoice>, Failure>> getInvoices(String cardId) async {
    final list = _invoices.where((inv) => inv.cardId == cardId).toList();
    list.sort((a, b) {
      final comp = a.year.compareTo(b.year);
      if (comp != 0) return comp;
      return a.month.compareTo(b.month);
    });
    return Result.success(list);
  }

  @override
  Future<Result<List<CardExpense>, Failure>> getActiveInstallments(
    String cardId,
  ) async {
    final installments = _expenses
        .where(
          (e) =>
              e.cardId == cardId &&
              e.isInstallment &&
              e.remainingInstallments > 0,
        )
        .toList();
    return Result.success(installments);
  }

  @override
  Future<Result<List<CardExpense>, Failure>> getExpenses(String cardId) async {
    final list = _expenses.where((e) => e.cardId == cardId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return Result.success(list);
  }

  @override
  Future<Result<CardExpense, Failure>> addExpense(CardExpense expense) async {
    _expenses.add(expense);

    // Atualiza limite utilizado do cartão
    final card = _cards[expense.cardId];
    if (card != null) {
      final updatedUsedLimit = card.usedLimit + expense.amount;
      _cards[expense.cardId] = card.copyWith(usedLimit: updatedUsedLimit);
    }

    // Atualiza fatura aberta
    final index = _invoices.indexWhere(
      (inv) => inv.cardId == expense.cardId && inv.status == InvoiceStatus.open,
    );
    if (index != -1) {
      final inv = _invoices[index];
      _invoices[index] = inv.copyWith(totalAmount: inv.totalAmount + expense.amount);
    }

    return Result.success(expense);
  }

  @override
  Future<Result<Invoice, Failure>> payInvoice({
    required String invoiceId,
    required Money amount,
    DateTime? paidDate,
  }) async {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index == -1) {
      return Result.failure(
        NotFoundFailure('Fatura "$invoiceId" não encontrada.'),
      );
    }

    final invoice = _invoices[index];
    final updated = invoice.copyWith(
      status: InvoiceStatus.paid,
      paidAmount: amount,
      paidDate: paidDate ?? DateTime.now(),
    );
    _invoices[index] = updated;

    // Desocupa o limite utilizado correspondente
    final card = _cards[invoice.cardId];
    if (card != null) {
      final newUsed = card.usedLimit - invoice.totalAmount;
      _cards[invoice.cardId] = card.copyWith(
        usedLimit: newUsed.isNegative ? const Money.zero() : newUsed,
      );
    }

    return Result.success(updated);
  }

  @override
  Future<Result<CreditCard, Failure>> create(CreditCard card) async {
    if (_cards.containsKey(card.id)) {
      return Result.failure(
        ValidationFailure('Já existe um cartão com o ID "${card.id}".'),
      );
    }
    _cards[card.id] = card;

    // Cria fatura aberta inicial para o novo cartão
    final now = DateTime.now();
    final newInvoice = Invoice.create(
      id: 'inv_${card.id}_${now.month}_${now.year}',
      cardId: card.id,
      month: now.month,
      year: now.year,
      closingDate: DateTime(now.year, now.month, card.closingDay),
      dueDate: DateTime(now.year, now.month, card.dueDay),
      totalAmount: const Money.zero(),
      status: InvoiceStatus.open,
    );
    _invoices.add(newInvoice);

    return Result.success(card);
  }

  @override
  Future<Result<CreditCard, Failure>> update(CreditCard card) async {
    if (!_cards.containsKey(card.id)) {
      return Result.failure(
        NotFoundFailure(
          'Cartão com ID "${card.id}" não encontrado para atualização.',
        ),
      );
    }
    _cards[card.id] = card;
    return Result.success(card);
  }

  @override
  Future<Result<void, Failure>> delete(String id) async {
    if (!_cards.containsKey(id)) {
      return Result.failure(
        NotFoundFailure('Cartão com ID "$id" não encontrado.'),
      );
    }
    _cards.remove(id);
    _invoices.removeWhere((inv) => inv.cardId == id);
    _expenses.removeWhere((e) => e.cardId == id);
    return const Result.success(null);
  }
}
