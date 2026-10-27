import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Campo hero central para digitação destacada do valor monetário da movimentação.
class TransactionAmountHeroInput extends StatelessWidget {
  /// Controlador do texto monetário.
  final TextEditingController controller;

  /// Tipo de movimentação associado para coloração semântica.
  final TransactionType transactionType;

  const TransactionAmountHeroInput({
    super.key,
    required this.controller,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (transactionType) {
      TransactionType.income => AppColors.income,
      TransactionType.expense => AppColors.expense,
      TransactionType.transfer => AppColors.transfer,
    };

    final prefix = switch (transactionType) {
      TransactionType.income => '+ R\$ ',
      TransactionType.expense => '- R\$ ',
      TransactionType.transfer => 'R\$ ',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            'VALOR DO LANÇAMENTO *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                prefix,
                style: AppTypography.currencyHero(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IntrinsicWidth(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTypography.currencyHero(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0,00',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
