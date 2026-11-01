/// Constantes de caminhos e nomes de rotas do MeuSaldo.
abstract final class AppRoutes {
  /// Tela de apresentação e inicialização (Splash Screen).
  static const String splash = '/splash';

  /// Tela de autenticação e login.
  static const String login = '/login';

  /// Aba Início / Visão Geral.
  static const String home = '/';

  /// Aba Lançamentos (extrato, receitas e despesas).
  static const String transactions = '/transactions';

  /// Tela de Agenda de Contas e Próximos Vencimentos.
  static const String schedule = '/schedule';

  /// Tela de Lançamentos Recorrentes e Assinaturas Fixas.
  static const String recurring = '/recurring';

  /// Aba Contas Financeiras.
  static const String accounts = '/accounts';

  /// Aba Cartões de Crédito e Faturas.
  static const String cards = '/cards';

  /// Aba Mais / Menu e Configurações.
  static const String more = '/more';
}
