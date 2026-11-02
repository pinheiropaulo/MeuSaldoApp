import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/cards/data/in_memory_credit_card_repository.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  group('InMemoryCreditCardRepository Tests', () {
    late InMemoryCreditCardRepository repository;

    setUp(() {
      repository = InMemoryCreditCardRepository.withDemoData();
    });

    test('construtor padrão inicializa com listas vazias', () async {
      final emptyRepo = InMemoryCreditCardRepository();
      final result = await emptyRepo.getAll();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!, isEmpty);
    });

    test('getAll retorna os cartões pré-carregados', () async {
      final result = await repository.getAll();
      expect(result.isSuccess, isTrue);
      final cards = result.valueOrNull!;
      expect(cards.length, equals(2));
      expect(cards.first.name, equals('Nubank Ultravioleta'));
    });

    test('getById retorna o cartão correto ou NotFoundFailure', () async {
      final success = await repository.getById('card-nubank');
      expect(success.isSuccess, isTrue);
      expect(success.valueOrNull!.name, equals('Nubank Ultravioleta'));

      final failure = await repository.getById('inexistente');
      expect(failure.isFailure, isTrue);
    });

    test('getCurrentInvoice retorna fatura do cartão ou NotFoundFailure', () async {
      final result = await repository.getCurrentInvoice('card-nubank');
      expect(result.isSuccess, isTrue);
      final invoice = result.valueOrNull!;
      expect(invoice.totalAmount, equals(const Money.fromCents(234870)));
      expect(invoice.status, equals(InvoiceStatus.open));

      final failure = await repository.getCurrentInvoice('inexistente');
      expect(failure.isFailure, isTrue);
    });

    test('getActiveInstallments filtra parcelamentos do cartão com parcelas pendentes', () async {
      final result = await repository.getActiveInstallments('card-nubank');
      expect(result.isSuccess, isTrue);
      final installments = result.valueOrNull!;
      expect(installments.length, equals(2));
      expect(installments.any((e) => e.description == 'Notebook Dell'), isTrue);
    });

    test('create adiciona novo cartão e impede duplicação de ID', () async {
      final newCard = CreditCard.create(
        id: 'card-c6',
        name: 'C6 Carbon',
        totalLimit: const Money.fromCents(1000000),
        closingDay: 1,
        dueDay: 8,
      );

      final result = await repository.create(newCard);
      expect(result.isSuccess, isTrue);

      final duplicate = await repository.create(newCard);
      expect(duplicate.isFailure, isTrue);
    });

    test('update atualiza cartão existente e delete remove', () async {
      final card = (await repository.getById('card-itau')).valueOrNull!;
      final updated = card.copyWith(name: 'Itaú Personalité');

      final updateResult = await repository.update(updated);
      expect(updateResult.isSuccess, isTrue);
      expect((await repository.getById('card-itau')).valueOrNull!.name, equals('Itaú Personalité'));

      final deleteResult = await repository.delete('card-itau');
      expect(deleteResult.isSuccess, isTrue);
      expect((await repository.getById('card-itau')).isFailure, isTrue);
    });
  });

  group('Card Riverpod Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          creditCardRepositoryProvider.overrideWithValue(
            InMemoryCreditCardRepository.withDemoData(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('cardsListProvider carrega lista e seleciona cartão padrão', () async {
      final cards = await container.read(cardsListProvider.future);
      expect(cards.length, equals(2));

      final selectedCard = container.read(selectedCreditCardProvider);
      expect(selectedCard, isNotNull);
      expect(selectedCard!.id, equals('card-nubank'));
      expect(selectedCard.isDefault, isTrue);
    });

    test('permite alternar o cartão selecionado no carrossel', () async {
      await container.read(cardsListProvider.future);

      container.read(selectedCardIdProvider.notifier).selectCard('card-itau');

      final selectedCard = container.read(selectedCreditCardProvider);
      expect(selectedCard, isNotNull);
      expect(selectedCard!.id, equals('card-itau'));
      expect(selectedCard.name, equals('Itaú Click'));
    });

    test('currentInvoiceProvider e activeInstallmentsProvider reagem à troca de cartão', () async {
      await container.read(cardsListProvider.future);

      // Nubank selecionado
      final nubankInvoice = await container.read(currentInvoiceProvider.future);
      expect(nubankInvoice, isNotNull);
      expect(nubankInvoice!.totalAmount, equals(const Money.fromCents(234870)));

      final nubankInstallments = await container.read(activeInstallmentsProvider.future);
      expect(nubankInstallments.length, equals(2));

      // Total comprometido mensal no Nubank: 389,90 + 180,00 = 569,90
      final monthlyTotal = container.read(monthlyInstallmentTotalProvider);
      expect(monthlyTotal, equals(const Money.fromCents(56990)));

      // Troca para Itaú
      container.read(selectedCardIdProvider.notifier).selectCard('card-itau');

      final itauInvoice = await container.read(currentInvoiceProvider.future);
      expect(itauInvoice, isNotNull);
      expect(itauInvoice!.totalAmount, equals(const Money.fromCents(145000)));

      final itauInstallments = await container.read(activeInstallmentsProvider.future);
      expect(itauInstallments.length, equals(1));
      expect(itauInstallments.first.description, equals('Curso de Especialização'));

      // Total comprometido mensal no Itaú: 120,00
      final itauMonthlyTotal = container.read(monthlyInstallmentTotalProvider);
      expect(itauMonthlyTotal, equals(const Money.fromCents(12000)));
    });

    test('addCard adiciona cartão à lista e o seleciona', () async {
      await container.read(cardsListProvider.future);

      final newCard = CreditCard.create(
        id: 'card-inter',
        name: 'Inter Black',
        totalLimit: const Money.fromCents(2000000),
        closingDay: 10,
        dueDay: 17,
      );

      final result = await container.read(cardsListProvider.notifier).addCard(newCard);
      expect(result.isSuccess, isTrue);

      final updatedList = await container.read(cardsListProvider.future);
      expect(updatedList.length, equals(3));
      expect(container.read(selectedCreditCardProvider)?.id, equals('card-inter'));
    });
  });
}
