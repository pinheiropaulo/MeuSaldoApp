import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:meusaldo/features/auth/presentation/widgets/auth_header.dart';
import 'package:meusaldo/features/auth/presentation/widgets/register/email_confirmation_dialog.dart';
import 'package:meusaldo/features/auth/presentation/widgets/register/register_form.dart';

/// Tela orquestradora para criação de nova conta de usuário no MeuSaldo.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.onRegisterSuccess});

  final VoidCallback? onRegisterSuccess;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleRegister(
    String name,
    String email,
    String password,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(authStateProvider.notifier).register(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      await EmailConfirmationDialog.show(
        context,
        email: email,
        onConfirm: () {
          if (widget.onRegisterSuccess != null) {
            widget.onRegisterSuccess!();
          } else {
            context.go(AppRoutes.login);
          }
        },
      );
    } else {
      setState(() => _errorMessage =
          result.failureOrNull?.message ?? 'Erro ao cadastrar usuário.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.login),
        ),
        title: const Text('MeuSaldo'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.help_outline, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Criar sua conta',
                    subtitle: 'Comece a organizar suas finanças com simplicidade',
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null) ...[
                    AuthErrorBanner(message: _errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  RegisterForm(
                    isLoading: _isLoading,
                    onSubmit: _handleRegister,
                    onErrorChanged: (err) =>
                        setState(() => _errorMessage = err),
                  ),
                  const SizedBox(height: 24),
                  _buildLoginLink(context),
                  const SizedBox(height: 20),
                  const Text(
                    'Termos de Uso  •  Privacidade e Segurança',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
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

  Widget _buildLoginLink(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Já possui uma conta? ',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.login),
          child: const Text(
            'Entrar',
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
