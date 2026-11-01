import 'package:meusaldo_core/src/cards/card_expense.dart';
import 'package:meusaldo_core/src/cards/credit_card.dart';
import 'package:meusaldo_core/src/cards/invoice.dart';
import 'package:meusaldo_core/src/shared/failures.dart';
import 'package:meusaldo_core/src/shared/money.dart';
import 'package:meusaldo_core/src/shared/result.dart';

/// Contrato do repositório para gerenciamento de cartões de crédito e faturas.
abstract interface class CreditCardRepository {
  /// Retorna todos os cartões cadastrados.
  Future<Result<List<CreditCard>, Failure>> getAll();

  /// Busca um cartão de crédito pelo seu identificador único.
  Future<Result<CreditCard, Failure>> getById(String id);

  /// Obtém a fatura atual (aberta ou em fechamento) para o cartão informado.
  Future<Result<Invoice, Failure>> getCurrentInvoice(String cardId);

  /// Obtém todas as faturas registradas para o cartão informado (passadas, atual e futuras).
  Future<Result<List<Invoice>, Failure>> getInvoices(String cardId);

  /// Obtém as compras parceladas ainda ativas para o cartão informado.
  Future<Result<List<CardExpense>, Failure>> getActiveInstallments(String cardId);

  /// Obtém todas as despesas/lançamentos registrados para o cartão informado.
  Future<Result<List<CardExpense>, Failure>> getExpenses(String cardId);

  /// Registra uma nova despesa no cartão de crédito.
  Future<Result<CardExpense, Failure>> addExpense(CardExpense expense);

  /// Registra a quitação de uma fatura de cartão de crédito.
  Future<Result<Invoice, Failure>> payInvoice({
    required String invoiceId,
    required Money amount,
    DateTime? paidDate,
  });

  /// Registra um novo cartão de crédito.
  Future<Result<CreditCard, Failure>> create(CreditCard card);

  /// Atualiza o cadastro de um cartão de crédito.
  Future<Result<CreditCard, Failure>> update(CreditCard card);

  /// Exclui um cartão de crédito e seus vínculos pelo identificador.
  Future<Result<void, Failure>> delete(String id);
}
