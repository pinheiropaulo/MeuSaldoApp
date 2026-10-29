import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meusaldo/app/theme/app_colors.dart';
import 'package:meusaldo/app/theme/runtime_environment.dart';

/// Definições tipográficas do MeuSaldo — Roboto para UI e JetBrains Mono para valores monetários.
abstract final class AppTypography {
  /// Indica se a execução atual ocorre no ambiente de testes do Flutter.
  static bool get isRunningInTest => isRunningInFlutterTest;

  /// Gera o `TextTheme` base da aplicação usando Roboto.
  static TextTheme createTextTheme({bool? useGoogleFonts}) {
    final shouldUseGoogleFonts = useGoogleFonts ?? !isRunningInTest;
    final base = shouldUseGoogleFonts
        ? GoogleFonts.robotoTextTheme()
        : const TextTheme().apply(fontFamily: 'Roboto');

    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        color: AppColors.textPrimary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.015,
        color: AppColors.textPrimary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01,
        color: AppColors.textPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.01,
        color: AppColors.textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.04,
        color: AppColors.textSecondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.02,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Estilo para grandes destaques de saldo ou valor hero (`28px` - `36px`).
  static TextStyle currencyHero({
    Color? color,
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w700,
    bool? useGoogleFonts,
  }) {
    final shouldUseGoogleFonts = useGoogleFonts ?? !isRunningInTest;
    if (shouldUseGoogleFonts) {
      return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: -0.03,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color ?? AppColors.textPrimary,
      );
    }
    return TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.03,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: color ?? AppColors.textPrimary,
    );
  }

  /// Estilo para valores monetários em linhas de listagem (`15px` - `16px`).
  static TextStyle currencyRow({
    Color? color,
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w600,
    bool? useGoogleFonts,
  }) {
    final shouldUseGoogleFonts = useGoogleFonts ?? !isRunningInTest;
    if (shouldUseGoogleFonts) {
      return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: -0.01,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color ?? AppColors.textPrimary,
      );
    }
    return TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.01,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: color ?? AppColors.textPrimary,
    );
  }

  /// Estilo para prefixo ou rótulo de moeda menor (`R$`).
  static TextStyle currencyPrefix({
    Color? color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    bool? useGoogleFonts,
  }) {
    final shouldUseGoogleFonts = useGoogleFonts ?? !isRunningInTest;
    if (shouldUseGoogleFonts) {
      return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color ?? AppColors.textSecondary,
      );
    }
    return TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: color ?? AppColors.textSecondary,
    );
  }
}
