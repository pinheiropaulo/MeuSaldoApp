import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_visuals.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Seletor em cartões dos tipos de contas financeiras suportadas no MeuSaldo.
class AccountTypeSelector extends StatelessWidget {
  /// Tipo de conta atualmente selecionado.
  final AccountType selectedType;

  /// Callback acionado quando o usuário seleciona um novo tipo.
  final ValueChanged<AccountType> onTypeChanged;

  const AccountTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  static const _options = [
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
      'Apps de pagamento, pré-pagos e virtuais',
      Icons.account_balance_wallet,
    ),
    (
      AccountType.investment,
      'Investimentos',
      'Ações, renda fixa e fundos',
      Icons.trending_up,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options.map((item) {
        final (type, title, subtitle, icon) = item;
        final isSelected = selectedType == type;
        final typeColor = AccountVisuals.colorForType(type);

        return GestureDetector(
          onTap: () => onTypeChanged(type),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryHighlight
                    : AppColors.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryHighlight,
                    size: 20,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
