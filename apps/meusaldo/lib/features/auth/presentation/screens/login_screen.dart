import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:meusaldo/features/auth/presentation/widgets/auth_header.dart';
import 'package:meusaldo/features/auth/presentation/widgets/login_form.dart';

/// Tela de login e autenticação com e-mail e senha.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.onLoginSuccess,
  });

  /// Callback opcional disparado quando o login é autenticado com sucesso.
  /// Se omitido, navega para [AppRoutes.home] via GoRouter.
  final VoidCallback? onLoginSuccess;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(authStateProvider.notifier).login(
          email: email,
          password: password,
        );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      } else {
        context.go(AppRoutes.home);
      }
    } else {
      setState(() {
        _errorMessage = result.failureOrNull?.message ??
            'E-mail ou senha incorretos. Verifique seus dados e tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Acesse sua conta',
                    subtitle: 'Informe seu e-mail e senha cadastrados para entrar',
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null) ...[
                    AuthErrorBanner(message: _errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  LoginForm(
                    isLoading: _isLoading,
                    onSubmit: _handleLogin,
                  ),
                  const SizedBox(height: 24),
                  _buildRegisterLink(),
                  const SizedBox(height: 24),
                  const Text(
                    'Termos de Uso  •  Privacidade  •  Segurança',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Não tem uma conta? ',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tela de cadastro disponível em breve.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text(
            'Criar conta',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryHighlight,
            ),
          ),
        ),
      ],
    );
  }
}
