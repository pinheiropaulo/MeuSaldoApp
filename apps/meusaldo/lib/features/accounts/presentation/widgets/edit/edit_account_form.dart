import 'package:material_ui/material_ui.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_action_buttons.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_balance_preview.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_danger_zone.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_form_fields.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/edit/edit_account_type_selector.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Formulário central com os campos e botões para edição de conta financeira.
class EditAccountForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final AccountType selectedType;
  final ValueChanged<AccountType> onTypeChanged;
  final Money currentBalance;
  final VoidCallback onDelete;
  final bool isDeleting;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const EditAccountForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.selectedType,
    required this.onTypeChanged,
    required this.currentBalance,
    required this.onDelete,
    required this.isDeleting,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          EditAccountFormFields(nameController: nameController),
          const SizedBox(height: 16),
          EditAccountTypeSelector(
            selectedType: selectedType,
            onTypeChanged: onTypeChanged,
          ),
          const SizedBox(height: 16),
          EditAccountBalancePreview(balance: currentBalance),
          const SizedBox(height: 16),
          EditAccountDangerZone(
            onDelete: onDelete,
            isDeleting: isDeleting,
          ),
          EditAccountActionButtons(
            isSaving: isSaving,
            onSave: onSave,
            onCancel: onCancel,
          ),
        ],
      ),
    );
  }
}
