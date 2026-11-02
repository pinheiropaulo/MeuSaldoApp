import 'package:meusaldo_core/meusaldo_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

/// Implementação remota de [CategoryRepository] conectada à tabela `categories` no Supabase.
class SupabaseCategoryRepository implements CategoryRepository {
  final sp.SupabaseClient _client;

  SupabaseCategoryRepository({sp.SupabaseClient? client})
      : _client = client ?? sp.Supabase.instance.client;

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  Future<Result<List<Category>, Failure>> getAllCategories({
    bool includeArchived = false,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      var query = _client.from('categories').select();
      if (!includeArchived) {
        query = query.eq('is_active', true);
      }

      final data = await query.order('name');
      final categories = (data as List<dynamic>)
          .map((row) => _mapFromRow(row as Map<String, dynamic>))
          .toList();

      return Result.success(categories);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao carregar categorias: $e'));
    }
  }

  @override
  Future<Result<List<Category>, Failure>> getCategoriesByType(
    CategoryType type,
  ) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      final data = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .or('type.eq.${type.name},type.eq.both')
          .order('name');

      final categories = (data as List<dynamic>)
          .map((row) => _mapFromRow(row as Map<String, dynamic>))
          .toList();

      return Result.success(categories);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(
        BusinessRuleFailure('Erro ao filtrar categorias por tipo: $e'),
      );
    }
  }

  @override
  Future<Result<Category, Failure>> getCategoryById(String id) async {
    try {
      final row = await _client
          .from('categories')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (row == null) {
        return Result.failure(
          NotFoundFailure('Categoria com id "$id" não encontrada.'),
        );
      }

      return Result.success(_mapFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao buscar categoria: $e'));
    }
  }

  @override
  Future<Result<Category, Failure>> saveCategory(Category category) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Result.failure(
          NotFoundFailure('Usuário não autenticado.', code: 'AUTH_NO_USER'),
        );
      }

      final payload = _mapToRow(category, userId: user.id);
      final row = await _client
          .from('categories')
          .insert(payload)
          .select()
          .single();

      return Result.success(_mapFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao salvar categoria: $e'));
    }
  }

  @override
  Future<Result<Category, Failure>> updateCategory(Category category) async {
    try {
      final payload = _mapToRow(category);
      final row = await _client
          .from('categories')
          .update(payload)
          .eq('id', category.id)
          .select()
          .single();

      return Result.success(_mapFromRow(row));
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao atualizar categoria: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> deleteCategory(String id) async {
    try {
      await _client.from('categories').delete().eq('id', id);
      return const Result.success(null);
    } on sp.PostgrestException catch (e) {
      return Result.failure(BusinessRuleFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(BusinessRuleFailure('Erro ao excluir categoria: $e'));
    }
  }

  Category _mapFromRow(Map<String, dynamic> row) {
    return Category(
      id: row['id'] as String,
      name: row['name'] as String,
      type: CategoryType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => CategoryType.expense,
      ),
      iconKey: row['icon_name'] as String?,
      colorHex: row['color_hex'] as String?,
      monthlyBudget: row['monthly_budget_cents'] != null
          ? Money.fromCents((row['monthly_budget_cents'] as num).toInt())
          : null,
      isArchived: !(row['is_active'] as bool? ?? true),
    );
  }

  Map<String, dynamic> _mapToRow(Category category, {String? userId}) {
    final isValidUuid = _uuidRegex.hasMatch(category.id);
    return {
      if (isValidUuid) 'id': category.id,
      'user_id': ?userId,
      'name': category.name,
      'type': category.type.name,
      'icon_name': category.iconKey ?? 'category',
      'color_hex': category.colorHex ?? '#6D1834',
      'monthly_budget_cents': category.monthlyBudget?.cents,
      'is_active': !category.isArchived,
    };
  }
}
