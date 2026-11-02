import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_visuals.dart';
import 'package:meusaldo/features/categories/presentation/widgets/details/category_budget_card.dart';
import 'package:meusaldo/features/categories/presentation/widgets/details/category_details_hero_card.dart';
import 'package:meusaldo/features/categories/presentation/widgets/details/category_month_navigator.dart';
import 'package:meusaldo/features/categories/presentation/widgets/set_budget_sheet.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_details_sheet.dart';
import 'package:meusaldo/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Tela orquestradora de detalhes analíticos de uma categoria financeira.
class CategoryDetailsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(categoryMonthDetailsProvider(categoryId));

    if (details == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Categoria')),
        body: const Center(
          child: Text(
            'Categoria não encontrada.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final category = details.category;
    final catColor = CategoryVisuals.colorForCategory(category);
    final catIcon = CategoryVisuals.iconForCategory(category);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: catColor.withValues(alpha: 0.35)),
              ),
              child: Icon(catIcon, color: catColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    category.description ?? 'Categoria',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('category_details_edit_button'),
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Editar Categoria',
            onPressed: () => CategoryFormSheet.show(context, category: category),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const CategoryMonthNavigator(),
          const SizedBox(height: 12),
          CategoryDetailsHeroCard(details: details),
          const SizedBox(height: 12),
          CategoryBudgetCard(
            report: details.budgetReport,
            onAdjustBudget: () => SetBudgetSheet.show(context, category: category),
          ),
          const SizedBox(height: 16),
          Text(
            'Lançamentos do Mês (${details.transactionsCount})',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (details.transactions.isEmpty)
            const AppCard(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text(
                      'Nenhum lançamento nesta categoria neste mês.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < details.transactions.length; i++) ...[
                    TransactionListItem(
                      transaction: details.transactions[i],
                      categoryName: category.name,
                      onTap: () => TransactionDetailsSheet.show(
                        context,
                        details.transactions[i],
                      ),
                    ),
                    if (i < details.transactions.length - 1)
                      const Divider(color: AppColors.outline, height: 1),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
