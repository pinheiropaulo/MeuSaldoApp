import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meusaldo/features/categories/data/in_memory_category_repository.dart';
import 'package:meusaldo/features/categories/presentation/state/category_providers.dart';
import 'package:meusaldo/features/categories/presentation/widgets/category_picker_sheet.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

void main() {
  testWidgets('CategoryPickerSheet lista categorias, alterna abas, busca e seleciona', (tester) async {
    final catRepo = InMemoryCategoryRepository(
      initialCategories: [
        Category.create(
          id: 'cat-alimentacao',
          name: 'Alimentação',
          type: CategoryType.expense,
          iconKey: 'restaurant',
          description: 'Mercado e compras',
        ),
        Category.create(
          id: 'cat-transporte',
          name: 'Transporte',
          type: CategoryType.expense,
          iconKey: 'directions_car',
          description: 'Combustível e Uber',
        ),
        Category.create(
          id: 'cat-salario',
          name: 'Salário',
          type: CategoryType.income,
          iconKey: 'payments',
          description: 'Renda principal',
        ),
      ],
    );

    Category? selectedCategory;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(catRepo),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    selectedCategory = await CategoryPickerSheet.show(
                      context,
                      initialType: CategoryType.expense,
                    );
                  },
                  child: const Text('Abrir Picker'),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Abre o picker
    await tester.tap(find.text('Abrir Picker'));
    await tester.pumpAndSettle();

    // Valida Header e Abas
    expect(find.text('Selecionar Categoria'), findsOneWidget);
    expect(find.text('Despesas'), findsOneWidget);
    expect(find.text('Receitas'), findsOneWidget);

    // Na aba Despesas deve listar Alimentação e Transporte
    expect(find.text('Alimentação'), findsOneWidget);
    expect(find.text('Transporte'), findsOneWidget);
    expect(find.text('Salário'), findsNothing);

    // Alterna para aba Receitas
    await tester.tap(find.byKey(const Key('category_picker_tab_income')));
    await tester.pumpAndSettle();

    expect(find.text('Salário'), findsOneWidget);
    expect(find.text('Alimentação'), findsNothing);

    // Alterna de volta para Despesas e testa busca
    await tester.tap(find.byKey(const Key('category_picker_tab_expense')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('category_picker_search_input')),
      'Trans',
    );
    await tester.pumpAndSettle();

    expect(find.text('Transporte'), findsOneWidget);
    expect(find.text('Alimentação'), findsNothing);

    // Seleciona Transporte
    await tester.tap(find.byKey(const Key('category_picker_item_cat-transporte')));
    await tester.pumpAndSettle();

    // Bottom sheet deve ter fechado e retornado a categoria
    expect(selectedCategory, isNotNull);
    expect(selectedCategory!.id, equals('cat-transporte'));
    expect(selectedCategory!.name, equals('Transporte'));
  });
}
