import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_details_providers.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_form.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Tela orquestradora para edição dedicada de conta financeira e exclusão segura.
class EditAccountScreen extends ConsumerStatefulWidget {
  final FinancialAccount? account;
  final String? accountId;

  const EditAccountScreen({super.key, this.account, this.accountId})
      : assert(account != null || accountId != null);

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late AccountType _selectedType;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _initialized = false;

  FinancialAccount? _getAccount() =>
      widget.account ??
      (widget.accountId != null
          ? ref.watch(accountByIdProvider(widget.accountId!))
          : null);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _selectedType = widget.account?.type ?? AccountType.checking;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.expense),
      );

  Future<void> _runAsync(Future<void> Function() fn, {required void Function(bool) onLoading}) async {
    onLoading(true);
    try {
      await fn().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      if (mounted) _showError('Tempo esgotado. Verifique sua conexão.');
    } catch (e) {
      if (mounted) _showError('Erro: $e');
    } finally {
      if (mounted) onLoading(false);
    }
  }

  Future<void> _handleSave(FinancialAccount account) async {
    if (!_formKey.currentState!.validate()) return;
    await _runAsync(onLoading: (v) => setState(() => _isSaving = v), () async {
      final updated = account.copyWith(name: _nameController.text.trim(), type: _selectedType);
      final res = await ref.read(accountsListProvider.notifier).updateAccount(updated);
      if (!mounted) return;
      if (res.isSuccess) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      } else {
        _showError(res.failureOrNull?.message ?? 'Erro ao salvar alterações.');
      }
    });
  }

  Future<void> _handleDelete(FinancialAccount account) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Excluir conta?',
      message:
          'A conta "${account.name}" será excluída do aplicativo. Deseja realmente prosseguir?',
      confirmLabel: 'Excluir conta',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    await _runAsync(onLoading: (v) => setState(() => _isDeleting = v), () async {
      final res = await ref.read(accountsListProvider.notifier).deleteAccount(account.id);
      if (!mounted) return;
      if (res.isSuccess) {
        try { context.go('/accounts'); } catch (_) { if (Navigator.of(context).canPop()) Navigator.of(context).pop(); }
      } else {
        _showError(res.failureOrNull?.message ?? 'Erro ao excluir conta.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = _getAccount();
    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar conta')),
        body: const Center(child: Text('Conta não encontrada')),
      );
    }
    if (!_initialized) {
      _initialized = true;
      if (_nameController.text.isEmpty) {
        _nameController.text = account.name;
        _selectedType = account.type;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar conta'),
        actions: [
          IconButton(
            key: const Key('edit_account_app_bar_delete_button'),
            icon: const Icon(Icons.delete_outline, color: AppColors.expense),
            tooltip: 'Excluir conta',
            onPressed: _isDeleting ? null : () => _handleDelete(account),
          ),
        ],
      ),
      body: EditAccountForm(
        formKey: _formKey,
        nameController: _nameController,
        selectedType: _selectedType,
        onTypeChanged: (type) => setState(() => _selectedType = type),
        currentBalance: account.currentBalance,
        onDelete: () => _handleDelete(account),
        isDeleting: _isDeleting,
        isSaving: _isSaving,
        onSave: () => _handleSave(account),
        onCancel: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
