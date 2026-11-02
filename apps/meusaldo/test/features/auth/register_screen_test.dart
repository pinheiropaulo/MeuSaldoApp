import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/auth/presentation/screens/register_screen.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:meusaldo/features/auth/presentation/widgets/register/password_requirements_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildRegisterScreen({
    ProviderContainer? container,
    VoidCallback? onRegisterSuccess,
  }) {
    return UncontrolledProviderScope(
      container: container ?? ProviderContainer(),
      child: MaterialApp(
        home: RegisterScreen(onRegisterSuccess: onRegisterSuccess),
      ),
    );
  }

  group('RegisterScreen', () {
    testWidgets('exibe título, campos de cadastro e checklist de senha', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pumpAndSettle();

      expect(find.text('Criar sua conta'), findsOneWidget);
      expect(
        find.text('Comece a organizar suas finanças com simplicidade'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('register_name_field')), findsOneWidget);
      expect(find.byKey(const Key('register_email_field')), findsOneWidget);
      expect(find.byKey(const Key('register_password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_confirm_password_field')), findsOneWidget);
      expect(find.byType(PasswordRequirementsCard), findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
      expect(find.text('Já possui uma conta? '), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('valida campos obrigatórios e exibe mensagem de erro', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pumpAndSettle();

      // Clica em 'Criar conta' com tudo vazio
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AuthErrorBanner), findsOneWidget);
      expect(find.text('Informe seu nome completo.'), findsOneWidget);

      // Preenche nome mas sem e-mail válido
      await tester.enterText(find.byKey(const Key('register_name_field')), 'Novo Usuário');
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Informe um endereço de e-mail válido.'), findsOneWidget);

      // Preenche e-mail mas senha curta (< 8 chars)
      await tester.enterText(find.byKey(const Key('register_email_field')), 'novo@meusaldo.app');
      await tester.enterText(find.byKey(const Key('register_password_field')), '123');
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('A senha deve possuir no mínimo 8 caracteres.'), findsOneWidget);

      // Preenche senha válida mas confirmação diferente
      await tester.enterText(find.byKey(const Key('register_password_field')), 'Senha@1234');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'Senha@9999');
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('As senhas não coincidem. Digite novamente.'), findsOneWidget);
    });

    testWidgets('cadastra usuário com sucesso e atualiza o estado de autenticação', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      bool successCalled = false;

      await tester.pumpWidget(
        buildRegisterScreen(
          container: container,
          onRegisterSuccess: () => successCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('register_name_field')), 'Maria Silva');
      await tester.enterText(find.byKey(const Key('register_email_field')), 'maria@meusaldo.app');
      await tester.enterText(find.byKey(const Key('register_password_field')), 'SenhaForte@123');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'SenhaForte@123');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
      final currentUser = container.read(authStateProvider).value;
      expect(currentUser, isNotNull);
      expect(currentUser?.name, 'Maria Silva');
      expect(currentUser?.email, 'maria@meusaldo.app');
    });
  });
}
