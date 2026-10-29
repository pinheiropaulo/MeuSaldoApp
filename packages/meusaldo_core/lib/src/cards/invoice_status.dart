/// Status de uma fatura de cartão de crédito.
enum InvoiceStatus {
  /// Fatura aberta, acumulando novos lançamentos até o dia de fechamento.
  open,

  /// Fatura fechada, com valor consolidado aguardando pagamento até o vencimento.
  closed,

  /// Fatura quitada integralmente.
  paid,

  /// Fatura vencida sem confirmação de pagamento integral.
  overdue,
}
