import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Seletor de cores da paleta oficial do MeuSaldo para categorias.
class CategoryColorSelector extends StatelessWidget {
  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;

  const CategoryColorSelector({
    super.key,
    required this.selectedColorHex,
    required this.onColorSelected,
  });

  static const List<String> palette = [
    '#6D1834', // Bordô MeuSaldo
    '#F04444', // Vermelho Despesa
    '#22A06B', // Verde Receita
    '#4C8DFF', // Azul Neutro
    '#F2C94C', // Amarelo Alerta
    '#7B61FF', // Roxo Estilo
    '#FF8C42', // Laranja
    '#06B6D4', // Ciano
    '#5A525B', // Cinza Neutro
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cor do marcador',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: palette.map((hex) {
              final isSelected = hex.toUpperCase() == selectedColorHex.toUpperCase();
              final color = Color(int.parse(hex.replaceAll('#', '0xFF')));

              return InkWell(
                key: Key('category_color_$hex'),
                borderRadius: BorderRadius.circular(16),
                onTap: () => onColorSelected(hex),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : AppColors.outline,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
