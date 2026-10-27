import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/home/presentation/screens/home_screen.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_accounts_section.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_balance_card.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_header.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_upcoming_alert.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_form_sheet.dart';

Widget _buildTestApp({GoRouter? router}) {
  final effectiveRouter = router ??
      GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (context, state) =>
                const Scaffold(body: Text('Tela Lançamentos')),
          ),
          GoRoute(
            path: '/accounts',
            builder: (context, state) =>
                const Scaffold(body: Text('Tela Contas')),
          ),
          GoRoute(
            path: '/cards',
            builder: (context, state) =>
                const Scaffold(body: Text('Tela Cartões')),
          ),
        ],
      );

  return ProviderScope(
    child: MaterialApp.router(
      theme: AppTheme.darkTheme,
      routerConfig: effectiveRouter,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen Widget Tests', () {
    testWidgets('exibe todas as seções e dados principais do dashboard',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Verifica App Bar e Título
      expect(find.text('MeuSaldo'), findsOneWidget);

      // Verifica Seções Modulares
      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.text('Seu mês em ordem.'), findsOneWidget);

      expect(find.byType(HomeBalanceCard), findsOneWidget);
      expect(find.text('Saldo disponível em contas'), findsOneWidget);
      expect(find.text('Receitas no mês'), findsOneWidget);
      expect(find.text('Despesas no mês'), findsOneWidget);

      expect(find.byType(HomeQuickActions), findsOneWidget);
      expect(find.text('Movimentar'), findsOneWidget);
      expect(find.text('Despesa'), findsOneWidget);
      expect(find.text('Receita'), findsOneWidget);
      expect(find.text('Transferir'), findsOneWidget);

      expect(find.byType(HomeUpcomingAlert), findsOneWidget);
      expect(find.text('Próximo compromisso'), findsOneWidget);
      expect(find.text('Fatura Nubank fecha em 3 dias'), findsOneWidget);
      expect(find.text('3 dias'), findsOneWidget);

      expect(find.byType(HomeAccountsSection), findsOneWidget);
      expect(find.text('Minhas contas'), findsOneWidget);
      expect(find.text('Ver todas'), findsOneWidget);
    });

    testWidgets('alterna privacidade ocultando e exibindo valores ao tocar no olho',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Antes do toque, os saldos estão visíveis
      expect(find.text('••••••••'), findsNothing);

      // Toca no botão de alternar visibilidade (olho)
      final eyeButton = find.byTooltip('Ocultar saldo');
      expect(eyeButton, findsOneWidget);
      await tester.tap(eyeButton);
      await tester.pumpAndSettle();

      // Agora os valores monetários estão mascarados
      expect(find.text('••••••••'), findsOneWidget);
      expect(find.byTooltip('Exibir saldo'), findsOneWidget);

      // Toca novamente para reexibir
      await tester.tap(find.byTooltip('Exibir saldo'));
      await tester.pumpAndSettle();

      expect(find.text('••••••••'), findsNothing);
      expect(find.byTooltip('Ocultar saldo'), findsOneWidget);
    });

    testWidgets('abre o modal de formulário ao tocar no atalho rápido de despesa',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Toca no atalho rápido "Despesa"
      await tester.tap(find.text('Despesa'));
      await tester.pumpAndSettle();

      // Confirma abertura do modal de formulário
      expect(find.byType(TransactionFormSheet), findsOneWidget);
      expect(find.text('Novo lançamento'), findsOneWidget);
    });

    testWidgets('navega para a tela de contas ao tocar em Ver todas',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Toca no link "Ver todas" da seção de contas
      await tester.tap(find.text('Ver todas'));
      await tester.pumpAndSettle();

      // Confirma redirecionamento
      expect(find.text('Tela Contas'), findsOneWidget);
    });
  });
}
