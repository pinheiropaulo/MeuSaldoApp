/// Objeto de valor monetário imutável expresso estritamente em centavos inteiros.
///
/// Não utiliza números de ponto flutuante (`double`) para evitar imprecisões de arredondamento.
class Money implements Comparable<Money> {
  /// Valor armazenado em centavos inteiros (ex: R$ 10,50 = 1050 centavos).
  final int cents;

  /// Cria uma instância de [Money] a partir do valor em centavos.
  const Money.fromCents(this.cents);

  /// Cria um valor financeiro zerado (R$ 0,00).
  const Money.zero() : cents = 0;

  /// Cria uma instância a partir de reais inteiros e centavos opcionais.
  factory Money.fromReais(int reais, [int centavos = 0]) {
    RangeError.checkValueInInterval(
      centavos,
      0,
      99,
      'centavos',
      'Os centavos devem estar entre 0 e 99.',
    );
    if (reais < 0) {
      return Money.fromCents((reais * 100) - centavos);
    }
    return Money.fromCents((reais * 100) + centavos);
  }

  /// Converte uma string no formato brasileiro (ex: "1.234,56", "10,50", "- R$ 50,00")
  /// para [Money]. Retorna `null` se a string for inválida.
  static Money? tryParse(String? raw) {
    if (raw == null) return null;
    var cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    final isNegative = cleaned.contains('-');
    // Remove sinal de menos, símbolo da moeda e espaços em branco
    cleaned = cleaned
        .replaceAll('-', '')
        .replaceAll('+', '')
        .replaceAll('R\$', '')
        .replaceAll('r\$', '')
        .replaceAll(' ', '')
        .trim();

    if (cleaned.isEmpty) return null;

    String intPartStr;
    String decPartStr;

    if (cleaned.contains(',')) {
      // Padrão brasileiro com vírgula: remove eventuais pontos de milhar
      final parts = cleaned.split(',');
      if (parts.length != 2) return null;
      intPartStr = parts[0].replaceAll('.', '');
      decPartStr = parts[1];
    } else if (cleaned.contains('.')) {
      final parts = cleaned.split('.');
      if (parts.length == 2 && parts[1].length <= 2) {
        // Formato decimal com ponto (ex: 10.5 ou 10.50)
        intPartStr = parts[0];
        decPartStr = parts[1];
      } else {
        // Apenas separadores de milhar (ex: 1.000)
        intPartStr = cleaned.replaceAll('.', '');
        decPartStr = '';
      }
    } else {
      intPartStr = cleaned;
      decPartStr = '';
    }

    if (intPartStr.isEmpty) {
      intPartStr = '0';
    }

    final intPart = int.tryParse(intPartStr);
    if (intPart == null || intPart < 0) return null;

    int decPart = 0;
    if (decPartStr.isNotEmpty) {
      if (decPartStr.length == 1) {
        final parsed = int.tryParse(decPartStr);
        if (parsed == null || parsed < 0) return null;
        decPart = parsed * 10;
      } else if (decPartStr.length == 2) {
        final parsed = int.tryParse(decPartStr);
        if (parsed == null || parsed < 0) return null;
        decPart = parsed;
      } else {
        // Se houver mais de 2 dígitos decimais, arredonda para 2 dígitos
        final firstTwo = int.tryParse(decPartStr.substring(0, 2));
        final thirdDigit = int.tryParse(decPartStr.substring(2, 3));
        if (firstTwo == null || thirdDigit == null) return null;
        decPart = thirdDigit >= 5 ? firstTwo + 1 : firstTwo;
      }
    }

    final totalCents = (intPart * 100) + decPart;
    return Money.fromCents(isNegative ? -totalCents : totalCents);
  }

  /// Converte uma string para [Money], lançando [FormatException] se inválida.
  factory Money.parse(String raw) {
    final result = tryParse(raw);
    if (result == null) {
      throw FormatException('Formato de moeda inválido: "$raw"');
    }
    return result;
  }

  /// Indica se o valor é exatamente zero.
  bool get isZero => cents == 0;

  /// Indica se o valor é estritamente positivo (> 0).
  bool get isPositive => cents > 0;

  /// Indica se o valor é estritamente negativo (< 0).
  bool get isNegative => cents < 0;

  /// Retorna o valor absoluto.
  Money get abs => Money.fromCents(cents.abs());

  /// Retorna a parte inteira em reais.
  int get reais => cents ~/ 100;

  /// Retorna a parte fracionária em centavos (0 a 99).
  int get centavosRemainder => (cents % 100).abs();

  /// Soma com outro [Money].
  Money operator +(Money other) => Money.fromCents(cents + other.cents);

  /// Subtrai outro [Money].
  Money operator -(Money other) => Money.fromCents(cents - other.cents);

  /// Nega o valor monetário.
  Money operator -() => Money.fromCents(-cents);

  /// Multiplica por um fator inteiro.
  Money operator *(int factor) => Money.fromCents(cents * factor);

  /// Divisão inteira por um divisor.
  Money operator ~/(int divisor) {
    if (divisor == 0) {
      throw ArgumentError('Divisão por zero não é permitida.');
    }
    return Money.fromCents(cents ~/ divisor);
  }

  /// Resto da divisão inteira de centavos.
  Money operator %(int divisor) {
    if (divisor == 0) {
      throw ArgumentError('Divisão por zero não é permitida.');
    }
    return Money.fromCents(cents % divisor);
  }

  bool operator >(Money other) => cents > other.cents;
  bool operator >=(Money other) => cents >= other.cents;
  bool operator <(Money other) => cents < other.cents;
  bool operator <=(Money other) => cents <= other.cents;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          cents == other.cents;

  @override
  int get hashCode => cents.hashCode;

  /// Formata o valor monetário no padrão brasileiro.
  ///
  /// Exemplos:
  /// - Positivo: `R$ 1.234,56` (ou `1.234,56` sem símbolo)
  /// - Negativo: `- R$ 150,00` (ou `- 150,00` sem símbolo)
  /// - Zero: `R$ 0,00`
  String format({bool includeSymbol = true, bool spaceAfterNegative = true}) {
    final absCents = cents.abs();
    final reaisPart = absCents ~/ 100;
    final centsPart = absCents % 100;

    // Formata milhares com ponto
    final reaisStr = reaisPart.toString();
    final buffer = StringBuffer();
    final length = reaisStr.length;
    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(reaisStr[i]);
    }

    final formattedCents = centsPart.toString().padLeft(2, '0');
    final numberFormatted = '$buffer,$formattedCents';

    if (cents < 0) {
      final signPrefix = spaceAfterNegative ? '- ' : '-';
      return includeSymbol
          ? '${signPrefix}R\$ $numberFormatted'
          : '$signPrefix$numberFormatted';
    }

    return includeSymbol ? 'R\$ $numberFormatted' : numberFormatted;
  }

  /// Formatação padrão para exibição completa com símbolo da moeda (`R$ 10,50`).
  String get formatted => format(includeSymbol: true);

  @override
  String toString() => format(includeSymbol: true);
}
