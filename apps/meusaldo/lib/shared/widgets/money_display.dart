import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Formato e exibição de valores monetários no MeuSaldo.
///
/// Segue as diretrizes visuais do Dark Burgundy:
/// - Fonte JetBrains Mono com números tabulares.
/// - Prefixo `R$` com menor ênfase visual.
/// - Valores negativos usam o sinal antes do símbolo da moeda (`- R$ 150,00`).
/// - Cores semânticas opcionais (verde para receita, vermelho para despesa, azul para transferência).
class MoneyDisplay extends StatelessWidget {
  /// Valor monetário imutável expresso em centavos inteiros.
  final Money money;

  /// Estilo tipográfico base (tamanho e peso).
  final TextStyle? style;

  /// Se deve exibir o símbolo `R$`. Padrão é `true`.
  final bool showSymbol;

  /// Tipo de movimentação associado para coloração semântica automática.
  final TransactionType? transactionType;

  /// Se deve aplicar sinal de `+` explícito para receitas positivas.
  final bool showPositiveSign;

  /// Cor customizada opcional para sobrescrever a cor padrão do tema.
  final Color? color;

  /// Se deve utilizar a tipografia destacada de hero (32px).
  final bool isHero;

  const MoneyDisplay({
    super.key,
    required this.money,
    this.style,
    this.showSymbol = true,
    this.transactionType,
    this.showPositiveSign = false,
    this.color,
  }) : isHero = false;

  /// Construtor de conveniência para destaque de grandes valores (hero/dashboard).
  const MoneyDisplay.hero({
    super.key,
    required this.money,
    this.transactionType,
    this.showPositiveSign = false,
    this.color,
  }) : style = null,
       isHero = true,
       showSymbol = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>();
    final resolvedColor = _resolveColor(colors);

    final baseStyle = style ??
        (isHero
            ? AppTypography.currencyHero(color: resolvedColor)
            : AppTypography.currencyRow(color: resolvedColor));
    final effectiveStyle = baseStyle.copyWith(color: resolvedColor);

    final prefixStyle = effectiveStyle.copyWith(
      fontSize: (effectiveStyle.fontSize ?? 15) * 0.85,
      fontWeight: FontWeight.w500,
      color: resolvedColor.withValues(alpha: 0.8),
    );

    final isNegative = money.isNegative;
    final absMoney = money.abs;
    final formattedValue = absMoney.format(includeSymbol: false);

    final String prefixText;
    if (isNegative) {
      prefixText = showSymbol ? '- R\$ ' : '- ';
    } else if (showPositiveSign && money.isPositive) {
      prefixText = showSymbol ? '+ R\$ ' : '+ ';
    } else {
      prefixText = showSymbol ? 'R\$ ' : '';
    }

    return Text.rich(
      TextSpan(
        children: [
          if (prefixText.isNotEmpty)
            TextSpan(
              text: prefixText,
              style: prefixStyle,
            ),
          TextSpan(
            text: formattedValue,
            style: effectiveStyle,
          ),
        ],
      ),
    );
  }

  Color _resolveColor(AppColorsExtension? colors) {
    if (color != null) return color!;
    if (colors == null) return AppColors.textPrimary;

    if (transactionType != null) {
      return switch (transactionType!) {
        TransactionType.income => colors.income,
        TransactionType.expense => colors.expense,
        TransactionType.transfer => colors.transfer,
      };
    }

    if (money.isNegative) {
      return colors.expense;
    }

    return colors.textPrimary;
  }
}
