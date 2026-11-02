import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_button.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Componente de estado vazio ou busca sem resultados para a lista de categorias.
class CategoriesEmptyState extends StatelessWidget {
  final CategoryType selectedType;
  final String? searchQuery;
  final VoidCallback onCreateCategory;
  final VoidCallback onClearSearch;

  const CategoriesEmptyState({
    super.key,
    required this.selectedType,
    this.searchQuery,
    required this.onCreateCategory,
    required this.onClearSearch,
  });

  bool get _isSearchResult => searchQuery != null && searchQuery!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isSearchResult) {
      return _buildNoResultsState();
    }
    return _buildEmptyListState();
  }

  Widget _buildEmptyListState() {
    final typeLabel = selectedType == CategoryType.expense ? 'despesas' : 'receitas';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Halo com ícone central
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryHighlight.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.label_off_outlined,
                size: 38,
                color: AppColors.primaryHighlight,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Nenhuma categoria cadastrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Você ainda não possui categorias de $typeLabel cadastradas para classificar seus lançamentos.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: AppButton(
                label: '+ Criar categoria',
                icon: Icons.add_circle_outline,
                onPressed: onCreateCategory,
              ),
            ),
            const SizedBox(height: 32),

            // Card educativo
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primaryHighlight,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DICA INTELIGENTE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.primaryHighlight,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Categorizar seus lançamentos ajuda a visualizar para onde seu dinheiro vai a cada mês.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outline),
              ),
              child: const Icon(
                Icons.search_off,
                size: 34,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Nenhuma categoria encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Não encontramos nenhuma categoria correspondente ao termo '),
                  TextSpan(
                    text: '"$searchQuery"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Limpar busca'),
                onPressed: onClearSearch,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.outline),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
