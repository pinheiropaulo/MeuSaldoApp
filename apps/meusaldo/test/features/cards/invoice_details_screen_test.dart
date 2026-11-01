import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/cards/data/in_memory_credit_card_repository.dart';
import 'package:meusaldo/features/cards/presentation/screens/invoice_details_screen.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/cards/presentation/widgets/invoice/invoice_month_selector.dart';
import 'package:meusaldo/features/cards/presentation/widgets/invoice/invoice_status_hero_card.dart';
import 'package:meusaldo/features/cards/presentation/widgets/payment/invoice_payment_sheet.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

Widget _buildTestApp({
  required String cardId,
  CreditCardRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      if (repository != null)
        creditCardRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: InvoiceDetailsScreen(cardId: cardId),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  final testCard = CreditCard.create(
    id: 'card_nubank_test',
    name: 'Nubank Ultravioleta',
    totalLimit: Money.fromReais(12000),
    usedLimit: Money.fromReais(5550),
    closingDay: 3,
    dueDay: 10,
    lastFourDigits: '8842',
    colorHex: '#820AD1',
    isDefault: true,
  );

  final now = DateTime.now();
  final currentInvoice = Invoice.create(
    id: 'inv_current',
    cardId: testCard.id,
    month: now.month,
    year: now.year,
    closingDate: DateTime(now.year, now.month, 3),
    dueDate: DateTime(now.year, now.month, 10),
    totalAmount: const Money.fromCents(234870),
    status: InvoiceStatus.open,
  );

  final paidInvoice = Invoice.create(
    id: 'inv_paid',
    cardId: testCard.id,
    month: now.month == 1 ? 12 : now.month - 1,
    year: now.month == 1 ? now.year - 1 : now.year,
    closingDate: DateTime(now.year, now.month - 1, 3),
    dueDate: DateTime(now.year, now.month - 1, 10),
    totalAmount: Money.fromReais(1850),
    paidAmount: Money.fromReais(1850),
    status: InvoiceStatus.paid,
    paidDate: DateTime(now.year, now.month - 1, 10),
  );

  final testExpense = CardExpense.create(
    id: 'exp_notebook',
    cardId: testCard.id,
    description: 'Notebook Dell Inspiron',
    amount: const Money.fromCents(38990),
    date: DateTime.now(),
    currentInstallment: 4,
    totalInstallments: 10,
  );

  group('InvoiceDetailsScreen Widget Tests', () {
    testWidgets(
        'renderiza cabeçalho, seletor de meses, hero card e extrato de compras',
        (tester) async {
      final repo = InMemoryCreditCardRepository(
        initialCards: [testCard],
        initialInvoices: [currentInvoice, paidInvoice],
        initialExpenses: [testExpense],
      );

      await tester.pumpWidget(
        _buildTestApp(cardId: testCard.id, repository: repo),
      );
      await tester.pumpAndSettle();

      // AppBar
      expect(find.text('Fatura Nubank Ultravioleta'), findsOneWidget);
      expect(find.textContaining('Final 8842'), findsOneWidget);

      // Seletor de meses e hero card
      expect(find.byType(InvoiceMonthSelector), findsOneWidget);
      expect(find.byType(InvoiceStatusHeroCard), findsOneWidget);
      expect(find.text('Fatura Aberta'), findsOneWidget);
      expect(find.text('Total de gastos desta fatura'), findsOneWidget);
      expect(find.text('2.348,70'), findsOneWidget);

      // Extrato de lançamentos
      expect(find.text('Lançamentos da fatura'), findsOneWidget);
      expect(find.text('Notebook Dell Inspiron'), findsOneWidget);
      expect(find.text('Parcela 4/10'), findsOneWidget);
      expect(find.text('R\$ 389,90'), findsOneWidget);
    });

    testWidgets('permite alternar entre fatura aberta e fatura paga no seletor',
        (tester) async {
      final repo = InMemoryCreditCardRepository(
        initialCards: [testCard],
        initialInvoices: [currentInvoice, paidInvoice],
        initialExpenses: [testExpense],
      );

      await tester.pumpWidget(
        _buildTestApp(cardId: testCard.id, repository: repo),
      );
      await tester.pumpAndSettle();

      // Inicialmente fatura aberta
      expect(find.text('Fatura Aberta'), findsOneWidget);

      // Toca na fatura anterior paga
      await tester.tap(find.byIcon(Icons.check_circle).first);
      await tester.pumpAndSettle();

      // Confirma que agora exibe Fatura Paga
      expect(find.text('Fatura Paga'), findsOneWidget);
      expect(find.text('Total liquidado'), findsOneWidget);
    });

    testWidgets('abre modal de pagamento ao tocar em Registrar Pagamento',
        (tester) async {
      final repo = InMemoryCreditCardRepository(
        initialCards: [testCard],
        initialInvoices: [currentInvoice],
        initialExpenses: [testExpense],
      );

      await tester.pumpWidget(
        _buildTestApp(cardId: testCard.id, repository: repo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('invoice_hero_pay_button')));
      await tester.pumpAndSettle();

      expect(find.byType(InvoicePaymentSheet), findsOneWidget);
      expect(find.text('Registrar Pagamento'), findsNWidgets(2));
      expect(find.text('Salvar Registro de Pagamento'), findsOneWidget);
    });
  });
}
