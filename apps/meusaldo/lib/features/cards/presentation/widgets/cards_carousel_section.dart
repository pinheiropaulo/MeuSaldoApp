import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_carousel_item.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Seção horizontal contendo o carrossel de cartões cadastrados.
class CardsCarouselSection extends StatelessWidget {
  final List<CreditCard> cards;
  final String? selectedCardId;
  final ValueChanged<String> onCardSelected;

  const CardsCarouselSection({
    super.key,
    required this.cards,
    required this.selectedCardId,
    required this.onCardSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEUS CARTÕES',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${cards.length} ${cards.length == 1 ? 'ativo' : 'ativos'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cards.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final card = cards[index];
              final isSelected = card.id == selectedCardId;
              return CardCarouselItem(
                card: card,
                isSelected: isSelected,
                onTap: () => onCardSelected(card.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
