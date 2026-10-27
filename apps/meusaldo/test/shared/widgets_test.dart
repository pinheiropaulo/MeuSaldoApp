import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/widgets.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Shared Widgets', () {
    testWidgets('MoneyDisplay exibe valores formatados e cores semânticas', (tester) async {
      final positiveMoney = Money.fromCents(123456); // R$ 1.234,56
      final negativeMoney = Money.fromCents(-15000); // - R$ 150,00

      await tester.pumpWidget(
        _buildTestApp(
          Column(
            children: [
              MoneyDisplay(
                key: const Key('positive'),
                money: positiveMoney,
                transactionType: TransactionType.income,
                showPositiveSign: true,
              ),
              MoneyDisplay(
                key: const Key('negative'),
                money: negativeMoney,
                transactionType: TransactionType.expense,
              ),
            ],
          ),
        ),
      );

      expect(find.byKey(const Key('positive')), findsOneWidget);
      expect(find.byKey(const Key('negative')), findsOneWidget);
      expect(find.textContaining('1.234,56'), findsOneWidget);
      expect(find.textContaining('150,00'), findsOneWidget);
    });

    testWidgets('AppCard renderiza filho e reage a toque', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          AppCard(
            onTap: () => tapped = true,
            child: const Text('Conteúdo do Card'),
          ),
        ),
      );

      expect(find.text('Conteúdo do Card'), findsOneWidget);
      await tester.tap(find.text('Conteúdo do Card'));
      expect(tapped, isTrue);
    });

    testWidgets('AppButton executa callback e exibe estado de loading', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          AppButton(
            label: 'Salvar',
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Salvar'), findsOneWidget);
      await tester.tap(find.text('Salvar'));
      expect(pressed, isTrue);

      // Botão em loading não deve acionar clique e deve exibir CircularProgressIndicator
      pressed = false;
      await tester.pumpWidget(
        _buildTestApp(
          AppButton(
            label: 'Salvar',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Salvar'), findsNothing);
    });

    testWidgets('EmptyStateWidget renderiza ícone, textos e ação', (tester) async {
      var actionTapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          EmptyStateWidget(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Nenhuma conta cadastrada',
            description: 'Cadastre sua primeira conta financeira.',
            actionLabel: 'Criar conta',
            onActionPressed: () => actionTapped = true,
          ),
        ),
      );

      expect(find.text('Nenhuma conta cadastrada'), findsOneWidget);
      expect(find.text('Cadastre sua primeira conta financeira.'), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);

      await tester.tap(find.text('Criar conta'));
      expect(actionTapped, isTrue);
    });

    testWidgets('showAppConfirmationDialog confirma ou cancela ação', (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                child: const Text('Abrir Diálogo'),
                onPressed: () async {
                  dialogResult = await showAppConfirmationDialog(
                    context: ctx,
                    title: 'Excluir lançamento?',
                    message: 'Esta ação não poderá ser desfeita.',
                    confirmLabel: 'Excluir',
                    isDestructive: true,
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir Diálogo'));
      await tester.pumpAndSettle();

      expect(find.text('Excluir lançamento?'), findsOneWidget);
      expect(find.text('Esta ação não poderá ser desfeita.'), findsOneWidget);

      // Clica em Excluir (confirmação destrutiva)
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });
  });
}
