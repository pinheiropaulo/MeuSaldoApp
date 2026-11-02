import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_visuals.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Modal bottom sheet para seleção visual de categoria com busca,
/// alternador de abas e atalho para criação rápida de categoria.
class CategoryPickerSheet extends ConsumerStatefulWidget {
  final String? selectedCategoryId;
  final CategoryType? initialType;

  const CategoryPickerSheet({
    super.key,
    this.selectedCategoryId,
    this.initialType,
  });

  /// Exibe o seletor modal e retorna a [Category] selecionada ou nulo se cancelado.
  static Future<Category?> show(
    BuildContext context, {
    String? selectedCategoryId,
    CategoryType? initialType,
  }) {
    return showAppBottomSheet<Category>(
      context: context,
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: selectedCategoryId,
        initialType: initialType,
      ),
    );
  }

  @override
  ConsumerState<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  late CategoryType _currentType;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType ?? CategoryType.expense;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final allCategories = categoriesAsync.value ?? [];

    final expenseList = allCategories
        .where((c) => c.isCompatibleWith(TransactionType.expense))
        .toList();
    final incomeList = allCategories
        .where((c) => c.isCompatibleWith(TransactionType.income))
        .toList();

    final activeList = _currentType == CategoryType.expense ? expenseList : incomeList;
    final filtered = activeList.where((c) {
      if (_searchQuery.trim().isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final nameMatches = c.name.toLowerCase().contains(query);
      final descMatches = c.description?.toLowerCase().contains(query) ?? false;
      return nameMatches || descMatches;
    }).toList();

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Selecionar Categoria',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton.icon(
                    key: const Key('category_picker_new_button'),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryHighlight,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nova', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      CategoryFormSheet.show(
                        context,
                        defaultType: _currentType,
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.outline),

            // Segmented Control (Despesas vs Receitas)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        key: const Key('category_picker_tab_expense'),
                        title: 'Despesas',
                        count: expenseList.length,
                        color: AppColors.expense,
                        isSelected: _currentType == CategoryType.expense,
                        onTap: () => setState(() => _currentType = CategoryType.expense),
                      ),
                    ),
                    Expanded(
                      child: _buildTypeButton(
                        key: const Key('category_picker_tab_income'),
                        title: 'Receitas',
                        count: incomeList.length,
                        color: AppColors.income,
                        isSelected: _currentType == CategoryType.income,
                        onTap: () => setState(() => _currentType = CategoryType.income),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                key: const Key('category_picker_search_input'),
                controller: _searchController,
                onChanged: (q) => setState(() => _searchQuery = q),
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome da categoria...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Category List
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Nenhuma categoria encontrada para "$_searchQuery".'
                              : 'Nenhuma categoria cadastrada.',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final cat = filtered[index];
                        final isSelected = cat.id == widget.selectedCategoryId;
                        final color = CategoryVisuals.colorForCategory(cat);
                        final icon = CategoryVisuals.iconForCategory(cat);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: Key('category_picker_item_${cat.id}'),
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).pop(cat),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryHighlight
                                      : AppColors.outline,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: color.withValues(alpha: 0.3)),
                                    ),
                                    child: Icon(icon, color: color, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (cat.description?.isNotEmpty == true)
                                          Text(
                                            cat.description!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primaryHighlight,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required Key key,
    required String title,
    required int count,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppColors.outline) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
