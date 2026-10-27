import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/home/presentation/state/home_providers.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_accounts_section.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_balance_card.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_header.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:meusaldo/features/home/presentation/widgets/home_upcoming_alert.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';

/// Tela orquestradora inicial (Dashboard / Resumo do mês).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsListProvider).value ?? const [];
    final consolidatedBalance = ref.watch(consolidatedBalanceProvider);
    final monthlyIncome = ref.watch(currentMonthIncomeTotalProvider);
    final monthlyExpenses = ref.watch(currentMonthExpensesTotalProvider);
    final isBalanceVisible = ref.watch(isBalanceVisibleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppColors.primaryHighlight,
              size: 26,
            ),
            SizedBox(width: 9),
            Text(
              'MeuSaldo',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificações',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nenhuma notificação pendente no momento.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryHighlight,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(accountsListProvider);
          ref.invalidate(transactionsListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const HomeHeader(),
            const SizedBox(height: 18),
            HomeBalanceCard(
              consolidatedBalance: consolidatedBalance,
              monthlyIncome: monthlyIncome,
              monthlyExpenses: monthlyExpenses,
              isVisible: isBalanceVisible,
              onToggleVisibility: () {
                ref.read(isBalanceVisibleProvider.notifier).toggle();
              },
            ),
            const SizedBox(height: 22),
            HomeQuickActions(
              onExpenseTap: () => context.go(AppRoutes.transactions),
              onIncomeTap: () => context.go(AppRoutes.transactions),
              onTransferTap: () => context.go(AppRoutes.transactions),
            ),
            const SizedBox(height: 22),
            HomeUpcomingAlert(
              onScheduleTap: () => context.go(AppRoutes.cards),
            ),
            const SizedBox(height: 22),
            HomeAccountsSection(
              accounts: accounts,
              isVisible: isBalanceVisible,
              onViewAll: () => context.go(AppRoutes.accounts),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
