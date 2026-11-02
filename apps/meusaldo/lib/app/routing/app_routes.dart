/// Constantes de caminhos e nomes de rotas do MeuSaldo.
abstract final class AppRoutes {
  /// Tela de apresentação e inicialização (Splash Screen).
  static const String splash = '/splash';

  /// Tela de autenticação e login.
  static const String login = '/login';

  /// Tela de cadastro de novo usuário.
  static const String register = '/register';

  /// Tela de recuperação de senha.
  static const String forgotPassword = '/forgot-password';

  /// Tela de edição de perfil do usuário.
  static const String editProfile = '/profile/edit';

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

  /// Tela de Detalhes e Extrato Individual da Conta Bancária.
  static const String accountDetails = '/accounts/:id';

  /// Tela de Edição Dedicada de Conta Financeira.
  static const String editAccount = '/accounts/:id/edit';

  /// Aba Cartões de Crédito e Faturas.
  static const String cards = '/cards';

  /// Tela de Detalhes da Fatura de Cartão de Crédito.
  static const String cardInvoice = '/cards/:id/invoice';

  /// Tela de Gestão e Listagem de Categorias.
  static const String categories = '/categories';

  /// Tela de Detalhes Analíticos da Categoria.
  static const String categoryDetails = '/categories/:id';

  /// Tela de Gestão de Orçamentos e Tetos de Gastos.
  static const String budgets = '/budgets';

  /// Tela de Configurações Gerais e Preferências.
  static const String settings = '/settings';

  /// Tela de Relatório Mensal e Gráficos Analíticos.
  static const String reports = '/reports';

  /// Aba Mais / Menu e Configurações.
  static const String more = '/more';
}
