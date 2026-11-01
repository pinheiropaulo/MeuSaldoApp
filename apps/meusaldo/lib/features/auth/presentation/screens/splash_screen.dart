import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/auth/presentation/widgets/splash_brand_hero.dart';
import 'package:meusaldo/features/auth/presentation/widgets/splash_loading_status.dart';

/// Tela de apresentação e carregamento inicial do MeuSaldo.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            children: const [
              Spacer(),
              SplashBrandHero(),
              Spacer(),
              SplashLoadingStatus(),
            ],
          ),
        ),
      ),
    );
  }
}
