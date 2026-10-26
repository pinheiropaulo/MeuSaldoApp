/// Estado de efetivação de um lançamento financeiro.
enum TransactionStatus {
  /// Lançamento já efetivado/consolidado (reflete no saldo atual da conta).
  completed('Efetivado'),

  /// Lançamento agendado ou pendente de compensação/pagamento.
  pending('Pendente');

  final String displayName;

  const TransactionStatus(this.displayName);
}
