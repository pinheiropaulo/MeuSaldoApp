import 'package:meusaldo/shared/data/demo_data.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Implementação em memória do [CreditCardRepository] para desenvolvimento ágil e testes.
class InMemoryCreditCardRepository implements CreditCardRepository {
  final Map<String, CreditCard> _cards = {};
  final Map<String, Invoice> _invoices = {};
  final List<CardExpense> _expenses = [];

  InMemoryCreditCardRepository({
    List<CreditCard>? initialCards,
    List<Invoice>? initialInvoices,
    List<CardExpense>? initialExpenses,
  }) {
    final seedCards = initialCards ?? DemoData.creditCards;
    for (final card in seedCards) {
      _cards[card.id] = card;
    }

    final seedInvoices = initialInvoices ?? DemoData.getInvoices();
    for (final inv in seedInvoices) {
      _invoices[inv.cardId] = inv;
    }

    _expenses.addAll(initialExpenses ?? DemoData.getCardExpenses());
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
    final invoice = _invoices[cardId];
    if (invoice == null) {
      return Result.failure(
        NotFoundFailure('Nenhuma fatura encontrada para o cartão "$cardId".'),
      );
    }
    return Result.success(invoice);
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
  Future<Result<CreditCard, Failure>> create(CreditCard card) async {
    if (_cards.containsKey(card.id)) {
      return Result.failure(
        ValidationFailure('Já existe um cartão com o ID "${card.id}".'),
      );
    }
    _cards[card.id] = card;
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
    _invoices.remove(id);
    _expenses.removeWhere((e) => e.cardId == id);
    return const Result.success(null);
  }
}
