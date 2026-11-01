import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/data/in_memory_account_repository.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/cards/data/in_memory_credit_card_repository.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/cards/presentation/widgets/payment/invoice_payment_sheet.dart';
import 'package:meusaldo/features/cards/presentation/widgets/payment/payment_account_selector.dart';
import 'package:meusaldo/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

Widget _buildTestApp({
  required Invoice invoice,
  required CreditCard card,
  CreditCardRepository? cardRepo,
  AccountRepository? accountRepo,
  TransactionRepository? transactionRepo,
}) {
  return ProviderScope(
    overrides: [
      if (cardRepo != null)
        creditCardRepositoryProvider.overrideWithValue(cardRepo),
      if (accountRepo != null)
        accountRepositoryProvider.overrideWithValue(accountRepo),
      if (transactionRepo != null)
        transactionRepositoryProvider.overrideWithValue(transactionRepo),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            key: const Key('open_sheet_btn'),
            onPressed: () => InvoicePaymentSheet.show(
              context,
              invoice: invoice,
              card: card,
            ),
            child: const Text('Abrir Sheet'),
          ),
        ),
      ),
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
    totalLimit: Money.fromReais(10000),
    usedLimit: Money.fromReais(2500),
    closingDay: 3,
    dueDay: 10,
    lastFourDigits: '8842',
    colorHex: '#820AD1',
    isDefault: true,
  );

  final testInvoice = Invoice.create(
    id: 'inv_123',
    cardId: testCard.id,
    month: 11,
    year: 2026,
    closingDate: DateTime(2026, 11, 3),
    dueDate: DateTime(2026, 11, 10),
    totalAmount: const Money.fromCents(234870),
    status: InvoiceStatus.open,
  );

  final testAccount = FinancialAccount.create(
    id: 'acc_itau',
    name: 'Itaú Unibanco',
    type: AccountType.checking,
    initialBalance: Money.fromReais(5000),
  );

  group('InvoicePaymentSheet Widget Tests', () {
    testWidgets(
        'exibe resumo da fatura, seletor de data e opções de débito em conta',
        (tester) async {
      final cardRepo = InMemoryCreditCardRepository(
        initialCards: [testCard],
        initialInvoices: [testInvoice],
      );
      final accRepo = InMemoryAccountRepository(
        initialAccounts: [testAccount],
      );

      await tester.pumpWidget(
        _buildTestApp(
          invoice: testInvoice,
          card: testCard,
          cardRepo: cardRepo,
          accountRepo: accRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      expect(find.byType(InvoicePaymentSheet), findsOneWidget);
      expect(find.text('Registrar Pagamento'), findsOneWidget);
      expect(find.text('Nubank Ultravioleta'), findsOneWidget);
      expect(find.text('R\$ 2.348,70'), findsWidgets);
      expect(find.byType(PaymentAccountSelector), findsOneWidget);
      expect(find.text('Itaú Unibanco'), findsOneWidget);
      expect(find.text('Apenas marcar fatura como paga'), findsOneWidget);
      expect(find.text('Salvar Registro de Pagamento'), findsOneWidget);
    });

    testWidgets(
        'seleciona conta bancária de saída e liquida fatura com sucesso',
        (tester) async {
      final cardRepo = InMemoryCreditCardRepository(
        initialCards: [testCard],
        initialInvoices: [testInvoice],
      );
      final accRepo = InMemoryAccountRepository(
        initialAccounts: [testAccount],
      );
      final txRepo =
          InMemoryTransactionRepository(initialTransactions: const []);

      await tester.pumpWidget(
        _buildTestApp(
          invoice: testInvoice,
          card: testCard,
          cardRepo: cardRepo,
          accountRepo: accRepo,
          transactionRepo: txRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Seleciona a conta Itaú
      await tester.tap(find.text('Itaú Unibanco'));
      await tester.pumpAndSettle();

      // Clica em confirmar pagamento
      await tester.ensureVisible(find.text('Salvar Registro de Pagamento'));
      await tester.tap(find.text('Salvar Registro de Pagamento'));
      await tester.pumpAndSettle();

      // Sheet fecha
      expect(find.byType(InvoicePaymentSheet), findsNothing);
      expect(find.textContaining('liquidada com sucesso'), findsOneWidget);

      // Fatura no repositório foi paga
      final invoices = await cardRepo.getInvoices(testCard.id);
      final updatedInv = invoices.valueOrNull?.first;
      expect(updatedInv?.isPaid, isTrue);
      expect(updatedInv?.paidAmount, equals(const Money.fromCents(234870)));

      // Transação contábil foi criada
      final txs = await txRepo.getAllTransactions();
      expect(txs.valueOrNull?.length, 1);
      expect(txs.valueOrNull?.first.accountId, 'acc_itau');
      expect(txs.valueOrNull?.first.amount, equals(const Money.fromCents(234870)));
    });

    testWidgets('liquida fatura sem criar transação bancária quando optado',
        (tester) async {
      final cardRepo = InMemoryCreditCardRepository(
        initialCards: [testCard],
        initialInvoices: [testInvoice],
      );
      final accRepo = InMemoryAccountRepository(
        initialAccounts: [testAccount],
      );
      final txRepo =
          InMemoryTransactionRepository(initialTransactions: const []);

      await tester.pumpWidget(
        _buildTestApp(
          invoice: testInvoice,
          card: testCard,
          cardRepo: cardRepo,
          accountRepo: accRepo,
          transactionRepo: txRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Clica na opção sem débito em conta
      await tester.tap(find.text('Apenas marcar fatura como paga'));
      await tester.pumpAndSettle();

      // Clica em confirmar pagamento
      await tester.ensureVisible(find.text('Salvar Registro de Pagamento'));
      await tester.tap(find.text('Salvar Registro de Pagamento'));
      await tester.pumpAndSettle();

      expect(find.byType(InvoicePaymentSheet), findsNothing);

      // Fatura no repo foi paga
      final invoices = await cardRepo.getInvoices(testCard.id);
      expect(invoices.valueOrNull?.first.isPaid, isTrue);

      // Nenhuma transação bancária foi criada
      final txs = await txRepo.getAllTransactions();
      expect(txs.valueOrNull?.isEmpty, isTrue);
    });

    testWidgets(
        'permite informar juros ou valor personalizado no pagamento',
        (tester) async {
      final cardRepo = InMemoryCreditCardRepository(
        initialCards: [testCard],
        initialInvoices: [testInvoice],
      );
      final accRepo = InMemoryAccountRepository(
        initialAccounts: [testAccount],
      );

      await tester.pumpWidget(
        _buildTestApp(
          invoice: testInvoice,
          card: testCard,
          cardRepo: cardRepo,
          accountRepo: accRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Marca o checkbox de juros/multa
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Campo de valor personalizado aparece
      expect(find.byKey(const Key('invoice_payment_custom_amount_field')),
          findsOneWidget);

      // Digita novo valor com juros (250000 centavos = 2500,00)
      await tester.enterText(
          find.byKey(const Key('invoice_payment_custom_amount_field')),
          '250000');
      await tester.pumpAndSettle();

      // Confirma pagamento
      await tester.ensureVisible(find.text('Salvar Registro de Pagamento'));
      await tester.tap(find.text('Salvar Registro de Pagamento'));
      await tester.pumpAndSettle();

      final invoices = await cardRepo.getInvoices(testCard.id);
      expect(invoices.valueOrNull?.first.paidAmount,
          equals(Money.fromReais(2500)));
    });
  });
}
