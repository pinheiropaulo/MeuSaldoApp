import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Item individual de conta na agenda de vencimentos com ação de dar baixa.
class BillScheduleItemCard extends StatelessWidget {
  final Transaction bill;
  final String? accountName;
  final VoidCallback onDarBaixa;

  const BillScheduleItemCard({
    super.key,
    required this.bill,
    this.accountName,
    required this.onDarBaixa,
  });

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    return '$day $month';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final isOverdue = bill.isPending && bill.date.isBefore(todayStart);
    final isPaid = bill.isCompleted;

    final formattedDate = _formatDate(bill.date);

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isPaid) {
      statusText = 'Baixa registrada em $formattedDate';
      statusColor = AppColors.income;
      statusIcon = Icons.task_alt;
    } else if (isOverdue) {
      final daysLate = todayStart.difference(bill.date).inDays;
      statusText = 'Venceu em $formattedDate (atrasada há $daysLate dias)';
      statusColor = AppColors.expense;
      statusIcon = Icons.event_busy;
    } else {
      final daysRemaining = bill.date.difference(todayStart).inDays;
      statusText = daysRemaining == 0
          ? 'Vence hoje!'
          : 'Vence em $formattedDate (em $daysRemaining dias)';
      statusColor = daysRemaining <= 3 ? AppColors.alert : AppColors.textSecondary;
      statusIcon = Icons.event;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOverdue ? AppColors.expense.withValues(alpha: 0.3) : AppColors.outline,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isOverdue
                    ? AppColors.expense.withValues(alpha: 0.15)
                    : isPaid
                        ? AppColors.income.withValues(alpha: 0.15)
                        : AppColors.surfaceElevated,
                child: Icon(
                  isPaid
                      ? Icons.check
                      : isOverdue
                          ? Icons.warning_amber
                          : Icons.receipt_long,
                  size: 18,
                  color: isPaid
                      ? AppColors.income
                      : isOverdue
                          ? AppColors.expense
                          : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isPaid ? AppColors.textSecondary : AppColors.textPrimary,
                        decoration: isPaid ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(statusIcon, size: 13, color: statusColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            statusText,
                            style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyDisplay(
                    money: bill.amount,
                    color: isPaid ? AppColors.textSecondary : AppColors.expense,
                  ),
                  if (accountName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      accountName!,
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (!isPaid) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  key: Key('dar_baixa_${bill.id}'),
                  label: isOverdue ? 'Registrar Baixa com Atraso' : 'Dar Baixa',
                  icon: Icons.check_circle_outline,
                  fullWidth: false,
                  onPressed: onDarBaixa,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
