/// Spacing constants based on 8pt grid system
class AppSpacing {
  AppSpacing._(); // Private constructor

  // Base spacing unit (8pt)
  static const double base = 8.0;

  // Spacing scale
  static const double xs = base * 0.5; // 4pt
  static const double sm = base; // 8pt
  static const double md = base * 2; // 16pt
  static const double lg = base * 3; // 24pt
  static const double xl = base * 4; // 32pt
  static const double xxl = base * 6; // 48pt
  static const double xxxl = base * 8; // 64pt

  // Named spacings for common use cases
  static const double iconSize = 24.0;
  static const double iconSizeMedium = 24.0; // Alias for iconSize
  static const double iconSizeLarge = 32.0;
  static const double iconSizeSmall = 20.0;

  static const double buttonHeight = 48.0;
  static const double buttonHeightMedium = 48.0; // Alias for buttonHeight
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightLarge = 56.0;

  static const double inputHeight = 48.0;
  static const double cardElevation = 2.0;
  static const double modalElevation = 8.0;

  // Border Radius
  static const double radiusNone = 0.0;
  static const double radiusSm = 4.0; // Badges, chips
  static const double radiusMd = 8.0; // Buttons, inputs
  static const double radiusLg = 12.0; // Cards
  static const double radiusXl = 16.0; // Modals
  static const double radiusXxl = 24.0; // Hero elements
  static const double radiusFull = 9999.0; // Pills, circles
}
