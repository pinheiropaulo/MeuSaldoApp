import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/routing/scaffold_shell.dart';
import 'package:meusaldo/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:meusaldo/features/cards/presentation/screens/cards_screen.dart';
import 'package:meusaldo/features/home/presentation/screens/home_screen.dart';
import 'package:meusaldo/features/more/presentation/screens/more_screen.dart';
import 'package:meusaldo/features/transactions/presentation/screens/transactions_screen.dart';

/// Provedor Riverpod para a instância do [GoRouter].
final appRouterProvider = Provider<GoRouter>((ref) {
  return createRouter();
});

/// Constrói a configuração declarativa do [GoRouter] com persistência de estado entre abas.
GoRouter createRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
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
