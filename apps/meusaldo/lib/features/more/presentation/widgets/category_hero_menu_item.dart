import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Item em destaque na Aba Mais para gerenciamento e pré-visualização de categorias.
class CategoryHeroMenuItem extends StatelessWidget {
  final int totalCategories;
  final VoidCallback onTap;

  const CategoryHeroMenuItem({
    super.key,
    required this.totalCategories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('more_categories_hero_item'),
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ícone em destaque
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryHighlight.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    color: AppColors.primaryHighlight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Textos descritivos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categorias',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalCategories categorias ativas (Alimentação, Moradia, Salário...)',
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

                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Badges semânticas de pré-visualização
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildCategoryBadge(
                  label: 'Salário',
                  color: AppColors.income,
                ),
                _buildCategoryBadge(
                  label: 'Alimentação',
                  color: AppColors.expense,
                ),
                _buildCategoryBadge(
                  label: 'Transporte',
                  color: AppColors.transfer,
                ),
                _buildCategoryBadge(
                  label: 'Moradia',
                  color: const Color(0xFFF59E0B),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${totalCategories > 4 ? totalCategories - 4 : 8} mais',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
