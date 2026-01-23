// path: lib/widgets/quick_action.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/shadows.dart';

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackgroundDark : AppColors.card,
              shape: BoxShape.circle,
              boxShadow: isDark ? [] : AppShadows.small,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style:
                (isDark
                        ? AppTypography.bodySmallDark
                        : AppTypography.bodySmallLight)
                    .copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
