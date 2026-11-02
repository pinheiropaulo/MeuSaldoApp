import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Seções de campos de edição de perfil, preferências regionais e alteração de senha.
class ProfileFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String weekStart;
  final ValueChanged<String> onWeekStartChanged;
  final VoidCallback onChangePassword;

  const ProfileFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.weekStart,
    required this.onWeekStartChanged,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Nome Completo
        const Text(
          'Nome Completo *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('profile_name_field'),
          controller: nameController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline, size: 20),
            hintText: 'Seu nome completo',
          ),
        ),
        const SizedBox(height: 14),

        // E-mail de Acesso
        const Text(
          'E-mail de Acesso *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('profile_email_field'),
          controller: emailController,
          enabled: false,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.mail_outline, size: 20),
            suffixIcon: Icon(Icons.lock_outline, size: 18),
            hintText: 'seu.email@exemplo.com',
          ),
        ),
        const SizedBox(height: 14),

        // Celular / WhatsApp
        const Text(
          'Celular / WhatsApp (Opcional)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          key: const Key('profile_phone_field'),
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_outlined, size: 20),
            hintText: '(11) 98765-4321',
          ),
        ),
        const SizedBox(height: 20),

        // Preferências
        const Text(
          'PREFERÊNCIAS REGIONAIS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moeda Principal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Real Brasileiro (BRL • R\$)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 13,
                          color: AppColors.primaryHighlight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Padrão BRL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryHighlight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.outline, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Início da Semana',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Exibição nos calendários',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: weekStart,
                    underline: const SizedBox.shrink(),
                    dropdownColor: AppColors.surfaceElevated,
                    items: const [
                      DropdownMenuItem(
                        value: 'Segunda-feira',
                        child: Text('Segunda-feira'),
                      ),
                      DropdownMenuItem(
                        value: 'Domingo',
                        child: Text('Domingo'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) onWeekStartChanged(val);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Atalho Alterar Senha
        InkWell(
          key: const Key('profile_change_password_tile'),
          onTap: onChangePassword,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_reset, size: 20, color: AppColors.primaryHighlight),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alterar Senha de Acesso',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
