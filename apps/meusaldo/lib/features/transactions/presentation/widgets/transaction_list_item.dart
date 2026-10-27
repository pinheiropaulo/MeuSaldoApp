import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Item visual de uma movimentação financeira no extrato.
class TransactionListItem extends StatelessWidget {
  /// Movimentação financeira a ser renderizada.
  final Transaction transaction;

  /// Nome da categoria associada, se houver.
  final String? categoryName;

  /// Nome da conta associada (ou conta de origem).
  final String? accountName;

  /// Nome da conta de destino (no caso de transferências).
  final String? destinationAccountName;

  /// Ação disparada ao tocar no item (ex: abrir detalhes).
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.categoryName,
    this.accountName,
    this.destinationAccountName,
    this.onTap,
  });

  String _formatSubtitle() {
    if (transaction.isTransfer) {
      final src = accountName ?? 'Conta Origem';
      final dst = destinationAccountName ?? 'Conta Destino';
      return '$src ➔ $dst';
    }

    final cat = categoryName ?? 'Sem categoria';
    final acc = accountName ?? 'Conta';
    return '$cat • $acc';
  }

  String _formatTime() {
    final hour = transaction.date.hour.toString().padLeft(2, '0');
    final minute = transaction.date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final color = TransactionVisuals.colorForTransaction(transaction);
    final icon = TransactionVisuals.iconForTransaction(transaction);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Ícone da movimentação
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),

              // Descrição e Subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatSubtitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Valor e Horário / Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyDisplay(
                    money: transaction.amount,
                    transactionType: transaction.type,
                    showPositiveSign: transaction.isIncome,
                    color: color,
                    style: AppTypography.currencyRow(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (transaction.isPending)
                    const Text(
                      'Pendente',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.alert,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      _formatTime(),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
