import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_color_selector.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_icon_selector.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_preview_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

class _FakeCategoryRepo implements CategoryRepository {
  List<Category> categories;
  _FakeCategoryRepo(this.categories);

  @override
  Future<Result<List<Category>, Failure>> getAllCategories({bool includeArchived = false}) async =>
      Result.success(categories);

  @override
  Future<Result<Category, Failure>> getCategoryById(String id) async {
    final cat = categories.firstWhere((c) => c.id == id);
    return Result.success(cat);
  }

  @override
  Future<Result<Category, Failure>> saveCategory(Category category) async {
    categories.add(category);
    return Result.success(category);
  }

  @override
  Future<Result<Category, Failure>> updateCategory(Category category) async {
    final idx = categories.indexWhere((c) => c.id == category.id);
    if (idx != -1) categories[idx] = category;
    return Result.success(category);
  }

  @override
  Future<Result<void, Failure>> deleteCategory(String id) async {
    categories.removeWhere((c) => c.id == id);
    return const Result.success(null);
  }

  @override
  Future<Result<List<Category>, Failure>> getCategoriesByType(CategoryType type) async {
    return Result.success(categories.where((c) => c.type == type || c.type == CategoryType.both).toList());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildSheetHarness({
    required _FakeCategoryRepo repo,
    Category? category,
  }) {
    return ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: CategoryFormSheet(category: category),
        ),
      ),
    );
  }

  group('CategoryFormSheet Tests (Parte 3)', () {
    testWidgets('renderiza modo de criação com preview, seletores de ícone e cor', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = _FakeCategoryRepo([]);
      await tester.pumpWidget(buildSheetHarness(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Nova Categoria'), findsOneWidget);
      expect(find.byType(CategoryPreviewCard), findsOneWidget);
      expect(find.byType(CategoryIconSelector), findsOneWidget);
      expect(find.byType(CategoryColorSelector), findsOneWidget);
      expect(find.byKey(const Key('category_form_name_field')), findsOneWidget);
      expect(find.byKey(const Key('category_form_save_button')), findsOneWidget);
      expect(find.byKey(const Key('category_form_delete_button')), findsNothing);
    });

    testWidgets('valida nome vazio ao tentar salvar', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = _FakeCategoryRepo([]);
      await tester.pumpWidget(buildSheetHarness(repo: repo));
      await tester.pumpAndSettle();

      // Clica em salvar com nome vazio
      await tester.tap(find.byKey(const Key('category_form_save_button')));
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome da categoria.'), findsOneWidget);
    });

    testWidgets('cria nova categoria com sucesso e persiste no repositório', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = _FakeCategoryRepo([]);
      await tester.pumpWidget(buildSheetHarness(repo: repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('category_form_name_field')), 'Supermercado Especial');
      // Seleciona ícone de compras
      await tester.tap(find.byKey(const Key('category_icon_shopping_bag')));
      // Seleciona cor azul
      await tester.tap(find.byKey(const Key('category_color_#4C8DFF')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('category_form_save_button')));
      await tester.pumpAndSettle();

      expect(repo.categories.length, 1);
      final created = repo.categories.first;
      expect(created.name, 'Supermercado Especial');
      expect(created.iconKey, 'shopping_bag');
      expect(created.colorHex, '#4C8DFF');
    });

    testWidgets('renderiza em modo de edição, altera dados e exclui categoria', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final existing = Category.create(
        id: 'cat-edit-1',
        name: 'Combustível',
        type: CategoryType.expense,
        iconKey: 'directions_car',
        colorHex: '#4C8DFF',
      );
      final repo = _FakeCategoryRepo([existing]);

      await tester.pumpWidget(buildSheetHarness(repo: repo, category: existing));
      await tester.pumpAndSettle();

      expect(find.text('Editar Categoria'), findsOneWidget);
      expect(find.text('Combustível'), findsWidgets);
      expect(find.byKey(const Key('category_form_delete_button')), findsOneWidget);

      // Clica em excluir
      await tester.tap(find.byKey(const Key('category_form_delete_button')));
      await tester.pumpAndSettle();

      expect(find.text('Excluir categoria?'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);

      // Confirma exclusão
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(repo.categories.isEmpty, isTrue);
    });
  });
}
