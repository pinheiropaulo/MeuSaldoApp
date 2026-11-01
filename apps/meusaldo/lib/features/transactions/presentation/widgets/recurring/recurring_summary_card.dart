import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/state/recurring_transaction_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card hero com o impacto financeiro mensal de lançamentos recorrentes e bento breakdown.
class RecurringSummaryCard extends StatelessWidget {
  final RecurringSummary summary;

  const RecurringSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'TOTAL DE GASTOS FIXOS POR MÊS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '- R\$ ',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                summary.totalFixedExpenses.format(includeSymbol: false),
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.expense,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '/mês',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Comprometimento de ${summary.commitmentPercentage}% da sua renda fixa',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.outline, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildBentoCard(
                  title: 'Assinaturas de Streaming',
                  value: '- ${summary.subscriptionsTotal.format()}',
                  valueColor: AppColors.textPrimary,
                  subtitle: '${summary.activeSubscriptionsCount} ativas',
                  subtitleColor: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBentoCard(
                  title: 'Receita Recorrente',
                  value: '+ ${summary.incomeTotal.format()}',
                  valueColor: AppColors.income,
                  subtitle: '${summary.incomeCount} salário registrado',
                  subtitleColor: AppColors.income,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
