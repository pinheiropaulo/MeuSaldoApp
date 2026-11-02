import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/auth/data/in_memory_auth_repository.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/home/presentation/state/home_providers.dart';
import 'package:meusaldo/features/settings/presentation/screens/settings_screen.dart';
import 'package:meusaldo/features/settings/presentation/state/settings_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  testWidgets('SettingsScreen renderiza preferências e alterna chaves reativas', (tester) async {
    final authRepo = InMemoryAuthRepository(
      initialUser: User.create(
        id: 'usr-1',
        name: 'Paulo Pinheiro',
        email: 'paulo.pinheiro@email.com',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Valida Header e Dados do Perfil
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Paulo Pinheiro'), findsOneWidget);
    expect(find.text('paulo.pinheiro@email.com'), findsOneWidget);

    // Valida Seções
    expect(find.text('Preferências Financeiras'), findsOneWidget);
    expect(find.text('Segurança & Privacidade'), findsOneWidget);
    expect(find.text('Notificações & Alertas'), findsOneWidget);

    // Alterna a chave de biometria
    final container = ProviderScope.containerOf(tester.element(find.byType(SettingsScreen)));
    expect(container.read(biometricsEnabledProvider), isFalse);

    await tester.tap(find.byKey(const Key('settings_biometrics_switch')));
    await tester.pumpAndSettle();

    expect(container.read(biometricsEnabledProvider), isTrue);

    // Alterna a chave de visibilidade de saldos
    expect(container.read(isBalanceVisibleProvider), isTrue);

    await tester.tap(find.byKey(const Key('settings_balance_visible_switch')));
    await tester.pumpAndSettle();

    expect(container.read(isBalanceVisibleProvider), isFalse);
  });
}
