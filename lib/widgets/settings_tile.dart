// path: lib/widgets/settings_tile.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.mutedForeground,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        (isDark
                                ? AppTypography.bodyDark
                                : AppTypography.bodyLight)
                            .copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      subtitle!,
                      style: isDark
                          ? AppTypography.bodySmallDark
                          : AppTypography.bodySmallLight,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
