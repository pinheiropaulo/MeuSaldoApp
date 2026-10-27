import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Bloco de atalhos rápidos para registro de despesas, receitas e transferências.
class HomeQuickActions extends StatelessWidget {
  /// Callback ao acionar nova despesa.
  final VoidCallback onExpenseTap;

  /// Callback ao acionar nova receita.
  final VoidCallback onIncomeTap;

  /// Callback ao acionar nova transferência entre contas.
  final VoidCallback onTransferTap;

  const HomeQuickActions({
    super.key,
    required this.onExpenseTap,
    required this.onIncomeTap,
    required this.onTransferTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Movimentar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Despesa',
                icon: Icons.remove_circle_outline,
                color: const Color(0xFFFFB1B1),
                onTap: onExpenseTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: 'Receita',
                icon: Icons.add_circle_outline,
                color: const Color(0xFF82D8A9),
                onTap: onIncomeTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: 'Transferir',
                icon: Icons.swap_horiz,
                color: const Color(0xFF8EB5FF),
                onTap: onTransferTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
