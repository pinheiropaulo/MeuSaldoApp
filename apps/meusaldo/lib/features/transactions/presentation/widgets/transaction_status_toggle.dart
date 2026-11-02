import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Componente visual reutilizável para alternar entre lançamento Efetivado e Pendente.
class TransactionStatusToggle extends StatelessWidget {
  final bool isCompleted;
  final ValueChanged<bool> onChanged;
  final TransactionType type;
  final bool isFutureDate;

  const TransactionStatusToggle({
    super.key,
    required this.isCompleted,
    required this.onChanged,
    required this.type,
    this.isFutureDate = false,
  });

  String get _title {
    return switch (type) {
      TransactionType.income => 'Receita já recebida?',
      TransactionType.expense => 'Despesa já paga?',
      TransactionType.transfer => 'Transferência já realizada?',
    };
  }

  String get _subtitle {
    if (isCompleted) {
      return switch (type) {
        TransactionType.income =>
          'Efetivada: credita o saldo da conta imediatamente.',
        TransactionType.expense =>
          'Efetivada: debita o saldo da conta imediatamente.',
        TransactionType.transfer =>
          'Efetivada: debita a origem e credita o destino imediatamente.',
      };
    } else {
      return isFutureDate
          ? 'Data futura: agendada como pendente. Não altera o saldo da conta agora.'
          : 'Pendente: o saldo da conta só mudará quando você confirmar.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.income.withValues(alpha: 0.15)
                            : AppColors.alert.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.income
                              : AppColors.alert,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isCompleted ? 'Efetivado' : 'Pendente',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AppColors.income
                              : AppColors.alert,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            key: const Key('transaction_status_switch'),
            value: isCompleted,
            activeThumbColor: AppColors.primaryHighlight,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.surfaceElevated,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
