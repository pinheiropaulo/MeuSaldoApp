import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/auth/presentation/widgets/profile/profile_avatar_picker.dart';
import 'package:meusaldo/features/auth/presentation/widgets/profile/profile_form_fields.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildEditProfileScreen({required ProviderContainer container}) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: EditProfileScreen(),
      ),
    );
  }

  group('EditProfileScreen', () {
    testWidgets('exibe dados atuais do usuário, avatar e campos de edição', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Efetua login para garantir usuário carregado
      await container.read(authStateProvider.notifier).login(
            email: 'paulo@meusaldo.app',
            password: 'password123',
          );

      await tester.pumpWidget(buildEditProfileScreen(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Editar Perfil'), findsOneWidget);
      expect(find.byType(ProfileAvatarPicker), findsOneWidget);
      expect(find.byType(ProfileFormFields), findsOneWidget);
      expect(find.byKey(const Key('profile_name_field')), findsOneWidget);
      expect(find.byKey(const Key('profile_email_field')), findsOneWidget);
      expect(find.byKey(const Key('profile_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('profile_save_button')), findsOneWidget);
    });

    testWidgets('valida nome vazio ao tentar salvar', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authStateProvider.notifier).login(
            email: 'paulo@meusaldo.app',
            password: 'password123',
          );

      await tester.pumpWidget(buildEditProfileScreen(container: container));
      await tester.pumpAndSettle();

      // Limpa o nome
      await tester.enterText(find.byKey(const Key('profile_name_field')), '');
      await tester.tap(find.byKey(const Key('profile_save_button')));
      await tester.pumpAndSettle();

      expect(find.text('O nome completo não pode ser vazio.'), findsOneWidget);
    });

    testWidgets('atualiza dados do usuário com sucesso', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authStateProvider.notifier).login(
            email: 'paulo@meusaldo.app',
            password: 'password123',
          );

      await tester.pumpWidget(buildEditProfileScreen(container: container));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('profile_name_field')), 'Paulo Pinheiro Editado');
      await tester.enterText(find.byKey(const Key('profile_phone_field')), '11999998888');
      await tester.tap(find.byKey(const Key('profile_save_button')));
      await tester.pumpAndSettle();

      final currentUser = container.read(authStateProvider).value;
      expect(currentUser?.name, 'Paulo Pinheiro Editado');
      expect(currentUser?.phone, '11999998888');
    });
  });
}
