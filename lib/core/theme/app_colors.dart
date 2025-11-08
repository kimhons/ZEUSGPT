import 'package:flutter/material.dart';

/// Zeus-themed color palette for ZeusGPT
/// Based on brand identity guidelines
class AppColors {
  AppColors._(); // Private constructor

  // ============================================================
  // PRIMARY COLORS - Zeus Blue (Electric Blue)
  // Represents intelligence, trust, and innovation
  // ============================================================

  static const Color primary = Color(0xFF1E88E5); // rgb(30, 136, 229)
  static const Color primaryDark = Color(0xFF1565C0); // rgb(21, 101, 192)
  static const Color primaryLight = Color(0xFF42A5F5); // rgb(66, 165, 245)
  static const Color primary50 = Color(0xFFE3F2FD); // rgb(227, 242, 253)

  // ============================================================
  // ACCENT COLORS - Lightning Yellow
  // Represents energy, innovation, and premium features
  // ============================================================

  static const Color accent = Color(0xFFFFC107); // rgb(255, 193, 7)
  static const Color accentDark = Color(0xFFFFA000); // rgb(255, 160, 0)
  static const Color accentLight = Color(0xFFFFD54F); // rgb(255, 213, 79)

  // ============================================================
  // SECONDARY COLORS - Thunder Purple
  // Represents wisdom, creativity, and advanced features
  // ============================================================

  static const Color secondary = Color(0xFF5E35B1); // rgb(94, 53, 177)
  static const Color secondaryDark = Color(0xFF4527A0); // rgb(69, 39, 160)
  static const Color secondaryLight = Color(0xFF7E57C2); // rgb(126, 87, 194)

  // ============================================================
  // LIGHT MODE COLORS
  // ============================================================

  static const Color lightBackground = Color(0xFFF5F7FA); // rgb(245, 247, 250)
  static const Color lightSurface = Color(0xFFFFFFFF); // rgb(255, 255, 255)
  static const Color lightSurfaceDim = Color(0xFFF0F2F5); // rgb(240, 242, 245)

  static const Color lightTextPrimary = Color(0xFF1A1A1A); // rgb(26, 26, 26)
  static const Color lightTextSecondary = Color(0xFF616161); // rgb(97, 97, 97)
  static const Color lightTextDisabled = Color(0xFF9E9E9E); // rgb(158, 158, 158)

  static const Color lightBorder = Color(0xFFE0E0E0); // rgb(224, 224, 224)
  static const Color lightDivider = Color(0xFFEEEEEE); // rgb(238, 238, 238)

  // ============================================================
  // DARK MODE COLORS
  // ============================================================

  static const Color darkBackground = Color(0xFF0A0E1A); // rgb(10, 14, 26)
  static const Color darkSurface = Color(0xFF1C2333); // rgb(28, 35, 51)
  static const Color darkSurfaceDim = Color(0xFF151B28); // rgb(21, 27, 40)

  static const Color darkTextPrimary = Color(0xFFFFFFFF); // rgb(255, 255, 255)
  static const Color darkTextSecondary = Color(0xFFB0B0B0); // rgb(176, 176, 176)
  static const Color darkTextDisabled = Color(0xFF666666); // rgb(102, 102, 102)

  static const Color darkBorder = Color(0xFF2C3544); // rgb(44, 53, 68)
  static const Color darkDivider = Color(0xFF252D3D); // rgb(37, 45, 61)

  // ============================================================
  // STATUS & FEEDBACK COLORS
  // ============================================================

  static const Color success = Color(0xFF4CAF50); // rgb(76, 175, 80)
  static const Color warning = Color(0xFFFF9800); // rgb(255, 152, 0)
  static const Color error = Color(0xFFF44336); // rgb(244, 67, 54)
  static const Color info = Color(0xFF2196F3); // rgb(33, 150, 243)

  // ============================================================
  // CHAT MESSAGE COLORS
  // ============================================================

  // Light mode message bubbles
  static const Color lightUserMessageBg = Color(0xFFE8E8EA); // User messages
  static const Color lightAIMessageBg = Color(0xFFFFFFFF); // AI messages

  // Dark mode message bubbles
  static const Color darkUserMessageBg = Color(0xFF2C3544); // User messages
  static const Color darkAIMessageBg = Color(0xFF1C2333); // AI messages

  // ============================================================
  // GRADIENT COLORS
  // ============================================================

  /// Zeus Gradient - Primary brand gradient
  /// Use: Hero sections, premium features, app splash
  static const Gradient zeusGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  /// Lightning Gradient - Energy/Premium
  /// Use: Pro badges, premium CTAs, special offers
  static const Gradient lightningGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accent, Color(0xFFFF6F00)],
  );

  /// Thunder Gradient - Advanced Features
  /// Use: AI model cards, advanced settings backgrounds
  static const Gradient thunderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primary],
  );

  /// Aurora Gradient - Dark Mode Accent
  /// Use: Dark mode hero, loading screens, overlays
  static const Gradient auroraGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryLight, secondaryLight],
  );

  /// Light Gradient - Light mode backgrounds
  /// Use: Light mode hero sections, cards
  static const Gradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, secondaryLight, Color(0xFFF0F4F8)],
  );

  /// Dark Gradient - Dark mode backgrounds
  /// Use: Dark mode hero sections, cards
  static const Gradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F2E), Color(0xFF2C3544), primaryDark],
  );

  // ============================================================
  // PROVIDER BRAND COLORS (for model indicators)
  // ============================================================

  static const Color openAI = Color(0xFF10A37F);
  static const Color anthropic = Color(0xFFD97757);
  static const Color google = Color(0xFF4285F4);
  static const Color meta = Color(0xFF0668E1);
  static const Color mistral = Color(0xFFFF6B35);
  static const Color cohere = Color(0xFF39594D);

  // ============================================================
  // UTILITY COLORS
  // ============================================================

  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Shimmer loading colors (light mode)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Shimmer loading colors (dark mode)
  static const Color shimmerBaseDark = Color(0xFF2C3544);
  static const Color shimmerHighlightDark = Color(0xFF3A4456);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get user message background color based on theme
  static Color userMessageBackground(bool isDark) =>
      isDark ? darkUserMessageBg : lightUserMessageBg;

  /// Get AI message background color based on theme
  static Color aiMessageBackground(bool isDark) =>
      isDark ? darkAIMessageBg : lightAIMessageBg;

  /// Get text color based on theme
  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;

  /// Get secondary text color based on theme
  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  /// Get background color based on theme
  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  /// Get surface color based on theme
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;

  /// Get border color based on theme
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;

  /// Get divider color based on theme
  static Color divider(bool isDark) => isDark ? darkDivider : lightDivider;

  /// Get color for model provider
  static Color? getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return openAI;
      case 'anthropic':
        return anthropic;
      case 'google':
        return google;
      case 'meta':
        return meta;
      case 'mistral':
        return mistral;
      case 'cohere':
        return cohere;
      default:
        return primary;
    }
  }

  /// Add opacity to any color
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Lighten a color by percentage (0.0 to 1.0)
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken a color by percentage (0.0 to 1.0)
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
