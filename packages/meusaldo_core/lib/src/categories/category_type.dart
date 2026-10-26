/// Tipo de operação suportado por uma categoria financeira.
enum CategoryType {
  /// Categoria destinada exclusivamente a despesas.
  expense('Despesa'),

  /// Categoria destinada exclusivamente a receitas.
  income('Receita'),

  /// Categoria que pode ser utilizada tanto em receitas quanto em despesas.
  both('Ambos');

  final String displayName;

  const CategoryType(this.displayName);
}
