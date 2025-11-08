import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system for ZeusGPT
/// Based on SF Pro Display/Text (iOS) and Roboto (Android/Web)
class AppTextStyles {
  AppTextStyles._(); // Private constructor

  // Font families
  static const String fontFamily = 'SFPro'; // Falls back to system font

  // ============================================================
  // DISPLAY STYLES (Hero Headlines)
  // Size: 40-48pt, Weight: Bold (700)
  // Usage: Landing page headers, major sections
  // ============================================================

  static TextStyle display({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 48,
      fontWeight: fontWeight ?? FontWeight.w700,
      height: height ?? 1.2,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle displayLight({Color? color}) =>
      display(color: color ?? AppColors.lightTextPrimary);

  static TextStyle displayDark({Color? color}) =>
      display(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // HEADLINE 1
  // Size: 32pt, Weight: Bold (700)
  // Usage: Screen titles, important headers
  // ============================================================

  static TextStyle headline1({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: fontWeight ?? FontWeight.w700,
      height: height ?? 1.25,
      letterSpacing: -0.3,
      color: color,
    );
  }

  static TextStyle headline1Light({Color? color}) =>
      headline1(color: color ?? AppColors.lightTextPrimary);

  static TextStyle headline1Dark({Color? color}) =>
      headline1(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // HEADLINE 2
  // Size: 24pt, Weight: Semibold (600)
  // Usage: Section headers, card titles
  // ============================================================

  static TextStyle headline2({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: height ?? 1.3,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle headline2Light({Color? color}) =>
      headline2(color: color ?? AppColors.lightTextPrimary);

  static TextStyle headline2Dark({Color? color}) =>
      headline2(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // HEADLINE 3
  // Size: 20pt, Weight: Semibold (600)
  // Usage: Subsection headers, list titles
  // ============================================================

  static TextStyle headline3({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: height ?? 1.4,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle headline3Light({Color? color}) =>
      headline3(color: color ?? AppColors.lightTextPrimary);

  static TextStyle headline3Dark({Color? color}) =>
      headline3(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // H2 (Alias for headline2)
  // Size: 24pt, Weight: Bold (700)
  // Usage: Shorter alias for headline2
  // ============================================================

  static TextStyle h2({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return headline2(
      color: color,
      height: height,
      fontWeight: fontWeight,
    );
  }

  static TextStyle h2Light({Color? color}) =>
      h2(color: color ?? AppColors.lightTextPrimary);

  static TextStyle h2Dark({Color? color}) =>
      h2(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // H3 (Alias for headline3)
  // Size: 20pt, Weight: Semibold (600)
  // Usage: Shorter alias for headline3
  // ============================================================

  static TextStyle h3({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return headline3(
      color: color,
      height: height,
      fontWeight: fontWeight,
    );
  }

  static TextStyle h3Light({Color? color}) =>
      h3(color: color ?? AppColors.lightTextPrimary);

  static TextStyle h3Dark({Color? color}) =>
      h3(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // H4 (Small Header)
  // Size: 18pt, Weight: Semibold (600)
  // Usage: Small headers, card titles
  // ============================================================

  static TextStyle h4({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: height ?? 1.4,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle h4Light({Color? color}) =>
      h4(color: color ?? AppColors.lightTextPrimary);

  static TextStyle h4Dark({Color? color}) =>
      h4(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // BODY LARGE
  // Size: 18pt, Weight: Regular (400)
  // Usage: Intro paragraphs, important body text
  // ============================================================

  static TextStyle bodyLarge({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: height ?? 1.5,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle bodyLargeLight({Color? color}) =>
      bodyLarge(color: color ?? AppColors.lightTextPrimary);

  static TextStyle bodyLargeDark({Color? color}) =>
      bodyLarge(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // BODY (Standard)
  // Size: 16pt, Weight: Regular (400)
  // Usage: Standard body text, chat messages
  // ============================================================

  static TextStyle body({
    Color? color,
    double? height,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: height ?? 1.5,
      letterSpacing: 0,
      color: color,
      decoration: decoration,
    );
  }

  static TextStyle bodyLight({Color? color}) =>
      body(color: color ?? AppColors.lightTextPrimary);

  static TextStyle bodyDark({Color? color}) =>
      body(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // BODY MEDIUM (Alias for body)
  // Size: 16pt, Weight: Regular (400)
  // Usage: Standard body text, Material Design 3 naming
  // ============================================================

  static TextStyle bodyMedium({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return body(
      color: color,
      height: height,
      fontWeight: fontWeight,
    );
  }

  static TextStyle bodyMediumLight({Color? color}) =>
      bodyMedium(color: color ?? AppColors.lightTextPrimary);

  static TextStyle bodyMediumDark({Color? color}) =>
      bodyMedium(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // BODY SMALL
  // Size: 14pt, Weight: Regular (400)
  // Usage: Secondary information, metadata
  // ============================================================

  static TextStyle bodySmall({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: height ?? 1.5,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle bodySmallLight({Color? color}) =>
      bodySmall(color: color ?? AppColors.lightTextSecondary);

  static TextStyle bodySmallDark({Color? color}) =>
      bodySmall(color: color ?? AppColors.darkTextSecondary);

  // ============================================================
  // CAPTION
  // Size: 12pt, Weight: Regular (400)
  // Usage: Timestamps, helper text, labels
  // ============================================================

  static TextStyle caption({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: height ?? 1.4,
      letterSpacing: 0.2,
      color: color,
    );
  }

  static TextStyle captionLight({Color? color}) =>
      caption(color: color ?? AppColors.lightTextSecondary);

  static TextStyle captionDark({Color? color}) =>
      caption(color: color ?? AppColors.darkTextSecondary);

  // ============================================================
  // LABEL SMALL
  // Size: 11pt, Weight: Medium (500)
  // Usage: Small labels, tiny text, Material Design 3 naming
  // ============================================================

  static TextStyle labelSmall({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: fontWeight ?? FontWeight.w500,
      height: height ?? 1.4,
      letterSpacing: 0.5,
      color: color,
    );
  }

  static TextStyle labelSmallLight({Color? color}) =>
      labelSmall(color: color ?? AppColors.lightTextSecondary);

  static TextStyle labelSmallDark({Color? color}) =>
      labelSmall(color: color ?? AppColors.darkTextSecondary);

  // ============================================================
  // OVERLINE
  // Size: 12pt, Weight: Medium (500), UPPERCASE
  // Usage: Category labels, section markers
  // ============================================================

  static TextStyle overline({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: fontWeight ?? FontWeight.w500,
      height: height ?? 1.5,
      letterSpacing: 1,
      color: color,
    );
  }

  static TextStyle overlineLight({Color? color}) =>
      overline(color: color ?? AppColors.lightTextSecondary);

  static TextStyle overlineDark({Color? color}) =>
      overline(color: color ?? AppColors.darkTextSecondary);

  // ============================================================
  // BUTTON TEXT
  // Size: 16pt, Weight: Semibold (600)
  // Usage: Button labels, CTAs
  // ============================================================

  static TextStyle button({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: height ?? 1.2,
      letterSpacing: 0.5,
      color: color,
    );
  }

  static TextStyle buttonLight({Color? color}) =>
      button(color: color ?? AppColors.white);

  static TextStyle buttonDark({Color? color}) =>
      button(color: color ?? AppColors.white);

  // ============================================================
  // CODE / MONOSPACE
  // Font: SF Mono / Roboto Mono, Size: 14pt
  // Usage: Code blocks, technical content
  // ============================================================

  static TextStyle code({
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      height: height ?? 1.6,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle codeLight({Color? color}) =>
      code(color: color ?? AppColors.lightTextPrimary);

  static TextStyle codeDark({Color? color}) =>
      code(color: color ?? AppColors.darkTextPrimary);

  // ============================================================
  // LINK TEXT
  // Underlined, colored primary
  // ============================================================

  static TextStyle link({
    Color? color,
    bool isDark = false,
  }) {
    return body(
      color: color ?? AppColors.primary,
      decoration: TextDecoration.underline,
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get appropriate text style based on theme mode
  static TextStyle getBodyStyle(bool isDark, {Color? color}) {
    return isDark ? bodyDark(color: color) : bodyLight(color: color);
  }

  static TextStyle getHeadline1Style(bool isDark, {Color? color}) {
    return isDark ? headline1Dark(color: color) : headline1Light(color: color);
  }

  static TextStyle getHeadline2Style(bool isDark, {Color? color}) {
    return isDark ? headline2Dark(color: color) : headline2Light(color: color);
  }

  static TextStyle getHeadline3Style(bool isDark, {Color? color}) {
    return isDark ? headline3Dark(color: color) : headline3Light(color: color);
  }

  static TextStyle getCaptionStyle(bool isDark, {Color? color}) {
    return isDark ? captionDark(color: color) : captionLight(color: color);
  }

  /// Apply bold weight to any text style
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  /// Apply semibold weight to any text style
  static TextStyle semibold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }

  /// Apply medium weight to any text style
  static TextStyle medium(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w500);
  }

  /// Apply italic to any text style
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply opacity to any text style
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withValues(alpha: opacity));
  }
}
