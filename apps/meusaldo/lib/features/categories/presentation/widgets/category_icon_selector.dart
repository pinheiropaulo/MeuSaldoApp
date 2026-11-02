import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_visuals.dart';

/// Modelo de metadados de ícones selecionáveis para categorias.
class CategoryIconOption {
  final String keyName;
  final String label;

  const CategoryIconOption({
    required this.keyName,
    required this.label,
  });
}

/// Seletor em grade de ícones para personalização de categorias.
class CategoryIconSelector extends StatelessWidget {
  final String selectedIconKey;
  final ValueChanged<String> onIconSelected;

  const CategoryIconSelector({
    super.key,
    required this.selectedIconKey,
    required this.onIconSelected,
  });

  static const List<CategoryIconOption> options = [
    CategoryIconOption(keyName: 'restaurant', label: 'Alimentação'),
    CategoryIconOption(keyName: 'shopping_bag', label: 'Compras'),
    CategoryIconOption(keyName: 'home', label: 'Moradia'),
    CategoryIconOption(keyName: 'directions_car', label: 'Transporte'),
    CategoryIconOption(keyName: 'medical_services', label: 'Saúde'),
    CategoryIconOption(keyName: 'school', label: 'Educação'),
    CategoryIconOption(keyName: 'sports_esports', label: 'Lazer'),
    CategoryIconOption(keyName: 'work', label: 'Salário'),
    CategoryIconOption(keyName: 'flight', label: 'Viagem'),
    CategoryIconOption(keyName: 'pets', label: 'Animais'),
    CategoryIconOption(keyName: 'receipt_long', label: 'Boletos'),
    CategoryIconOption(keyName: 'savings', label: 'Investimentos'),
    CategoryIconOption(keyName: 'fitness_center', label: 'Academia'),
    CategoryIconOption(keyName: 'local_cafe', label: 'Café & Bares'),
    CategoryIconOption(keyName: 'subscriptions', label: 'Assinaturas'),
    CategoryIconOption(keyName: 'card_giftcard', label: 'Presentes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ícone da categoria',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final opt = options[index];
              final isSelected = opt.keyName == selectedIconKey;
              final icon = CategoryVisuals.iconFromKey(opt.keyName);

              return InkWell(
                key: Key('category_icon_${opt.keyName}'),
                borderRadius: BorderRadius.circular(8),
                onTap: () => onIconSelected(opt.keyName),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandPrimary : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryHighlight
                          : AppColors.outline.withValues(alpha: 0.5),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected ? AppColors.primaryHighlight : AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
