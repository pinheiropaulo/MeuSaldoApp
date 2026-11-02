import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/auth/presentation/widgets/register/password_requirements_card.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';

/// Formulário de cadastro de novo usuário com validação de senha e campos.
class RegisterForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String name, String email, String password) onSubmit;
  final ValueChanged<String?> onErrorChanged;

  const RegisterForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onErrorChanged,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _currentPassword = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (mounted) {
        setState(() => _currentPassword = _passwordController.text);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty) {
      widget.onErrorChanged('Informe seu nome completo.');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      widget.onErrorChanged('Informe um endereço de e-mail válido.');
      return;
    }

    if (password.length < 8) {
      widget.onErrorChanged('A senha deve possuir no mínimo 8 caracteres.');
      return;
    }

    if (password != confirm) {
      widget.onErrorChanged('As senhas não coincidem. Digite novamente.');
      return;
    }

    widget.onErrorChanged(null);
    widget.onSubmit(name, email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo 1: Nome Completo
        const Text(
          'Nome completo',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('register_name_field'),
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline, size: 20),
            hintText: 'Como gostaria de ser chamado?',
          ),
        ),
        const SizedBox(height: 14),

        // Campo 2: E-mail
        const Text(
          'E-mail',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('register_email_field'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.mail_outline, size: 20),
            hintText: 'seu.email@exemplo.com',
          ),
        ),
        const SizedBox(height: 14),

        // Campo 3: Senha
        const Text(
          'Senha',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('register_password_field'),
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            hintText: 'Crie uma senha forte',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Campo 4: Confirmar Senha
        const Text(
          'Confirmar senha',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('register_confirm_password_field'),
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            hintText: 'Repita a senha criada',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Checklist dos Requisitos
        PasswordRequirementsCard(password: _currentPassword),
        const SizedBox(height: 20),

        // Botão Criar Conta
        AppButton(
          key: const Key('register_submit_button'),
          label: 'Criar conta',
          isLoading: widget.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
