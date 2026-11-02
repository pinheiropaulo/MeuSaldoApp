import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_visuals.dart';
import 'package:meusaldo/features/reports/presentation/state/report_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Seção com divisão detalhada das despesas por categoria e barras proporcionais.
class CategoryDistributionSection extends StatelessWidget {
  final List<CategoryExpenseShare> shares;

  const CategoryDistributionSection({
    super.key,
    required this.shares,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distribuição por Categoria',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Top gastos',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (shares.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Nenhuma despesa registrada neste mês.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            )
          else
            for (int i = 0; i < shares.length; i++) ...[
              _buildCategoryShareItem(context, shares[i], currencyFmt),
              if (i < shares.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  Widget _buildCategoryShareItem(
    BuildContext context,
    CategoryExpenseShare share,
    NumberFormat currencyFmt,
  ) {
    final color = CategoryVisuals.colorForCategory(share.category);
    final pctFormatted = (share.percentage * 100).toStringAsFixed(1);

    return InkWell(
      key: Key('report_category_share_${share.category.id}'),
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (share.category.id != 'sem_categoria') {
          context.push('/categories/${share.category.id}');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      share.category.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      currencyFmt.format(share.spent.cents / 100),
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($pctFormatted%)',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: share.percentage.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
