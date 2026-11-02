import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card dinâmico de checklist dos requisitos mínimos de segurança de senha.
class PasswordRequirementsCard extends StatelessWidget {
  final String password;

  const PasswordRequirementsCard({
    super.key,
    required this.password,
  });

  bool get hasMinLength => password.length >= 8;
  bool get hasUpperAndNumber =>
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REQUISITOS DA SENHA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _RequirementRow(
            label: 'Mínimo de 8 caracteres',
            isMet: hasMinLength,
          ),
          const SizedBox(height: 6),
          _RequirementRow(
            label: 'Ao menos uma letra maiúscula e um número',
            isMet: hasUpperAndNumber,
          ),
          const SizedBox(height: 6),
          _RequirementRow(
            label: 'Um caractere especial (@, #, \$, etc.)',
            isMet: hasSpecialChar,
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool isMet;

  const _RequirementRow({
    required this.label,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? AppColors.primaryHighlight : AppColors.outline,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
