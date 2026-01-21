// path: lib/widgets/theme_toggle.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/spacing.dart';
import '../theme/shadows.dart';
import '../theme/colors.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);

    return Semantics(
      label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      button: true,
      child: Material(
        color: isDark
            ? AppColors.iconBackgroundDark
            : AppColors.iconBackgroundLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        elevation: 0,
        child: InkWell(
          onTap: () => themeProvider.toggleTheme(),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: isDark
                  ? AppShadows.toggleDark
                  : AppShadows.toggleLight,
            ),
            child: Icon(
              isDark ? Icons.wb_sunny : Icons.nightlight_round,
              color: isDark
                  ? AppColors.primaryOrange
                  : AppColors.textSecondaryLight,
              size: AppSpacing.iconMd,
            ),
          ),
        ),
      ),
    );
  }
}
