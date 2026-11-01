import 'package:flutter/services.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Formatador de entrada de texto que aplica máscara monetária em centavos (padrão bancário brasileiro).
///
/// Conforme o usuário digita ou apaga dígitos numéricos, formata automaticamente
/// no padrão de moeda brasileira (ex: 2 -> "0,02", 200 -> "2,00", 200000 -> "2.000,00").
class CurrencyInputFormatter extends TextInputFormatter {
  final int maxDigits;

  const CurrencyInputFormatter({this.maxDigits = 12});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extrai apenas os dígitos numéricos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '0,00',
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    // Limita quantidade máxima de dígitos para evitar overflow
    final truncatedDigits = digitsOnly.length > maxDigits
        ? digitsOnly.substring(0, maxDigits)
        : digitsOnly;

    final cents = int.tryParse(truncatedDigits) ?? 0;
    final formatted = Money.fromCents(cents).format(includeSymbol: false);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Extrai os centavos inteiros a partir do texto formatado (ex: "2.147,60" -> 214760).
  static int parseCents(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }
}
