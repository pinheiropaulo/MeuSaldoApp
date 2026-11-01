import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Seletor horizontal de meses da fatura (fatura anterior, atual e futura).
class InvoiceMonthSelector extends StatelessWidget {
  final List<Invoice> invoices;
  final String? selectedInvoiceId;
  final ValueChanged<Invoice> onInvoiceSelected;

  const InvoiceMonthSelector({
    super.key,
    required this.invoices,
    required this.selectedInvoiceId,
    required this.onInvoiceSelected,
  });

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return DateFormat('MMMM', 'pt_BR').format(DateTime(2026, month));
  }

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: invoices.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          final isSelected = invoice.id == selectedInvoiceId;
          final isCurrent =
              invoice.month == now.month && invoice.year == now.year;
          final monthName = _getMonthName(invoice.month);

          return InkWell(
            onTap: () => onInvoiceSelected(invoice),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.surfaceElevated
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryHighlight
                      : AppColors.outline,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (invoice.isPaid)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.check_circle,
                        size: 15,
                        color: AppColors.income,
                      ),
                    )
                  else if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.alert,
                        ),
                      ),
                    ),
                  Text(
                    monthName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.primaryHighlight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'Atual',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryHighlight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
