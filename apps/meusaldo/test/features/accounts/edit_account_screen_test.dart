import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/data/in_memory_account_repository.dart';
import 'package:meusaldo/features/accounts/presentation/screens/edit_account_screen.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_balance_preview.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_danger_zone.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_type_selector.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

Widget _buildTestApp({
  required FinancialAccount account,
  AccountRepository? repository,
}) {
  return ProviderScope(
    overrides: [
      if (repository != null)
        accountRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: EditAccountScreen(account: account),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final initialAccount = FinancialAccount.create(
    id: 'acc_itau_123',
    name: 'Itaú Salário',
    type: AccountType.checking,
    initialBalance: Money.fromReais(3200),
  );

  group('EditAccountScreen Widget Tests', () {
    testWidgets('renderiza campos com valores iniciais e saldo somente leitura',
        (tester) async {
      final repo = InMemoryAccountRepository(initialAccounts: [initialAccount]);

      await tester.pumpWidget(
        _buildTestApp(account: initialAccount, repository: repo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar conta'), findsOneWidget);
      expect(find.text('Nome da conta *'), findsNothing); // RichText
      expect(find.text('Itaú Salário'), findsOneWidget);
      expect(find.byType(EditAccountTypeSelector), findsOneWidget);
      expect(find.byType(EditAccountBalancePreview), findsOneWidget);
      expect(find.text('Somente leitura'), findsOneWidget);
      expect(find.text('R\$ 3.200,00'), findsOneWidget);

      await tester.drag(find.byType(Form), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.byType(EditAccountDangerZone), findsOneWidget);
      expect(find.text('Zona de exclusão'), findsOneWidget);
      expect(find.text('Salvar alterações'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('permite editar nome e tipo de conta com sucesso',
        (tester) async {
      final repo = InMemoryAccountRepository(initialAccounts: [initialAccount]);

      await tester.pumpWidget(
        _buildTestApp(account: initialAccount, repository: repo),
      );
      await tester.pumpAndSettle();

      // Altera o nome da conta
      final nameField = find.byKey(const Key('edit_account_name_field'));
      await tester.enterText(nameField, 'Itaú Reserva');
      await tester.pumpAndSettle();

      // Seleciona tipo Poupança
      await tester.tap(find.text('Conta poupança'));
      await tester.pumpAndSettle();

      // Rola até o botão salvar
      await tester.drag(find.byType(Form), const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      // Verifica no repositório se os dados foram atualizados
      final updated = await repo.getAccountById('acc_itau_123');
      expect(updated.isSuccess, isTrue);
      expect(updated.valueOrNull?.name, 'Itaú Reserva');
      expect(updated.valueOrNull?.type, AccountType.savings);
    });

    testWidgets('validação impede salvar com nome vazio', (tester) async {
      final repo = InMemoryAccountRepository(initialAccounts: [initialAccount]);

      await tester.pumpWidget(
        _buildTestApp(account: initialAccount, repository: repo),
      );
      await tester.pumpAndSettle();

      final nameField = find.byKey(const Key('edit_account_name_field'));
      await tester.enterText(nameField, '   ');
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Form), const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      // Rola de volta para o topo para visualizar o campo com erro
      await tester.drag(find.byType(Form), const Offset(0, 600));
      await tester.pumpAndSettle();

      // Permanece na tela exibindo mensagem de validação
      expect(find.text('Informe o nome da conta'), findsOneWidget);

      final current = await repo.getAccountById('acc_itau_123');
      expect(current.valueOrNull?.name, 'Itaú Salário');
    });

    testWidgets('excluir conta exibe diálogo de confirmação e remove do repositório',
        (tester) async {
      final repo = InMemoryAccountRepository(initialAccounts: [initialAccount]);

      await tester.pumpWidget(
        _buildTestApp(account: initialAccount, repository: repo),
      );
      await tester.pumpAndSettle();

      // Toca no botão de exclusão na AppBar
      await tester.tap(find.byKey(const Key('edit_account_app_bar_delete_button')));
      await tester.pumpAndSettle();

      // Confirma que abriu diálogo de confirmação
      expect(find.text('Excluir conta?'), findsOneWidget);
      expect(
        find.text(
          'A conta "Itaú Salário" será excluída do aplicativo. Deseja realmente prosseguir?',
        ),
        findsOneWidget,
      );

      // Confirma exclusão
      await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir conta'));
      await tester.pumpAndSettle();

      // Conta deve ter sido desativada (soft delete para integridade financeira)
      final check = await repo.getAccountById('acc_itau_123');
      expect(check.valueOrNull?.isActive, isFalse);

      final activeAccounts = await repo.getAllAccounts();
      expect(activeAccounts.valueOrNull, isEmpty);
    });
  });
}
