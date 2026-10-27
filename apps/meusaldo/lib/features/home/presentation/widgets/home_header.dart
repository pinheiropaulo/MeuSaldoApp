import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Seção superior da tela inicial contendo saudação personalizada e indicador do mês.
class HomeHeader extends StatelessWidget {
  /// Nome do usuário para personalização da saudação.
  final String userName;

  const HomeHeader({
    super.key,
    this.userName = 'Paulo',
  });

  static const _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia, $userName';
    if (hour < 18) return 'Boa tarde, $userName';
    return 'Boa noite, $userName';
  }

  String _getCurrentMonthName() {
    final monthIndex = DateTime.now().month - 1;
    if (monthIndex >= 0 && monthIndex < _monthNames.length) {
      return _monthNames[monthIndex];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _getCurrentMonthName();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seu mês em ordem.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: AppColors.primaryHighlight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    monthName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
