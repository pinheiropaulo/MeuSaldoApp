import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_details_sheet.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_period_selector.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_type_filter_bar.dart';

Widget _buildTestApp() {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: const TransactionsScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TransactionsScreen Widget Tests', () {
    testWidgets('exibe tela de lançamentos com seletor de período, filtros e itens agrupados',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Verifica App Bar e Ação
      expect(find.text('Lançamentos'), findsOneWidget);
      expect(find.text('+ Novo'), findsOneWidget);

      // Verifica Seletor de Período e Barra de Filtros
      expect(find.byType(TransactionPeriodSelector), findsOneWidget);
      expect(find.byType(TransactionTypeFilterBar), findsOneWidget);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Receitas'), findsOneWidget);
      expect(find.text('Despesas'), findsOneWidget);
      expect(find.text('Transferências'), findsOneWidget);

      // Verifica itens de movimentação carregados
      expect(find.byType(TransactionListItem), findsWidgets);
    });

    testWidgets('filtra lançamentos ao alternar os chips de tipo',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Toca no filtro de Receitas
      await tester.tap(find.text('Receitas'));
      await tester.pumpAndSettle();

      // Apenas itens de receita devem ser exibidos (ex: Salário Mensal)
      expect(find.text('Salário Mensal'), findsOneWidget);
      expect(find.text('Supermercado Pão de Açúcar'), findsNothing);

      // Toca no filtro de Despesas
      await tester.tap(find.text('Despesas'));
      await tester.pumpAndSettle();

      expect(find.text('Supermercado Pão de Açúcar'), findsOneWidget);
      expect(find.text('Salário Mensal'), findsNothing);

      // Retorna para Todos
      await tester.tap(find.text('Todos'));
      await tester.pumpAndSettle();

      expect(find.text('Supermercado Pão de Açúcar'), findsOneWidget);
      expect(find.text('Salário Mensal'), findsOneWidget);
    });

    testWidgets('abre formulário ao tocar em + Novo e permite cadastrar despesa',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Toca em + Novo
      await tester.tap(find.text('+ Novo'));
      await tester.pumpAndSettle();

      // Verifica abertura do modal
      expect(find.byType(TransactionFormSheet), findsOneWidget);
      expect(find.text('Novo lançamento'), findsOneWidget);

      // Digita valor e descrição
      await tester.enterText(find.byType(TextField).first, '120,50');
      await tester.enterText(find.byType(TextField).at(1), 'Cinema Shopping');
      await tester.pumpAndSettle();

      // Salva
      await tester.ensureVisible(find.text('Salvar despesa'));
      await tester.tap(find.text('Salvar despesa'));
      await tester.pumpAndSettle();

      // Verifica se o item cadastrado aparece na listagem
      expect(find.text('Cinema Shopping'), findsOneWidget);
    });

    testWidgets('abre modal de detalhes ao tocar em um lançamento',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Toca no primeiro item de lançamento
      await tester.tap(find.text('Supermercado Pão de Açúcar'));
      await tester.pumpAndSettle();

      // Verifica exibição do modal de detalhes
      expect(find.byType(TransactionDetailsSheet), findsOneWidget);
      expect(find.text('Detalhes do lançamento'), findsOneWidget);
      expect(find.text('Excluir lançamento'), findsOneWidget);
    });
  });
}
