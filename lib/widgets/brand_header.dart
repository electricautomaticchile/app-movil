// path: lib/widgets/brand_header.dart

import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Logo image
        Image.asset(
          'assets/images/logo.png',
          width: AppSpacing.brandIconSize,
          height: AppSpacing.brandIconSize,
          fit: BoxFit.contain,
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
