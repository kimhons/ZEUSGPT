import 'package:flutter/material.dart';
import '../constants/responsive_breakpoints.dart';

/// Adaptive scaffold that automatically chooses the appropriate navigation
/// pattern based on screen size and platform
///
/// - Mobile (<600px): Bottom navigation bar
/// - Tablet (600-900px): Optional navigation rail or bottom bar
/// - Desktop (900px+): Persistent sidebar navigation rail
/// - Web: Can be configured for any of the above
///
/// Example usage:
/// ```dart
/// AdaptiveScaffold(
///   currentIndex: 0,
///   onDestinationSelected: (index) {
///     // Handle navigation
///   },
///   destinations: const [
///     AdaptiveScaffoldDestination(
///       icon: Icons.home,
///       label: 'Home',
///     ),
///     AdaptiveScaffoldDestination(
///       icon: Icons.chat,
///       label: 'Chat',
///     ),
///   ],
///   body: HomeScreen(),
/// )
/// ```
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.navigationRailWidth = 80.0,
    this.useNavigationRailOnTablet = false,
  });

  /// The primary content widget
  final Widget body;

  /// List of destinations for navigation
  final List<AdaptiveScaffoldDestination> destinations;

  /// Current selected destination index
  final int currentIndex;

  /// Called when a destination is selected
  final ValueChanged<int> onDestinationSelected;

  /// Optional app bar
  final PreferredSizeWidget? appBar;

  /// Optional floating action button
  final Widget? floatingActionButton;

  /// FAB location
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Optional drawer
  final Widget? drawer;

  /// Optional end drawer
  final Widget? endDrawer;

  /// Background color
  final Color? backgroundColor;

  /// Resize to avoid bottom inset
  final bool? resizeToAvoidBottomInset;

  /// Extend body behind bottom navigation
  final bool extendBody;

  /// Extend body behind app bar
  final bool extendBodyBehindAppBar;

  /// Width of navigation rail (desktop/tablet)
  final double navigationRailWidth;

  /// Whether to use navigation rail on tablet (default: bottom nav)
  final bool useNavigationRailOnTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Desktop: Use navigation rail
        if (ResponsiveBreakpoints.isDesktop(width) ||
            ResponsiveBreakpoints.isLargeDesktop(width)) {
          return _buildWithNavigationRail(context);
        }

        // Tablet: Use rail or bottom nav based on preference
        if (ResponsiveBreakpoints.isTablet(width)) {
          if (useNavigationRailOnTablet) {
            return _buildWithNavigationRail(context);
          }
          return _buildWithBottomNav(context);
        }

        // Mobile: Use bottom navigation
        return _buildWithBottomNav(context);
      },
    );
  }

  Widget _buildWithBottomNav(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((dest) {
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: dest.selectedIcon != null
                ? Icon(dest.selectedIcon)
                : null,
            label: dest.label,
            tooltip: dest.tooltip,
          );
        }).toList(),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  Widget _buildWithNavigationRail(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          // Navigation rail
          SizedBox(
            width: navigationRailWidth,
            child: NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: destinations.map((dest) {
                return NavigationRailDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: dest.selectedIcon != null
                      ? Icon(dest.selectedIcon)
                      : null,
                  label: Text(dest.label),
                );
              }).toList(),
            ),
          ),
          // Vertical divider
          const VerticalDivider(thickness: 1, width: 1),
          // Main content
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}

/// Destination for AdaptiveScaffold navigation
class AdaptiveScaffoldDestination {
  const AdaptiveScaffoldDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.tooltip,
  });

  /// Icon to display for this destination
  final IconData icon;

  /// Icon to display when this destination is selected (optional)
  final IconData? selectedIcon;

  /// Label text for this destination
  final String label;

  /// Tooltip text (optional, defaults to label)
  final String? tooltip;
}

/// Extended adaptive scaffold with more customization options
///
/// Provides additional features like:
/// - Extended navigation rail with leading/trailing widgets
/// - Custom rail width
/// - Better app bar integration
/// - Drawer support for both mobile and desktop
///
/// Example usage:
/// ```dart
/// ExtendedAdaptiveScaffold(
///   currentIndex: 0,
///   onDestinationSelected: (index) {},
///   destinations: [...],
///   body: HomeScreen(),
///   railLeading: FloatingActionButton.extended(
///     onPressed: () {},
///     label: Text('New Chat'),
///     icon: Icon(Icons.add),
///   ),
///   railTrailing: Expanded(
///     child: Align(
///       alignment: Alignment.bottomCenter,
///       child: UserProfileButton(),
///     ),
///   ),
/// )
/// ```
class ExtendedAdaptiveScaffold extends StatelessWidget {
  const ExtendedAdaptiveScaffold({
    super.key,
    required this.body,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.railLeading,
    this.railTrailing,
    this.railWidth = 80.0,
    this.extendedRailWidth = 256.0,
    this.isRailExtended = false,
    this.useNavigationRailOnTablet = false,
  });

  final Widget body;
  final List<AdaptiveScaffoldDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;

  /// Widget to show at the top of the navigation rail
  final Widget? railLeading;

  /// Widget to show at the bottom of the navigation rail
  final Widget? railTrailing;

  /// Width of collapsed rail
  final double railWidth;

  /// Width of extended rail
  final double extendedRailWidth;

  /// Whether the rail should be extended (show labels)
  final bool isRailExtended;

  final bool useNavigationRailOnTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Desktop: Use extended navigation rail
        if (ResponsiveBreakpoints.isDesktop(width) ||
            ResponsiveBreakpoints.isLargeDesktop(width)) {
          return _buildWithExtendedRail(context);
        }

        // Tablet: Use rail or bottom nav
        if (ResponsiveBreakpoints.isTablet(width)) {
          if (useNavigationRailOnTablet) {
            return _buildWithExtendedRail(context);
          }
          return _buildWithBottomNav(context);
        }

        // Mobile: Use bottom navigation
        return _buildWithBottomNav(context);
      },
    );
  }

  Widget _buildWithBottomNav(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((dest) {
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: dest.selectedIcon != null
                ? Icon(dest.selectedIcon)
                : null,
            label: dest.label,
          );
        }).toList(),
      ),
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildWithExtendedRail(BuildContext context) {
    final effectiveRailWidth = isRailExtended ? extendedRailWidth : railWidth;

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          SizedBox(
            width: effectiveRailWidth,
            child: NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              extended: isRailExtended,
              labelType: isRailExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: railLeading,
              trailing: railTrailing,
              destinations: destinations.map((dest) {
                return NavigationRailDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: dest.selectedIcon != null
                      ? Icon(dest.selectedIcon)
                      : null,
                  label: Text(dest.label),
                );
              }).toList(),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
    );
  }
}
