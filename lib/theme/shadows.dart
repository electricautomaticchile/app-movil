// path: lib/theme/shadows.dart

import 'package:flutter/material.dart';

class AppShadows {
  // Dashboard shadows
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000), // ~5% black
      blurRadius: 10,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x0F000000), // ~6% black
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0A000000), // ~4% black
      blurRadius: 6,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  // Legacy shadows (for login/landing screens)
  static const List<BoxShadow> cardLight = card;
  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x1A000000), // Slightly stronger for dark theme
      blurRadius: 10,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonLight = button;
  static const List<BoxShadow> buttonDark = button;

  static const List<BoxShadow> iconLight = small;
  static const List<BoxShadow> iconDark = small;

  static const List<BoxShadow> toggleLight = small;
  static const List<BoxShadow> toggleDark = small;
}
