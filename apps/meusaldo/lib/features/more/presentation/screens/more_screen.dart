import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/more/presentation/widgets/category_hero_menu_item.dart';
import 'package:meusaldo/features/more/presentation/widgets/more_menu_card.dart';
import 'package:meusaldo/features/more/presentation/widgets/user_profile_bento_card.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';

/// Tela orquestradora da Aba Mais com perfil, cadastros, preferências e suporte.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final categoriesAsync = ref.watch(categoriesListProvider);
    final totalCategories = categoriesAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.tune, color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserProfileBentoCard(
              name: user?.name,
              email: user?.email,
              onEdit: () => context.push(AppRoutes.editProfile),
            ),
            const SizedBox(height: 16),
            MoreMenuCard(
              title: 'Cadastros & Classificação',
              trailingHeader: 'Atalhos rápidos',
              topHeroWidget: CategoryHeroMenuItem(
                totalCategories: totalCategories,
                onTap: () => context.push(AppRoutes.categories),
              ),
              items: [
                MoreMenuItemData(
                  icon: Icons.repeat,
                  title: 'Lançamentos Recorrentes',
                  subtitle: 'Regras de repetição e despesas fixas',
                  onTap: () => context.push(AppRoutes.recurring),
                ),
                MoreMenuItemData(
                  icon: Icons.calendar_month_outlined,
                  title: 'Agenda & Contas a Vencer',
                  subtitle: 'Previsão de contas a pagar e faturas',
                  onTap: () => context.push(AppRoutes.schedule),
                ),
                MoreMenuItemData(
                  icon: Icons.track_changes, title: 'Orçamentos & Metas',
                  subtitle: 'Tetos de gastos mensais por categoria', onTap: () => context.push(AppRoutes.budgets),
                ),
                MoreMenuItemData(
                  icon: Icons.bar_chart, title: 'Relatório Mensal & Gráficos',
                  subtitle: 'Balanço, economia e evolução de gastos', onTap: () => context.push(AppRoutes.reports),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MoreMenuCard(
              title: 'Preferências & Sistema',
              items: [
                const MoreMenuItemData(
                  icon: Icons.dark_mode_outlined,
                  title: 'Aparência / Tema',
                  subtitle: 'Tema Escuro ativo (Dark Burgundy)',
                  trailing: Icon(Icons.check_circle, color: AppColors.primaryHighlight, size: 20),
                ),
                MoreMenuItemData(
                  icon: Icons.settings_outlined,
                  title: 'Configurações Gerais',
                  subtitle: 'Moeda, ciclo contábil e preferências',
                  onTap: () => context.push(AppRoutes.settings),
                ),
                MoreMenuItemData(
                  icon: Icons.notifications_outlined, title: 'Notificações & Alertas',
                  subtitle: 'Lembretes de vencimento de fatura e metas', onTap: () => context.push(AppRoutes.settings),
                ),
                MoreMenuItemData(
                  icon: Icons.fingerprint, title: 'Segurança & Biometria',
                  subtitle: 'Proteção por biometria e PIN de 6 dígitos', onTap: () => context.push(AppRoutes.settings),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MoreMenuCard(
              title: 'Suporte & Sessão',
              items: [
                const MoreMenuItemData(
                  icon: Icons.help_outline,
                  title: 'Ajuda & Termos de Uso',
                  subtitle: 'Central de ajuda e política de privacidade',
                ),
                MoreMenuItemData(
                  key: const Key('more_logout_button'),
                  icon: Icons.logout,
                  title: 'Encerrar Sessão',
                  subtitle: 'Desconectar conta deste dispositivo',
                  isDestructive: true,
                  onTap: () => _handleLogout(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'MeuSaldo v1.0.0 (Beta)\nDark Burgundy Edition',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Encerrar Sessão',
      message: 'Tem certeza de que deseja sair da sua conta?',
      confirmLabel: 'Sair',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão encerrada com sucesso.')),
        );
      }
    }
  }
}
