import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRouter Navigation', () {
    testWidgets('inicia na aba Início e permite alternar entre todas as abas', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MeuSaldoApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica aba inicial (Início)
      expect(find.text('Início'), findsWidgets);

      // Alterna para Lançamentos
      await tester.tap(find.text('Lançamentos'));
      await tester.pumpAndSettle();
      expect(find.text('Lançamentos'), findsWidgets);

      // Alterna para Contas
      await tester.tap(find.text('Contas'));
      await tester.pumpAndSettle();
      expect(find.text('Contas financeiras'), findsOneWidget);

      // Alterna para Cartões
      await tester.tap(find.text('Cartões'));
      await tester.pumpAndSettle();
      expect(find.text('Cartões de crédito'), findsOneWidget);

      // Alterna para Mais
      await tester.tap(find.text('Mais'));
      await tester.pumpAndSettle();
      expect(find.text('Menu e configurações'), findsOneWidget);

      // Retorna para Início
      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();
      expect(find.text('Início'), findsWidgets);
    });
  });
}
