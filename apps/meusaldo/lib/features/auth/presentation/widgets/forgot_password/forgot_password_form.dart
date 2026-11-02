import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';

/// Formulário simples para envio do e-mail de recuperação de senha.
class ForgotPasswordForm extends StatefulWidget {
  final bool isLoading;
  final ValueChanged<String> onSubmit;

  const ForgotPasswordForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      widget.onSubmit(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'E-mail cadastrado',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('forgot_password_email_field'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.mail_outline, size: 20),
            hintText: 'exemplo@email.com',
          ),
        ),
        const SizedBox(height: 18),
        AppButton(
          key: const Key('forgot_password_submit_button'),
          label: 'Enviar instruções',
          icon: Icons.send,
          isLoading: widget.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
