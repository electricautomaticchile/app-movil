// path: lib/widgets/app_card.dart

import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/shadows.dart';
import '../theme/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 600;

        return Container(
          width: double.infinity,
          padding:
              padding ??
              EdgeInsets.all(
                isWeb ? AppSpacing.cardPadding : AppSpacing.cardPaddingMobile,
              ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardBackgroundDark
                : AppColors.cardBackgroundLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
          ),
          child: child,
        );
      },
    );
  }
}
