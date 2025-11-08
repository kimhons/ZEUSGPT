import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/window_state_manager.dart';

/// Utilities for window management and screen information
///
/// Provides helper functions for working with desktop windows,
/// screen sizes, and display information.

/// Window size presets for common use cases
class WindowPresets {
  WindowPresets._();

  /// Compact window (small utility window)
  static const Size compact = Size(600, 400);

  /// Default window (standard app window)
  static const Size standard = Size(1200, 800);

  /// Large window (content-heavy apps)
  static const Size large = Size(1600, 1000);

  /// Wide window (dashboard, multi-panel)
  static const Size wide = Size(1800, 900);

  /// Square window (design tools, media viewers)
  static const Size square = Size(1000, 1000);

  /// Minimum recommended window size
  static const Size minimum = Size(400, 300);

  /// Maximum recommended window size (90% of typical screen)
  static const Size maximum = Size(1920, 1080);
}

/// Window positioning utilities
class WindowPositioning {
  WindowPositioning._();

  /// Center window on screen
  static Offset center(Size windowSize, Size screenSize) {
    final x = (screenSize.width - windowSize.width) / 2;
    final y = (screenSize.height - windowSize.height) / 2;
    return Offset(x.clamp(0.0, screenSize.width), y.clamp(0.0, screenSize.height));
  }

  /// Position window at top-left with margin
  static Offset topLeft({double margin = 50.0}) {
    return Offset(margin, margin);
  }

  /// Position window at top-right with margin
  static Offset topRight(Size windowSize, Size screenSize, {double margin = 50.0}) {
    final x = screenSize.width - windowSize.width - margin;
    return Offset(x.clamp(0.0, screenSize.width), margin);
  }

  /// Position window at bottom-left with margin
  static Offset bottomLeft(Size windowSize, Size screenSize, {double margin = 50.0}) {
    final y = screenSize.height - windowSize.height - margin;
    return Offset(margin, y.clamp(0.0, screenSize.height));
  }

  /// Position window at bottom-right with margin
  static Offset bottomRight(
    Size windowSize,
    Size screenSize, {
    double margin = 50.0,
  }) {
    final x = screenSize.width - windowSize.width - margin;
    final y = screenSize.height - windowSize.height - margin;
    return Offset(
      x.clamp(0.0, screenSize.width),
      y.clamp(0.0, screenSize.height),
    );
  }

  /// Cascade position for multiple windows
  static Offset cascade(int windowIndex, {double offset = 30.0}) {
    final x = 100.0 + (windowIndex * offset);
    final y = 100.0 + (windowIndex * offset);
    return Offset(x, y);
  }
}

/// Screen information utilities
class ScreenInfo {
  ScreenInfo._();

  /// Get primary screen size
  static Size getPrimaryScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get usable screen size (excluding taskbar, menu bar)
  static Size getUsableScreenSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Size(
      size.width,
      size.height - padding.top - padding.bottom,
    );
  }

  /// Check if screen is large enough for window size
  static bool canFitWindow(Size windowSize, Size screenSize) {
    return windowSize.width <= screenSize.width &&
        windowSize.height <= screenSize.height;
  }

  /// Get recommended window size for screen
  static Size getRecommendedSize(Size screenSize) {
    // 80% of screen size
    return Size(
      screenSize.width * 0.8,
      screenSize.height * 0.8,
    );
  }

  /// Check if screen is considered "desktop" size
  static bool isDesktopSize(Size screenSize) {
    return screenSize.width >= 1024 && screenSize.height >= 768;
  }

  /// Check if screen is considered "large desktop" size
  static bool isLargeDesktopSize(Size screenSize) {
    return screenSize.width >= 1920 && screenSize.height >= 1080;
  }

  /// Get screen aspect ratio
  static double getAspectRatio(Size screenSize) {
    return screenSize.width / screenSize.height;
  }

  /// Check if screen is landscape orientation
  static bool isLandscape(Size screenSize) {
    return screenSize.width > screenSize.height;
  }

  /// Check if screen is portrait orientation
  static bool isPortrait(Size screenSize) {
    return screenSize.height > screenSize.width;
  }
}

/// Window constraints helper
class WindowConstraints {
  WindowConstraints._();

  /// Constrain window size to valid range
  static Size constrainSize(Size size, {
    Size? minSize,
    Size? maxSize,
  }) {
    final min = minSize ?? WindowPresets.minimum;
    final max = maxSize ?? WindowPresets.maximum;

    return Size(
      size.width.clamp(min.width, max.width),
      size.height.clamp(min.height, max.height),
    );
  }

  /// Constrain window position to screen bounds
  static Offset constrainPosition(
    Offset position,
    Size windowSize,
    Size screenSize,
  ) {
    return Offset(
      position.dx.clamp(0.0, (screenSize.width - windowSize.width).clamp(0.0, screenSize.width)),
      position.dy.clamp(0.0, (screenSize.height - windowSize.height).clamp(0.0, screenSize.height)),
    );
  }

  /// Create constrained window state
  static WindowState constrainWindowState(
    WindowState state,
    Size screenSize, {
    Size? minSize,
    Size? maxSize,
  }) {
    final constrainedSize = constrainSize(
      state.size,
      minSize: minSize,
      maxSize: maxSize,
    );

    final constrainedPosition = constrainPosition(
      state.position,
      constrainedSize,
      screenSize,
    );

    return state.copyWith(
      size: constrainedSize,
      position: constrainedPosition,
    );
  }
}

/// Window title bar utilities
class WindowTitleBar {
  WindowTitleBar._();

  /// Standard title bar height on macOS
  static const double macOSTitleBarHeight = 28.0;

  /// Standard title bar height on Windows
  static const double windowsTitleBarHeight = 32.0;

  /// Standard title bar height on Linux
  static const double linuxTitleBarHeight = 32.0;

  /// Get platform-specific title bar height
  static double getPlatformTitleBarHeight() {
    // This would use PlatformHelper to determine actual platform
    // For now, return standard height
    return 32.0;
  }
}

/// Extension methods for window state management
extension WindowStateExtensions on BuildContext {
  /// Get current screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get usable screen size (excluding system UI)
  Size get usableScreenSize => ScreenInfo.getUsableScreenSize(this);

  /// Check if current screen is desktop size
  bool get isDesktopScreen => ScreenInfo.isDesktopSize(screenSize);

  /// Get recommended window size for current screen
  Size get recommendedWindowSize => ScreenInfo.getRecommendedSize(screenSize);
}

/// Window state builder widget
///
/// Rebuilds when window state changes.
///
/// Example usage:
/// ```dart
/// WindowStateBuilder(
///   builder: (context, state) {
///     return Text('Window: ${state.size}');
///   },
/// )
/// ```
class WindowStateBuilder extends StatefulWidget {
  const WindowStateBuilder({
    super.key,
    required this.builder,
  });

  /// Builder function that receives window state
  final Widget Function(BuildContext context, WindowState? state) builder;

  @override
  State<WindowStateBuilder> createState() => _WindowStateBuilderState();
}

class _WindowStateBuilderState extends State<WindowStateBuilder> {
  final _windowManager = WindowStateManager();
  WindowState? _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = _windowManager.currentState;
    _windowManager.stateChanges.listen((state) {
      setState(() {
        _currentState = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentState);
  }
}

/// Window debug overlay
///
/// Shows window state information for debugging.
///
/// Example usage:
/// ```dart
/// if (kDebugMode)
///   WindowDebugOverlay(),
/// ```
class WindowDebugOverlay extends StatelessWidget {
  const WindowDebugOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowStateBuilder(
      builder: (context, state) {
        if (state == null) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Window State',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${state.size.width.toInt()} x ${state.size.height.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Position: (${state.position.dx.toInt()}, ${state.position.dy.toInt()})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Maximized: ${state.isMaximized}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Fullscreen: ${state.isFullscreen}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Helper functions for common window operations
class WindowOperations {
  WindowOperations._();

  /// Calculate window size that fits content
  static Size calculateContentSize({
    required Size contentSize,
    EdgeInsets padding = EdgeInsets.zero,
    bool includeTitleBar = true,
  }) {
    final width = contentSize.width + padding.left + padding.right;
    final titleBarHeight = includeTitleBar ? WindowTitleBar.getPlatformTitleBarHeight() : 0.0;
    final height = contentSize.height + padding.top + padding.bottom + titleBarHeight;

    return Size(width, height);
  }

  /// Calculate content size from window size
  static Size calculateWindowContentSize({
    required Size windowSize,
    EdgeInsets padding = EdgeInsets.zero,
    bool includeTitleBar = true,
  }) {
    final titleBarHeight = includeTitleBar ? WindowTitleBar.getPlatformTitleBarHeight() : 0.0;
    final width = windowSize.width - padding.left - padding.right;
    final height = windowSize.height - padding.top - padding.bottom - titleBarHeight;

    return Size(width.clamp(0.0, double.infinity), height.clamp(0.0, double.infinity));
  }

  /// Check if two window states are effectively the same
  static bool areStatesSimilar(
    WindowState a,
    WindowState b, {
    double sizeTolerance = 5.0,
    double positionTolerance = 5.0,
  }) {
    final sizeMatch = (a.size.width - b.size.width).abs() <= sizeTolerance &&
        (a.size.height - b.size.height).abs() <= sizeTolerance;

    final positionMatch = (a.position.dx - b.position.dx).abs() <= positionTolerance &&
        (a.position.dy - b.position.dy).abs() <= positionTolerance;

    final flagsMatch = a.isMaximized == b.isMaximized && a.isFullscreen == b.isFullscreen;

    return sizeMatch && positionMatch && flagsMatch;
  }
}
