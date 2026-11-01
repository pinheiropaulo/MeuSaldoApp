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
        id: 'tx-enel-vencida',
        type: TransactionType.expense,
        amount: const Money.fromCents(13990), // R$ 139,90
        date: now.subtract(const Duration(days: 8)),
        description: 'Enel Energia Elétrica',
        status: TransactionStatus.pending,
        accountId: 'acc-nubank',
        categoryId: 'cat-moradia',
        notes: 'Boleto vencido aguardando pagamento',
      ),
      Transaction.create(
        id: 'tx-condominio-futuro',
        type: TransactionType.expense,
        amount: const Money.fromCents(45000), // R$ 450,00
        date: now.add(const Duration(days: 3)),
        description: 'Condomínio Residencial',
        status: TransactionStatus.pending,
        accountId: 'acc-nubank',
        categoryId: 'cat-moradia',
      ),
      Transaction.create(
        id: 'tx-smartfit',
        type: TransactionType.expense,
        amount: const Money.fromCents(12990), // R$ 129,90
        date: now.add(const Duration(days: 3)),
        description: 'Academia SmartFit',
        status: TransactionStatus.pending,
        accountId: 'acc-nubank',
        categoryId: 'cat-lazer',
      ),
      Transaction.create(
        id: 'tx-aluguel-pago',
        type: TransactionType.expense,
        amount: const Money.fromCents(180000), // R$ 1.800,00
        date: DateTime(now.year, now.month, 1),
        description: 'Aluguel do Apartamento',
        status: TransactionStatus.completed,
        accountId: 'acc-nubank',
        categoryId: 'cat-moradia',
      ),
    ];
  }

  /// Cartões de crédito pré-carregados para a aba de Cartões & Faturas.
  static List<CreditCard> get creditCards => [
        CreditCard.create(
          id: 'card-nubank',
          name: 'Nubank Ultravioleta',
          totalLimit: const Money.fromCents(1200000), // R$ 12.000,00
          usedLimit: const Money.fromCents(555000), // R$ 5.550,00 (46% usado, 54% livre)
          closingDay: 3,
          dueDay: 10,
          colorHex: '#6D1834',
          lastFourDigits: '8842',
          isDefault: true,
          bankId: 'nubank',
        ),
        CreditCard.create(
          id: 'card-itau',
          name: 'Itaú Click',
          totalLimit: const Money.fromCents(500000), // R$ 5.000,00
          usedLimit: const Money.fromCents(290000), // R$ 2.900,00 (58% usado, 42% livre)
          closingDay: 15,
          dueDay: 22,
          colorHex: '#4C8DFF',
          lastFourDigits: '1049',
          isDefault: false,
          bankId: 'itau',
        ),
      ];

  /// Faturas de exemplo para os cartões cadastrados.
  static List<Invoice> getInvoices() {
    final now = DateTime.now();
    return [
      Invoice.create(
        id: 'inv-nubank-current',
        cardId: 'card-nubank',
        month: now.month,
        year: now.year,
        closingDate: DateTime(now.year, now.month, 3),
        dueDate: DateTime(now.year, now.month, 10),
        totalAmount: const Money.fromCents(234870), // R$ 2.348,70
        status: InvoiceStatus.open,
      ),
      Invoice.create(
        id: 'inv-itau-current',
        cardId: 'card-itau',
        month: now.month,
        year: now.year,
        closingDate: DateTime(now.year, now.month, 15),
        dueDate: DateTime(now.year, now.month, 22),
        totalAmount: const Money.fromCents(145000), // R$ 1.450,00
        status: InvoiceStatus.open,
      ),
    ];
  }

  /// Compras parceladas ativas vinculadas aos cartões.
  static List<CardExpense> getCardExpenses() {
    final now = DateTime.now();
    return [
      CardExpense.create(
        id: 'exp-notebook',
        cardId: 'card-nubank',
        description: 'Notebook Dell',
        amount: const Money.fromCents(38990), // R$ 389,90/mês
        date: DateTime(now.year, now.month, 15),
        currentInstallment: 4,
        totalInstallments: 10,
        categoryId: 'cat-lazer',
      ),
      CardExpense.create(
        id: 'exp-mercado',
        cardId: 'card-nubank',
        description: 'Supermercado',
        amount: const Money.fromCents(18000), // R$ 180,00/mês
        date: DateTime(now.year, now.month, 8),
        currentInstallment: 2,
        totalInstallments: 3,
        categoryId: 'cat-alimentacao',
      ),
      CardExpense.create(
        id: 'exp-curso',
        cardId: 'card-itau',
        description: 'Curso de Especialização',
        amount: const Money.fromCents(12000), // R$ 120,00/mês
        date: DateTime(now.year, now.month, 5),
        currentInstallment: 3,
        totalInstallments: 6,
        categoryId: 'cat-lazer',
      ),
    ];
  }

  /// Lançamentos recorrentes e assinaturas pré-carregadas.
  static List<RecurringTransaction> getRecurringTransactions() {
    return [
      RecurringTransaction.create(
        id: 'rec-netflix',
        description: 'Netflix Brasil',
        amount: const Money.fromCents(5590), // R$ 55,90
        type: TransactionType.expense,
        category: RecurrenceCategory.subscription,
        billingDay: 20,
        billingDayDescription: 'Todo dia 20 • Cartão Nubank',
        paymentMethod: 'Cartão Nubank',
        iconKey: 'movie',
      ),
      RecurringTransaction.create(
        id: 'rec-spotify',
        description: 'Spotify Premium',
        amount: const Money.fromCents(2190), // R$ 21,90
        type: TransactionType.expense,
        category: RecurrenceCategory.subscription,
        billingDay: 12,
        billingDayDescription: 'Todo dia 12 • Cartão Nubank',
        paymentMethod: 'Cartão Nubank',
        iconKey: 'headphones',
      ),
      RecurringTransaction.create(
        id: 'rec-smartfit',
        description: 'SmartFit Plano Black',
        amount: const Money.fromCents(12990), // R$ 129,90
        type: TransactionType.expense,
        category: RecurrenceCategory.subscription,
        billingDay: 5,
        billingDayDescription: 'Todo dia 05 • Débito NuConta',
        paymentMethod: 'Débito NuConta',
        iconKey: 'fitness_center',
      ),
      RecurringTransaction.create(
        id: 'rec-aluguel',
        description: 'Aluguel do Apartamento',
        amount: const Money.fromCents(180000), // R$ 1.800,00
        type: TransactionType.expense,
        category: RecurrenceCategory.fixedExpense,
        billingDay: 10,
        billingDayDescription: 'Vence todo dia 10 • NuConta',
        paymentMethod: 'NuConta',
        iconKey: 'key',
      ),
      RecurringTransaction.create(
        id: 'rec-fibra',
        description: 'Vivo Fibra 500MB',
        amount: const Money.fromCents(13990), // R$ 139,90
        type: TransactionType.expense,
        category: RecurrenceCategory.fixedExpense,
        billingDay: 15,
        billingDayDescription: 'Vence todo dia 15 • Boleto',
        paymentMethod: 'Boleto',
        iconKey: 'wifi',
      ),
      RecurringTransaction.create(
        id: 'rec-salario',
        description: 'Salário Mensal CLT',
        amount: const Money.fromCents(650000), // R$ 6.500,00
        type: TransactionType.income,
        category: RecurrenceCategory.income,
        billingDay: 5,
        billingDayDescription: 'Todo 5º dia útil • NuConta',
        paymentMethod: 'NuConta',
        iconKey: 'account_balance_wallet',
      ),
    ];
  }
}
