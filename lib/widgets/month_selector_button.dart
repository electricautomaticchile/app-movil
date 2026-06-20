// path: lib/widgets/month_selector_button.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/shadows.dart';

/// Botón reutilizable para selección de mes en grid
class MonthSelectorButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MonthSelectorButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.cardBackgroundDark : Colors.white),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
          boxShadow: isSelected ? AppShadows.small : null,
        ),
        child: Center(
          child: Text(
            label,
            style:
                (isDark
                        ? AppTypography.bodySmallDark
                        : AppTypography.bodySmallLight)
                    .copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.foreground),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
          ),
        ),
      ),
    );
  }
}
