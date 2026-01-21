// path: lib/theme/spacing.dart

class AppSpacing {
  // Base spacing unit (8px)
  static const double base = 8.0;

  // Spacing scale
  static const double xs = base * 0.5; // 4
  static const double sm = base * 1; // 8
  static const double md = base * 2; // 16
  static const double lg = base * 3; // 24
  static const double xl = base * 4; // 32
  static const double xxl = base * 5; // 40
  static const double xxxl = base * 6; // 48

  // Component-specific spacing
  static const double cardPadding = xl; // 32
  static const double cardPaddingMobile = lg; // 24
  static const double buttonPaddingVertical = md; // 16
  static const double buttonPaddingHorizontal = xl; // 32
  static const double inputPadding = md; // 16

  // Layout spacing
  static const double sectionSpacing = xxl; // 40
  static const double elementSpacing = md; // 16
  static const double tightSpacing = sm; // 8

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0; // For pill shapes

  // Card dimensions
  static const double cardMaxWidth =
      720.0; // Increased for better screen utilization
  static const double cardMaxWidthMobile = double.infinity;

  // Icon sizes
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // Logo/Brand icon container
  static const double brandIconSize = 80.0;
  static const double brandIconPadding = lg;
}
