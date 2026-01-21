// path: lib/widgets/outline_button.dart

import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/colors.dart';

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const OutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: text,
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingHorizontal,
              vertical: AppSpacing.buttonPaddingVertical,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardBackgroundDark
                  : AppColors.cardBackgroundLight,
              border: Border.all(color: AppColors.primaryOrange, width: 2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style:
                      (isDark
                              ? AppTypography.buttonDark
                              : AppTypography.buttonLight)
                          .copyWith(color: AppColors.primaryOrange),
                ),
                if (icon != null) ...[
                  SizedBox(width: AppSpacing.sm),
                  Icon(
                    icon,
                    color: AppColors.primaryOrange,
                    size: AppSpacing.iconSm,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
