import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/routing/app_routes.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/auth/presentation/state/auth_providers.dart';
import 'package:meusaldo/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:meusaldo/features/auth/presentation/widgets/forgot_password/forgot_password_form.dart';
import 'package:meusaldo/features/auth/presentation/widgets/forgot_password/forgot_password_success_card.dart';

/// Tela orquestradora para recuperação e redefinição de senha do usuário.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String _lastEmail = '';

  Future<void> _handleSendInstructions(String email) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _lastEmail = email;
    });

    final result = await ref
        .read(authStateProvider.notifier)
        .resetPassword(email: email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      setState(() => _isSuccess = true);
    } else {
      setState(() {
        _errorMessage =
            result.failureOrNull?.message ??
            'Erro ao enviar instruções de recuperação.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
        title: const Text('MeuSaldo'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderIcon(),
                  const SizedBox(height: 16),
                  const Text(
                    'Recuperar senha',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Digite o e-mail associado à sua conta do MeuSaldo. Enviaremos um link seguro com as instruções para redefinir sua senha.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    AuthErrorBanner(message: _errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  if (_isSuccess)
                    ForgotPasswordSuccessCard(
                      onResend: () => _handleSendInstructions(_lastEmail),
                    )
                  else
                    ForgotPasswordForm(
                      isLoading: _isLoading,
                      onSubmit: _handleSendInstructions,
                    ),
                  const SizedBox(height: 28),
                  _buildBackToLoginLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: const Icon(
          Icons.lock_reset,
          size: 26,
          color: AppColors.primaryHighlight,
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.login);
          }
        },
        icon: const Icon(
          Icons.arrow_back,
          size: 16,
          color: AppColors.primaryHighlight,
        ),
        label: const Text(
          'Lembrou sua senha? Voltar para o Login',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
