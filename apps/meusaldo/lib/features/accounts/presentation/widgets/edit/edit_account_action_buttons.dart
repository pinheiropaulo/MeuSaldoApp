import 'package:flutter/material.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';

/// Botões de ação inferior (Salvar e Cancelar) da tela de edição de conta.
class EditAccountActionButtons extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const EditAccountActionButtons({
    super.key,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        AppButton(
          label: 'Salvar alterações',
          icon: Icons.check_circle,
          isLoading: isSaving,
          onPressed: onSave,
        ),
        const SizedBox(height: 10),
        AppButton.outlined(
          label: 'Cancelar',
          onPressed: onCancel,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
