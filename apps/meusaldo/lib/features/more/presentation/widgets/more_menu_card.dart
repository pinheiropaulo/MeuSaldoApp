import 'package:flutter/material.dart';
import 'package:meusaldo/app/theme/theme.dart';
import 'package:meusaldo/shared/widgets/app_card.dart';

/// Modelo representativo de um item de menu na Aba Mais.
class MoreMenuItemData {
  final Key? key;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const MoreMenuItemData({
    this.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });
}

/// Seção de menu agrupada em card com título de seção superior.
class MoreMenuCard extends StatelessWidget {
  final String title;
  final String? trailingHeader;
  final List<MoreMenuItemData> items;
  final Widget? topHeroWidget;

  const MoreMenuCard({
    super.key,
    required this.title,
    this.trailingHeader,
    required this.items,
    this.topHeroWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              if (trailingHeader != null)
                Text(
                  trailingHeader!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryHighlight,
                  ),
                ),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (topHeroWidget != null) ...[
                topHeroWidget!,
                if (items.isNotEmpty)
                  const Divider(color: AppColors.outline, height: 1),
              ],
              for (int i = 0; i < items.length; i++) ...[
                _buildTile(context, items[i]),
                if (i < items.length - 1)
                  const Divider(color: AppColors.outline, height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, MoreMenuItemData item) {
    final textColor = item.isDestructive
        ? AppColors.expense
        : AppColors.textPrimary;
    final iconColor = item.isDestructive
        ? AppColors.expense
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: item.key,
        borderRadius: BorderRadius.circular(12),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Ícone com container sutil
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.isDestructive
                      ? AppColors.expense.withValues(alpha: 0.12)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.isDestructive
                        ? AppColors.expense.withValues(alpha: 0.3)
                        : AppColors.outline,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Título e subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing widget ou chevron
              item.trailing ??
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
