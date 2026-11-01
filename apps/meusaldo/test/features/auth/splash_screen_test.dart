import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/auth/presentation/screens/splash_screen.dart';
import 'package:meusaldo/features/auth/presentation/widgets/splash_brand_hero.dart';
import 'package:meusaldo/features/auth/presentation/widgets/splash_loading_status.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('exibe elementos da marca e identidade visual MeuSaldo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SplashScreen(),
        ),
      );

      // Renderização da tela e componentes modulares
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(SplashBrandHero), findsOneWidget);
      expect(find.byType(SplashLoadingStatus), findsOneWidget);

      // Textos principais da marca
      expect(find.text('MeuSaldo'), findsOneWidget);
      expect(find.text('CONTROLE FINANCEIRO PESSOAL'), findsOneWidget);

      // Ícone central da carteira
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);

      // Mensagem de inicialização e indicador de progresso
      expect(find.text('Iniciando com segurança...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Rodapé de segurança e versão
      expect(
        find.text('Dados protegidos com criptografia local • v1.0.0'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('SplashLoadingStatus permite customizar o texto de status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SplashLoadingStatus(statusText: 'Sincronizando contas...'),
          ),
        ),
      );

      expect(find.text('Sincronizando contas...'), findsOneWidget);
    });
  });
}
