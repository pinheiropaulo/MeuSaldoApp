import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Utilitários de apresentação visual para ícones e cores de categorias financeiras.
abstract final class CategoryVisuals {
  /// Retorna o ícone Material correspondente à chave ou categoria.
  static IconData iconForCategory(Category category) {
    return iconFromKey(category.iconKey);
  }

  /// Retorna o ícone Material correspondente a uma chave de string.
  static IconData iconFromKey(String? iconKey) {
    if (iconKey == null) return Icons.category_outlined;

    return switch (iconKey.toLowerCase().trim()) {
      'restaurant' || 'food' || 'alimentacao' => Icons.restaurant,
      'home' || 'moradia' || 'casa' => Icons.home,
      'directions_car' || 'car' || 'transporte' => Icons.directions_car,
      'medical_services' || 'health' || 'saude' => Icons.medical_services,
      'sports_esports' || 'lazer' || 'game' => Icons.sports_esports,
      'shopping_bag' || 'compras' || 'shop' => Icons.shopping_bag,
      'school' || 'educacao' => Icons.school,
      'account_balance' || 'impostos' || 'taxas' => Icons.account_balance,
      'work' || 'salario' || 'job' => Icons.work,
      'payments' || 'renda' || 'money' => Icons.payments,
      'trending_up' || 'investimentos' => Icons.trending_up,
      'savings' || 'reserva' => Icons.savings,
      'flight' || 'viagem' => Icons.flight,
      'fitness_center' || 'academia' => Icons.fitness_center,
      'pets' || 'pet' => Icons.pets,
      'subscriptions' || 'assinaturas' => Icons.subscriptions,
      _ => Icons.category_outlined,
    };
  }

  /// Retorna a cor distintiva da categoria (hexadecimal ou cor semântica do tipo).
  static Color colorForCategory(Category category) {
    if (category.colorHex != null && category.colorHex!.isNotEmpty) {
      final hex = category.colorHex!.replaceAll('#', '');
      final intVal = int.tryParse(hex, radix: 16);
      if (intVal != null) {
        return Color(hex.length == 6 ? 0xFF000000 | intVal : intVal);
      }
    }

    return switch (category.type) {
      CategoryType.expense => AppColors.expense,
      CategoryType.income => AppColors.income,
      CategoryType.both => AppColors.primaryHighlight,
    };
  }
}
