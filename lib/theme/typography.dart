// path: lib/theme/typography.dart

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  // Font family (using system default, can be changed to Google Fonts)
  static const String fontFamily = 'Roboto';

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Light theme text styles
  static TextStyle h1Light = const TextStyle(
    fontSize: 28,
    fontWeight: bold,
    color: AppColors.textPrimaryLight,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle h2Light = const TextStyle(
    fontSize: 24,
    fontWeight: bold,
    color: AppColors.textPrimaryLight,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle h3Light = const TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    color: AppColors.textPrimaryLight,
    height: 1.4,
  );

  static TextStyle bodyLargeLight = const TextStyle(
    fontSize: 16,
    fontWeight: regular,
    color: AppColors.textPrimaryLight,
    height: 1.5,
  );

  static TextStyle bodyLight = const TextStyle(
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.textSecondaryLight,
    height: 1.5,
  );

  static TextStyle bodySmallLight = const TextStyle(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.textTertiaryLight,
    height: 1.4,
  );

  static TextStyle buttonLight = const TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    color: AppColors.textPrimaryLight,
    letterSpacing: 0.2,
  );

  static TextStyle linkLight = const TextStyle(
    fontSize: 14,
    fontWeight: medium,
    color: AppColors.primaryOrange,
    decoration: TextDecoration.none,
  );

  // Dark theme text styles
  static TextStyle h1Dark = h1Light.copyWith(color: AppColors.textPrimaryDark);

  static TextStyle h2Dark = h2Light.copyWith(color: AppColors.textPrimaryDark);

  static TextStyle h3Dark = h3Light.copyWith(color: AppColors.textPrimaryDark);

  static TextStyle bodyLargeDark = bodyLargeLight.copyWith(
    color: AppColors.textPrimaryDark,
  );

  static TextStyle bodyDark = bodyLight.copyWith(
    color: AppColors.textSecondaryDark,
  );

  static TextStyle bodySmallDark = bodySmallLight.copyWith(
    color: AppColors.textTertiaryDark,
  );

  static TextStyle buttonDark = buttonLight.copyWith(
    color: AppColors.textPrimaryDark,
  );

  static TextStyle linkDark = linkLight.copyWith(
    color: AppColors.primaryOrange,
  );

  // Subtitle style (used for tagline)
  static TextStyle subtitleLight = const TextStyle(
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.textSecondaryLight,
    height: 1.5,
  );

  static TextStyle subtitleDark = subtitleLight.copyWith(
    color: AppColors.textSecondaryDark,
  );
}
