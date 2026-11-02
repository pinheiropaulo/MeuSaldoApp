import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Card de confirmação exibido após o envio bem-sucedido das instruções de recuperação.
class ForgotPasswordSuccessCard extends StatelessWidget {
  final VoidCallback onResend;

  const ForgotPasswordSuccessCard({
    super.key,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.3),
                  border: Border.all(color: AppColors.primaryHighlight),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: AppColors.primaryHighlight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instruções enviadas!',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Verifique sua caixa de entrada e spam para redefinir sua senha com segurança.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.outline, height: 1),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('forgot_password_resend_button'),
              onPressed: onResend,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text(
                'Reenviar e-mail agora',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryHighlight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
