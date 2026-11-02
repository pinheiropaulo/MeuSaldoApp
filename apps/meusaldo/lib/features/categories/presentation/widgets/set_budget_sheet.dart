import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_visuals.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Modal bottom sheet para definir ou alterar o teto de gastos mensal de uma categoria.
class SetBudgetSheet extends ConsumerStatefulWidget {
  final Category? initialCategory;

  const SetBudgetSheet({
    super.key,
    this.initialCategory,
  });

  /// Exibe o modal na tela de forma padronizada.
  static Future<void> show(
    BuildContext context, {
    Category? category,
  }) {
    return showAppBottomSheet(
      context: context,
      builder: (_) => SetBudgetSheet(initialCategory: category),
    );
  }

  @override
  ConsumerState<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends ConsumerState<SetBudgetSheet> {
  late Category? _selectedCategory;
  late final TextEditingController _amountController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    final existingBudget = widget.initialCategory?.monthlyBudget;
    if (existingBudget != null && !existingBudget.isZero) {
      final reais = (existingBudget.cents / 100).toStringAsFixed(2).replaceAll('.', ',');
      _amountController = TextEditingController(text: reais);
    } else {
      _amountController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Money? _parseAmount() {
    final cleanText = _amountController.text.replaceAll('.', '').replaceAll(',', '.').trim();
    if (cleanText.isEmpty) return null;
    final value = double.tryParse(cleanText);
    if (value == null || value <= 0) return null;
    return Money.fromCents((value * 100).round());
  }

  Future<void> _handleSave() async {
    final category = _selectedCategory;
    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria para definir o teto.')),
      );
      return;
    }

    final budget = _parseAmount();
    if (budget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor de teto válido maior que zero.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final updated = category.copyWith(monthlyBudget: budget);
    final result = await ref.read(categoriesListProvider.notifier).updateCategory(updated);
    setState(() => _isLoading = false);

    if (mounted) {
      result.when(
        onSuccess: (_) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Teto de gastos de ${category.name} definido com sucesso!')),
          );
        },
        onFailure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar teto: ${failure.message}')),
          );
        },
      );
    }
  }

  Future<void> _handleRemoveBudget() async {
    final category = _selectedCategory;
    if (category == null) return;

    setState(() => _isLoading = true);
    final updated = category.copyWith(clearBudget: true);
    final result = await ref.read(categoriesListProvider.notifier).updateCategory(updated);
    setState(() => _isLoading = false);

    if (mounted) {
      result.when(
        onSuccess: (_) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Teto de ${category.name} removido com sucesso.')),
          );
        },
        onFailure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${failure.message}')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(expenseCategoriesProvider);
    final currentCat = _selectedCategory;
    final hasBudget = currentCat?.monthlyBudget != null && !currentCat!.monthlyBudget!.isZero;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasBudget ? 'Ajustar Teto de Gastos' : 'Definir Teto de Gastos',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Text(
            'Controle de orçamento mensal por categoria',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          if (widget.initialCategory == null) ...[
            Text(
              'Categoria',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Category>(
              key: const Key('set_budget_category_select'),
              initialValue: _selectedCategory,
              dropdownColor: AppColors.surface,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined, size: 20),
                hintText: 'Selecione a categoria',
              ),
              items: categories.map((cat) {
                final icon = CategoryVisuals.iconForCategory(cat);
                final color = CategoryVisuals.colorForCategory(cat);
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 18),
                      const SizedBox(width: 10),
                      Text(cat.name, style: const TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (cat) {
                setState(() {
                  _selectedCategory = cat;
                  if (cat?.monthlyBudget != null && !cat!.monthlyBudget!.isZero) {
                    final reais = (cat.monthlyBudget!.cents / 100).toStringAsFixed(2).replaceAll('.', ',');
                    _amountController.text = reais;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
          ] else if (currentCat != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: CategoryVisuals.colorForCategory(currentCat).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CategoryVisuals.iconForCategory(currentCat),
                      color: CategoryVisuals.colorForCategory(currentCat),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentCat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          currentCat.description ?? 'Categoria de despesa',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            'Limite Mensal Planejado (R\$)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('set_budget_amount_input'),
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+[\,\.]?\d{0,2}')),
            ],
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              prefixText: 'R\$ ',
              prefixStyle: TextStyle(
                fontFamily: 'JetBrains Mono',
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
              hintText: '0,00',
            ),
          ),
          const SizedBox(height: 24),

          AppButton(
            key: const Key('set_budget_save_button'),
            label: 'Salvar Teto Orçamentário',
            isLoading: _isLoading,
            onPressed: _handleSave,
          ),

          if (hasBudget) ...[
            const SizedBox(height: 12),
            AppButton(
              key: const Key('set_budget_remove_button'),
              label: 'Remover Teto desta Categoria',
              variant: AppButtonVariant.outlined,
              isLoading: _isLoading,
              onPressed: _handleRemoveBudget,
            ),
          ],
        ],
      ),
    );
  }
}
