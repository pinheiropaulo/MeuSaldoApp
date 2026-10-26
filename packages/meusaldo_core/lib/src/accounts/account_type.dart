/// Tipos de contas financeiras suportadas no MeuSaldo.
enum AccountType {
  /// Conta corrente para movimentação diária, PIX e transferências.
  checking('Conta corrente'),

  /// Conta poupança para reservas e rendimentos tradicionais.
  savings('Conta poupança'),

  /// Dinheiro físico/cédulas em espécie.
  cash('Dinheiro em espécie'),

  /// Carteira digital, apps de pagamento e pré-pagos.
  digitalWallet('Carteira digital'),

  /// Conta de investimento.
  investment('Investimentos');

  final String displayName;

  const AccountType(this.displayName);
}
