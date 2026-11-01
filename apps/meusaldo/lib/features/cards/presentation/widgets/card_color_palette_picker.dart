import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Paleta circular de seleção de cores para personalização visual do cartão.
class CardColorPalettePicker extends StatelessWidget {
  final String selectedColorHex;
  final ValueChanged<String> onColorChanged;

  const CardColorPalettePicker({
    super.key,
    required this.selectedColorHex,
    required this.onColorChanged,
  });

  static const List<(String, Color)> palette = [
    ('#820AD1', Color(0xFF820AD1)), // Nubank Purple
    ('#EC7000', Color(0xFFEC7000)), // Itaú Orange
    ('#6D1834', Color(0xFF6D1834)), // MeuSaldo Burgundy
    ('#00497E', Color(0xFF00497E)), // Banking Blue
    ('#2E2830', Color(0xFF2E2830)), // Black / Graphite
    ('#22A06B', Color(0xFF22A06B)), // Income Green
  ];

  @override
  Widget build(BuildContext context) {
    final normalizedSelected = selectedColorHex.toUpperCase().trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cor de Identificação',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: palette.map((entry) {
            final hex = entry.$1.toUpperCase();
            final color = entry.$2;
            final isSelected = normalizedSelected == hex;

            return InkWell(
              onTap: () => onColorChanged(entry.$1),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryHighlight
                        : AppColors.outline,
                    width: isSelected ? 2.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
