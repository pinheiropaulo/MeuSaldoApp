import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_visuals.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card interativo de pré-visualização em tempo real de uma categoria no extrato.
class CategoryPreviewCard extends StatelessWidget {
  final String name;
  final CategoryType type;
  final String iconKey;
  final String colorHex;

  const CategoryPreviewCard({
    super.key,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorHex,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.tryParse(colorHex.replaceAll('#', '0xFF')) ?? 0xFFF04444);
    final icon = CategoryVisuals.iconFromKey(iconKey);
    final displayName = name.trim().isNotEmpty ? name.trim() : 'Nome da categoria';
    final isExpense = type == CategoryType.expense;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pré-visualização no extrato',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.income,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Tempo real',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.income,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                // Avatar com a cor e ícone selecionados
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Nome e detalhe
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Hoje às 14:30 • Exemplo',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Valor simulado
                Text(
                  isExpense ? '- R\$ 142,80' : '+ R\$ 2.500,00',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isExpense ? AppColors.expense : AppColors.income,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
