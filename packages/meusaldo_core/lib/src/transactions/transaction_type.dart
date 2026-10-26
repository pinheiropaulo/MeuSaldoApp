/// Tipos de movimentação financeira suportados.
enum TransactionType {
  /// Lançamento de despesa (reduz o saldo da conta).
  expense('Despesa'),

  /// Lançamento de receita (aumenta o saldo da conta).
  income('Receita'),

  /// Transferência de recursos entre duas contas do usuário (débito na origem e crédito no destino).
  transfer('Transferência');

  final String displayName;

  const TransactionType(this.displayName);
}
