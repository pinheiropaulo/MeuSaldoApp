import 'package:meusaldo_core/src/categories/category_type.dart';
import 'package:meusaldo_core/src/transactions/transaction_type.dart';

/// Representa uma categoria de classificação financeira (ex: "Alimentação", "Salário", "Transporte").
class Category {
  /// Identificador único da categoria.
  final String id;

  /// Nome de exibição da categoria.
  final String name;

  /// Tipo de operação suportado pela categoria.
  final CategoryType type;

  /// Chave identificadora do ícone associado.
  final String? iconKey;

  /// Código hexadecimal da cor associada (ex: "#22A06B").
  final String? colorHex;

  /// Descrição detalhada ou dicas de uso.
  final String? description;

  /// Indica se a categoria foi arquivada pelo usuário.
  final bool isArchived;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.iconKey,
    this.colorHex,
    this.description,
    this.isArchived = false,
  });

  /// Cria uma nova categoria validando suas propriedades.
  factory Category.create({
    required String id,
    required String name,
    required CategoryType type,
    String? iconKey,
    String? colorHex,
    String? description,
    bool isArchived = false,
  }) {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError.value(
        id,
        'id',
        'O identificador da categoria não pode ser vazio.',
      );
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'O nome da categoria não pode ser vazio.',
      );
    }

    return Category(
      id: trimmedId,
      name: trimmedName,
      type: type,
      iconKey: iconKey,
      colorHex: colorHex,
      description: description?.trim(),
      isArchived: isArchived,
    );
  }

  /// Verifica se a categoria é compatível com o tipo de lançamento financeiro informado.
  bool isCompatibleWith(TransactionType transactionType) {
    return switch (transactionType) {
      TransactionType.expense =>
        type == CategoryType.expense || type == CategoryType.both,
      TransactionType.income =>
        type == CategoryType.income || type == CategoryType.both,
      TransactionType.transfer => true,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? iconKey,
    String? colorHex,
    String? description,
    bool? isArchived,
  }) {
    return Category.create(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          iconKey == other.iconKey &&
          colorHex == other.colorHex &&
          description == other.description &&
          isArchived == other.isArchived;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    iconKey,
    colorHex,
    description,
    isArchived,
  );

  @override
  String toString() =>
      'Category(id: $id, name: $name, type: ${type.name}, isArchived: $isArchived)';
}
