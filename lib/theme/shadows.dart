// path: lib/theme/shadows.dart

import 'package:flutter/material.dart';

class AppShadows {
  // Card shadows - Light theme
  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color(0x0D000000), // ~5% black
      blurRadius: 10,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000), // ~4% black
      blurRadius: 20,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // Card shadows - Dark theme
  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% black
      blurRadius: 12,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000), // ~8% black
      blurRadius: 24,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  // Button shadows
  static const List<BoxShadow> buttonLight = [
    BoxShadow(
      color: Color(0x0F000000), // ~6% black
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonDark = [
    BoxShadow(
      color: Color(0x1F000000), // ~12% black
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Icon/Logo container shadows
  static const List<BoxShadow> iconLight = [
    BoxShadow(
      color: Color(0x0A000000), // ~4% black
      blurRadius: 12,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> iconDark = [
    BoxShadow(
      color: Color(0x14000000), // ~8% black
      blurRadius: 12,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Subtle shadow for toggle button
  static const List<BoxShadow> toggleLight = [
    BoxShadow(
      color: Color(0x08000000), // ~3% black
      blurRadius: 6,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> toggleDark = [
    BoxShadow(
      color: Color(0x12000000), // ~7% black
      blurRadius: 6,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
}
