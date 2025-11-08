import 'package:flutter/material.dart';
import '../constants/responsive_breakpoints.dart';
import '../utils/platform_helper.dart';
import 'responsive_layout.dart';

/// Base class for responsive screens that adapt to different form factors
///
/// This abstract class provides a template for creating screens that automatically
/// adapt to mobile, tablet, and desktop layouts. Simply extend this class and
/// implement the required builder methods.
///
/// Example usage:
/// ```dart
/// class HomeScreen extends ResponsiveScreen {
///   @override
///   Widget buildMobile(BuildContext context) {
///     return Column(
///       children: [
///         AppBar(title: Text('Home')),
///         // Mobile-specific UI
///       ],
///     );
///   }
///
///   @override
///   Widget buildDesktop(BuildContext context) {
///     return Row(
///       children: [
///         // Sidebar
///         NavigationRail(...),
///         // Main content
///         Expanded(child: ...),
///       ],
///     );
///   }
/// }
/// ```
abstract class ResponsiveScreen extends StatelessWidget {
  const ResponsiveScreen({super.key});

  /// Build the mobile layout (portrait phones, <600px)
  ///
  /// This should provide a compact, vertical-first layout optimized
  /// for one-handed use and small screens.
  Widget buildMobile(BuildContext context);

  /// Build the tablet layout (landscape phones, tablets, 600-900px)
  ///
  /// Optional. If not overridden, defaults to mobile layout.
  /// Should provide a more spacious layout with better use of horizontal space.
  Widget buildTablet(BuildContext context) => buildMobile(context);

  /// Build the desktop layout (laptops, monitors, 900px+)
  ///
  /// Optional. If not overridden, defaults to tablet layout.
  /// Should provide a multi-column layout with sidebars, expanded controls,
  /// and keyboard-first navigation.
  Widget buildDesktop(BuildContext context) => buildTablet(context);

  /// Build the large desktop layout (large monitors, 1200px+)
  ///
  /// Optional. If not overridden, defaults to desktop layout.
  /// Should maximize use of screen space with additional panels or details.
  Widget buildLargeDesktop(BuildContext context) => buildDesktop(context);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: buildMobile(context),
      tablet: buildTablet(context),
      desktop: buildDesktop(context),
      largeDesktop: buildLargeDesktop(context),
    );
  }
}

/// Base class for responsive screens with app bar
///
/// Similar to ResponsiveScreen but includes automatic app bar management
/// with platform-appropriate styling.
///
/// Example usage:
/// ```dart
/// class SettingsScreen extends ResponsiveScreenWithAppBar {
///   @override
///   String getTitle(BuildContext context) => 'Settings';
///
///   @override
///   Widget buildMobileContent(BuildContext context) {
///     return ListView(...);
///   }
/// }
/// ```
abstract class ResponsiveScreenWithAppBar extends StatelessWidget {
  const ResponsiveScreenWithAppBar({super.key});

  /// Get the screen title
  String getTitle(BuildContext context);

  /// Get app bar actions (optional)
  List<Widget>? getActions(BuildContext context) => null;

  /// Build the mobile content (without app bar)
  Widget buildMobileContent(BuildContext context);

  /// Build the tablet content (without app bar)
  Widget buildTabletContent(BuildContext context) => buildMobileContent(context);

  /// Build the desktop content (without app bar)
  Widget buildDesktopContent(BuildContext context) => buildTabletContent(context);

  /// Build the large desktop content (without app bar)
  Widget buildLargeDesktopContent(BuildContext context) =>
      buildDesktopContent(context);

  /// Build the app bar for mobile
  PreferredSizeWidget buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: Text(getTitle(context)),
      actions: getActions(context),
    );
  }

  /// Build the app bar for desktop
  PreferredSizeWidget buildDesktopAppBar(BuildContext context) {
    return AppBar(
      title: Text(getTitle(context)),
      actions: getActions(context),
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: buildMobileAppBar(context),
        body: buildMobileContent(context),
      ),
      tablet: Scaffold(
        appBar: buildMobileAppBar(context),
        body: buildTabletContent(context),
      ),
      desktop: Scaffold(
        appBar: buildDesktopAppBar(context),
        body: buildDesktopContent(context),
      ),
      largeDesktop: Scaffold(
        appBar: buildDesktopAppBar(context),
        body: buildLargeDesktopContent(context),
      ),
    );
  }
}

/// Responsive content builder that provides platform and breakpoint information
///
/// Use this when you need fine-grained control over responsive behavior
/// within a specific part of your UI.
///
/// Example usage:
/// ```dart
/// ResponsiveContentBuilder(
///   builder: (context, info) {
///     if (info.isMobile) {
///       return Text('Mobile: ${info.width.toInt()}px');
///     }
///     return Text('Desktop: ${info.width.toInt()}px on ${info.platformName}');
///   },
/// )
/// ```
class ResponsiveContentBuilder extends StatelessWidget {
  const ResponsiveContentBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, ResponsiveInfo info) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final info = ResponsiveInfo(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
        );
        return builder(context, info);
      },
    );
  }
}

/// Information about current responsive context
class ResponsiveInfo {
  const ResponsiveInfo({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  // Screen size queries
  bool get isMobile => ResponsiveBreakpoints.isMobile(width);
  bool get isTablet => ResponsiveBreakpoints.isTablet(width);
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(width);
  bool get isLargeDesktop => ResponsiveBreakpoints.isLargeDesktop(width);
  bool get isExtraLargeDesktop => ResponsiveBreakpoints.isExtraLargeDesktop(width);

  bool get isSmallScreen => ResponsiveBreakpoints.isSmallScreen(width);
  bool get isLargeScreen => ResponsiveBreakpoints.isLargeScreen(width);

  // Platform queries
  bool get isWebPlatform => PlatformHelper.isWeb;
  bool get isMobilePlatform => PlatformHelper.isMobile;
  bool get isDesktopPlatform => PlatformHelper.isDesktop;

  String get platformName => PlatformHelper.platformName;
  String get breakpointName => ResponsiveBreakpoints.getBreakpointName(width);

  // Layout recommendations
  int get recommendedColumns => ResponsiveBreakpoints.getColumnCount(width);
  bool get shouldUseBottomNav => PlatformHelper.useBottomNavigation;
  bool get shouldUseSidebar => PlatformHelper.useSidebarNavigation;
  bool get shouldUseTopNav => PlatformHelper.useTopNavigation;

  @override
  String toString() =>
      'ResponsiveInfo(${width.toInt()}x${height.toInt()}px, '
      '$breakpointName on $platformName)';
}
