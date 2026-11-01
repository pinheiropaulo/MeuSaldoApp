import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/cards/presentation/widgets/invoice/invoice_expenses_list.dart';
import 'package:meusaldo/features/cards/presentation/widgets/invoice/invoice_month_selector.dart';
import 'package:meusaldo/features/cards/presentation/widgets/invoice/invoice_status_hero_card.dart';
import 'package:meusaldo/features/cards/presentation/widgets/payment/invoice_payment_sheet.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Tela orquestradora para visualização detalhada da fatura de cartão e extrato de compras.
class InvoiceDetailsScreen extends ConsumerStatefulWidget {
  final String cardId;

  const InvoiceDetailsScreen({
    super.key,
    required this.cardId,
  });

  @override
  ConsumerState<InvoiceDetailsScreen> createState() =>
      _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends ConsumerState<InvoiceDetailsScreen> {
  String? _selectedInvoiceId;

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(cardsListProvider);
    final cards = cardsAsync.value ?? const [];

    if (cardsAsync.isLoading && cards.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final selectedCard = ref.watch(selectedCreditCardProvider);
    final card = cards.where((c) => c.id == widget.cardId).firstOrNull ??
        selectedCard ??
        (cards.isNotEmpty ? cards.first : _fallbackCard(widget.cardId));

    final invoices = ref.watch(cardInvoicesProvider(widget.cardId)).value ?? [];
    final allExpenses =
        ref.watch(cardExpensesProvider(widget.cardId)).value ?? [];

    final activeInvoice = invoices.firstWhere(
      (inv) => inv.id == _selectedInvoiceId,
      orElse: () => invoices.firstWhere(
        (inv) => inv.status == InvoiceStatus.open,
        orElse: () => invoices.isNotEmpty ? invoices.first : _fallbackInvoice(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fatura ${card.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Final ${card.lastFourDigits ?? '••••'} • Limite R\$ ${card.totalLimit.format()}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          InvoiceMonthSelector(
            invoices: invoices,
            selectedInvoiceId: activeInvoice.id,
            onInvoiceSelected: (inv) =>
                setState(() => _selectedInvoiceId = inv.id),
          ),
          const SizedBox(height: 16),
          InvoiceStatusHeroCard(
            invoice: activeInvoice,
            card: card,
            onPayPressed: () => InvoicePaymentSheet.show(
              context,
              invoice: activeInvoice,
              card: card,
            ),
            onViewInstallmentsPressed: () => context.pop(),
          ),
          const SizedBox(height: 20),
          InvoiceExpensesList(expenses: allExpenses),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  CreditCard _fallbackCard(String id) {
    return CreditCard.create(
      id: id,
      name: 'Cartão de Crédito',
      totalLimit: const Money.zero(),
      closingDay: 1,
      dueDay: 10,
    );
  }

  Invoice _fallbackInvoice() {
    final now = DateTime.now();
    return Invoice.create(
      id: 'inv_fallback',
      cardId: widget.cardId,
      month: now.month,
      year: now.year,
      closingDate: DateTime(now.year, now.month, 3),
      dueDate: DateTime(now.year, now.month, 10),
      totalAmount: const Money.zero(),
    );
  }
}
