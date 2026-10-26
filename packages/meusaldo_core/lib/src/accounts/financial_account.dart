import 'package:meusaldo_core/src/accounts/account_type.dart';
import 'package:meusaldo_core/src/shared/money.dart';

/// Representa uma conta financeira no MeuSaldo (ex: Conta corrente, Poupança, Carteira).
class FinancialAccount {
  /// Identificador único da conta.
  final String id;

  /// Nome de identificação (ex: "Nubank", "Carteira", "Itaú Principal").
  final String name;

  /// Tipo de conta financeira.
  final AccountType type;

  /// Saldo com o qual a conta iniciou no aplicativo.
  final Money initialBalance;

  /// Saldo atual calculado a partir do saldo inicial e das movimentações efetivadas.
  final Money currentBalance;

  /// Indica se a conta está ativa para novos lançamentos.
  final bool isActive;

  /// Código hexadecimal da cor de identificação da conta (ex: "#6D1834").
  final String? colorHex;

  /// Identificador do ícone da conta.
  final String? iconKey;

  /// Data de criação da conta no sistema.
  final DateTime createdAt;

  /// Data da última alteração de cadastro da conta.
  final DateTime? updatedAt;

  const FinancialAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.currentBalance,
    this.isActive = true,
    this.colorHex,
    this.iconKey,
    required this.createdAt,
    this.updatedAt,
  });

  /// Cria uma nova conta com saldo atual igual ao saldo inicial.
  factory FinancialAccount.create({
    required String id,
    required String name,
    required AccountType type,
    Money initialBalance = const Money.zero(),
    bool isActive = true,
    String? colorHex,
    String? iconKey,
    DateTime? createdAt,
  }) {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError.value(
        id,
        'id',
        'O identificador da conta não pode ser vazio.',
      );
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'O nome da conta não pode ser vazio.',
      );
    }

    final created = createdAt ?? DateTime.now();
    return FinancialAccount(
      id: trimmedId,
      name: trimmedName,
      type: type,
      initialBalance: initialBalance,
      currentBalance: initialBalance,
      isActive: isActive,
      colorHex: colorHex,
      iconKey: iconKey,
      createdAt: created,
    );
  }

  /// Credita um valor ao saldo atual da conta.
  FinancialAccount applyCredit(Money amount) {
    if (amount.isNegative) {
      throw ArgumentError.value(
        amount,
        'amount',
        'O valor para crédito não pode ser negativo.',
      );
    }
    return copyWith(currentBalance: currentBalance + amount);
  }

  /// Debita um valor do saldo atual da conta.
  FinancialAccount applyDebit(Money amount) {
    if (amount.isNegative) {
      throw ArgumentError.value(
        amount,
        'amount',
        'O valor para débito não pode ser negativo.',
      );
    }
    return copyWith(currentBalance: currentBalance - amount);
  }

  FinancialAccount copyWith({
    String? id,
    String? name,
    AccountType? type,
    Money? initialBalance,
    Money? currentBalance,
    bool? isActive,
    String? colorHex,
    String? iconKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final effectiveId = id != null ? id.trim() : this.id;
    if (effectiveId.isEmpty) {
      throw ArgumentError.value(
        id,
        'id',
        'O identificador da conta não pode ser vazio.',
      );
    }

    final effectiveName = name != null ? name.trim() : this.name;
    if (effectiveName.isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'O nome da conta não pode ser vazio.',
      );
    }

    return FinancialAccount(
      id: effectiveId,
      name: effectiveName,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      colorHex: colorHex ?? this.colorHex,
      iconKey: iconKey ?? this.iconKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialAccount &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          initialBalance == other.initialBalance &&
          currentBalance == other.currentBalance &&
          isActive == other.isActive &&
          colorHex == other.colorHex &&
          iconKey == other.iconKey;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    initialBalance,
    currentBalance,
    isActive,
    colorHex,
    iconKey,
  );

  @override
  String toString() =>
      'FinancialAccount(id: $id, name: $name, type: ${type.name}, currentBalance: $currentBalance)';
}
