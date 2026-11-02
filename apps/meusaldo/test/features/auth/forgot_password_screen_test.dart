import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:meusaldo/features/auth/presentation/widgets/forgot_password/forgot_password_form.dart';
import 'package:meusaldo/features/auth/presentation/widgets/forgot_password/forgot_password_success_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildForgotPasswordScreen({ProviderContainer? container}) {
    return UncontrolledProviderScope(
      container: container ?? ProviderContainer(),
      child: const MaterialApp(
        home: ForgotPasswordScreen(),
      ),
    );
  }

  group('ForgotPasswordScreen', () {
    testWidgets('exibe cabeçalho, campo de e-mail e botão de envio', (tester) async {
      await tester.pumpWidget(buildForgotPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.text('Recuperar senha'), findsOneWidget);
      expect(
        find.text(
          'Digite o e-mail associado à sua conta do MeuSaldo. Enviaremos um link seguro com as instruções para redefinir sua senha.',
        ),
        findsOneWidget,
      );
      expect(find.byType(ForgotPasswordForm), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_email_field')), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_submit_button')), findsOneWidget);
      expect(find.text('Lembrou sua senha? Voltar para o Login'), findsOneWidget);
    });

    testWidgets('envia instruções e exibe card de sucesso com opção de reenvio', (tester) async {
      await tester.pumpWidget(buildForgotPasswordScreen());
      await tester.pumpAndSettle();

      // Digita o e-mail
      await tester.enterText(
        find.byKey(const Key('forgot_password_email_field')),
        'paulo@meusaldo.app',
      );
      await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
      await tester.pumpAndSettle();

      // Formulário deve ser substituído pelo ForgotPasswordSuccessCard
      expect(find.byType(ForgotPasswordForm), findsNothing);
      expect(find.byType(ForgotPasswordSuccessCard), findsOneWidget);
      expect(find.text('Instruções enviadas!'), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_resend_button')), findsOneWidget);

      // Clica em reenviar e-mail
      await tester.tap(find.byKey(const Key('forgot_password_resend_button')));
      await tester.pumpAndSettle();

      // Permanece no card de sucesso
      expect(find.byType(ForgotPasswordSuccessCard), findsOneWidget);
    });
  });
}
