import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_color_selector.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_icon_selector.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_preview_card.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_type_segmented_bar.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Modal bottom sheet para criação e edição de categorias financeiras.
class CategoryFormSheet extends ConsumerStatefulWidget {
  final Category? category;
  final CategoryType defaultType;

  const CategoryFormSheet({
    super.key,
    this.category,
    this.defaultType = CategoryType.expense,
  });

  static Future<void> show(
    BuildContext context, {
    Category? category,
    CategoryType defaultType = CategoryType.expense,
  }) {
    return showAppBottomSheet(
      context: context,
      builder: (_) => CategoryFormSheet(
        category: category,
        defaultType: defaultType,
      ),
    );
  }

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late CategoryType _type;
  late String _iconKey;
  late String _colorHex;
  bool _isLoading = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _type = widget.category?.type ?? widget.defaultType;
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descController = TextEditingController(text: widget.category?.description ?? '');
    _iconKey = widget.category?.iconKey ?? (_type == CategoryType.expense ? 'restaurant' : 'work');
    _colorHex = widget.category?.colorHex ?? (_type == CategoryType.expense ? '#F04444' : '#22A06B');
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da categoria.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = _isEditing
        ? await ref.read(categoriesListProvider.notifier).updateCategory(
              widget.category!.copyWith(
                name: name,
                type: _type,
                iconKey: _iconKey,
                colorHex: _colorHex,
                description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
              ),
            )
        : await ref.read(categoriesListProvider.notifier).addCategory(
              Category.create(
                id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                type: _type,
                iconKey: _iconKey,
                colorHex: _colorHex,
                description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
              ),
            );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Categoria atualizada com sucesso!' : 'Categoria criada com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failureOrNull?.message ?? 'Erro ao salvar categoria.')),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Excluir categoria?',
      message: 'Esta ação não poderá ser desfeita. Lançamentos associados manterão seu histórico.',
      confirmLabel: 'Excluir',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final res = await ref.read(categoriesListProvider.notifier).deleteCategory(widget.category!.id);
      if (mounted && res.isSuccess) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoria excluída com sucesso.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _isEditing ? 'Editar Categoria' : 'Nova Categoria',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 12),
          CategoryTypeSegmentedBar(
            selectedType: _type,
            expenseCount: _type == CategoryType.expense ? 1 : 0,
            incomeCount: _type == CategoryType.income ? 1 : 0,
            onTypeChanged: (t) => setState(() {
              _type = t;
              if (!_isEditing) {
                _iconKey = t == CategoryType.expense ? 'restaurant' : 'work';
                _colorHex = t == CategoryType.expense ? '#F04444' : '#22A06B';
              }
            }),
          ),
          const SizedBox(height: 14),
          CategoryPreviewCard(name: _nameController.text, type: _type, iconKey: _iconKey, colorHex: _colorHex),
          const SizedBox(height: 14),
          TextField(
            key: const Key('category_form_name_field'),
            controller: _nameController,
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: 'Nome da categoria *',
              hintText: 'Ex: Alimentação, Moradia, Salário...',
            ),
          ),
          const SizedBox(height: 10),
          CategoryIconSelector(selectedIconKey: _iconKey, onIconSelected: (k) => setState(() => _iconKey = k)),
          const SizedBox(height: 14),
          CategoryColorSelector(selectedColorHex: _colorHex, onColorSelected: (c) => setState(() => _colorHex = c)),
          const SizedBox(height: 20),
          AppButton(
            key: const Key('category_form_save_button'),
            label: _isEditing ? 'Salvar Alterações' : 'Criar Categoria',
            isLoading: _isLoading,
            onPressed: _handleSave,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              key: const Key('category_form_delete_button'),
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Excluir Categoria'),
              onPressed: _handleDelete,
            ),
          ],
        ],
      ),
    );
  }
}
