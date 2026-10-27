import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

enum AppButtonVariant {
  primary,
  outlined,
  destructive,
}

/// Botão padrão do MeuSaldo com alvo de toque mínimo de 48px e raio de 8px.
class AppButton extends StatelessWidget {
  /// Texto do botão.
  final String label;

  /// Callback de clique. Se nulo, o botão fica desabilitado.
  final VoidCallback? onPressed;

  /// Variante visual do botão.
  final AppButtonVariant variant;

  /// Ícone opcional exibido antes do texto.
  final IconData? icon;

  /// Indica se uma operação assíncrona está em andamento.
  final bool isLoading;

  /// Se o botão deve expandir horizontalmente para ocupar toda a largura.
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  }) : variant = AppButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    final childWidget = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.textPrimary,
              ),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final buttonStyle = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.surfaceElevated,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: Size(fullWidth ? double.infinity : 48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      AppButtonVariant.outlined => OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: Size(fullWidth ? double.infinity : 48, 48),
        side: const BorderSide(
          color: AppColors.outline,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      AppButtonVariant.destructive => ElevatedButton.styleFrom(
        backgroundColor: AppColors.expense,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.surfaceElevated,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: Size(fullWidth ? double.infinity : 48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    };

    if (variant == AppButtonVariant.outlined) {
      return OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: buttonStyle,
        child: childWidget,
      );
    }

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: buttonStyle,
      child: childWidget,
    );
  }
}
