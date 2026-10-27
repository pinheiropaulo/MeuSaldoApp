import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_details_sheet.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card container com a lista de transações de uma data específica.
class TransactionGroupCard extends StatelessWidget {
  /// Lista de transações do grupo.
  final List<Transaction> transactions;

  /// Lista de contas para resolução de nomes.
  final List<FinancialAccount> accounts;

  /// Lista de categorias para resolução de nomes.
  final List<Category> categories;

  const TransactionGroupCard({
    super.key,
    required this.transactions,
    required this.accounts,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: transactions.length,
          separatorBuilder: (_, _) => const Divider(
            color: AppColors.outline,
            height: 1,
          ),
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final categoryName = categories
                .where((c) => c.id == tx.categoryId)
                .map((c) => c.name)
                .firstOrNull;
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

            return TransactionListItem(
              transaction: tx,
              categoryName: categoryName,
              accountName: accountName,
              destinationAccountName: destAccountName,
              onTap: () => TransactionDetailsSheet.show(context, tx),
            );
          },
        ),
      ),
    );
  }
}
