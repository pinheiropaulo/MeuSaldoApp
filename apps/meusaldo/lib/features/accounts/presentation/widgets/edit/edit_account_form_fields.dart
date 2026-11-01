import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Banners e campos de entrada de texto para a edição de conta.
class EditAccountFormFields extends StatelessWidget {
  final TextEditingController nameController;

  const EditAccountFormFields({
    super.key,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card informativo
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.outline),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.primaryHighlight,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Edite as informações da sua conta. Alterações no nome ou tipo serão refletidas no extrato e lançamentos vinculados.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Campo Nome da Conta
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: const TextSpan(
                text: 'Nome da conta ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: '*',
                    style: TextStyle(
                      color: AppColors.primaryHighlight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Obrigatório',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: const Key('edit_account_name_field'),
          controller: nameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Ex: Conta principal, Nubank, Carteira...',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Informe o nome da conta';
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        const Text(
          'Dica: Atribua um nome intuitivo para facilitar a conciliação mensal.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
