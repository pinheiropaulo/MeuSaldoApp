import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Cabeçalho padronizado do formulário modal de contas com título, botão fechar e dica informativa.
class AccountFormHeader extends StatelessWidget {
  /// Indica se o formulário está em modo de edição ou criação.
  final bool isEditing;

  /// Callback para fechar o modal.
  final VoidCallback onClose;

  const AccountFormHeader({
    super.key,
    required this.isEditing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEditing ? 'Editar conta' : 'Nova conta',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primaryHighlight,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEditing
                      ? 'Altere o nome e o tipo mantendo o histórico de lançamentos.'
                      : 'Cadastre suas contas para monitorar lançamentos e saldos reais em tempo real.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
