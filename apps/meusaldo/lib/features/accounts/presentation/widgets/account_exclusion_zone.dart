import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';

/// Painel de zona de perigo para exclusão segura de uma conta financeira.
class AccountExclusionZone extends StatelessWidget {
  /// Indica se a exclusão está em processamento.
  final bool isLoading;

  /// Callback disparado ao acionar o botão de exclusão.
  final VoidCallback onDelete;

  const AccountExclusionZone({
    super.key,
    required this.isLoading,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.expense.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.expense,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Zona de exclusão',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'A exclusão removerá esta conta do aplicativo.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          AppButton.destructive(
            label: 'Excluir conta',
            icon: Icons.delete_outline,
            isLoading: isLoading,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
