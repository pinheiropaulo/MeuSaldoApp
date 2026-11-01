import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Estado vazio da aba de cartões quando o usuário não possui cartões cadastrados.
class CardsEmptyState extends StatelessWidget {
  final VoidCallback onAddCardPressed;

  const CardsEmptyState({
    super.key,
    required this.onAddCardPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Halo Glow e Ícone de Cartão
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.outline),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceElevated,
                    border: Border.all(
                      color: AppColors.primaryHighlight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: AppColors.primaryHighlight,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum cartão cadastrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre seus cartões de crédito para acompanhar faturas do mês, limites disponíveis e o impacto das suas compras parceladas.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              child: AppButton(
                label: 'Cadastrar Primeiro Cartão',
                icon: Icons.add_circle_outline,
                onPressed: onAddCardPressed,
              ),
            ),
            const SizedBox(height: 36),
            // Card de Privacidade e Segurança
            const AppCard(
              padding: EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryHighlight,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Controle 100% Privado',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'O MeuSaldo não se conecta aos seus bancos e não solicita senhas. Você apenas cadastra o limite e registra seus gastos manualmente.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
