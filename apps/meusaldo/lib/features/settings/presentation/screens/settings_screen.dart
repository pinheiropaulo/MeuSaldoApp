import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/home/presentation/state/home_providers.dart';
import 'package:meusaldo/features/settings/presentation/state/settings_providers.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Tela de configurações gerais, preferências financeiras e privacidade do usuário.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final hideCents = ref.watch(hideCentsProvider);
    final isBalanceVisible = ref.watch(isBalanceVisibleProvider);
    final biometrics = ref.watch(biometricsEnabledProvider);
    final invoiceAlerts = ref.watch(invoiceAlertsEnabledProvider);
    final budgetAlerts = ref.watch(budgetAlertsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Configurações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Perfil do Usuário
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryHighlight),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Usuário',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        user?.email ?? 'usuario@email.com',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('settings_edit_profile_button'),
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryHighlight),
                  onPressed: () => context.push(AppRoutes.editProfile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Seção Preferências Financeiras
          _buildSectionTitle('Preferências Financeiras'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.currency_exchange, color: AppColors.primaryHighlight, size: 22),
                    title: Text('Moeda Padrão', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                    subtitle: Text('Real Brasileiro (BRL R\$)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                  const Divider(height: 1, color: AppColors.outline),
                  SwitchListTile(
                    secondary: const Icon(Icons.money_off_outlined, color: AppColors.primaryHighlight, size: 22),
                    title: const Text('Ocultar Centavos', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                    subtitle: const Text('Arredondar valores no extrato', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    value: hideCents,
                    onChanged: (v) => ref.read(hideCentsProvider.notifier).set(v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Seção Segurança & Privacidade
          _buildSectionTitle('Segurança & Privacidade'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  SwitchListTile(
                    key: const Key('settings_balance_visible_switch'),
                    secondary: const Icon(Icons.visibility_off_outlined, color: AppColors.primaryHighlight, size: 22),
                    title: const Text('Exibir Saldos ao Abrir', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                    subtitle: const Text('Manter saldos visíveis na tela inicial', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    value: isBalanceVisible,
                    onChanged: (v) => ref.read(isBalanceVisibleProvider.notifier).toggle(),
                  ),
                  const Divider(height: 1, color: AppColors.outline),
                  SwitchListTile(
                    key: const Key('settings_biometrics_switch'),
                    secondary: const Icon(Icons.fingerprint, color: AppColors.primaryHighlight, size: 22),
                    title: const Text('Bloqueio por Biometria', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                    subtitle: const Text('Exigir autenticação ao iniciar o aplicativo', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    value: biometrics,
                    onChanged: (v) => ref.read(biometricsEnabledProvider.notifier).set(v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Seção Notificações
          _buildSectionTitle('Notificações & Alertas'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.calendar_today_outlined, color: AppColors.primaryHighlight, size: 22),
                    title: const Text('Vencimento de Faturas', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                    subtitle: const Text('Alertas para faturas e contas próximas', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    value: invoiceAlerts,
                    onChanged: (v) => ref.read(invoiceAlertsEnabledProvider.notifier).set(v),
                  ),
                  const Divider(height: 1, color: AppColors.outline),
                  SwitchListTile(
                    secondary: const Icon(Icons.track_changes, color: AppColors.primaryHighlight, size: 22),
                    title: const Text('Alertas de Teto Orçamentário', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                    subtitle: const Text('Avisar quando ultrapassar 80% e 100% do teto', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    value: budgetAlerts,
                    onChanged: (v) => ref.read(budgetAlertsEnabledProvider.notifier).set(v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'MeuSaldo v1.0.0 (Dark Burgundy Edition)\n100% Pessoal e Privado',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }
}
