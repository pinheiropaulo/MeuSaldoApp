import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/categories_empty_state.dart';
import 'package:meusaldo/features/categories/presentation/widgets/categories_search_bar.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_list_item.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_type_segmented_bar.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Tela orquestradora para visualização e gerenciamento de categorias financeiras.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchController = TextEditingController();
  CategoryType _selectedType = CategoryType.expense;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleOpenForm([Category? category]) =>
      CategoryFormSheet.show(context, category: category, defaultType: _selectedType);

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final allCategories = categoriesAsync.value ?? [];

    final isExp = _selectedType == CategoryType.expense;
    final expType = TransactionType.expense;
    final incType = TransactionType.income;
    final expenseCount = allCategories.where((c) => c.isCompatibleWith(expType)).length;
    final incomeCount = allCategories.where((c) => c.isCompatibleWith(incType)).length;
    final typeCategories = allCategories.where((c) => c.isCompatibleWith(isExp ? expType : incType)).toList();

    final filtered = typeCategories.where((c) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) || (c.description?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Categorias'),
        actions: [
          IconButton(
            key: const Key('categories_budgets_button'),
            icon: const Icon(Icons.track_changes, color: AppColors.primaryHighlight, size: 20),
            tooltip: 'Orçamentos & Tetos',
            onPressed: () => context.push(AppRoutes.budgets),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: TextButton.icon(
              key: const Key('categories_new_button'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nova', style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: _handleOpenForm,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoriesSearchBar(
                  controller: _searchController,
                  onChanged: (q) => setState(() => _searchQuery = q),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
                const SizedBox(height: 12),
                CategoryTypeSegmentedBar(
                  selectedType: _selectedType,
                  expenseCount: expenseCount,
                  incomeCount: incomeCount,
                  onTypeChanged: (t) => setState(() => _selectedType = t),
                ),
                const SizedBox(height: 8),
                Text('${filtered.length} categorias cadastradas', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? CategoriesEmptyState(
                    selectedType: _selectedType,
                    searchQuery: _searchQuery,
                    onCreateCategory: () => _handleOpenForm(),
                    onClearSearch: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (int i = 0; i < filtered.length; i++) ...[
                              CategoryListItem(
                                category: filtered[i],
                                onTap: () => context.push('/categories/${filtered[i].id}'),
                                onEdit: () => _handleOpenForm(filtered[i]),
                              ),
                              if (i < filtered.length - 1)
                                const Divider(color: AppColors.outline, height: 1),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
