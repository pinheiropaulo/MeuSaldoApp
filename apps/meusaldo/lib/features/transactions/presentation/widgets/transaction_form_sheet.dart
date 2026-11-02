import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_amount_hero_input.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_date_picker_field.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_status_toggle.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_type_segmented_tab.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Forma de pagamento da despesa (débito em conta ou cartão de crédito).
enum ExpensePaymentMethod { account, creditCard }

/// Modal bottom sheet para criação de despesa, receita ou transferência.
class TransactionFormSheet extends ConsumerStatefulWidget {
  /// Tipo de movimentação inicial (padrão é despesa).
  final TransactionType initialType;

  /// Conta financeira pré-selecionada (opcional).
  final String? initialAccountId;

  const TransactionFormSheet({
    super.key,
    this.initialType = TransactionType.expense,
    this.initialAccountId,
  });

  /// Exibe o formulário de novo lançamento.
  static Future<bool?> show(
    BuildContext context, {
    TransactionType initialType = TransactionType.expense,
    String? initialAccountId,
  }) {
    return showAppBottomSheet<bool>(
      context: context,
      builder: (_) => TransactionFormSheet(
        initialType: initialType,
        initialAccountId: initialAccountId,
      ),
    );
  }

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  late TransactionType _selectedType;
  late final TextEditingController _amountController;
  late final TextEditingController _descController;
  late final TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  late bool _isCompleted;

  String? _selectedAccountId;
  String? _selectedDestinationAccountId;
  String? _selectedCategoryId;
  String? _selectedCardId;
  ExpensePaymentMethod _paymentMethod = ExpensePaymentMethod.account;
  int _selectedInstallments = 1;

  bool _isLoading = false;
  String? _errorMessage;

  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isAfter(today);
  }

  bool get _isCard =>
      _selectedType == TransactionType.expense &&
      _paymentMethod == ExpensePaymentMethod.creditCard;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedAccountId = widget.initialAccountId;
    _isCompleted = !_isFutureDate(_selectedDate);
    _amountController = TextEditingController();
    _descController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final amount = Money.tryParse(_amountController.text);
    if (amount == null || !amount.isPositive) {
      setState(() => _errorMessage = 'Informe um valor maior que zero.');
      return;
    }

    final desc = _descController.text.trim();
    if (desc.isEmpty && _selectedType != TransactionType.transfer) {
      setState(() => _errorMessage = 'A descrição é obrigatória.');
      return;
    }

    final isCard =
        _selectedType == TransactionType.expense &&
        _paymentMethod == ExpensePaymentMethod.creditCard;

    if (isCard) {
      if (_selectedCardId == null) {
        setState(() => _errorMessage = 'Selecione um cartão de crédito.');
        return;
      }
    } else {
      if (_selectedAccountId == null) {
        setState(() => _errorMessage = 'Selecione uma conta financeira.');
        return;
      }
    }

    if (_selectedType == TransactionType.transfer) {
      if (_selectedDestinationAccountId == null) {
        setState(() => _errorMessage = 'Selecione a conta de destino.');
        return;
      }
      if (_selectedAccountId == _selectedDestinationAccountId) {
        setState(() => _errorMessage = 'As contas devem ser distintas.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final notifier = ref.read(transactionsListProvider.notifier);

    if (_selectedType == TransactionType.transfer) {
      final effectiveDesc = desc.isEmpty ? 'Transferência entre contas' : desc;
      final effectiveStatus = _isCompleted
          ? TransactionStatus.completed
          : TransactionStatus.pending;

      final result = await notifier.executeTransfer(
        transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        sourceAccountId: _selectedAccountId!,
        destinationAccountId: _selectedDestinationAccountId!,
        amount: amount,
        date: _selectedDate,
        description: effectiveDesc,
        status: effectiveStatus,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (!mounted) return;
      if (result.isSuccess) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.failureOrNull?.message ?? 'Erro ao transferir';
        });
      }
    } else {
      final accounts = ref.read(accountsListProvider).value ?? const [];
      final effectiveAccountId = isCard
          ? (_selectedAccountId ??
                (accounts.isNotEmpty ? accounts.first.id : 'acc-default'))
          : _selectedAccountId!;

      final effectiveStatus = isCard
          ? TransactionStatus.completed
          : (_isCompleted
                ? TransactionStatus.completed
                : TransactionStatus.pending);

      final newTx = Transaction.create(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        description: desc,
        amount: amount,
        date: _selectedDate,
        type: _selectedType,
        status: effectiveStatus,
        accountId: effectiveAccountId,
        cardId: isCard ? _selectedCardId : null,
        installments: isCard ? _selectedInstallments : null,
        categoryId: _selectedCategoryId,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final result = await notifier.addTransaction(newTx);
      if (!mounted) return;
      if (result.isSuccess) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              result.failureOrNull?.message ?? 'Erro ao salvar lançamento';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsListProvider).value ?? const [];
    final cards = ref.watch(cardsListProvider).value ?? const [];
    final categories = ref.watch(categoriesListProvider).value ?? const [];

    // Se o cartão padrão ainda não foi selecionado, pega o primeiro
    if (_selectedCardId == null && cards.isNotEmpty) {
      _selectedCardId = cards.first.id;
    }

    // Filtra categorias compatíveis com o tipo selecionado
    final filteredCategories = categories.where((c) {
      if (_selectedType == TransactionType.income) {
        return c.type == CategoryType.income;
      }
      if (_selectedType == TransactionType.expense) {
        return c.type == CategoryType.expense;
      }
      return false;
    }).toList();

    // Se a conta padrão ainda não foi selecionada, pega a primeira
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }
    if (_selectedType == TransactionType.transfer &&
        _selectedDestinationAccountId == null &&
        accounts.length > 1) {
      _selectedDestinationAccountId = accounts[1].id;
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Novo lançamento',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TransactionTypeSegmentedTab(
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                  _errorMessage = null;
                });
              },
            ),
            const SizedBox(height: 16),
            TransactionAmountHeroInput(
              controller: _amountController,
              transactionType: _selectedType,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.expense, width: 1),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.expense,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            // Descrição
            Text(
              'Descrição *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                hintText: _selectedType == TransactionType.transfer
                    ? 'Transferência entre contas'
                    : 'Ex: Supermercado, Salário, Farmácia...',
                prefixIcon: const Icon(Icons.edit_note, size: 20),
              ),
            ),
            const SizedBox(height: 14),

            // Contas
            if (_selectedType == TransactionType.transfer) ...[
              Text(
                'Conta de origem *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              _buildAccountDropdown(
                value: _selectedAccountId,
                accounts: accounts,
                onChanged: (id) => setState(() => _selectedAccountId = id),
              ),
              const SizedBox(height: 10),
              Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.swap_vert,
                    color: AppColors.primaryHighlight,
                  ),
                  tooltip: 'Inverter contas',
                  onPressed: () {
                    setState(() {
                      final temp = _selectedAccountId;
                      _selectedAccountId = _selectedDestinationAccountId;
                      _selectedDestinationAccountId = temp;
                    });
                  },
                ),
              ),
              Text(
                'Conta de destino *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              _buildAccountDropdown(
                value: _selectedDestinationAccountId,
                accounts: accounts,
                onChanged: (id) =>
                    setState(() => _selectedDestinationAccountId = id),
              ),
            ] else ...[
              if (_selectedType == TransactionType.expense) ...[
                Text(
                  'Forma de pagamento *',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPaymentMethodOption(
                          label: 'Conta Bancária',
                          icon: Icons.account_balance,
                          isSelected:
                              _paymentMethod == ExpensePaymentMethod.account,
                          onTap: () => setState(
                            () => _paymentMethod = ExpensePaymentMethod.account,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildPaymentMethodOption(
                          label: 'Cartão de Crédito',
                          icon: Icons.credit_card,
                          isSelected:
                              _paymentMethod == ExpensePaymentMethod.creditCard,
                          onTap: () => setState(() {
                            _paymentMethod = ExpensePaymentMethod.creditCard;
                            if (_selectedCardId == null && cards.isNotEmpty) {
                              _selectedCardId = cards.first.id;
                            }
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (_selectedType == TransactionType.expense &&
                  _paymentMethod == ExpensePaymentMethod.creditCard) ...[
                Text(
                  'Cartão de crédito *',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _buildCardDropdown(
                  value: _selectedCardId,
                  cards: cards,
                  onChanged: (id) => setState(() => _selectedCardId = id),
                ),
                const SizedBox(height: 14),
                Text(
                  'Parcelamento',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _buildInstallmentsDropdown(
                  selectedInstallments: _selectedInstallments,
                  amount:
                      Money.tryParse(_amountController.text) ??
                      const Money.zero(),
                  onChanged: (val) =>
                      setState(() => _selectedInstallments = val ?? 1),
                ),
                const SizedBox(height: 14),
              ] else ...[
                Text(
                  _selectedType == TransactionType.expense
                      ? 'Conta de débito *'
                      : 'Conta de crédito *',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _buildAccountDropdown(
                  value: _selectedAccountId,
                  accounts: accounts,
                  onChanged: (id) => setState(() => _selectedAccountId = id),
                ),
                const SizedBox(height: 14),
              ],
              // Categoria
              Text(
                'Categoria',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedCategoryId,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                  hintText: 'Selecione uma categoria (opcional)',
                ),
                items: filteredCategories.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (id) => setState(() => _selectedCategoryId = id),
              ),
            ],
            const SizedBox(height: 14),

            // Data
            TransactionDatePickerField(
              selectedDate: _selectedDate,
              onDateSelected: (d) => setState(() {
                _selectedDate = d;
                _isCompleted = !_isFutureDate(d);
              }),
            ),
            if (!_isCard) ...[
              const SizedBox(height: 14),
              TransactionStatusToggle(
                isCompleted: _isCompleted,
                isFutureDate: _isFutureDate(_selectedDate),
                type: _selectedType,
                onChanged: (val) => setState(() => _isCompleted = val),
              ),
            ],
            const SizedBox(height: 24),

            // Botão Salvar
            AppButton(
              label: switch (_selectedType) {
                TransactionType.income => 'Salvar receita',
                TransactionType.expense => 'Salvar despesa',
                TransactionType.transfer => 'Confirmar transferência',
              },
              icon: Icons.check_circle_outline,
              isLoading: _isLoading,
              onPressed: _handleSave,
            ),
            const SizedBox(height: 10),
            AppButton.outlined(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.primaryHighlight
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDropdown({
    required String? value,
    required List<CreditCard> cards,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      dropdownColor: AppColors.surface,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.credit_card, size: 20),
      ),
      items: cards.map((card) {
        final digits = card.lastFourDigits != null
            ? ' (Final ${card.lastFourDigits})'
            : '';
        return DropdownMenuItem(
          value: card.id,
          child: Text('${card.name}$digits'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInstallmentsDropdown({
    required int selectedInstallments,
    required Money amount,
    required ValueChanged<int?> onChanged,
  }) {
    final options = List.generate(12, (index) => index + 1);
    return DropdownButtonFormField<int>(
      isExpanded: true,
      initialValue: selectedInstallments,
      dropdownColor: AppColors.surface,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.splitscreen, size: 20),
      ),
      items: options.map((n) {
        if (n == 1) {
          return const DropdownMenuItem(
            value: 1,
            child: Text('1x à vista'),
          );
        }
        final installmentCents = (amount.cents / n).round();
        final installmentMoney = Money.fromCents(installmentCents);
        final valText = amount.isPositive
            ? ' (${installmentMoney.format()} /mês)'
            : '';
        return DropdownMenuItem(
          value: n,
          child: Text('${n}x parcelado$valText'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAccountDropdown({
    required String? value,
    required List<FinancialAccount> accounts,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      dropdownColor: AppColors.surface,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.account_balance, size: 20),
      ),
      items: accounts.map((acc) {
        return DropdownMenuItem(
          value: acc.id,
          child: Text('${acc.name} (${acc.type.displayName})'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
