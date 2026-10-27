import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/data/in_memory_account_repository.dart';
import 'package:meusaldo/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_card_item.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_form_sheet.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/accounts_header_section.dart';
import 'package:meusaldo/shared/widgets/empty_state_widget.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

Widget _buildTestApp({AccountRepository? repository}) {
  return ProviderScope(
    overrides: [
      if (repository != null)
        accountRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: const AccountsScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccountsScreen Widget Tests', () {
    testWidgets('exibe lista de contas com cabeçalho e saldo consolidado',
        (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AccountsHeaderSection), findsOneWidget);
      expect(find.text('Saldo total consolidado'), findsOneWidget);
      expect(find.byType(AccountCardItem), findsWidgets);
      expect(find.text('+ Nova conta'), findsOneWidget);
      expect(find.text('+ Adicionar nova conta'), findsOneWidget);
    });

    testWidgets('exibe estado vazio quando não há contas cadastradas',
        (tester) async {
      final emptyRepo =
          InMemoryAccountRepository(initialAccounts: const []);
      await tester.pumpWidget(_buildTestApp(repository: emptyRepo));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('Nenhuma conta cadastrada'), findsOneWidget);
      expect(find.text('Cadastrar primeira conta'), findsOneWidget);
    });

    testWidgets('abre bottom sheet de nova conta ao tocar em + Nova conta',
        (tester) async {
      final emptyRepo =
          InMemoryAccountRepository(initialAccounts: const []);
      await tester.pumpWidget(_buildTestApp(repository: emptyRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cadastrar primeira conta'));
      await tester.pumpAndSettle();

      expect(find.byType(AccountFormSheet), findsOneWidget);
      expect(find.text('Nova conta'), findsOneWidget);
      expect(find.text('Nome da conta *'), findsOneWidget);
      expect(find.text('Salvar conta'), findsOneWidget);
    });

    testWidgets('permite cadastrar nova conta e atualiza a listagem',
        (tester) async {
      final repo = InMemoryAccountRepository(initialAccounts: const []);
      await tester.pumpWidget(_buildTestApp(repository: repo));
      await tester.pumpAndSettle();

      // Inicia com estado vazio
      expect(find.text('Nenhuma conta cadastrada'), findsOneWidget);

      // Abre cadastro
      await tester.tap(find.text('Cadastrar primeira conta'));
      await tester.pumpAndSettle();

      // Digita o nome da conta
      await tester.enterText(find.byType(TextField).first, 'Inter Global');
      await tester.pumpAndSettle();

      // Garante visibilidade do botão no scroll e salva
      await tester.ensureVisible(find.text('Salvar conta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar conta'));
      await tester.pumpAndSettle();

      // Confirma que a nova conta apareceu na tela
      expect(find.text('Inter Global'), findsOneWidget);
      expect(find.byType(AccountCardItem), findsOneWidget);
    });

    testWidgets('abre edição de conta ao tocar no item', (tester) async {
      final account = FinancialAccount.create(
        id: 'acc_nubank',
        name: 'Nubank Teste',
        type: AccountType.checking,
        initialBalance: Money.fromReais(1500),
      );
      final repo = InMemoryAccountRepository(initialAccounts: [account]);
      await tester.pumpWidget(_buildTestApp(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Nubank Teste'), findsOneWidget);

      // Toca no card da conta
      await tester.tap(find.text('Nubank Teste'));
      await tester.pumpAndSettle();

      // Confirma que abriu em modo de edição
      expect(find.text('Editar conta'), findsOneWidget);
      expect(find.text('Salvar alterações'), findsOneWidget);
      expect(find.text('Somente leitura'), findsOneWidget);
      expect(find.text('Zona de exclusão'), findsOneWidget);
    });
  });
}
