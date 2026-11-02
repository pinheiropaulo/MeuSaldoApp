import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_visuals.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Item visual de uma categoria financeira dentro da listagem.
class CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = CategoryVisuals.colorForCategory(category);
    final icon = CategoryVisuals.iconForCategory(category);
    final subtitle = category.description?.isNotEmpty == true
        ? category.description!
        : (category.type == CategoryType.expense
            ? 'Despesa'
            : (category.type == CategoryType.income ? 'Receita' : 'Ambas'));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar com ícone e cor temática da categoria
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Informações textuais (Nome e Descrição)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Botão de Edição
              IconButton(
                icon: const Icon(
                  Icons.edit_note,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
