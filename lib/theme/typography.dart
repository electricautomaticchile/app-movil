// path: lib/theme/typography.dart

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.foreground,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.foreground,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
    height: 1.4,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.foreground,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.foreground,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.mutedForeground,
    height: 1.4,
  );

  // Special styles
  static const TextStyle label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedForeground,
    letterSpacing: 0.5,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Dark theme variants (for login/landing screens)
  static const TextStyle h1Dark = h1;
  static const TextStyle h1Light = h1;

  static const TextStyle h2Dark = h2;
  static const TextStyle h2Light = h2;

  static const TextStyle h3Dark = h3;
  static const TextStyle h3Light = h3;

  static const TextStyle bodyDark = body;
  static const TextStyle bodyLight = body;

  static const TextStyle bodyLargeDark = bodyLarge;
  static const TextStyle bodyLargeLight = bodyLarge;

  static const TextStyle bodySmallDark = bodySmall;
  static const TextStyle bodySmallLight = bodySmall;

  static const TextStyle linkDark = link;
  static const TextStyle linkLight = link;

  static const TextStyle subtitleDark = bodySmall;
  static const TextStyle subtitleLight = bodySmall;

  // Button text styles
  static const TextStyle buttonDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );

  static const TextStyle buttonLight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );
}
