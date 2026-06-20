// path: lib/theme/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // dashboard colores principales
  static const Color primary = Color(0xFFF97316); // Naranja
  static const Color info = Color(0xFF3B82F6); // Azul
  static const Color success = Color(0xFF10B981); // Verde
  static const Color warning = Color(0xFFF59E0B); // Amarillo
  static const Color danger = Color(0xFFEF4444); // Rojo

  // Background Colors
  static const Color background = Color(0xFFEFF1F4);
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors
  static const Color foreground = Color(0xFF0A0A0A);
  static const Color mutedForeground = Color(0xFF737373);

  // UI Elements
  static const Color border = Color(0xFFE5E5E5);

  // Badge notification
  static const Color badgeRed = Color(0xFFEF4444);

  // Login/Landing Screen Colors (legacy compatibility)
  static const Color primaryOrange = primary;
  static const Color primaryOrangeDark = Color(0xFFE55A2B);
  static const Color primaryOrangeLight = Color(0xFFFF8A5C);

  // Light theme colors
  static const Color backgroundLight = background;
  static const Color surfaceLight = card;
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color cardBackgroundLight = card;
  static const Color textPrimaryLight = foreground;
  static const Color textSecondaryLight = mutedForeground;
  static const Color borderLight = border;
  static const Color iconBackgroundLight = card;

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF101010);
  static const Color surfaceDark = Color(0xFF181818);
  static const Color surfaceElevatedDark = Color(0xFF202020);
  static const Color cardBackgroundDark = surfaceElevatedDark;
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFB8C0CC);
  static const Color borderDark = Color(0xFF303030);
  static const Color iconBackgroundDark = Color(0xFF262626);

  // Error color
  static const Color error = danger;

  // Dot indicator colors
  static const Color dotActive = primary;
  static const Color dotInactive = mutedForeground;
}
