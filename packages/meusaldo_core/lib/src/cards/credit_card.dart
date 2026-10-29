import 'package:meusaldo_core/src/shared/money.dart';

/// Representa um cartão de crédito cadastrado no MeuSaldo.
class CreditCard {
  /// Identificador único do cartão.
  final String id;

  /// Nome de exibição do cartão (ex: "Nubank Ultravioleta", "Itaú Click").
  final String name;

  /// Limite de crédito total concedido pela instituição.
  final Money totalLimit;

  /// Limite atualmente comprometido por faturas e parcelamentos.
  final Money usedLimit;

  /// Dia do mês em que a fatura fecha (1 a 31).
  final int closingDay;

  /// Dia do mês em que a fatura vence (1 a 31).
  final int dueDay;

  /// Código hexadecimal da cor do cartão (ex: "#6D1834").
  final String? colorHex;

  /// Últimos 4 dígitos do cartão para identificação rápida (ex: "8842").
  final String? lastFourDigits;

  /// Indica se é o cartão principal/padrão do usuário.
  final bool isDefault;

  /// Identificador opcional da instituição bancária ou conta associada.
  final String? bankId;

  /// Data de cadastro no aplicativo.
  final DateTime createdAt;

  /// Data da última alteração de cadastro.
  final DateTime? updatedAt;

  const CreditCard({
    required this.id,
    required this.name,
    required this.totalLimit,
    required this.usedLimit,
    required this.closingDay,
    required this.dueDay,
    this.colorHex,
    this.lastFourDigits,
    this.isDefault = false,
    this.bankId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Construtor de fábrica com validação rigorosa de invariantes.
  factory CreditCard.create({
    required String id,
    required String name,
    required Money totalLimit,
    Money usedLimit = const Money.zero(),
    required int closingDay,
    required int dueDay,
    String? colorHex,
    String? lastFourDigits,
    bool isDefault = false,
    String? bankId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'O identificador do cartão não pode ser vazio.');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'O nome do cartão não pode ser vazio.');
    }

    if (!totalLimit.isPositive) {
      throw ArgumentError.value(
        totalLimit,
        'totalLimit',
        'O limite total do cartão deve ser estritamente maior que zero.',
      );
    }

    if (usedLimit.isNegative) {
      throw ArgumentError.value(
        usedLimit,
        'usedLimit',
        'O limite utilizado não pode ser negativo.',
      );
    }

    if (closingDay < 1 || closingDay > 31) {
      throw ArgumentError.value(
        closingDay,
        'closingDay',
        'O dia de fechamento deve estar entre 1 e 31.',
      );
    }

    if (dueDay < 1 || dueDay > 31) {
      throw ArgumentError.value(
        dueDay,
        'dueDay',
        'O dia de vencimento deve estar entre 1 e 31.',
      );
    }

    return CreditCard(
      id: trimmedId,
      name: trimmedName,
      totalLimit: totalLimit,
      usedLimit: usedLimit,
      closingDay: closingDay,
      dueDay: dueDay,
      colorHex: colorHex,
      lastFourDigits: lastFourDigits?.trim(),
      isDefault: isDefault,
      bankId: bankId?.trim(),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt,
    );
  }

  /// Limite disponível para novas compras.
  Money get availableLimit {
    final diff = totalLimit - usedLimit;
    return diff.isNegative ? const Money.zero() : diff;
  }

  /// Percentual de limite utilizado (de 0 a 100).
  int get usedPercentage {
    if (totalLimit.cents == 0) return 0;
    final ratio = (usedLimit.cents / totalLimit.cents) * 100;
    return ratio.clamp(0, 100).round();
  }

  /// Percentual de limite livre (de 0 a 100).
  int get freePercentage => 100 - usedPercentage;

  CreditCard copyWith({
    String? id,
    String? name,
    Money? totalLimit,
    Money? usedLimit,
    int? closingDay,
    int? dueDay,
    String? colorHex,
    String? lastFourDigits,
    bool? isDefault,
    String? bankId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditCard.create(
      id: id ?? this.id,
      name: name ?? this.name,
      totalLimit: totalLimit ?? this.totalLimit,
      usedLimit: usedLimit ?? this.usedLimit,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      colorHex: colorHex ?? this.colorHex,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      isDefault: isDefault ?? this.isDefault,
      bankId: bankId ?? this.bankId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          totalLimit == other.totalLimit &&
          usedLimit == other.usedLimit &&
          closingDay == other.closingDay &&
          dueDay == other.dueDay &&
          isDefault == other.isDefault &&
          lastFourDigits == other.lastFourDigits &&
          colorHex == other.colorHex;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        id,
        name,
        totalLimit,
        usedLimit,
        closingDay,
        dueDay,
        isDefault,
        lastFourDigits,
        colorHex,
      );

  @override
  String toString() =>
      'CreditCard(id: $id, name: $name, totalLimit: $totalLimit, available: $availableLimit)';
}
