import 'package:meusaldo_core/meusaldo_core.dart';

class FakeCategoryRepository implements CategoryRepository {
  final Map<String, Category> _categories = {};

  @override
  Future<Result<List<Category>, Failure>> getAllCategories({
    bool includeArchived = false,
  }) async {
    final list = _categories.values
        .where((cat) => includeArchived || !cat.isArchived)
        .toList();
    return Result.success(list);
  }

  @override
  Future<Result<List<Category>, Failure>> getCategoriesByType(CategoryType type) async {
    final list = _categories.values
        .where((cat) => !cat.isArchived && (cat.type == type || cat.type == CategoryType.both))
        .toList();
    return Result.success(list);
  }

  @override
  Future<Result<Category, Failure>> getCategoryById(String id) async {
    final category = _categories[id];
    if (category == null) {
      return Result.failure(NotFoundFailure('Categoria com ID "$id" não encontrada.'));
    }
    return Result.success(category);
  }

  @override
  Future<Result<Category, Failure>> saveCategory(Category category) async {
    if (_categories.containsKey(category.id)) {
      return Result.failure(
        ValidationFailure('Já existe uma categoria com o ID "${category.id}".'),
      );
    }
    _categories[category.id] = category;
    return Result.success(category);
  }

  @override
  Future<Result<Category, Failure>> updateCategory(Category category) async {
    if (!_categories.containsKey(category.id)) {
      return Result.failure(
        NotFoundFailure('Categoria com ID "${category.id}" não encontrada para atualização.'),
      );
    }
    _categories[category.id] = category;
    return Result.success(category);
  }

  @override
  Future<Result<void, Failure>> deleteCategory(String id) async {
    if (!_categories.containsKey(id)) {
      return Result.failure(NotFoundFailure('Categoria com ID "$id" não encontrada.'));
    }
    _categories.remove(id);
    return const Result.success(null);
  }
}
