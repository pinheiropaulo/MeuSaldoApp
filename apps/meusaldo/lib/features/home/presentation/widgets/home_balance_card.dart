import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card principal do dashboard com o saldo disponível e balanço de receitas/despesas do mês.
class HomeBalanceCard extends StatelessWidget {
  /// Saldo consolidado total de todas as contas ativas.
  final Money consolidatedBalance;

  /// Total de receitas efetivadas no mês corrente.
  final Money monthlyIncome;

  /// Total de despesas efetivadas no mês corrente.
  final Money monthlyExpenses;

  /// Indica se os valores monetários estão visíveis ou ocultados por privacidade.
  final bool isVisible;

  /// Callback para alternar a visibilidade dos saldos.
  final VoidCallback onToggleVisibility;

  const HomeBalanceCard({
    super.key,
    required this.consolidatedBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Círculo decorativo da marca em Dark Burgundy no canto superior direito
            Positioned(
              top: -45,
              right: -45,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brandPrimary.withValues(alpha: 0.2),
                    width: 24,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linha superior com rótulo e alternador de privacidade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saldo disponível em contas',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                      IconButton(
                        icon: Icon(
                          isVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: onToggleVisibility,
                        tooltip: isVisible ? 'Ocultar saldo' : 'Exibir saldo',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Valor do saldo em destaque
                  if (isVisible)
                    MoneyDisplay.hero(
                      money: consolidatedBalance,
                      color: consolidatedBalance.isNegative
                          ? AppColors.expense
                          : AppColors.transfer,
                    )
                  else
                    Text(
                      '••••••••',
                      style: AppTypography.currencyHero(
                        color: AppColors.transfer,
                        fontSize: 30,
                      ),
                    ),
                  const SizedBox(height: 18),

                  // Linha divisória
                  const Divider(color: AppColors.outline, height: 1),
                  const SizedBox(height: 14),

                  // Grade de métricas do mês (Receitas vs Despesas)
                  Row(
                    children: [
                      // Métrica: Receitas
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.income.withValues(alpha: 0.16),
                              ),
                              child: const Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: AppColors.income,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receitas no mês',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (isVisible)
                                    MoneyDisplay(
                                      money: monthlyIncome,
                                      color: AppColors.textPrimary,
                                      style: AppTypography.currencyRow(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  else
                                    const Text(
                                      '••••••',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Métrica: Despesas
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.expense.withValues(alpha: 0.16),
                              ),
                              child: const Icon(
                                Icons.arrow_upward,
                                size: 16,
                                color: AppColors.expense,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Despesas no mês',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (isVisible)
                                    MoneyDisplay(
                                      money: monthlyExpenses,
                                      color: AppColors.textPrimary,
                                      style: AppTypography.currencyRow(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  else
                                    const Text(
                                      '••••••',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
