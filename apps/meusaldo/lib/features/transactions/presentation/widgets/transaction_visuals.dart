import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Utilitários visuais para ícones e cores semânticas de lançamentos financeiros.
abstract final class TransactionVisuals {
  /// Retorna o ícone representativo para uma movimentação.
  static IconData iconForTransaction(Transaction tx, [Category? category]) {
    if (category?.iconKey != null && category!.iconKey!.isNotEmpty) {
      final icon = _mapIconKey(category.iconKey!);
      if (icon != null) return icon;
    }

    return switch (tx.type) {
      TransactionType.income => Icons.arrow_downward,
      TransactionType.expense => Icons.arrow_upward,
      TransactionType.transfer => Icons.swap_horiz,
    };
  }

  /// Retorna a cor semântica da movimentação.
  static Color colorForTransaction(Transaction tx) {
    return switch (tx.type) {
      TransactionType.income => AppColors.income,
      TransactionType.expense => AppColors.expense,
      TransactionType.transfer => AppColors.transfer,
    };
  }

  static IconData? _mapIconKey(String key) {
    return switch (key) {
      'shopping_cart' || 'restaurant' => Icons.restaurant,
      'home' => Icons.home,
      'directions_car' || 'local_gas_station' => Icons.directions_car,
      'medical_services' => Icons.medical_services,
      'sports_esports' => Icons.sports_esports,
      'work' || 'payments' => Icons.work,
      'trending_up' || 'savings' => Icons.trending_up,
      'bolt' => Icons.bolt,
      _ => null,
    };
  }
}
