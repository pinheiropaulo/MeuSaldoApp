import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/cards/data/in_memory_credit_card_repository.dart';
import 'package:meusaldo/features/cards/presentation/screens/cards_screen.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_installments_section.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_invoice_hero_card.dart';
import 'package:meusaldo/features/cards/presentation/widgets/cards_carousel_section.dart';
import 'package:meusaldo/features/cards/presentation/widgets/cards_empty_state.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

Widget _buildTestApp({CreditCardRepository? repository}) {
  return ProviderScope(
    overrides: [
      if (repository != null)
        creditCardRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: const CardsScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CardsScreen Widget Tests', () {
    testWidgets('exibe tela de cartões com carrossel, fatura hero e compras parceladas',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // AppBar
      expect(find.text('Cartões'), findsOneWidget);
      expect(find.text('Novo Cartão'), findsOneWidget);

      // Carrossel
      expect(find.byType(CardsCarouselSection), findsOneWidget);
      expect(find.text('MEUS CARTÕES'), findsOneWidget);
      expect(find.text('2 ativos'), findsOneWidget);
      expect(find.text('Nubank Ultravioleta'), findsOneWidget);
      expect(find.text('Final 8842'), findsOneWidget);
      expect(find.text('PADRÃO'), findsOneWidget);
      expect(find.text('54% livre'), findsOneWidget);

      // Fatura Atual
      expect(find.byType(CardInvoiceHeroCard), findsOneWidget);
      expect(find.text('Fatura Atual'), findsOneWidget);
      expect(find.text('Fatura Aberta'), findsOneWidget);
      expect(find.text('Total a pagar este mês'), findsOneWidget);
      expect(find.text('Ver Fatura'), findsOneWidget);
      expect(find.text('Pagar Fatura'), findsOneWidget);

      // Compras Parceladas
      expect(find.byType(CardInstallmentsSection), findsOneWidget);
      expect(find.text('Compras Parceladas Ativas'), findsOneWidget);
      expect(find.text('Notebook Dell'), findsOneWidget);
      expect(find.text('Parcela 4/10'), findsOneWidget);
      expect(find.text('Supermercado'), findsOneWidget);
      expect(find.text('Parcela 2/3'), findsOneWidget);

      // Comprometimento Mensal
      expect(find.text('Comprometimento Mensal'), findsOneWidget);
      expect(find.text('Total em parcelas ativas'), findsOneWidget);
    });

    testWidgets('permite tocar no segundo cartão do carrossel para alternar foco',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Toca no card do Itaú no carrossel
      final itauCardItem = find.text('Itaú Click');
      expect(itauCardItem, findsOneWidget);
      await tester.tap(itauCardItem);
      await tester.pumpAndSettle();

      // Agora a fatura e parcelamentos do Itaú devem ser carregados
      expect(find.text('Curso de Especialização'), findsOneWidget);
      expect(find.text('Parcela 3/6'), findsOneWidget);
    });

    testWidgets('exibe estado vazio quando não há cartões cadastrados',
        (tester) async {
      final emptyRepo = InMemoryCreditCardRepository(
        initialCards: const [],
        initialInvoices: const [],
        initialExpenses: const [],
      );

      await tester.pumpWidget(
        _buildTestApp(repository: emptyRepo),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CardsEmptyState), findsOneWidget);
      expect(find.text('Nenhum cartão cadastrado'), findsOneWidget);
      expect(find.text('Cadastrar Primeiro Cartão'), findsOneWidget);
      expect(find.text('Controle 100% Privado'), findsOneWidget);
    });
  });
}
