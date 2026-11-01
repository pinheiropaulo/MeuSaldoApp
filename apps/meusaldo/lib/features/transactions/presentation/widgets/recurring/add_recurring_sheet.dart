import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/state/recurring_transaction_providers.dart';
import 'package:meusaldo/shared/formatters/currency_input_formatter.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Modal bottom sheet para cadastrar uma nova recorrência ou assinatura.
class AddRecurringSheet extends ConsumerStatefulWidget {
  const AddRecurringSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddRecurringSheet(),
    );
  }

  @override
  ConsumerState<AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends ConsumerState<AddRecurringSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _billingDayController;

  TransactionType _selectedType = TransactionType.expense;
  RecurrenceCategory _selectedCategory = RecurrenceCategory.subscription;
  RecurrenceFrequency _selectedFrequency = RecurrenceFrequency.monthly;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController(text: '0,00');
    _billingDayController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _billingDayController.dispose();
    super.dispose();
  }

  void _saveRecurring() {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();
    final cents = CurrencyInputFormatter.parseCents(_amountController.text);
    if (cents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um valor maior que zero.'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final day = int.tryParse(_billingDayController.text.trim()) ?? 10;
    final id = 'rec-${DateTime.now().millisecondsSinceEpoch}';

    final newRecurring = RecurringTransaction.create(
      id: id,
      description: description,
      amount: Money.fromCents(cents),
      type: _selectedType,
      category: _selectedCategory,
      frequency: _selectedFrequency,
      billingDay: day.clamp(1, 31),
      billingDayDescription: 'Todo dia ${day.toString().padLeft(2, '0')}',
      iconKey: _selectedType == TransactionType.income
          ? 'account_balance_wallet'
          : (_selectedCategory == RecurrenceCategory.subscription ? 'movie' : 'key'),
    );

    ref.read(recurringListProvider.notifier).addRecurring(newRecurring);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recorrência "$description" cadastrada com sucesso!'),
        backgroundColor: AppColors.income,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cadastrar Recorrência',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Assinatura ou lançamento fixo',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTypeSelector(),
                const SizedBox(height: 14),
                _buildDescriptionField(),
                const SizedBox(height: 14),
                _buildAmountField(),
                const SizedBox(height: 14),
                _buildFrequencyAndDayFields(),
                const SizedBox(height: 14),
                _buildCategoryDropdown(),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Salvar Recorrência',
                  onPressed: _saveRecurring,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final isExpense = _selectedType == TransactionType.expense;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedType = TransactionType.expense;
                  if (_selectedCategory == RecurrenceCategory.income) {
                    _selectedCategory = RecurrenceCategory.subscription;
                  }
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isExpense ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: isExpense ? AppColors.expense : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Despesa',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isExpense ? FontWeight.bold : FontWeight.normal,
                        color: isExpense ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedType = TransactionType.income;
                  _selectedCategory = RecurrenceCategory.income;
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !isExpense ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: !isExpense ? AppColors.income : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Receita',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !isExpense ? FontWeight.bold : FontWeight.normal,
                        color: !isExpense ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição do Lançamento',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _descriptionController,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Ex: Netflix, Aluguel, Plano de Saúde...',
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe uma descrição' : null,
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valor Estimado (R\$)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                'R\$',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyAndDayFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequência',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<RecurrenceFrequency>(
                initialValue: _selectedFrequency,
                dropdownColor: AppColors.surfaceElevated,
                items: RecurrenceFrequency.values.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f.label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedFrequency = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dia da Cobrança',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _billingDayController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 31) return 'Dia 1 a 31';
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final availableCategories = _selectedType == TransactionType.income
        ? [RecurrenceCategory.income]
        : [RecurrenceCategory.subscription, RecurrenceCategory.fixedExpense];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<RecurrenceCategory>(
          initialValue: _selectedCategory,
          dropdownColor: AppColors.surfaceElevated,
          items: availableCategories.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(c.label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ],
    );
  }
}
