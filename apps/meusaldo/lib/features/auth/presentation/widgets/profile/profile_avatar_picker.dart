import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Componente de avatar do usuário com iniciais e badge com ícone de câmera.
class ProfileAvatarPicker extends StatelessWidget {
  final String displayName;
  final VoidCallback onTap;

  const ProfileAvatarPicker({
    super.key,
    required this.displayName,
    required this.onTap,
  });

  String get _initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'US';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(
                    color: AppColors.primaryHighlight,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryHighlight,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceElevated,
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: AppColors.primaryHighlight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Alterar foto de perfil',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryHighlight,
            ),
          ),
        ),
      ],
    );
  }
}
