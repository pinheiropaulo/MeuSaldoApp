import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/categories/presentation/widgets/details/category_month_navigator.dart';
import 'package:meusaldo/features/reports/presentation/state/report_providers.dart';
import 'package:meusaldo/features/reports/presentation/widgets/category_distribution_section.dart';
import 'package:meusaldo/features/reports/presentation/widgets/monthly_report_comparison_card.dart';
import 'package:meusaldo/features/reports/presentation/widgets/monthly_report_hero_card.dart';
import 'package:meusaldo/features/reports/presentation/widgets/weekly_spending_chart.dart';

/// Tela orquestradora do relatório mensal com balanço, gráficos e distribuição de gastos.
class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportData = ref.watch(monthlyReportProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relatório Mensal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Balanço & Análise de Gastos',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const CategoryMonthNavigator(),
          const SizedBox(height: 12),
          MonthlyReportHeroCard(data: reportData),
          const SizedBox(height: 12),
          MonthlyReportComparisonCard(data: reportData),
          const SizedBox(height: 12),
          WeeklySpendingChart(data: reportData),
          const SizedBox(height: 12),
          CategoryDistributionSection(shares: reportData.categoryShares),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
