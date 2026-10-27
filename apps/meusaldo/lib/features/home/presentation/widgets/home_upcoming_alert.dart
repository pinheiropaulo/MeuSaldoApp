import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Card de alerta de compromisso financeiro próximo (ex: fechamento de fatura ou conta a vencer).
class HomeUpcomingAlert extends StatelessWidget {
  /// Callback ao acionar visualização da agenda.
  final VoidCallback? onScheduleTap;

  const HomeUpcomingAlert({
    super.key,
    this.onScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximo compromisso',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
            ),
            if (onScheduleTap != null)
              GestureDetector(
                onTap: onScheduleTap,
                child: const Text(
                  'Ver agenda',
                  style: TextStyle(
                    color: AppColors.primaryHighlight,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF33291C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF795C20), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.credit_card,
                size: 22,
                color: AppColors.alert,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fatura Nubank fecha em 3 dias',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimativa atual de R\$ 2.348,70. Revise os lançamentos antes do fechamento.',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFE1D2AE).withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.alert.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '3 dias',
                  style: TextStyle(
                    color: AppColors.alert,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
