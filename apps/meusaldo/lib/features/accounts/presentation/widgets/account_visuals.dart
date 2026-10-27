import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Utilitários de apresentação visual para ícones e cores de contas financeiras.
abstract final class AccountVisuals {
  /// Retorna o ícone Material padrão correspondente ao tipo de conta.
  static IconData iconForType(AccountType type) {
    return switch (type) {
      AccountType.checking => Icons.account_balance,
      AccountType.savings => Icons.savings,
      AccountType.cash => Icons.payments,
      AccountType.digitalWallet => Icons.account_balance_wallet,
      AccountType.investment => Icons.trending_up,
    };
  }

  /// Retorna a cor distintiva da conta (personalizada, banco identificado ou tipo).
  static Color colorForAccount(FinancialAccount account) {
    if (account.colorHex != null && account.colorHex!.isNotEmpty) {
      final hex = account.colorHex!.replaceAll('#', '');
      final intVal = int.tryParse(hex, radix: 16);
      if (intVal != null) {
        return Color(hex.length == 6 ? 0xFF000000 | intVal : intVal);
      }
    }

    final lowerName = account.name.toLowerCase();
    if (lowerName.contains('nubank') || lowerName.contains('nu ')) {
      return const Color(0xFF820AD1);
    }
    if (lowerName.contains('inter')) {
      return const Color(0xFFFF7A00);
    }
    if (lowerName.contains('itaú') || lowerName.contains('itau')) {
      return const Color(0xFFEC7000);
    }
    if (lowerName.contains('bradesco')) {
      return const Color(0xFFCC092F);
    }
    if (lowerName.contains('santander')) {
      return const Color(0xFFEA1D2C);
    }
    if (lowerName.contains('caixa')) {
      return const Color(0xFF0066B3);
    }
    if (lowerName.contains('brasil') || lowerName.contains('bb')) {
      return const Color(0xFF003882);
    }
    if (lowerName.contains('mercado pago') || lowerName.contains('pagbank')) {
      return const Color(0xFF00A9E0);
    }
    if (lowerName.contains('picpay')) {
      return const Color(0xFF11C76F);
    }

    return colorForType(account.type);
  }

  /// Retorna a cor representativa padrão baseada no tipo de conta.
  static Color colorForType(AccountType type) {
    return switch (type) {
      AccountType.checking => AppColors.transfer,
      AccountType.savings => AppColors.income,
      AccountType.cash => AppColors.alert,
      AccountType.digitalWallet => const Color(0xFF9ECAFF),
      AccountType.investment => const Color(0xFF74DB9D),
    };
  }
}
