import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/categories/data/in_memory_category_repository.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Provedor do repositório de categorias.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return InMemoryCategoryRepository();
});

/// Notifier reativo para listagem e manipulação de categorias.
class CategoriesListNotifier extends AsyncNotifier<List<Category>> {
  @override
  FutureOr<List<Category>> build() async {
    final repo = ref.watch(categoryRepositoryProvider);
    final result = await repo.getAllCategories();
    return result.when(
      onSuccess: (categories) => categories,
      onFailure: (failure) => throw Exception(failure.message),
    );
  }

  /// Adiciona uma nova categoria e invalida o estado para recarregamento.
  Future<Result<Category, Failure>> addCategory(Category category) async {
    final repo = ref.read(categoryRepositoryProvider);
    final result = await repo.saveCategory(category);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
    return result;
  }

  /// Atualiza uma categoria existente.
  Future<Result<Category, Failure>> updateCategory(Category category) async {
    final repo = ref.read(categoryRepositoryProvider);
    final result = await repo.updateCategory(category);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
    return result;
  }

  /// Arquiva uma categoria.
  Future<Result<void, Failure>> deleteCategory(String id) async {
    final repo = ref.read(categoryRepositoryProvider);
    final result = await repo.deleteCategory(id);
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
    return result;
  }
}

/// Provedor da lista reativa de categorias.
final categoriesListProvider =
    AsyncNotifierProvider<CategoriesListNotifier, List<Category>>(
  CategoriesListNotifier.new,
);

/// Provedor das categorias compatíveis com despesas.
final expenseCategoriesProvider = Provider<List<Category>>((ref) {
  final categoriesAsync = ref.watch(categoriesListProvider);
  return categoriesAsync.maybeWhen(
    data: (categories) => categories
        .where((cat) => cat.isCompatibleWith(TransactionType.expense))
        .toList(),
    orElse: () => const [],
  );
});

/// Provedor das categorias compatíveis com receitas.
final incomeCategoriesProvider = Provider<List<Category>>((ref) {
  final categoriesAsync = ref.watch(categoriesListProvider);
  return categoriesAsync.maybeWhen(
    data: (categories) => categories
        .where((cat) => cat.isCompatibleWith(TransactionType.income))
        .toList(),
    orElse: () => const [],
  );
});
