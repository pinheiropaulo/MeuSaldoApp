import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';

/// Widget de estado vazio padronizado conforme protótipos do MeuSaldo.
class EmptyStateWidget extends StatelessWidget {
  /// Ícone central representativo do estado vazio.
  final IconData icon;

  /// Título explicativo (ex: "Nenhum lançamento encontrado").
  final String title;

  /// Descrição detalhada ou mensagem orientando a primeira ação.
  final String description;

  /// Texto do botão de ação principal (opcional).
  final String? actionLabel;

  /// Callback do botão de ação (opcional).
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Círculo com ícone destacado
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.outline,
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 32,
                  color: AppColors.brandHighlight,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: actionLabel!,
                onPressed: onActionPressed,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
