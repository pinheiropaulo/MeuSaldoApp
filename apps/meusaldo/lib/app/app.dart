import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meusaldo/app/routing/app_router.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Raiz do aplicativo MeuSaldo configurado com rotas, tema Dark Burgundy e localização pt-BR.
class MeuSaldoApp extends ConsumerWidget {
  const MeuSaldoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MeuSaldo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
