import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/more/presentation/screens/more_screen.dart';
import 'package:meusaldo/features/more/presentation/widgets/category_hero_menu_item.dart';
import 'package:meusaldo/features/more/presentation/widgets/user_profile_bento_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildMoreScreen({required ProviderContainer container}) {
    final router = GoRouter(
      initialLocation: '/more',
      routes: [
        GoRoute(
          path: '/more',
          builder: (context, state) => const MoreScreen(),
        ),
        GoRoute(
          path: AppRoutes.categories,
          builder: (context, state) => const Scaffold(body: Text('Tela Categorias')),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (context, state) => const Scaffold(body: Text('Tela Perfil')),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('MoreScreen Widget Tests (Parte 1)', () {
    testWidgets('exibe card de perfil do usuário com nome, e-mail e botão editar', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authStateProvider.notifier).login(
            email: 'paulo@meusaldo.app',
            password: 'password123',
          );

      await tester.pumpWidget(buildMoreScreen(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(UserProfileBentoCard), findsOneWidget);
      expect(find.text('Paulo Pinheiro'), findsOneWidget);
      expect(find.text('paulo@meusaldo.app'), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);

      // Não deve ter badges nem dados de cobrança/SaaS
      expect(find.text('PRO'), findsNothing);
      expect(find.text('Plano'), findsNothing);
      expect(find.text('Anual Ativo'), findsNothing);
      expect(find.text('Sincronizado'), findsNothing);
    });

    testWidgets('exibe item hero de categorias e navega para tela de categorias ao tocar', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(buildMoreScreen(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryHeroMenuItem), findsOneWidget);
      expect(find.text('Categorias'), findsOneWidget);
      expect(find.text('Salário'), findsOneWidget);
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('Transporte'), findsOneWidget);
      expect(find.text('Moradia'), findsOneWidget);

      // Toca no card de categorias
      await tester.tap(find.byType(CategoryHeroMenuItem));
      await tester.pumpAndSettle();

      expect(find.text('Tela Categorias'), findsOneWidget);
    });

    testWidgets('exibe seções de Cadastros e Preferências', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(buildMoreScreen(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Lançamentos Recorrentes'), findsOneWidget);
      expect(find.text('Agenda & Contas a Vencer'), findsOneWidget);
      expect(find.text('Aparência / Tema'), findsOneWidget);
      expect(find.text('Notificações & Alertas'), findsOneWidget);
      expect(find.text('Segurança & Biometria'), findsOneWidget);

      // Não deve ter item de sincronização manual/backup
      expect(find.text('Backup & Sincronização'), findsNothing);
      expect(find.text('Sync'), findsNothing);
    });

    testWidgets('exibe diálogo de confirmação ao tocar em Encerrar Sessão', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(buildMoreScreen(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Encerrar Sessão'), findsOneWidget);

      // Clica em Encerrar Sessão
      await tester.tap(find.text('Encerrar Sessão'));
      await tester.pumpAndSettle();

      // Confirma que abriu o diálogo
      expect(find.text('Tem certeza de que deseja sair da sua conta?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
    });
  });
}
