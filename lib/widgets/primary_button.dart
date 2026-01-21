// path: lib/widgets/primary_button.dart

import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../theme/colors.dart';
import '../theme/shadows.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: text,
      button: true,
      enabled: !isLoading,
      child: Material(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        elevation: 0,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingHorizontal,
              vertical: AppSpacing.buttonPaddingVertical,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: isDark
                  ? AppShadows.buttonDark
                  : AppShadows.buttonLight,
            ),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: AppTypography.buttonLight.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      if (icon != null) ...[
                        SizedBox(width: AppSpacing.sm),
                        Icon(
                          icon,
                          color: Colors.white,
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
