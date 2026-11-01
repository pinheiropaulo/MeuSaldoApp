import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_details_providers.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_balance_preview.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_danger_zone.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_form_fields.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_type_selector.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
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

  Future<void> _handleSave(FinancialAccount account) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final updated = account.copyWith(
      name: _nameController.text.trim(),
      type: _selectedType,
    );
    final result =
        await ref.read(accountsListProvider.notifier).updateAccount(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (result.isSuccess && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
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

    setState(() => _isDeleting = true);
    final result =
        await ref.read(accountsListProvider.notifier).deleteAccount(account.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    if (result.isSuccess) {
      try {
        context.go('/accounts');
      } catch (_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      }
    }
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            EditAccountFormFields(nameController: _nameController),
            const SizedBox(height: 16),
            EditAccountTypeSelector(
              selectedType: _selectedType,
              onTypeChanged: (type) => setState(() => _selectedType = type),
            ),
            const SizedBox(height: 16),
            EditAccountBalancePreview(balance: account.currentBalance),
            const SizedBox(height: 16),
            EditAccountDangerZone(
              onDelete: () => _handleDelete(account),
              isDeleting: _isDeleting,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Salvar alterações',
              icon: Icons.check_circle,
              isLoading: _isSaving,
              onPressed: () => _handleSave(account),
            ),
            const SizedBox(height: 10),
            AppButton.outlined(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
