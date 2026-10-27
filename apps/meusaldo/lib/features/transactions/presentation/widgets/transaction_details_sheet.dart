import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/money_display.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Modal bottom sheet para visualização detalhada e exclusão de um lançamento.
class TransactionDetailsSheet extends ConsumerStatefulWidget {
  /// Movimentação financeira detalhada.
  final Transaction transaction;

  const TransactionDetailsSheet({
    super.key,
    required this.transaction,
  });

  /// Exibe os detalhes do lançamento em um modal bottom sheet.
  static Future<bool?> show(BuildContext context, Transaction transaction) {
    return showAppBottomSheet<bool>(
      context: context,
      builder: (_) => TransactionDetailsSheet(transaction: transaction),
    );
  }

  @override
  ConsumerState<TransactionDetailsSheet> createState() =>
      _TransactionDetailsSheetState();
}

class _TransactionDetailsSheetState
    extends ConsumerState<TransactionDetailsSheet> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Excluir lançamento',
      message:
          'Deseja realmente excluir "${widget.transaction.description}"? O saldo das contas associadas será recalculado automaticamente.',
      confirmLabel: 'Excluir',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      setState(() => _isDeleting = true);
      final result = await ref
          .read(transactionsListProvider.notifier)
          .deleteTransaction(widget.transaction.id);

      if (mounted) {
        if (result.isSuccess) {
          Navigator.of(context).pop(true);
        } else {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.failureOrNull?.message ?? 'Erro ao excluir lançamento',
              ),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final color = TransactionVisuals.colorForTransaction(tx);
    final accounts = ref.watch(accountsListProvider).value ?? const [];
    final categories = ref.watch(categoriesListProvider).value ?? const [];

    final accountName = accounts
        .where((a) => a.id == tx.accountId)
        .map((a) => a.name)
        .firstOrNull;

    final destAccountName = tx.destinationAccountId != null
        ? accounts
            .where((a) => a.id == tx.destinationAccountId)
            .map((a) => a.name)
            .firstOrNull
        : null;

    final categoryName = tx.categoryId != null
        ? categories
            .where((c) => c.id == tx.categoryId)
            .map((c) => c.name)
            .firstOrNull
        : null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Topo do Modal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalhes do lançamento',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card Hero com Valor em Destaque
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    tx.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MoneyDisplay.hero(
                    money: tx.amount,
                    transactionType: tx.type,
                    showPositiveSign: tx.isIncome,
                    color: color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informações estruturadas
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline, width: 1),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Tipo',
                    value: switch (tx.type) {
                      TransactionType.income => 'Receita',
                      TransactionType.expense => 'Despesa',
                      TransactionType.transfer => 'Transferência entre contas',
                    },
                  ),
                  if (tx.isTransfer) ...[
                    const Divider(color: AppColors.outline, height: 16),
                    _InfoRow(
                      label: 'Origem',
                      value: accountName ?? 'Conta de origem',
                    ),
                    const Divider(color: AppColors.outline, height: 16),
                    _InfoRow(
                      label: 'Destino',
                      value: destAccountName ?? 'Conta de destino',
                    ),
                  ] else ...[
                    const Divider(color: AppColors.outline, height: 16),
                    _InfoRow(
                      label: 'Conta',
                      value: accountName ?? 'Conta padrão',
                    ),
                    if (categoryName != null) ...[
                      const Divider(color: AppColors.outline, height: 16),
                      _InfoRow(
                        label: 'Categoria',
                        value: categoryName,
                      ),
                    ],
                  ],
                  const Divider(color: AppColors.outline, height: 16),
                  _InfoRow(
                    label: 'Data',
                    value:
                        '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}',
                  ),
                  const Divider(color: AppColors.outline, height: 16),
                  _InfoRow(
                    label: 'Status',
                    value: tx.isCompleted ? 'Efetivado' : 'Pendente',
                    valueColor:
                        tx.isCompleted ? AppColors.income : AppColors.alert,
                  ),
                  if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                    const Divider(color: AppColors.outline, height: 16),
                    _InfoRow(
                      label: 'Notas',
                      value: tx.notes!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão Excluir
            AppButton.destructive(
              label: 'Excluir lançamento',
              icon: Icons.delete_outline,
              isLoading: _isDeleting,
              onPressed: _handleDelete,
            ),
            const SizedBox(height: 10),
            AppButton.outlined(
              label: 'Fechar',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
