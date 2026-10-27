import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';

/// Exibe um modal bottom sheet padronizado com cantos superiores arredondados de 16px
/// e alça de arraste superior.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Alça de arraste
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Flexible(child: builder(ctx)),
        ],
      ),
    ),
  );
}

/// Exibe um diálogo de confirmação explícita para ações importantes ou destrutivas.
Future<bool> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline, width: 1),
      ),
      title: Text(
        title,
        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.expense : AppColors.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton.outlined(
                label: cancelLabel,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isDestructive
                  ? AppButton.destructive(
                      label: confirmLabel,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    )
                  : AppButton(
                      label: confirmLabel,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
            ),
          ],
        ),
      ],
    ),
  );

  return result ?? false;
}
