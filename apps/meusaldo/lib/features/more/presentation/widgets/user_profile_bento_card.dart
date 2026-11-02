import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card de perfil do usuário na Aba Mais.
class UserProfileBentoCard extends StatelessWidget {
  final String? name;
  final String? email;
  final VoidCallback onEdit;

  const UserProfileBentoCard({
    super.key,
    required this.name,
    required this.email,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name?.isNotEmpty == true ? name! : 'Usuário';
    final displayEmail = email?.isNotEmpty == true ? email! : 'usuario@meusaldo.app';
    final initial = displayName[0].toUpperCase();

    return AppCard(
      key: const Key('more_user_profile_card'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Avatar do usuário
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryHighlight,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Informações de nome e e-mail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  displayEmail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Botão Editar
          InkWell(
            key: const Key('more_edit_profile_button'),
            borderRadius: BorderRadius.circular(8),
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Editar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
