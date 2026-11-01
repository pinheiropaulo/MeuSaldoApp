import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_installments_section.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_invoice_hero_card.dart';
import 'package:meusaldo/features/cards/presentation/widgets/cards_carousel_section.dart';
import 'package:meusaldo/features/cards/presentation/widgets/cards_empty_state.dart';

/// Tela orquestradora de cartões de crédito e gestão de faturas.
class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsListProvider);
    final cards = cardsAsync.value ?? const [];
    final selectedCard = ref.watch(selectedCreditCardProvider);
    final invoice = ref.watch(currentInvoiceProvider).value;
    final installments = ref.watch(activeInstallmentsProvider).value ?? const [];
    final monthlyTotal = ref.watch(monthlyInstallmentTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.credit_card,
              color: AppColors.primaryHighlight,
              size: 24,
            ),
            SizedBox(width: 8),
            Text('Cartões'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.outline),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _showAddCardNotice(context),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primaryHighlight),
              label: const Text(
                'Novo Cartão',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryHighlight,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(cardsListProvider);
        },
        child: cards.isEmpty && !cardsAsync.isLoading
            ? CardsEmptyState(
                onAddCardPressed: () => _showAddCardNotice(context),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  CardsCarouselSection(
                    cards: cards,
                    selectedCardId: selectedCard?.id,
                    onCardSelected: (cardId) {
                      ref.read(selectedCardIdProvider.notifier).selectCard(cardId);
                    },
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CardInvoiceHeroCard(
                      invoice: invoice,
                      onViewInvoiceTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Detalhe completo da fatura em breve.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      onPayInvoiceTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fluxo de pagamento de fatura em breve.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CardInstallmentsSection(
                      installments: installments,
                      monthlyTotal: monthlyTotal,
                      onViewAllTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Listagem expandida de parcelamentos em breve.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  void _showAddCardNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulário de cadastro de novo cartão na próxima etapa.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
