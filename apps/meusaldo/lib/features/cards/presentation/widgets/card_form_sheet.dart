import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_brand_selector.dart';
import 'package:meusaldo/features/cards/presentation/widgets/card_color_palette_picker.dart';
import 'package:meusaldo/shared/formatters/currency_input_formatter.dart';
import 'package:meusaldo/shared/widgets/app_bottom_sheet.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Modal bottom sheet para cadastro e edição de cartões de crédito.
class CardFormSheet extends ConsumerStatefulWidget {
  final CreditCard? initialCard;

  const CardFormSheet({
    super.key,
    this.initialCard,
  });

  /// Exibe o modal padronizado de cadastro/edição de cartão.
  static Future<void> show(BuildContext context, {CreditCard? card}) {
    return showAppBottomSheet<void>(
      context: context,
      builder: (_) => CardFormSheet(initialCard: card),
    );
  }

  @override
  ConsumerState<CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends ConsumerState<CardFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _digitsController;
  late final TextEditingController _limitController;
  late final TextEditingController _closingDayController;
  late final TextEditingController _dueDayController;

  late String _selectedBrand;
  late String _selectedColorHex;
  late bool _isDefault;
  bool _isLoading = false;

  bool get _isEditing => widget.initialCard != null;

  @override
  void initState() {
    super.initState();
    final card = widget.initialCard;
    _nameController = TextEditingController(text: card?.name ?? '');
    _digitsController =
        TextEditingController(text: card?.lastFourDigits ?? '');
    _limitController = TextEditingController(
      text: card != null ? card.totalLimit.format(includeSymbol: false) : '',
    );
    _closingDayController = TextEditingController(
      text: card != null ? card.closingDay.toString().padLeft(2, '0') : '',
    );
    _dueDayController = TextEditingController(
      text: card != null ? card.dueDay.toString().padLeft(2, '0') : '',
    );

    _selectedBrand = 'mastercard';
    _selectedColorHex = card?.colorHex ?? '#820AD1';
    _isDefault = card?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _digitsController.dispose();
    _limitController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final limitCents = CurrencyInputFormatter.parseCents(_limitController.text);
    if (limitCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um limite de crédito maior que zero.'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final closingDay = int.tryParse(_closingDayController.text) ?? 1;
    final dueDay = int.tryParse(_dueDayController.text) ?? 10;

    setState(() => _isLoading = true);

    try {
      final card = widget.initialCard != null
          ? widget.initialCard!.copyWith(
              name: _nameController.text.trim(),
              totalLimit: Money.fromCents(limitCents),
              closingDay: closingDay,
              dueDay: dueDay,
              colorHex: _selectedColorHex,
              lastFourDigits: _digitsController.text.trim().isEmpty
                  ? null
                  : _digitsController.text.trim(),
              isDefault: _isDefault,
              updatedAt: DateTime.now(),
            )
          : CreditCard.create(
              id: 'card_${DateTime.now().millisecondsSinceEpoch}',
              name: _nameController.text.trim(),
              totalLimit: Money.fromCents(limitCents),
              closingDay: closingDay,
              dueDay: dueDay,
              colorHex: _selectedColorHex,
              lastFourDigits: _digitsController.text.trim().isEmpty
                  ? null
                  : _digitsController.text.trim(),
              isDefault: _isDefault,
            );

      final result = _isEditing
          ? await ref.read(cardsListProvider.notifier).updateCard(card)
          : await ref.read(cardsListProvider.notifier).addCard(card);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Cartão atualizado com sucesso!'
                  : 'Cartão cadastrado com sucesso!',
            ),
            backgroundColor: AppColors.income,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.failureOrNull?.message ?? 'Erro ao salvar'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar cartão: $e'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContextBanner(),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 14),
              _buildDigitsField(),
              const SizedBox(height: 14),
              _buildLimitField(),
              const SizedBox(height: 14),
              _buildCycleDaysGrid(),
              const SizedBox(height: 16),
              CardBrandSelector(
                selectedBrand: _selectedBrand,
                onBrandChanged: (b) => setState(() => _selectedBrand = b),
              ),
              const SizedBox(height: 16),
              CardColorPalettePicker(
                selectedColorHex: _selectedColorHex,
                onColorChanged: (c) => setState(() => _selectedColorHex = c),
              ),
              const SizedBox(height: 16),
              _buildDefaultCardToggle(),
              const SizedBox(height: 24),
              AppButton(
                label: _isEditing ? 'Salvar alterações' : 'Salvar Cartão',
                icon: Icons.check,
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _isEditing ? 'Editar Cartão' : 'Novo Cartão',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Fechar',
        ),
      ],
    );
  }

  Widget _buildContextBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outline),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.credit_card,
            size: 20,
            color: AppColors.primaryHighlight,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cadastre seu cartão para controlar limites, fechamento de faturas e compras parceladas.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Nome do Cartão ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(
                  color: AppColors.primaryHighlight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: const Key('card_form_name_field'),
          controller: _nameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Ex: Nubank Ultravioleta, Itaú Click...',
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Informe o nome do cartão';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDigitsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Últimos 4 dígitos',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '(Opcional)',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: const Key('card_form_digits_field'),
          controller: _digitsController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            prefixText: '••••  ',
            prefixStyle: TextStyle(
              fontFamily: 'JetBrains Mono',
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            hintText: '8842',
          ),
        ),
      ],
    );
  }

  Widget _buildLimitField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Limite Total de Crédito ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(
                  color: AppColors.primaryHighlight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: const Key('card_form_limit_field'),
          controller: _limitController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            prefixText: 'R\$ ',
            prefixStyle: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.bold,
              color: AppColors.transfer,
            ),
            hintText: '0,00',
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Informe o limite do cartão';
            }
            final cents = CurrencyInputFormatter.parseCents(val);
            if (cents <= 0) return 'O limite deve ser maior que zero';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCycleDaysGrid() {
    return Row(
      children: [
        // Dia de Fechamento
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Dia Fechamento ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: AppColors.primaryHighlight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('card_form_closing_day_field'),
                controller: _closingDayController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(hintText: 'Ex: 03'),
                validator: (val) {
                  final day = int.tryParse(val ?? '');
                  if (day == null || day < 1 || day > 31) {
                    return '1 a 31';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Melhor dia de compra',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Dia de Vencimento
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Dia Vencimento ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: AppColors.primaryHighlight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('card_form_due_day_field'),
                controller: _dueDayController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(hintText: 'Ex: 10'),
                validator: (val) {
                  final day = int.tryParse(val ?? '');
                  if (day == null || day < 1 || day > 31) {
                    return '1 a 31';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Data limite de pagamento',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultCardToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Definir como Cartão Padrão',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Pré-selecionado ao registrar novas despesas',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            key: const Key('card_form_default_switch'),
            value: _isDefault,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.income,
            onChanged: (val) => setState(() => _isDefault = val),
          ),
        ],
      ),
    );
  }
}
