import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/state/category_analytics_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/budgets/budget_category_card.dart';
import 'package:meusaldo/features/categories/presentation/widgets/budgets/budget_filter_bar.dart';
import 'package:meusaldo/features/categories/presentation/widgets/budgets/overall_budget_hero_card.dart';
import 'package:meusaldo/features/categories/presentation/widgets/details/category_month_navigator.dart';
import 'package:meusaldo/features/categories/presentation/widgets/set_budget_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Tela orquestradora de monitoramento e gestão de orçamentos mensais por categoria.
class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  BudgetFilter _currentFilter = BudgetFilter.all;

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(overallBudgetSummaryProvider);
    final reports = ref.watch(categoryBudgetReportsProvider);

    final filteredReports = reports.where((r) {
      return switch (_currentFilter) {
        BudgetFilter.all => true,
        BudgetFilter.alert =>
          r.status == CategoryBudgetStatus.warning ||
              r.status == CategoryBudgetStatus.exceeded,
        BudgetFilter.ok => r.status == CategoryBudgetStatus.ok,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orçamento Mensal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Tetos por categoria', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              key: const Key('budgets_new_limit_button'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primaryHighlight),
              label: const Text('Novo Limite', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              onPressed: () => SetBudgetSheet.show(context),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const CategoryMonthNavigator(),
          const SizedBox(height: 12),
          if (reports.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.track_changes, size: 48, color: AppColors.primaryHighlight),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhum teto orçamentário definido',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Defina tetos mensais para suas categorias de despesas para acompanhar os gastos e evitar surpresas no final do mês.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    key: const Key('budgets_empty_define_button'),
                    label: 'Definir Primeiro Teto',
                    onPressed: () => SetBudgetSheet.show(context),
                  ),
                ],
              ),
            )
          else ...[
            OverallBudgetHeroCard(summary: summary),
            const SizedBox(height: 12),
            BudgetFilterBar(
              currentFilter: _currentFilter,
              summary: summary,
              totalCount: reports.length,
              onFilterChanged: (f) => setState(() => _currentFilter = f),
            ),
            const SizedBox(height: 12),
            for (final report in filteredReports) ...[
              BudgetCategoryCard(
                report: report,
                onTap: () => context.push('/categories/${report.category.id}'),
                onEdit: () => SetBudgetSheet.show(context, category: report.category),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
