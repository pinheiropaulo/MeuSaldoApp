import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Tela de opções adicionais, menu do usuário, categorias e configurações.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserCard(user?.name, user?.email),
            const SizedBox(height: 16),
            _buildMenuSection(
              title: 'Gestão Financeira',
              items: [
                _MenuItem(
                  icon: Icons.repeat,
                  label: 'Lançamentos Recorrentes',
                  onTap: () => context.push(AppRoutes.recurring),
                ),
                _MenuItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Agenda & Contas a Vencer',
                  onTap: () => context.push(AppRoutes.schedule),
                ),
                const _MenuItem(icon: Icons.category_outlined, label: 'Categorias', badge: 'Em breve'),
                const _MenuItem(icon: Icons.pie_chart_outline, label: 'Orçamentos', badge: 'Em breve'),
                const _MenuItem(icon: Icons.bar_chart_outlined, label: 'Relatórios', badge: 'Em breve'),
              ],
            ),
            const SizedBox(height: 16),
            _buildMenuSection(
              title: 'Preferências',
              items: const [
                _MenuItem(icon: Icons.settings_outlined, label: 'Configurações', badge: 'Em breve'),
                _MenuItem(icon: Icons.security_outlined, label: 'Segurança & Biometria', badge: 'Em breve'),
              ],
            ),
            const SizedBox(height: 24),
            _buildLogoutButton(context, ref),
            const SizedBox(height: 24),
            const Text(
              'MeuSaldo v1.0.0 (Beta)\nDark Burgundy Edition',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(String? name, String? email) {
    final initial = (name?.isNotEmpty == true ? name![0] : 'U').toUpperCase();
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              initial,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryHighlight),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'Usuário',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email ?? 'usuario@meusaldo.app',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({required String title, required List<_MenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: items.map((item) {
                return ListTile(
                  leading: Icon(item.icon, color: AppColors.textSecondary, size: 22),
                  title: Text(item.label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  trailing: item.badge != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.badge!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        )
                      : const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
                  onTap: item.onTap,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      key: const Key('more_logout_button'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.expense,
        side: const BorderSide(color: AppColors.expense),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.logout, size: 20),
      label: const Text('Sair da conta', style: TextStyle(fontWeight: FontWeight.w600)),
      onPressed: () async {
        await ref.read(authStateProvider.notifier).logout();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sessão encerrada com sucesso.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
  });
}
