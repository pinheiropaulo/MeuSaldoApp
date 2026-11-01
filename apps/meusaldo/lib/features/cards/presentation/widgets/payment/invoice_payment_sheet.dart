import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/cards/presentation/widgets/payment/payment_account_selector.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo/shared/formatters/currency_input_formatter.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Modal bottom sheet para registrar o pagamento e liquidação de fatura com débito em conta.
class InvoicePaymentSheet extends ConsumerStatefulWidget {
  final Invoice invoice;
  final CreditCard card;

  const InvoicePaymentSheet({
    super.key,
    required this.invoice,
    required this.card,
  });

  static Future<void> show(
    BuildContext context, {
    required Invoice invoice,
    required CreditCard card,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      builder: (_) => InvoicePaymentSheet(invoice: invoice, card: card),
    );
  }

  @override
  ConsumerState<InvoicePaymentSheet> createState() =>
      _InvoicePaymentSheetState();
}

class _InvoicePaymentSheetState extends ConsumerState<InvoicePaymentSheet> {
  String? _selectedAccountId;
  late DateTime _paymentDate;
  bool _hasInterestOrLateFee = false;
  late final TextEditingController _customAmountController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paymentDate = DateTime.now();
    _customAmountController = TextEditingController(
      text: widget.invoice.totalAmount.format(includeSymbol: false),
    );
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Money _getEffectiveAmount() {
    if (!_hasInterestOrLateFee) return widget.invoice.totalAmount;
    final cents =
        CurrencyInputFormatter.parseCents(_customAmountController.text);
    return cents > 0 ? Money.fromCents(cents) : widget.invoice.totalAmount;
  }

  Future<void> _handleConfirmPayment() async {
    setState(() => _isLoading = true);
    final effectiveAmount = _getEffectiveAmount();

    try {
      final repo = ref.read(creditCardRepositoryProvider);
      final payResult = await repo.payInvoice(
        invoiceId: widget.invoice.id,
        amount: effectiveAmount,
        paidDate: _paymentDate,
      );

      if (!payResult.isSuccess) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              payResult.failureOrNull?.message ?? 'Erro ao pagar fatura',
            ),
            backgroundColor: AppColors.expense,
          ),
        );
        return;
      }

      // Se houver conta bancária selecionada, cria o lançamento contábil debitando o saldo
      if (_selectedAccountId != null) {
        final tx = Transaction.create(
          id: 'tx_pay_${DateTime.now().millisecondsSinceEpoch}',
          description: 'Pagamento Fatura ${widget.card.name}',
          amount: effectiveAmount,
          type: TransactionType.expense,
          accountId: _selectedAccountId!,
          date: _paymentDate,
          status: TransactionStatus.completed,
        );
        await ref.read(transactionsListProvider.notifier).addTransaction(tx);
      }

      // Sincroniza estados
      ref.invalidate(cardInvoicesProvider(widget.card.id));
      ref.invalidate(currentInvoiceProvider);
      ref.invalidate(cardsListProvider);

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fatura ${widget.card.name} liquidada com sucesso! (${effectiveAmount.format()})',
          ),
          backgroundColor: AppColors.income,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar pagamento: $e'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsListProvider).value ?? const [];
    final dueFormat = DateFormat("dd MMM", "pt_BR");
    final dateFormat = DateFormat("dd/MM/yyyy", "pt_BR");

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildInvoiceSummary(dueFormat),
            const SizedBox(height: 16),
            PaymentAccountSelector(
              accounts: accounts,
              selectedAccountId: _selectedAccountId,
              onAccountSelected: (id) =>
                  setState(() => _selectedAccountId = id),
            ),
            const SizedBox(height: 16),
            _buildDateSection(dateFormat),
            const SizedBox(height: 16),
            _buildAmountAndInterestSection(),
            const SizedBox(height: 24),
            AppButton(
              label: 'Salvar Registro de Pagamento',
              icon: Icons.check_circle,
              isLoading: _isLoading,
              onPressed: _handleConfirmPayment,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Registrar Pagamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Fechar',
        ),
      ],
    );
  }

  Widget _buildInvoiceSummary(DateFormat dueFormat) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: AppColors.primaryHighlight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.card.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vence em ${dueFormat.format(widget.invoice.dueDate)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total Fatura',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              Text(
                widget.invoice.totalAmount.formatted,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data do Pagamento',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _paymentDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.surface,
                    onPrimary: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() => _paymentDate = picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(_paymentDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: AppColors.primaryHighlight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountAndInterestSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Valor original da fatura',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                widget.invoice.totalAmount.formatted,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.outline, height: 1),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => setState(
              () => _hasInterestOrLateFee = !_hasInterestOrLateFee,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _hasInterestOrLateFee,
                    activeColor: AppColors.primary,
                    checkColor: AppColors.primaryHighlight,
                    onChanged: (val) => setState(
                      () => _hasInterestOrLateFee = val ?? false,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Houve atraso / pagamento com juros?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_hasInterestOrLateFee) ...[
            const SizedBox(height: 12),
            const Text(
              'Quanto você pagou no total (com juros/multa)?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.alert,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              key: const Key('invoice_payment_custom_amount_field'),
              controller: _customAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.bold,
                  color: AppColors.transfer,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Nota de uso: O aplicativo não efetua cálculos de juros bancários. Insira o valor total pago para registrar seus gastos com precisão.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
