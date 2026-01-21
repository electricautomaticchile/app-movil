// path: lib/widgets/brand_header.dart

import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/colors.dart';
import '../theme/shadows.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Lightning bolt icon in white square
        Container(
          width: AppSpacing.brandIconSize,
          height: AppSpacing.brandIconSize,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.iconBackgroundDark
                : AppColors.iconBackgroundLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: isDark ? AppShadows.iconDark : AppShadows.iconLight,
          ),
          child: const Icon(
            Icons.flash_on,
            color: AppColors.primaryOrange,
            size: AppSpacing.iconXl,
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Brand title
        Text(
          'Electricautomaticchile',
          style: isDark ? AppTypography.h1Dark : AppTypography.h1Light,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),

        // Subtitle
        Text(
          'Administración Inteligente del Suministro Eléctrico',
          style: isDark
              ? AppTypography.subtitleDark
              : AppTypography.subtitleLight,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
