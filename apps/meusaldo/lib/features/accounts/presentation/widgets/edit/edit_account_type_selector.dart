import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Grade de seleção de tipo de conta com cards estilizados e indicadores visuais.
class EditAccountTypeSelector extends StatelessWidget {
  final AccountType selectedType;
  final ValueChanged<AccountType> onTypeChanged;

  const EditAccountTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (
        AccountType.checking,
        'Conta corrente',
        'Movimentação diária, PIX e transferências',
        Icons.account_balance,
      ),
      (
        AccountType.savings,
        'Conta poupança',
        'Reserva tradicional e rendimentos básicos',
        Icons.savings,
      ),
      (
        AccountType.cash,
        'Dinheiro em espécie',
        'Cédulas físicas na carteira ou cofre pessoal',
        Icons.payments,
      ),
      (
        AccountType.digitalWallet,
        'Carteira digital',
        'Apps de pagamento, pré-pagos e saldos virtuais',
        Icons.account_balance_wallet,
      ),
    ];

    return Column(
      children: options.map((opt) {
        final isSelected = selectedType == opt.$1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onTypeChanged(opt.$1),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : AppColors.surfaceElevated,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outline,
                      ),
                    ),
                    child: Icon(
                      opt.$4,
                      size: 20,
                      color: isSelected
                          ? AppColors.primaryHighlight
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt.$2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          opt.$3,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outline,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.textPrimary,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
