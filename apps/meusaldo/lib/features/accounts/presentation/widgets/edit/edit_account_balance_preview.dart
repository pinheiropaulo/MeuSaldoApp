import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card de exibição do saldo atual da conta em modo somente leitura com aviso contábil.
class EditAccountBalancePreview extends StatelessWidget {
  final Money balance;

  const EditAccountBalancePreview({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Saldo atual',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Somente leitura',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'R\$ ',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.transfer,
                    ),
                  ),
                  Text(
                    balance.format(),
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.transfer,
                    ),
                  ),
                ],
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.transfer.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 20,
                  color: AppColors.transfer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'O saldo atual é calculado automaticamente a partir do saldo inicial e das movimentações registradas nesta conta. Não é possível editá-lo diretamente aqui para manter a consistência do seu histórico financeiro.',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
