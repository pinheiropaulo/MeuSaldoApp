import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/config/app_config.dart';
import 'package:meusaldo/features/cards/data/in_memory_credit_card_repository.dart';
import 'package:meusaldo/features/cards/data/supabase_card_repository.dart';
import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

/// Provedor do repositório de cartões de crédito.
final creditCardRepositoryProvider = Provider<CreditCardRepository>((ref) {
  if (AppConfig.isSupabaseConfigured) {
    try {
      final client = sp.Supabase.instance.client;
      return SupabaseCardRepository(client: client);
    } catch (_) {
      // Supabase não inicializado (ex: testes de widget isolados)
    }
  }
  return InMemoryCreditCardRepository();
});

/// Gerenciador do ID do cartão atualmente selecionado no carrossel.
class SelectedCardIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectCard(String id) {
    state = id;
  }
}

/// Provedor do ID do cartão atualmente em foco.
final selectedCardIdProvider =
    NotifierProvider<SelectedCardIdNotifier, String?>(
      SelectedCardIdNotifier.new,
    );

/// Notifier reativo para listagem e gerenciamento de cartões de crédito.
class CardsListNotifier extends AsyncNotifier<List<CreditCard>> {
  @override
  FutureOr<List<CreditCard>> build() async {
    final repo = ref.watch(creditCardRepositoryProvider);
    final result = await repo.getAll();
    final cards = result.when(
      onSuccess: (list) => list,
      onFailure: (failure) => throw Exception(failure.message),
    );

    // Se nenhum cartão foi selecionado ainda, define o padrão ou o primeiro
    final selectedId = ref.read(selectedCardIdProvider);
    if (selectedId == null && cards.isNotEmpty) {
      final defaultCard = cards.firstWhere(
        (c) => c.isDefault,
        orElse: () => cards.first,
      );
      // Agenda a seleção para o próximo microtask para não conflitar com a montagem
      Future.microtask(() {
        ref.read(selectedCardIdProvider.notifier).selectCard(defaultCard.id);
      });
    }

    return cards;
  }

  /// Adiciona um novo cartão de crédito e foca nele.
  Future<Result<CreditCard, Failure>> addCard(CreditCard card) async {
    final repo = ref.read(creditCardRepositoryProvider);
    final result = await repo.create(card);
    if (result.isSuccess) {
      ref.invalidateSelf();
      ref.read(selectedCardIdProvider.notifier).selectCard(card.id);
    }
    return result;
  }

  /// Atualiza o cadastro de um cartão.
  Future<Result<CreditCard, Failure>> updateCard(CreditCard card) async {
    final repo = ref.read(creditCardRepositoryProvider);
    final result = await repo.update(card);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
    return result;
  }

  /// Exclui um cartão de crédito.
  Future<Result<void, Failure>> deleteCard(String id) async {
    final repo = ref.read(creditCardRepositoryProvider);
    final result = await repo.delete(id);
    if (result.isSuccess) {
      ref.read(selectedCardIdProvider.notifier).selectCard('');
      ref.invalidateSelf();
    }
    return result;
  }
}

/// Provedor da lista reativa de cartões cadastrados.
final cardsListProvider =
    AsyncNotifierProvider<CardsListNotifier, List<CreditCard>>(
      CardsListNotifier.new,
    );

/// Provedor do cartão atualmente em foco no carrossel.
final selectedCreditCardProvider = Provider<CreditCard?>((ref) {
  final cards = ref.watch(cardsListProvider).value ?? const [];
  if (cards.isEmpty) return null;

  final selectedId = ref.watch(selectedCardIdProvider);
  if (selectedId != null) {
    for (final card in cards) {
      if (card.id == selectedId) return card;
    }
  }

  return cards.firstWhere(
    (c) => c.isDefault,
    orElse: () => cards.first,
  );
});

/// Provedor da fatura atual do cartão selecionado.
final currentInvoiceProvider = FutureProvider<Invoice?>((ref) async {
  final selectedCard = ref.watch(selectedCreditCardProvider);
  if (selectedCard == null) return null;

  final repo = ref.watch(creditCardRepositoryProvider);
  final result = await repo.getCurrentInvoice(selectedCard.id);
  return result.when(
    onSuccess: (invoice) => invoice,
    onFailure: (_) => null,
  );
});

/// Provedor das compras parceladas ativas do cartão selecionado.
final activeInstallmentsProvider = FutureProvider<List<CardExpense>>((
  ref,
) async {
  final selectedCard = ref.watch(selectedCreditCardProvider);
  if (selectedCard == null) return const [];

  final repo = ref.watch(creditCardRepositoryProvider);
  final result = await repo.getActiveInstallments(selectedCard.id);
  return result.when(
    onSuccess: (expenses) => expenses,
    onFailure: (_) => const [],
  );
});

/// Provedor do valor mensal total comprometido em parcelas ativas do cartão selecionado.
final monthlyInstallmentTotalProvider = Provider<Money>((ref) {
  final installments = ref.watch(activeInstallmentsProvider).value ?? const [];
  var total = const Money.zero();
  for (final exp in installments) {
    total += exp.amount;
  }
  return total;
});

/// Provedor do saldo total restante de todas as parcelas ativas do cartão selecionado.
final totalInstallmentRemainingProvider = Provider<Money>((ref) {
  final installments = ref.watch(activeInstallmentsProvider).value ?? const [];
  var total = const Money.zero();
  for (final exp in installments) {
    total += exp.remainingAmount;
  }
  return total;
});

/// Provedor da lista de todas as faturas de um cartão específico.
final cardInvoicesProvider =
    FutureProvider.family<List<Invoice>, String>((ref, cardId) async {
  final repo = ref.watch(creditCardRepositoryProvider);
  final result = await repo.getInvoices(cardId);
  return result.when(
    onSuccess: (list) => list,
    onFailure: (_) => const [],
  );
});

/// Provedor de todos os lançamentos/despesas registrados para um cartão específico.
final cardExpensesProvider =
    FutureProvider.family<List<CardExpense>, String>((ref, cardId) async {
  final repo = ref.watch(creditCardRepositoryProvider);
  final result = await repo.getExpenses(cardId);
  return result.when(
    onSuccess: (list) => list,
    onFailure: (_) => const [],
  );
});
