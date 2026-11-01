import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/accounts/presentation/widgets/account_visuals.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Campos de entrada estruturados para edição de lançamento (Descrição, Categoria, Contas e Notas).
class EditTransactionFields extends StatelessWidget {
  const EditTransactionFields({
    super.key,
    required this.descController,
    required this.notesController,
    required this.selectedType,
    required this.accounts,
    required this.categories,
    required this.selectedAccountId,
    required this.selectedDestinationAccountId,
    required this.selectedCategoryId,
    required this.onAccountChanged,
    required this.onDestinationAccountChanged,
    required this.onCategoryChanged,
  });

  final TextEditingController descController;
  final TextEditingController notesController;
  final TransactionType selectedType;
  final List<FinancialAccount> accounts;
  final List<Category> categories;
  final String? selectedAccountId;
  final String? selectedDestinationAccountId;
  final String? selectedCategoryId;
  final ValueChanged<String?> onAccountChanged;
  final ValueChanged<String?> onDestinationAccountChanged;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Descrição
        _buildFieldLabel('Descrição', hint: 'Obrigatório'),
        TextField(
          key: const Key('edit_transaction_desc_field'),
          controller: descController,
          decoration: const InputDecoration(
            hintText: 'Ex: Supermercado, Salário...',
            prefixIcon: Icon(Icons.edit_note, size: 20),
          ),
        ),
        const SizedBox(height: 14),

        // Categoria (se não for transferência)
        if (selectedType != TransactionType.transfer) ...[
          _buildFieldLabel('Categoria', hint: 'Classificação'),
          _buildCategoryDropdown(),
          const SizedBox(height: 14),
        ],

        // Conta de débito/origem
        _buildFieldLabel(
          selectedType == TransactionType.transfer ? 'Conta de origem' : 'Conta financeira',
          hint: selectedType == TransactionType.income ? 'Destino do crédito' : 'Origem do débito',
        ),
        _buildAccountDropdown(
          value: selectedAccountId,
          onChanged: onAccountChanged,
        ),
        const SizedBox(height: 14),

        // Conta de destino (se for transferência)
        if (selectedType == TransactionType.transfer) ...[
          _buildFieldLabel('Conta de destino', hint: 'Destino do crédito'),
          _buildAccountDropdown(
            value: selectedDestinationAccountId,
            onChanged: onDestinationAccountChanged,
          ),
          const SizedBox(height: 14),
        ],

        // Observações
        _buildFieldLabel('Observações', hint: 'Opcional'),
        TextField(
          key: const Key('edit_transaction_notes_field'),
          controller: notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Detalhes ou notas adicionais...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(hint, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: categories.any((c) => c.id == selectedCategoryId) ? selectedCategoryId : null,
      decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined, size: 20)),
      hint: const Text('Selecione uma categoria'),
      items: categories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat.id,
          child: Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: const Icon(Icons.category, size: 12, color: AppColors.primaryHighlight),
              ),
              const SizedBox(width: 8),
              Text(cat.name, style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
      onChanged: onCategoryChanged,
    );
  }

  Widget _buildAccountDropdown({
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: accounts.any((a) => a.id == value) ? value : null,
      decoration: const InputDecoration(prefixIcon: Icon(Icons.account_balance_outlined, size: 20)),
      hint: const Text('Selecione a conta'),
      items: accounts.map((acc) {
        final color = AccountVisuals.colorForAccount(acc);
        final icon = AccountVisuals.iconForType(acc.type);
        return DropdownMenuItem<String>(
          value: acc.id,
          child: Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 8),
              Text(acc.name, style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
