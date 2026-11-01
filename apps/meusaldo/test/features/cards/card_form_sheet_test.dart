import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/cards/data/in_memory_credit_card_repository.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_brand_selector.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_color_palette_picker.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_form_sheet.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

Widget _buildTestApp({
  CreditCard? card,
  CreditCardRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      if (repository != null)
        creditCardRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => CardFormSheet.show(context, card: card),
            child: const Text('Abrir'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final existingCard = CreditCard.create(
    id: 'card_nubank',
    name: 'Nubank Ultravioleta',
    totalLimit: Money.fromReais(12000),
    closingDay: 3,
    dueDay: 10,
    lastFourDigits: '8842',
    colorHex: '#820AD1',
    isDefault: true,
  );

  group('CardFormSheet Widget Tests', () {
    testWidgets('renderiza campos de cadastro com valores padrão',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Novo Cartão'), findsOneWidget);
      expect(
        find.text(
          'Cadastre seu cartão para controlar limites, fechamento de faturas e compras parceladas.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('card_form_name_field')), findsOneWidget);
      expect(find.byKey(const Key('card_form_digits_field')), findsOneWidget);
      expect(find.byKey(const Key('card_form_limit_field')), findsOneWidget);
      expect(
        find.byKey(const Key('card_form_closing_day_field')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('card_form_due_day_field')), findsOneWidget);
      expect(find.byType(CardBrandSelector), findsOneWidget);
      expect(find.byType(CardColorPalettePicker), findsOneWidget);
      expect(find.text('Definir como Cartão Padrão'), findsOneWidget);
      expect(find.text('Salvar Cartão'), findsOneWidget);
    });

    testWidgets('validação bloqueia submissão com campos inválidos',
        (tester) async {
      final repo = InMemoryCreditCardRepository(initialCards: []);
      await tester.pumpWidget(_buildTestApp(repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Rola até o botão salvar
      await tester.ensureVisible(find.text('Salvar Cartão'));
      await tester.pumpAndSettle();

      // Clica em salvar sem preencher nada
      await tester.tap(find.text('Salvar Cartão'));
      await tester.pumpAndSettle();

      // Rola de volta para o topo para verificar a mensagem
      await tester.ensureVisible(find.byKey(const Key('card_form_name_field')));
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome do cartão'), findsOneWidget);
      expect(find.text('Informe o limite do cartão'), findsOneWidget);
    });

    testWidgets('cadastra novo cartão com sucesso e adiciona ao repositório',
        (tester) async {
      final repo = InMemoryCreditCardRepository(initialCards: []);
      await tester.pumpWidget(_buildTestApp(repository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Preenche nome
      await tester.enterText(
        find.byKey(const Key('card_form_name_field')),
        'C6 Carbon Black',
      );
      // Preenche dígitos
      await tester.enterText(
        find.byKey(const Key('card_form_digits_field')),
        '1234',
      );
      // Preenche limite (500000 centavos = R$ 5.000,00)
      await tester.enterText(
        find.byKey(const Key('card_form_limit_field')),
        '500000',
      );
      // Preenche fechamento e vencimento
      await tester.enterText(
        find.byKey(const Key('card_form_closing_day_field')),
        '05',
      );
      await tester.enterText(
        find.byKey(const Key('card_form_due_day_field')),
        '12',
      );
      await tester.pumpAndSettle();

      // Rola para baixo para ver a bandeira e botão
      await tester.ensureVisible(find.text('Salvar Cartão'));
      await tester.pumpAndSettle();

      // Seleciona bandeira Visa
      await tester.tap(find.text('Visa'));
      await tester.pumpAndSettle();

      // Salva cartão
      await tester.tap(find.text('Salvar Cartão'));
      await tester.pumpAndSettle();

      final cards = await repo.getAll();
      expect(cards.isSuccess, isTrue);
      expect(cards.valueOrNull?.length, 1);
      final created = cards.valueOrNull!.first;
      expect(created.name, 'C6 Carbon Black');
      expect(created.lastFourDigits, '1234');
      expect(created.totalLimit, Money.fromReais(5000));
      expect(created.closingDay, 5);
      expect(created.dueDay, 12);
    });

    testWidgets('permite editar cartão existente com dados pré-preenchidos',
        (tester) async {
      final repo =
          InMemoryCreditCardRepository(initialCards: [existingCard]);
      await tester.pumpWidget(
        _buildTestApp(card: existingCard, repository: repo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Cartão'), findsOneWidget);
      expect(find.text('Nubank Ultravioleta'), findsOneWidget);

      // Altera o nome
      await tester.enterText(
        find.byKey(const Key('card_form_name_field')),
        'Nubank Platinum',
      );
      await tester.pumpAndSettle();

      // Rola até o botão salvar
      await tester.ensureVisible(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      final updated = await repo.getById('card_nubank');
      expect(updated.valueOrNull?.name, 'Nubank Platinum');
    });
  });
}
