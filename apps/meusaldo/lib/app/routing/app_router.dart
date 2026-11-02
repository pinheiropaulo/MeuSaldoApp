import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/routing/scaffold_shell.dart';
import 'package:meusaldo/features/accounts/presentation/screens/account_details_screen.dart';
import 'package:meusaldo/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:meusaldo/features/accounts/presentation/screens/edit_account_screen.dart';
import 'package:meusaldo/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:meusaldo/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:meusaldo/features/auth/presentation/screens/login_screen.dart';
import 'package:meusaldo/features/auth/presentation/screens/register_screen.dart';
import 'package:meusaldo/features/auth/presentation/screens/splash_screen.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/cards/presentation/screens/cards_screen.dart';
import 'package:meusaldo/features/cards/presentation/screens/invoice_details_screen.dart';
import 'package:meusaldo/features/categories/presentation/screens/budgets_screen.dart';
import 'package:meusaldo/features/categories/presentation/screens/categories_screen.dart';
import 'package:meusaldo/features/categories/presentation/screens/category_details_screen.dart';
import 'package:meusaldo/features/home/presentation/screens/home_screen.dart';
import 'package:meusaldo/features/more/presentation/screens/more_screen.dart';
import 'package:meusaldo/features/reports/presentation/screens/monthly_report_screen.dart';
import 'package:meusaldo/features/settings/presentation/screens/settings_screen.dart';
import 'package:meusaldo/features/transactions/presentation/screens/bill_schedule_screen.dart';
import 'package:meusaldo/features/transactions/presentation/screens/recurring_transactions_screen.dart';
import 'package:meusaldo/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Notificador que conecta o estado reativo de autenticação ao [GoRouter].
class AuthRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  AuthRouterNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(authStateProvider, (_, _) {
      notifyListeners();
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    if (authState.isLoading) return null;

    final isLoggedIn = authState.value != null;
    final isLoggingIn = state.matchedLocation == AppRoutes.login;
    final isRegistering = state.matchedLocation == AppRoutes.register;
    final isForgotPassword = state.matchedLocation == AppRoutes.forgotPassword;
    final isSplashing = state.matchedLocation == AppRoutes.splash;

    if (!isLoggedIn) {
      if (isLoggingIn || isRegistering || isForgotPassword) {
        return null;
      }
      return AppRoutes.login;
    }

    if (isLoggingIn || isSplashing || isRegistering || isForgotPassword) {
      return AppRoutes.home;
    }

    return null;
  }
}

/// Provedor Riverpod para a instância do [GoRouter].
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = AuthRouterNotifier(ref);
  return createRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
  );
});

/// Constrói a configuração declarativa do [GoRouter] com persistência de estado entre abas.
GoRouter createRouter({
  String initialLocation = AppRoutes.splash,
  Listenable? refreshListenable,
  GoRouterRedirect? redirect,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.schedule,
        builder: (context, state) => const BillScheduleScreen(),
      ),
      GoRoute(
        path: AppRoutes.recurring,
        builder: (context, state) => const RecurringTransactionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.categoryDetails,
        builder: (context, state) {
          final categoryId = state.pathParameters['id']!;
          return CategoryDetailsScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: AppRoutes.budgets,
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => const MonthlyReportScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountDetails,
        builder: (context, state) {
          final accountId = state.pathParameters['id']!;
          return AccountDetailsScreen(accountId: accountId);
        },
      ),
      GoRoute(
        path: AppRoutes.editAccount,
        builder: (context, state) {
          final accountId = state.pathParameters['id']!;
          return EditAccountScreen(accountId: accountId);
        },
      ),
      GoRoute(
        path: AppRoutes.cardInvoice,
        builder: (context, state) {
          final cardId = state.pathParameters['id']!;
          return InvoiceDetailsScreen(cardId: cardId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldShell(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.accounts,
                builder: (context, state) => const AccountsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cards,
                builder: (context, state) => const CardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
