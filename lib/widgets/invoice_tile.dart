import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/shadows.dart';
import 'status_badge.dart';

class InvoiceTile extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;

  const InvoiceTile({super.key, required this.invoice, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? invoice.iconColor.withValues(alpha: 0.15)
                    : invoice.iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(invoice.icon, size: 24, color: invoice.iconColor),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.periodo,
                    style:
                        (isDark
                                ? AppTypography.bodyDark
                                : AppTypography.bodyLight)
                            .copyWith(fontWeight: FontWeight.w600),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  invoice.formattedMonto,
                  style:
                      (isDark
                              ? AppTypography.bodyDark
                              : AppTypography.bodyLight)
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 16),
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
