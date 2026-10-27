import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Campo de entrada de texto com sugestão inteligente dos principais bancos brasileiros.
class BankNameAutocomplete extends StatelessWidget {
  /// Controlador do texto para o nome da conta.
  final TextEditingController controller;

  /// Callback disparado quando uma instituição financeira é selecionada da lista.
  final ValueChanged<Bank>? onBankSelected;

  const BankNameAutocomplete({
    super.key,
    required this.controller,
    this.onBankSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Bank>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Bank>.empty();
        }
        return Bank.defaultBrazilianBanks.where((bank) {
          return bank.name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (bank) => bank.name,
      onSelected: (bank) {
        controller.text = bank.name;
        onBankSelected?.call(bank);
      },
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
        controller.addListener(() {
          if (fieldController.text != controller.text) {
            fieldController.text = controller.text;
          }
        });
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          onChanged: (val) => controller.text = val,
          decoration: const InputDecoration(
            hintText: 'Ex: Conta principal, Nubank, Itaú...',
            prefixIcon: Icon(Icons.account_balance, size: 20),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final bank = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      bank.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      bank.type,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => onSelected(bank),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
