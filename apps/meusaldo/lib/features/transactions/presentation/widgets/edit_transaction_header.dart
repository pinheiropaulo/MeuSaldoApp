import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';

/// Cabeçalho da tela de edição de lançamento com botão de fechar e exclusão rápida.
class EditTransactionHeader extends StatelessWidget {
  const EditTransactionHeader({
    super.key,
    required this.onDelete,
    this.isDeleting = false,
  });

  final Future<void> Function() onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(width: 4),
            Text(
              'Editar lançamento',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        if (isDeleting)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.expense),
            ),
          )
        else
          IconButton(
            key: const Key('edit_transaction_delete_button'),
            icon: const Icon(Icons.delete_outline, color: AppColors.expense),
            tooltip: 'Excluir lançamento',
            onPressed: () async {
              final confirmed = await showAppConfirmationDialog(
                context: context,
                title: 'Excluir lançamento?',
                message:
                    'Esta movimentação será permanentemente excluída e o saldo da conta será recalculado.',
                confirmLabel: 'Excluir',
                isDestructive: true,
              );
              if (confirmed == true) {
                await onDelete();
              }
            },
          ),
      ],
    );
  }
}
