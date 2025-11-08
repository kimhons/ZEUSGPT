import 'package:flutter/material.dart';

/// Responsive breakpoints for cross-platform layouts
/// 
/// Defines standard breakpoints for responsive design across mobile, tablet,
/// desktop, and large desktop screens.
/// 
/// Example usage:
/// ```dart
/// final screenWidth = MediaQuery.of(context).size.width;
/// if (screenWidth < ResponsiveBreakpoints.tablet) {
///   // Mobile layout
/// } else if (screenWidth < ResponsiveBreakpoints.desktop) {
///   // Tablet layout
/// } else {
///   // Desktop layout
/// }
/// ```
class ResponsiveBreakpoints {
  /// Private constructor to prevent instantiation
  ResponsiveBreakpoints._();

  // ============== Breakpoint Values ==============

  /// Mobile devices (0-599px)
  /// Phones in portrait and landscape
  static const double mobile = 600.0;

  /// Tablet devices (600-899px)
  /// Tablets in portrait, some small laptops
  static const double tablet = 900.0;

  /// Desktop devices (900-1199px)
  /// Standard laptops and monitors
  static const double desktop = 1200.0;

  /// Large desktop devices (1200-1799px)
  /// Large monitors and displays
  static const double largeDesktop = 1800.0;

  /// Extra large desktop devices (1800px+)
  /// Ultra-wide monitors and 4K displays
  static const double extraLargeDesktop = 2400.0;

  // ============== Helper Methods ==============

  /// Returns true if width is in mobile range
  static bool isMobile(double width) => width < mobile;

  /// Returns true if width is in tablet range
  static bool isTablet(double width) => width >= mobile && width < desktop;

  /// Returns true if width is in desktop range
  static bool isDesktop(double width) => width >= desktop && width < largeDesktop;

  /// Returns true if width is in large desktop range
  static bool isLargeDesktop(double width) => 
      width >= largeDesktop && width < extraLargeDesktop;

  /// Returns true if width is in extra large desktop range
  static bool isExtraLargeDesktop(double width) => width >= extraLargeDesktop;

  /// Returns the current breakpoint category as a string
  static String getBreakpointName(double width) {
    if (isMobile(width)) return 'Mobile';
    if (isTablet(width)) return 'Tablet';
    if (isDesktop(width)) return 'Desktop';
    if (isLargeDesktop(width)) return 'Large Desktop';
    return 'Extra Large Desktop';
  }

  /// Returns true if width is mobile or tablet (small screens)
  static bool isSmallScreen(double width) => width < desktop;

  /// Returns true if width is desktop or larger (large screens)
  static bool isLargeScreen(double width) => width >= desktop;

  // ============== Layout Column Counts ==============

  /// Recommended number of columns for grid layouts based on width
  static int getColumnCount(double width) {
    if (isMobile(width)) return 1;
    if (isTablet(width)) return 2;
    if (isDesktop(width)) return 3;
    if (isLargeDesktop(width)) return 4;
    return 6; // Extra large desktop
  }

  /// Maximum content width for readable text content
  static const double maxContentWidth = 1200.0;

  /// Maximum width for centered dialogs and cards
  static const double maxDialogWidth = 600.0;

  /// Maximum width for sidebars and navigation drawers
  static const double maxSidebarWidth = 320.0;

  /// Minimum width for sidebars
  static const double minSidebarWidth = 240.0;
}

/// Extension on BuildContext for easy breakpoint access
extension ResponsiveContext on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if current screen is mobile
  bool get isMobile => ResponsiveBreakpoints.isMobile(screenWidth);

  /// Check if current screen is tablet
  bool get isTablet => ResponsiveBreakpoints.isTablet(screenWidth);

  /// Check if current screen is desktop
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(screenWidth);

  /// Check if current screen is large desktop
  bool get isLargeDesktop => ResponsiveBreakpoints.isLargeDesktop(screenWidth);

  /// Check if current screen is extra large desktop
  bool get isExtraLargeDesktop => 
      ResponsiveBreakpoints.isExtraLargeDesktop(screenWidth);

  /// Check if current screen is small (mobile or tablet)
  bool get isSmallScreen => ResponsiveBreakpoints.isSmallScreen(screenWidth);

  /// Check if current screen is large (desktop or larger)
  bool get isLargeScreen => ResponsiveBreakpoints.isLargeScreen(screenWidth);

  /// Get breakpoint name
  String get breakpointName => 
      ResponsiveBreakpoints.getBreakpointName(screenWidth);

  /// Get recommended column count for grid layouts
  int get columnCount => ResponsiveBreakpoints.getColumnCount(screenWidth);
}
