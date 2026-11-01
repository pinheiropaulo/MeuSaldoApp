import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/routing/scaffold_shell.dart';
import 'package:meusaldo/features/accounts/presentation/screens/account_details_screen.dart';
import 'package:meusaldo/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:meusaldo/features/accounts/presentation/screens/edit_account_screen.dart';
import 'package:meusaldo/features/auth/presentation/screens/login_screen.dart';
import 'package:meusaldo/features/auth/presentation/screens/splash_screen.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/cards/presentation/screens/cards_screen.dart';
import 'package:meusaldo/features/home/presentation/screens/home_screen.dart';
import 'package:meusaldo/features/more/presentation/screens/more_screen.dart';
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
    final isSplashing = state.matchedLocation == AppRoutes.splash;

    if (!isLoggedIn) {
      return isLoggingIn ? null : AppRoutes.login;
    }

    if (isLoggingIn || isSplashing) {
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
        path: AppRoutes.schedule,
        builder: (context, state) => const BillScheduleScreen(),
      ),
      GoRoute(
        path: AppRoutes.recurring,
        builder: (context, state) => const RecurringTransactionsScreen(),
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
