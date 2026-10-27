import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_balance_preview.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_exclusion_zone.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_form_header.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_initial_balance_field.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_type_selector.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/bank_name_autocomplete.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// BottomSheet para criação ou edição de conta financeira.
class AccountFormSheet extends ConsumerStatefulWidget {
  /// Conta financeira existente para edição, ou nula caso seja nova conta.
  final FinancialAccount? initialAccount;

  const AccountFormSheet({
    super.key,
    this.initialAccount,
  });

  /// Exibe o formulário de conta via bottom sheet modal.
  static Future<bool?> show(
    BuildContext context, {
    FinancialAccount? account,
  }) {
    return showAppBottomSheet<bool>(
      context: context,
      builder: (_) => AccountFormSheet(initialAccount: account),
    );
  }

  @override
  ConsumerState<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<AccountFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late AccountType _selectedType;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.initialAccount != null;

  @override
  void initState() {
    super.initState();
    final account = widget.initialAccount;
    _nameController = TextEditingController(text: account?.name ?? '');
    _balanceController = TextEditingController(
      text: account != null
          ? account.initialBalance.format(includeSymbol: false)
          : '0,00',
    );
    _selectedType = account?.type ?? AccountType.checking;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'O nome da conta é obrigatório.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final notifier = ref.read(accountsListProvider.notifier);

    if (_isEditing) {
      final updated = widget.initialAccount!.copyWith(
        name: name,
        type: _selectedType,
        updatedAt: DateTime.now(),
      );
      final result = await notifier.updateAccount(updated);
      if (!mounted) return;
      if (result.isSuccess) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              result.failureOrNull?.message ?? 'Erro ao atualizar conta';
        });
      }
    } else {
      final initialBalance =
          Money.tryParse(_balanceController.text) ?? const Money.zero();
      final newAccount = FinancialAccount.create(
        id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: _selectedType,
        initialBalance: initialBalance,
      );
      final result = await notifier.addAccount(newAccount);
      if (!mounted) return;
      if (result.isSuccess) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              result.failureOrNull?.message ?? 'Erro ao criar conta';
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    final account = widget.initialAccount;
    if (account == null) return;

    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'Excluir conta',
      message:
          'Deseja realmente excluir "${account.name}"? As movimentações registradas não serão apagadas.',
      confirmLabel: 'Excluir',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      setState(() => _isLoading = true);
      final result =
          await ref.read(accountsListProvider.notifier).deleteAccount(account.id);
      if (mounted) {
        if (result.isSuccess) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage =
                result.failureOrNull?.message ?? 'Erro ao excluir conta';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccountFormHeader(
              isEditing: _isEditing,
              onClose: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.expense, width: 1),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.expense, fontSize: 13),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              'Nome da conta *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            BankNameAutocomplete(
              controller: _nameController,
              onBankSelected: (bank) {
                if (bank.type.toLowerCase().contains('digital')) {
                  setState(() => _selectedType = AccountType.digitalWallet);
                } else if (bank.type.toLowerCase().contains('tradicional')) {
                  setState(() => _selectedType = AccountType.checking);
                }
              },
            ),
            const SizedBox(height: 18),
            Text(
              'Tipo de conta *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            AccountTypeSelector(
              selectedType: _selectedType,
              onTypeChanged: (type) => setState(() => _selectedType = type),
            ),
            const SizedBox(height: 18),
            if (_isEditing)
              AccountBalancePreview(
                balance: widget.initialAccount!.currentBalance,
              )
            else
              AccountInitialBalanceField(controller: _balanceController),
            const SizedBox(height: 24),
            if (_isEditing) ...[
              AccountExclusionZone(
                isLoading: _isLoading,
                onDelete: _handleDelete,
              ),
              const SizedBox(height: 16),
            ],
            AppButton(
              label: _isEditing ? 'Salvar alterações' : 'Salvar conta',
              icon: Icons.check_circle_outline,
              isLoading: _isLoading,
              onPressed: _handleSave,
            ),
            const SizedBox(height: 10),
            AppButton.outlined(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
