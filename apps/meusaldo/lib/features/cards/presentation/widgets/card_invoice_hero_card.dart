import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card hero da fatura atual do cartão selecionado.
class CardInvoiceHeroCard extends StatelessWidget {
  final Invoice? invoice;
  final VoidCallback? onViewInvoiceTap;
  final VoidCallback? onPayInvoiceTap;

  static const _shortMonthNames = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ];

  const CardInvoiceHeroCard({
    super.key,
    required this.invoice,
    this.onViewInvoiceTap,
    this.onPayInvoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (invoice == null) {
      return const AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nenhuma fatura disponível para o cartão selecionado.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final inv = invoice!;
    final (statusColor, statusText) = switch (inv.status) {
      InvoiceStatus.open => (AppColors.alert, 'Fatura Aberta'),
      InvoiceStatus.closed => (AppColors.transfer, 'Fatura Fechada'),
      InvoiceStatus.paid => (AppColors.income, 'Fatura Paga'),
      InvoiceStatus.overdue => (AppColors.expense, 'Fatura Vencida'),
    };

    final monthStr = (inv.dueDate.month >= 1 && inv.dueDate.month <= 12)
        ? _shortMonthNames[inv.dueDate.month - 1]
        : '';
    final daysUntilDue = inv.dueDate.difference(DateTime.now()).inDays;
    final countdownStr = daysUntilDue >= 0
        ? '(em $daysUntilDue ${daysUntilDue == 1 ? 'dia' : 'dias'})'
        : '(vencida)';

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: AppColors.primaryHighlight,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Fatura Atual',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Total a pagar este mês',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          MoneyDisplay(
            money: inv.totalAmount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.event,
                size: 15,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: statusColor),
                  children: [
                    const TextSpan(text: 'Vencimento em '),
                    TextSpan(
                      text: '${inv.dueDate.day} $monthStr ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: countdownStr,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.outline, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  label: 'Ver Fatura',
                  icon: Icons.receipt_long,
                  onPressed: onViewInvoiceTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Pagar Fatura',
                  icon: Icons.bolt,
                  onPressed: onPayInvoiceTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
