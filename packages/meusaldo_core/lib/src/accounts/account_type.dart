/// Tipos de contas financeiras suportadas no MeuSaldo.
enum AccountType {
  /// Conta corrente para movimentação diária, PIX e transferências.
  checking('Conta corrente'),

  /// Conta poupança para reservas e rendimentos tradicionais.
  savings('Conta poupança'),

  /// Dinheiro físico/cédulas em espécie.
  cash('Dinheiro em espécie'),

  /// Benefícios corporativos (VR, VA, alimentação, refeição, Flash, mobilidade).
  benefit('Benefícios'),

  /// Conta de investimento.
  investment('Investimentos');

  final String displayName;

  const AccountType(this.displayName);

  /// Indica se esta conta faz parte do saldo bancário livre/líquido.
  bool get isLiquidBalance => this != AccountType.benefit;

  /// Indica se esta conta é de benefícios corporativos (VR/VA/Mobilidade).
  bool get isBenefit => this == AccountType.benefit;
}
