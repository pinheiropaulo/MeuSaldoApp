import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';

/// Card padrão do MeuSaldo seguindo o Design System Dark Burgundy.
///
/// Apresenta raio de 12px, borda sutil de 1px (`#3D353F`), superfície `#242025`
/// e suporte a clique tátil via InkWell.
class AppCard extends StatelessWidget {
  /// Conteúdo interno do card.
  final Widget child;

  /// Espaçamento interno. Padrão: 16px.
  final EdgeInsetsGeometry padding;

  /// Espaçamento externo. Padrão: zero.
  final EdgeInsetsGeometry margin;

  /// Ação executada ao tocar no card.
  final VoidCallback? onTap;

  /// Cor de fundo opcional (sobrescreve `AppColors.surface`).
  final Color? color;

  /// Cor da borda opcional (sobrescreve `AppColors.outline`).
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.surface;
    final effectiveBorderColor = borderColor ?? AppColors.outline;
    final borderRadius = BorderRadius.circular(12);

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: 1,
        ),
      ),
      child: content,
    );
  }
}
