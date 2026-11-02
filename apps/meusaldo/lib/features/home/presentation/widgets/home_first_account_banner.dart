import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card de boas-vindas e incentivo ao primeiro cadastro de conta bancária/carteira.
class HomeFirstAccountBanner extends StatelessWidget {
  final VoidCallback onCreateAccount;

  const HomeFirstAccountBanner({
    super.key,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.primaryHighlight.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primaryHighlight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo ao MeuSaldo! 👋',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Vamos configurar seu primeiro saldo',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Para começar a registrar despesas, receitas e acompanhar seus gráficos, cadastre sua primeira conta bancária ou carteira.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            key: const Key('home_create_first_account_button'),
            label: '+ Cadastrar Primeira Conta',
            icon: Icons.add,
            onPressed: onCreateAccount,
          ),
        ],
      ),
    );
  }
}
