// path: lib/widgets/invoice_tile.dart

import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/shadows.dart';
import 'status_badge.dart';

/// Widget para mostrar una factura en la lista
class InvoiceTile extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;

  const InvoiceTile({
    super.key,
    required this.invoice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeConfig = invoice.typeConfig;
    final statusConfig = invoice.statusConfig;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: isDark ? [] : AppShadows.small,
        ),
        child: Row(
          children: [
            // Ícono circular
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark 
                    ? typeConfig.color.withValues(alpha: 0.15)
                    : typeConfig.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                typeConfig.icon,
                size: 24,
                color: typeConfig.color,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            
            // Contenido central
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Factura #${invoice.number}',
                    style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    invoice.description,
                    style: isDark
                        ? AppTypography.bodySmallDark
                        : AppTypography.bodySmallLight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    invoice.formattedDate,
                    style: AppTypography.label.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            
            // Monto y estado
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  invoice.formattedAmount,
                  style: (isDark ? AppTypography.bodyDark : AppTypography.bodyLight)
                      .copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                StatusBadge(
                  label: statusConfig.label,
                  color: statusConfig.color,
                  backgroundColor: isDark 
                      ? statusConfig.color.withValues(alpha: 0.15)
                      : statusConfig.backgroundColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
