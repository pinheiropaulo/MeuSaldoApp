import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Campo de digitação de saldo inicial com formatação monetária e tipografia JetBrains Mono.
class AccountInitialBalanceField extends StatelessWidget {
  /// Controlador do texto para o saldo inicial.
  final TextEditingController controller;

  const AccountInitialBalanceField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saldo inicial (R\$) *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTypography.currencyRow(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            prefixText: 'R\$ ',
            hintText: '0,00',
            helperText: 'Saldo existente no momento do cadastro no MeuSaldo.',
          ),
        ),
      ],
    );
  }
}
