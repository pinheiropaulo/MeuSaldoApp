import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Grade de seleção de bandeira do cartão de crédito (Mastercard, Visa, Elo, Outra).
class CardBrandSelector extends StatelessWidget {
  final String selectedBrand;
  final ValueChanged<String> onBrandChanged;

  const CardBrandSelector({
    super.key,
    required this.selectedBrand,
    required this.onBrandChanged,
  });

  @override
  Widget build(BuildContext context) {
    const brands = [
      ('mastercard', 'Mastercard'),
      ('visa', 'Visa'),
      ('elo', 'Elo / Outra'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bandeira do Cartão',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: brands.map((item) {
            final isSelected = selectedBrand.toLowerCase() == item.$1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onBrandChanged(item.$1),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceElevated
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryHighlight
                            : AppColors.outline,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
