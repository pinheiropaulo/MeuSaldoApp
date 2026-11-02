import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/categories/presentation/screens/categories_screen.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/categories_empty_state.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_type_segmented_bar.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

class _FakeCategoryRepo implements CategoryRepository {
  List<Category> categories;
  _FakeCategoryRepo(this.categories);

  @override
  Future<Result<List<Category>, Failure>> getAllCategories({
    bool includeArchived = false,
  }) async =>
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

  Widget buildCategoriesScreen({List<Category>? initialCategories}) {
    final repo = _FakeCategoryRepo(initialCategories ?? [
      Category.create(
        id: 'cat-1',
        name: 'Alimentação & Mercado',
        type: CategoryType.expense,
        iconKey: 'restaurant',
        colorHex: '#F04444',
        description: 'Supermercado e refeições',
      ),
      Category.create(
        id: 'cat-2',
        name: 'Transporte',
        type: CategoryType.expense,
        iconKey: 'directions_car',
        colorHex: '#4C8DFF',
        description: 'Uber e combustível',
      ),
      Category.create(
        id: 'cat-3',
        name: 'Salário Principal',
        type: CategoryType.income,
        iconKey: 'work',
        colorHex: '#22A06B',
        description: 'Remuneração mensal',
      ),
    ]);

    return ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(
        home: CategoriesScreen(),
      ),
    );
  }

  group('CategoriesScreen Widget Tests (Parte 2)', () {
    testWidgets('exibe cabeçalho, barra de busca, alternador de abas e lista de despesas padrão', (tester) async {
      await tester.pumpWidget(buildCategoriesScreen());
      await tester.pumpAndSettle();

      expect(find.text('Categorias'), findsOneWidget);
      expect(find.byKey(const Key('categories_new_button')), findsOneWidget);
      expect(find.byKey(const Key('categories_search_field')), findsOneWidget);
      expect(find.byType(CategoryTypeSegmentedBar), findsOneWidget);

      // Despesas ativas por padrão
      expect(find.text('Despesas (2)'), findsOneWidget);
      expect(find.text('Receitas (1)'), findsOneWidget);
      expect(find.text('Alimentação & Mercado'), findsOneWidget);
      expect(find.text('Transporte'), findsOneWidget);
      expect(find.text('Salário Principal'), findsNothing);
    });

    testWidgets('alterna para a aba de Receitas e exibe categorias de receita', (tester) async {
      await tester.pumpWidget(buildCategoriesScreen());
      await tester.pumpAndSettle();

      // Clica na aba Receitas
      await tester.tap(find.byKey(const Key('categories_tab_income')));
      await tester.pumpAndSettle();

      expect(find.text('Salário Principal'), findsOneWidget);
      expect(find.text('Alimentação & Mercado'), findsNothing);
      expect(find.text('Transporte'), findsNothing);
    });

    testWidgets('filtra categorias pela busca textual e limpa busca', (tester) async {
      await tester.pumpWidget(buildCategoriesScreen());
      await tester.pumpAndSettle();

      // Busca por 'Uber' (presente na descrição de Transporte)
      await tester.enterText(find.byKey(const Key('categories_search_field')), 'Uber');
      await tester.pumpAndSettle();

      expect(find.text('Transporte'), findsOneWidget);
      expect(find.text('Alimentação & Mercado'), findsNothing);

      // Busca por termo inexistente exibe estado sem resultados
      await tester.enterText(find.byKey(const Key('categories_search_field')), 'Inexistente');
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma categoria encontrada'), findsOneWidget);
      expect(find.text('Limpar busca'), findsOneWidget);

      // Limpa busca
      await tester.tap(find.text('Limpar busca'));
      await tester.pumpAndSettle();

      expect(find.text('Alimentação & Mercado'), findsOneWidget);
      expect(find.text('Transporte'), findsOneWidget);
    });

    testWidgets('exibe estado vazio quando não há categorias cadastradas para o tipo', (tester) async {
      await tester.pumpWidget(buildCategoriesScreen(initialCategories: []));
      await tester.pumpAndSettle();

      expect(find.byType(CategoriesEmptyState), findsOneWidget);
      expect(find.text('Nenhuma categoria cadastrada'), findsOneWidget);
      expect(find.text('+ Criar categoria'), findsOneWidget);
      expect(find.text('DICA INTELIGENTE'), findsOneWidget);
    });

    testWidgets('toca em nova categoria e em editar abrindo o modal CategoryFormSheet', (tester) async {
      await tester.pumpWidget(buildCategoriesScreen());
      await tester.pumpAndSettle();

      // Toca em '+ Nova'
      await tester.tap(find.byKey(const Key('categories_new_button')));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryFormSheet), findsOneWidget);
      expect(find.text('Nova Categoria'), findsOneWidget);

      // Fecha o modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Toca em editar no item de Alimentação
      await tester.tap(find.byIcon(Icons.edit_note).first);
      await tester.pumpAndSettle();

      expect(find.byType(CategoryFormSheet), findsOneWidget);
      expect(find.text('Editar Categoria'), findsOneWidget);
    });
  });
}
