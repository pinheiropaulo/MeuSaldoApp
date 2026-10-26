import 'package:meusaldo_core/src/categories/category.dart';
import 'package:meusaldo_core/src/categories/category_type.dart';
import 'package:meusaldo_core/src/shared/failures.dart';
import 'package:meusaldo_core/src/shared/result.dart';

/// Contrato para persistência e recuperação de categorias de classificação financeira.
abstract interface class CategoryRepository {
  /// Retorna todas as categorias cadastradas.
  ///
  /// Se [includeArchived] for `false` (padrão), retorna apenas categorias não arquivadas.
  Future<Result<List<Category>, Failure>> getAllCategories({
    bool includeArchived = false,
  });

  /// Retorna as categorias compatíveis com um determinado [type] (despesa ou receita).
  Future<Result<List<Category>, Failure>> getCategoriesByType(CategoryType type);

  /// Busca uma categoria pelo seu identificador único [id].
  Future<Result<Category, Failure>> getCategoryById(String id);

  /// Salva uma nova categoria.
  Future<Result<Category, Failure>> saveCategory(Category category);

  /// Atualiza os dados de uma categoria existente.
  Future<Result<Category, Failure>> updateCategory(Category category);

  /// Remove ou desativa uma categoria pelo seu [id].
  Future<Result<void, Failure>> deleteCategory(String id);
}
