import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/state/bill_schedule_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card hero de resumo da agenda de contas a vencer (Total pendente, pagas e alerta de atraso).
class BillScheduleSummaryCard extends StatelessWidget {
  final BillScheduleSummary summary;
  final Transaction? oldestOverdue;

  const BillScheduleSummaryCard({
    super.key,
    required this.summary,
    this.oldestOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONTAS PENDENTES NO MÊS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MoneyDisplay(
                      money: summary.totalPending,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${summary.pendingCount} contas aguardando baixa',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'JÁ PAGAS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    MoneyDisplay(
                      money: summary.totalPaid,
                      color: AppColors.income,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (summary.overdueCount > 0) ...[
            const SizedBox(height: 14),
            _buildOverdueAlertBanner(context),
          ],
        ],
      ),
    );
  }

  Widget _buildOverdueAlertBanner(BuildContext context) {
    final now = DateTime.now();
    final daysLate = oldestOverdue != null
        ? now.difference(oldestOverdue!.date).inDays
        : 1;

    final subtext = oldestOverdue != null
        ? '${oldestOverdue!.description} venceu há $daysLate dias'
        : 'Regularize os pagamentos pendentes';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.expense.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.expense.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.expense, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${summary.overdueCount} ${summary.overdueCount == 1 ? "conta atrasada" : "contas atrasadas"}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.expense,
                  ),
                ),
                Text(
                  subtext,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          MoneyDisplay(
            money: summary.totalOverdue,
            color: AppColors.expense,
          ),
        ],
      ),
    );
  }
}
