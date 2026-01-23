// path: lib/widgets/settings_header.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class SettingsHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SettingsHeader({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: isDark ? AppColors.textPrimaryDark : AppColors.foreground,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: (isDark ? AppTypography.h3Dark : AppTypography.h3Light).copyWith(
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }
}
