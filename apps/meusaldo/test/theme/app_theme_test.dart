import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/theme/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme Dark Burgundy', () {
    test('configurações base e cores do tema escuro', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(const Color(0xFF171417)));
      expect(theme.colorScheme.surface, equals(const Color(0xFF242025)));

      // Verifica ThemeExtension com cores semânticas fixas
      final colors = theme.extension<AppColorsExtension>();
      expect(colors, isNotNull);
      expect(colors!.income, equals(const Color(0xFF22A06B)));
      expect(colors.expense, equals(const Color(0xFFF04444)));
      expect(colors.alert, equals(const Color(0xFFF2C94C)));
      expect(colors.transfer, equals(const Color(0xFF4C8DFF)));
      expect(colors.brandPrimary, equals(const Color(0xFF6D1834)));
      expect(colors.brandHighlight, equals(const Color(0xFFFFB1C1)));
    });

    test('geometria de componentes segue especificação de design', () {
      final theme = AppTheme.darkTheme;

      // Card: raio 12px e borda 1px
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder?;
      expect(cardShape, isNotNull);
      expect(cardShape!.borderRadius, equals(BorderRadius.circular(12)));
      expect(cardShape.side.width, equals(1));
      expect(cardShape.side.color, equals(AppColors.outline));

      // Botão elevado: raio 8px e altura mínima 48px
      final buttonStyle = theme.elevatedButtonTheme.style;
      expect(buttonStyle, isNotNull);
      final minSize = buttonStyle!.minimumSize?.resolve({});
      expect(minSize?.height, greaterThanOrEqualTo(48));

      // BottomSheet: raio superior de 16px
      final sheetShape = theme.bottomSheetTheme.shape as RoundedRectangleBorder?;
      expect(sheetShape, isNotNull);
      expect(
        sheetShape!.borderRadius,
        equals(const BorderRadius.vertical(top: Radius.circular(16))),
      );
    });

    test('estilos monetários utilizam numeração tabular', () {
      final hero = AppTypography.currencyHero();
      expect(hero.fontFeatures, contains(const FontFeature.tabularFigures()));

      final row = AppTypography.currencyRow();
      expect(row.fontFeatures, contains(const FontFeature.tabularFigures()));
    });
  });
}
