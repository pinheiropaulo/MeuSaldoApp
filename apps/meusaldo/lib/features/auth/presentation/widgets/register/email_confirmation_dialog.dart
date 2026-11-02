import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Diálogo de orientação ao usuário após cadastro para confirmação de e-mail.
class EmailConfirmationDialog extends StatelessWidget {
  final String email;
  final VoidCallback onConfirm;

  const EmailConfirmationDialog({
    super.key,
    required this.email,
    required this.onConfirm,
  });

  /// Exibe o diálogo de confirmação de e-mail de forma modal.
  static Future<void> show(
    BuildContext context, {
    required String email,
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmailConfirmationDialog(
        email: email,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.primaryHighlight,
            size: 26,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Confirme seu E-mail',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conta criada com sucesso! 🎉',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enviamos um link de confirmação para:\n$email\n\nPor favor, verifique sua caixa de entrada (ou pasta de spam) para ativar sua conta antes de fazer o primeiro login.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          key: const Key('register_confirm_dialog_button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryHighlight,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Entendido, ir para Login'),
        ),
      ],
    );
  }
}
