import 'package:meusaldo_core/meusaldo_core.dart';

/// Dados de demonstração iniciais para validação rápida das telas do MeuSaldo.
abstract final class DemoData {
  /// Contas financeiras pré-carregadas.
  static List<FinancialAccount> get accounts => [
    FinancialAccount.create(
      id: 'acc-nubank',
      name: 'Nubank Principal',
      type: AccountType.checking,
      initialBalance: const Money.fromCents(384050), // R$ 3.840,50
      colorHex: '#6D1834',
      iconKey: 'account_balance',
    ),
    FinancialAccount.create(
      id: 'acc-itau',
      name: 'Itaú Reserva',
      type: AccountType.savings,
      initialBalance: const Money.fromCents(1250000), // R$ 12.500,00
      colorHex: '#4C8DFF',
      iconKey: 'savings',
    ),
    FinancialAccount.create(
      id: 'acc-carteira',
      name: 'Carteira Física',
      type: AccountType.cash,
      initialBalance: const Money.fromCents(18000), // R$ 180,00
      colorHex: '#22A06B',
      iconKey: 'payments',
    ),
  ];

  /// Categorias pré-carregadas para despesas e receitas.
  static List<Category> get categories => [
    // Despesas
    Category.create(
      id: 'cat-alimentacao',
      name: 'Alimentação & Bebidas',
      type: CategoryType.expense,
      iconKey: 'restaurant',
      colorHex: '#F04444',
      description: 'Supermercado, restaurantes e delivery',
    ),
    Category.create(
      id: 'cat-moradia',
      name: 'Moradia & Contas',
      type: CategoryType.expense,
      iconKey: 'home',
      colorHex: '#FF8C42',
      description: 'Aluguel, luz, água e internet',
    ),
    Category.create(
      id: 'cat-transporte',
      name: 'Transporte',
      type: CategoryType.expense,
      iconKey: 'directions_car',
      colorHex: '#4C8DFF',
      description: 'Combustível, transporte público e aplicativos',
    ),
    Category.create(
      id: 'cat-saude',
      name: 'Saúde & Farmácia',
      type: CategoryType.expense,
      iconKey: 'medical_services',
      colorHex: '#22A06B',
      description: 'Consultas, exames e medicamentos',
    ),
    Category.create(
      id: 'cat-lazer',
      name: 'Lazer & Cultura',
      type: CategoryType.expense,
      iconKey: 'sports_esports',
      colorHex: '#9B51E0',
      description: 'Passeios, cinemas e assinaturas',
    ),

    // Receitas
    Category.create(
      id: 'cat-salario',
      name: 'Salário & Remuneração',
      type: CategoryType.income,
      iconKey: 'work',
      colorHex: '#22A06B',
      description: 'Salário mensal e benefícios',
    ),
    Category.create(
      id: 'cat-investimentos',
      name: 'Rendimentos',
      type: CategoryType.income,
      iconKey: 'trending_up',
      colorHex: '#22A06B',
      description: 'Dividendos e rendimentos de aplicação',
    ),
    Category.create(
      id: 'cat-extra',
      name: 'Trabalhos Extras',
      type: CategoryType.income,
      iconKey: 'bolt',
      colorHex: '#4C8DFF',
      description: 'Freelas e consultorias',
    ),

    // Misto
    Category.create(
      id: 'cat-ajustes',
      name: 'Ajuste de Saldo',
      type: CategoryType.both,
      iconKey: 'tune',
      colorHex: '#B5A7AD',
      description: 'Conciliações e correções de saldo',
    ),
  ];

  /// Lançamentos financeiros do mês corrente.
  static List<Transaction> getTransactions() {
    final now = DateTime.now();
    return [
      Transaction.create(
        id: 'tx-salario-mes',
        type: TransactionType.income,
        amount: const Money.fromCents(550000), // R$ 5.500,00
        date: DateTime(now.year, now.month, 5),
        description: 'Salário Mensal',
        status: TransactionStatus.completed,
        accountId: 'acc-nubank',
        categoryId: 'cat-salario',
      ),
      Transaction.create(
        id: 'tx-mercado-1',
        type: TransactionType.expense,
        amount: const Money.fromCents(42050), // R$ 420,50
        date: DateTime(now.year, now.month, 8),
        description: 'Supermercado Pão de Açúcar',
        status: TransactionStatus.completed,
        accountId: 'acc-nubank',
        categoryId: 'cat-alimentacao',
      ),
      Transaction.create(
        id: 'tx-farmacia-1',
        type: TransactionType.expense,
        amount: const Money.fromCents(8990), // R$ 89,90
        date: DateTime(now.year, now.month, 12),
        description: 'Farmácia Droga Raia',
        status: TransactionStatus.completed,
        accountId: 'acc-nubank',
        categoryId: 'cat-saude',
      ),
      Transaction.create(
        id: 'tx-reserva-1',
        type: TransactionType.transfer,
        amount: const Money.fromCents(100000), // R$ 1.000,00
        date: DateTime(now.year, now.month, 15),
        description: 'Aporte Reserva de Emergência',
        status: TransactionStatus.completed,
        accountId: 'acc-nubank',
        destinationAccountId: 'acc-itau',
      ),
      Transaction.create(
        id: 'tx-condominio-futuro',
        type: TransactionType.expense,
        amount: const Money.fromCents(65000), // R$ 650,00
        date: DateTime(now.year, now.month, 28),
        description: 'Condomínio Residencial',
        status: TransactionStatus.pending,
        accountId: 'acc-nubank',
        categoryId: 'cat-moradia',
      ),
    ];
  }
}
