import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Seção inferior da Splash Screen com indicador de progresso e nota de segurança.
class SplashLoadingStatus extends StatelessWidget {
  final String statusText;

  const SplashLoadingStatus({
    super.key,
    this.statusText = 'Iniciando com segurança...',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandHighlight),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          statusText,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 13,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 6),
            Text(
              'Dados protegidos com criptografia local • v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
