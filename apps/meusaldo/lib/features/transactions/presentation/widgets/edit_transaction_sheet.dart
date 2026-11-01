import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/edit_transaction_fields.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/edit_transaction_header.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/edit_transaction_hint_banner.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_amount_hero_input.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_date_picker_field.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_type_segmented_tab.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Modal bottom sheet para visualização e edição detalhada de lançamentos existentes.
class EditTransactionSheet extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditTransactionSheet({super.key, required this.transaction});

  static Future<bool?> show(BuildContext context, {required Transaction transaction}) {
    return showAppBottomSheet<bool>(
      context: context,
      builder: (_) => EditTransactionSheet(transaction: transaction),
    );
  }

  @override
  ConsumerState<EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<EditTransactionSheet> {
  late TransactionType _selectedType;
  late final TextEditingController _amountController;
  late final TextEditingController _descController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  String? _selectedAccountId;
  String? _selectedDestinationAccountId;
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    _selectedType = tx.type;
    _amountController = TextEditingController(text: tx.amount.format(includeSymbol: false));
    _descController = TextEditingController(text: tx.description);
    _notesController = TextEditingController(text: tx.notes ?? '');
    _selectedDate = tx.date;
    _selectedAccountId = tx.accountId;
    _selectedDestinationAccountId = tx.destinationAccountId;
    _selectedCategoryId = tx.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final parsed = Money.tryParse(_amountController.text);
    if (parsed == null || !parsed.isPositive || _descController.text.trim().isEmpty || _selectedAccountId == null) {
      setState(() => _errorMessage = 'Preencha todos os campos obrigatórios corretamente.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    final updated = widget.transaction.copyWith(
      type: _selectedType,
      amount: parsed,
      description: _descController.text.trim(),
      date: _selectedDate,
      accountId: _selectedAccountId,
      destinationAccountId: _selectedType == TransactionType.transfer ? _selectedDestinationAccountId : null,
      categoryId: _selectedType != TransactionType.transfer ? _selectedCategoryId : null,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );
    final res = await ref.read(transactionsListProvider.notifier).updateTransaction(updated);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (res.isSuccess) { Navigator.of(context).pop(true); } else {
      setState(() => _errorMessage = res.failureOrNull?.message ?? 'Erro ao salvar.');
    }
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    final res = await ref.read(transactionsListProvider.notifier).deleteTransaction(widget.transaction.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    if (res.isSuccess) { Navigator.of(context).pop(true); } else {
      setState(() => _errorMessage = res.failureOrNull?.message ?? 'Erro ao excluir.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsListProvider).value ?? const [];
    final categories = ref.watch(categoriesListProvider).value ?? const [];
    final filteredCategories = categories.where((c) => _selectedType == TransactionType.income ? c.type == CategoryType.income : c.type == CategoryType.expense).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EditTransactionHeader(onDelete: _handleDelete, isDeleting: _isDeleting),
            const SizedBox(height: 12),
            TransactionTypeSegmentedTab(selectedType: _selectedType, onTypeChanged: (t) => setState(() => _selectedType = t)),
            const SizedBox(height: 16),
            TransactionAmountHeroInput(controller: _amountController, transactionType: _selectedType),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.expense, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            EditTransactionFields(
              descController: _descController,
              notesController: _notesController,
              selectedType: _selectedType,
              accounts: accounts,
              categories: filteredCategories,
              selectedAccountId: _selectedAccountId,
              selectedDestinationAccountId: _selectedDestinationAccountId,
              selectedCategoryId: _selectedCategoryId,
              onAccountChanged: (v) => setState(() => _selectedAccountId = v),
              onDestinationAccountChanged: (v) => setState(() => _selectedDestinationAccountId = v),
              onCategoryChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
            const SizedBox(height: 14),
            TransactionDatePickerField(selectedDate: _selectedDate, onDateSelected: (d) => setState(() => _selectedDate = d)),
            const SizedBox(height: 16),
            const EditTransactionHintBanner(),
            const SizedBox(height: 20),
            AppButton(key: const Key('edit_transaction_submit_button'), label: 'Salvar alterações', isLoading: _isLoading, onPressed: _handleSave),
            const SizedBox(height: 10),
            AppButton.outlined(label: 'Cancelar', onPressed: () => Navigator.of(context).pop(false)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
