import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card de estado vazio quando a conta bancária ainda não possui lançamentos registrados.
class AccountEmptyTransactionsCard extends StatelessWidget {
  final String accountId;

  const AccountEmptyTransactionsCard({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceElevated,
              border: Border.all(color: AppColors.outline),
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 28,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma movimentação nesta conta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Os lançamentos, receitas, despesas e transferências vinculados a esta conta aparecerão listados aqui em ordem cronológica.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: '+ Adicionar primeira movimentação',
              icon: Icons.add_circle_outline,
              onPressed: () => TransactionFormSheet.show(
                context,
                initialAccountId: accountId,
                initialType: TransactionType.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
