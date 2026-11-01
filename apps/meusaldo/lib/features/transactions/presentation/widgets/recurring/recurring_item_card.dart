import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Card de exibição individual de uma recorrência com ação rápida de pausar/ativar.
class RecurringItemCard extends StatelessWidget {
  final RecurringTransaction item;
  final VoidCallback onToggle;

  const RecurringItemCard({
    super.key,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == TransactionType.income;
    final prefix = isIncome ? '+ ' : '- ';
    final amountColor = isIncome ? AppColors.income : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _buildLeadingIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: item.isActive ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _buildSubtitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prefix${item.amount.format()}',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: item.isActive ? amountColor : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    item.isActive ? 'Pausar' : 'Ativar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: item.isActive ? AppColors.textSecondary : AppColors.primaryHighlight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon() {
    final iconData = _getIconData(item.iconKey);
    final iconColor = _getIconColor(item);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Icon(
        iconData,
        size: 20,
        color: item.isActive ? iconColor : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (item.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.income.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.income.withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: const Text(
          'Ativa',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.income,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.outline,
          width: 0.8,
        ),
      ),
      child: const Text(
        'Pausada',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  String _buildSubtitle() {
    if (item.billingDayDescription != null && item.billingDayDescription!.isNotEmpty) {
      return item.billingDayDescription!;
    }
    final method = item.paymentMethod != null ? ' • ${item.paymentMethod}' : '';
    return 'Todo dia ${item.billingDay.toString().padLeft(2, '0')}$method';
  }

  IconData _getIconData(String? key) {
    switch (key) {
      case 'movie':
        return Icons.movie_outlined;
      case 'headphones':
        return Icons.headphones_outlined;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'key':
        return Icons.vpn_key_outlined;
      case 'wifi':
        return Icons.wifi;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.repeat;
    }
  }

  Color _getIconColor(RecurringTransaction item) {
    if (item.type == TransactionType.income) return AppColors.income;
    switch (item.iconKey) {
      case 'fitness_center':
        return AppColors.alert;
      case 'key':
      case 'wifi':
        return AppColors.transfer;
      case 'headphones':
        return AppColors.income;
      default:
        return AppColors.primaryHighlight;
    }
  }
}
