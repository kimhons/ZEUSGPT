import 'package:flutter/material.dart';
import '../constants/responsive_breakpoints.dart';
import '../utils/platform_helper.dart';

/// Responsive layout builder that adapts to different screen sizes
/// 
/// Provides different widget trees for mobile, tablet, and desktop layouts.
/// 
/// Example usage:
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileLayout(),
///   tablet: TabletLayout(),
///   desktop: DesktopLayout(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  /// Widget to show on mobile devices
  final Widget mobile;

  /// Widget to show on tablet devices (defaults to mobile if not provided)
  final Widget? tablet;

  /// Widget to show on desktop devices (defaults to tablet/mobile)
  final Widget? desktop;
  /// Widget to show on large desktop devices (defaults to desktop/tablet/mobile)
  final Widget? largeDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Large desktop layout
        if (ResponsiveBreakpoints.isLargeDesktop(width)) {
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        }

        // Desktop layout
        if (ResponsiveBreakpoints.isDesktop(width)) {
          return desktop ?? tablet ?? mobile;
        }

        // Tablet layout
        if (ResponsiveBreakpoints.isTablet(width)) {
          return tablet ?? mobile;
        }

        // Mobile layout
        return mobile;
      },
    );
  }
}

/// Responsive builder that provides the current screen width
/// 
/// Example usage:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, width) {
///     if (width < ResponsiveBreakpoints.tablet) {
///       return Text('Mobile: $width');
///     }
///     return Text('Desktop: $width');
///   },
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  /// Builder function that receives context and screen width
  final Widget Function(BuildContext context, double width) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints.maxWidth);
      },
    );
  }
}

/// Responsive padding that scales with screen size
/// 
/// Example usage:
/// ```dart
/// ResponsivePadding(
///   child: Text('Content'),
/// )
/// ```
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = 16.0,
    this.tabletPadding = 24.0,
    this.desktopPadding = 32.0,
  });

  final Widget child;
  final double mobilePadding;
  final double tabletPadding;
  final double desktopPadding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, width) {
        double padding;
        if (ResponsiveBreakpoints.isMobile(width)) {
          padding = mobilePadding;
        } else if (ResponsiveBreakpoints.isTablet(width)) {
          padding = tabletPadding;
        } else {
          padding = desktopPadding;
        }

        return Padding(
          padding: EdgeInsets.all(padding),
          child: child,
        );
      },
    );
  }
}

/// Responsive center container with max width constraints
/// 
/// Example usage:
/// ```dart
/// ResponsiveCenter(
///   child: Text('Centered content'),
/// )
/// ```
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Responsive grid that adapts column count based on screen size
/// 
/// Example usage:
/// ```dart
/// ResponsiveGrid(
///   children: [
///     Card(child: Text('Item 1')),
///     Card(child: Text('Item 2')),
///     Card(child: Text('Item 3')),
///   ],
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeDesktopColumns = 4,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int largeDesktopColumns;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, width) {
        int columns;
        if (ResponsiveBreakpoints.isMobile(width)) {
          columns = mobileColumns;
        } else if (ResponsiveBreakpoints.isTablet(width)) {
          columns = tabletColumns;
        } else if (ResponsiveBreakpoints.isLargeDesktop(width)) {
          columns = largeDesktopColumns;
        } else {
          columns = desktopColumns;
        }

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}

/// Adaptive navigation wrapper that chooses navigation pattern based on platform
/// 
/// Shows bottom navigation on mobile, sidebar on desktop, top bar on web
/// 
/// Example usage:
/// ```dart
/// AdaptiveNavigation(
///   destinations: [
///     AdaptiveDestination(icon: Icons.home, label: 'Home'),
///     AdaptiveDestination(icon: Icons.chat, label: 'Chat'),
///   ],
///   selectedIndex: 0,
///   onDestinationSelected: (index) => {},
///   body: HomeScreen(),
/// )
/// ```
class AdaptiveNavigation extends StatelessWidget {
  const AdaptiveNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
  });

  final List<AdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    // Use platform helper to determine navigation style
    if (PlatformHelper.useSidebarNavigation) {
      // Desktop: Sidebar navigation
      return Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: destinations.map((dest) {
              return NavigationRailDestination(
                icon: Icon(dest.icon),
                label: Text(dest.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      );
    } else if (PlatformHelper.useBottomNavigation) {
      // Mobile: Bottom navigation
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations.map((dest) {
            return NavigationDestination(
              icon: Icon(dest.icon),
              label: dest.label,
            );
          }).toList(),
        ),
      );
    } else {
      // Web: Top navigation (simplified)
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations.map((dest) {
            return NavigationDestination(
              icon: Icon(dest.icon),
              label: dest.label,
            );
          }).toList(),
        ),
      );
    }
  }
}

/// Destination data for adaptive navigation
class AdaptiveDestination {
  const AdaptiveDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final String label;
  final IconData? selectedIcon;
}
