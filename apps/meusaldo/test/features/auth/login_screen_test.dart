import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/auth/presentation/screens/login_screen.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildLoginScreen({VoidCallback? onLoginSuccess}) {
    return ProviderScope(
      child: MaterialApp(
        home: LoginScreen(
          onLoginSuccess: onLoginSuccess,
        ),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('exibe cabeçalho, campos de e-mail, senha e botão de entrar', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Acesse sua conta'), findsOneWidget);
      expect(find.text('Informe seu e-mail e senha cadastrados para entrar'), findsOneWidget);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Não tem uma conta? '), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
    });

    testWidgets('exibe mensagem de erro quando o login falha', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      // Limpa os campos para forçar erro de validação
      await tester.enterText(find.byKey(const Key('login_email_field')), 'invalido');
      await tester.enterText(find.byKey(const Key('login_password_field')), '123');
      await tester.pumpAndSettle();

      // Clica no botão Entrar
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Deve exibir o AuthErrorBanner
      expect(find.byType(AuthErrorBanner), findsOneWidget);
      expect(
        find.text('E-mail ou senha incorretos. Verifique seus dados e tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('realiza login com sucesso quando credenciais são válidas', (tester) async {
      bool loginSuccessCalled = false;
      late ProviderContainer container;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container = ProviderContainer(),
          child: MaterialApp(
            home: LoginScreen(
              onLoginSuccess: () => loginSuccessCalled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Preenche as credenciais válidas
      await tester.enterText(find.byKey(const Key('login_email_field')), 'paulo@meusaldo.app');
      await tester.enterText(find.byKey(const Key('login_password_field')), '123456');
      await tester.pumpAndSettle();

      // Clica no botão Entrar
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(loginSuccessCalled, isTrue);
      final currentUser = container.read(authStateProvider).value;
      expect(currentUser, isNotNull);
      expect(currentUser?.email, 'paulo@meusaldo.app');
    });
  });
}
