import 'package:flutter/material.dart';

/// Paleta de cores oficial do MeuSaldo — Tema Dark Burgundy.
///
/// Todas as cores seguem a especificação de `docs/DESIGN_SYSTEM.md`.
abstract final class AppColors {
  // Fundo e Superfícies
  static const Color background = Color(0xFF171417);
  static const Color surface = Color(0xFF242025);
  static const Color surfaceElevated = Color(0xFF2E2830);
  static const Color outline = Color(0xFF3D353F);

  // Tipografia e Conteúdo
  static const Color textPrimary = Color(0xFFF4EEF1);
  static const Color textSecondary = Color(0xFFB5A7AD);

  // Marca e Ações (CTA)
  static const Color brandPrimary = Color(0xFF6D1834);
  static const Color brandHighlight = Color(0xFFFFB1C1);

  // Cores Semânticas Financeiras (Fixas e Imutáveis por tema)
  static const Color income = Color(0xFF22A06B);
  static const Color expense = Color(0xFFF04444);
  static const Color alert = Color(0xFFF2C94C);
  static const Color transfer = Color(0xFF4C8DFF);
}

/// Extensão de tema para acessar cores semânticas customizadas via `Theme.of(context)`.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color outline;
  final Color textPrimary;
  final Color textSecondary;
  final Color brandPrimary;
  final Color brandHighlight;
  final Color income;
  final Color expense;
  final Color alert;
  final Color transfer;

  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.brandPrimary,
    required this.brandHighlight,
    required this.income,
    required this.expense,
    required this.alert,
    required this.transfer,
  });

  /// Instância padrão Dark Burgundy.
  static const darkBurgundy = AppColorsExtension(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceElevated: AppColors.surfaceElevated,
    outline: AppColors.outline,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    brandPrimary: AppColors.brandPrimary,
    brandHighlight: AppColors.brandHighlight,
    income: AppColors.income,
    expense: AppColors.expense,
    alert: AppColors.alert,
    transfer: AppColors.transfer,
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? outline,
    Color? textPrimary,
    Color? textSecondary,
    Color? brandPrimary,
    Color? brandHighlight,
    Color? income,
    Color? expense,
    Color? alert,
    Color? transfer,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      outline: outline ?? this.outline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandHighlight: brandHighlight ?? this.brandHighlight,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      alert: alert ?? this.alert,
      transfer: transfer ?? this.transfer,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t) ??
          surfaceElevated,
      outline: Color.lerp(outline, other.outline, t) ?? outline,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      brandPrimary:
          Color.lerp(brandPrimary, other.brandPrimary, t) ?? brandPrimary,
      brandHighlight:
          Color.lerp(brandHighlight, other.brandHighlight, t) ?? brandHighlight,
      income: Color.lerp(income, other.income, t) ?? income,
      expense: Color.lerp(expense, other.expense, t) ?? expense,
      alert: Color.lerp(alert, other.alert, t) ?? alert,
      transfer: Color.lerp(transfer, other.transfer, t) ?? transfer,
    );
  }
}
