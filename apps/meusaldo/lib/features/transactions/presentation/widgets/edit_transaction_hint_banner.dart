import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Banner informativo exibido na edição de lançamento para alertar sobre o recálculo automático de saldos.
class EditTransactionHintBanner extends StatelessWidget {
  const EditTransactionHintBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Alterações recalculam imediatamente o saldo da conta e a fatura relacionada.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
