import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/app.dart';
import 'package:meusaldo/features/auth/data/in_memory_auth_repository.dart';
import 'package:meusaldo/features/auth/presentation/screens/login_screen.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/cards/presentation/screens/cards_screen.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final authenticatedUser = User.create(
    id: 'usr-default',
    name: 'Paulo Pinheiro',
    email: 'paulo@meusaldo.app',
  );

  group('AppRouter Navigation', () {
    testWidgets('quando autenticado, inicia na aba Início e permite alternar entre todas as abas', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              InMemoryAuthRepository(initialUser: authenticatedUser),
            ),
          ],
          child: const MeuSaldoApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica aba inicial (Início)
      expect(find.text('Início'), findsWidgets);

      // Alterna para Lançamentos
      await tester.tap(find.widgetWithText(NavigationDestination, 'Lançamentos'));
      await tester.pumpAndSettle();
      expect(find.text('Lançamentos'), findsWidgets);

      // Alterna para Contas
      await tester.tap(find.widgetWithText(NavigationDestination, 'Contas'));
      await tester.pumpAndSettle();
      expect(find.text('Contas'), findsWidgets);

      // Alterna para Cartões
      await tester.tap(find.widgetWithText(NavigationDestination, 'Cartões'));
      await tester.pumpAndSettle();
      expect(find.byType(CardsScreen), findsOneWidget);

      // Alterna para Mais
      await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
      await tester.pumpAndSettle();
      expect(find.text('CADASTROS & CLASSIFICAÇÃO'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('more_logout_button')));
      await tester.pumpAndSettle();
      expect(find.text('Encerrar Sessão'), findsOneWidget);

      // Retorna para Início
      await tester.tap(find.widgetWithText(NavigationDestination, 'Início'));
      await tester.pumpAndSettle();
      expect(find.text('Início'), findsWidgets);
    });

    testWidgets('quando não autenticado, redireciona para login e navega para Início após entrar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              InMemoryAuthRepository(),
            ),
          ],
          child: const MeuSaldoApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Usuário não autenticado é redirecionado para a tela de login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Acesse sua conta'), findsOneWidget);

      // Toca em Entrar (campos já vêm preenchidos para demonstração)
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      // Redireciona com sucesso para a Home
      expect(find.text('Início'), findsWidgets);

      // Vai até a aba Mais e faz Logout
      await tester.tap(find.widgetWithText(NavigationDestination, 'Mais'));
      await tester.pumpAndSettle();
      expect(find.text('CADASTROS & CLASSIFICAÇÃO'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('more_logout_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('more_logout_button')));
      await tester.pumpAndSettle();

      // Confirma no diálogo de encerramento de sessão
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      // Após logout, redireciona de volta para a tela de login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Acesse sua conta'), findsOneWidget);
    });
  });
}
