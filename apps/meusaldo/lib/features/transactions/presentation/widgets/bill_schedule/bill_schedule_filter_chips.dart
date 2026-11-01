import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/transactions/presentation/state/bill_schedule_providers.dart';

/// Barra de filtros horizontais por urgência e status na agenda de contas.
class BillScheduleFilterChips extends StatelessWidget {
  final BillScheduleFilter selectedFilter;
  final ValueChanged<BillScheduleFilter> onFilterSelected;
  final int totalCount;
  final int overdueCount;
  final int upcomingCount;
  final int paidCount;

  const BillScheduleFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.totalCount,
    required this.overdueCount,
    required this.upcomingCount,
    required this.paidCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            label: 'Todas ($totalCount)',
            isSelected: selectedFilter == BillScheduleFilter.all,
            onTap: () => onFilterSelected(BillScheduleFilter.all),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Atrasadas ($overdueCount)',
            isSelected: selectedFilter == BillScheduleFilter.overdue,
            hasWarningBullet: overdueCount > 0,
            onTap: () => onFilterSelected(BillScheduleFilter.overdue),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Próximas ($upcomingCount)',
            isSelected: selectedFilter == BillScheduleFilter.thisWeek,
            onTap: () => onFilterSelected(BillScheduleFilter.thisWeek),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Pagas ($paidCount)',
            isSelected: selectedFilter == BillScheduleFilter.paid,
            onTap: () => onFilterSelected(BillScheduleFilter.paid),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasWarningBullet = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryHighlight.withValues(alpha: 0.4)
                : hasWarningBullet
                    ? AppColors.expense.withValues(alpha: 0.5)
                    : AppColors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasWarningBullet) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.expense,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryHighlight
                    : hasWarningBullet
                        ? AppColors.expense
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
