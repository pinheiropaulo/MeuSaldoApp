import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Seção central de identidade visual da Splash Screen com logotipo e slogan.
class SplashBrandHero extends StatelessWidget {
  const SplashBrandHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outline),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_wallet,
              color: AppColors.primaryHighlight,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'MeuSaldo',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'CONTROLE FINANCEIRO PESSOAL',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}
