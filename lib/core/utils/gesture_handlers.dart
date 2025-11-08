import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// Utilities for handling touch gestures on mobile and tablet devices
///
/// Provides common gesture patterns like swipe, long press, double tap,
/// and context menus with platform-appropriate feedback.

/// Widget that detects swipe gestures in all directions
///
/// Example usage:
/// ```dart
/// SwipeDetector(
///   onSwipeLeft: () => print('Swiped left'),
///   onSwipeRight: () => print('Swiped right'),
///   child: Container(...),
/// )
/// ```
class SwipeDetector extends StatelessWidget {
  const SwipeDetector({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.swipeThreshold = 50.0,
    this.velocityThreshold = 300.0,
  });

  /// The child widget
  final Widget child;

  /// Called when user swipes left
  final VoidCallback? onSwipeLeft;

  /// Called when user swipes right
  final VoidCallback? onSwipeRight;

  /// Called when user swipes up
  final VoidCallback? onSwipeUp;

  /// Called when user swipes down
  final VoidCallback? onSwipeDown;

  /// Minimum distance to trigger swipe (logical pixels)
  final double swipeThreshold;

  /// Minimum velocity to trigger swipe (pixels/second)
  final double velocityThreshold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Track swipe direction and distance
        final delta = details.delta;
        final isHorizontal = delta.dx.abs() > delta.dy.abs();

        if (isHorizontal) {
          if (delta.dx > swipeThreshold && onSwipeRight != null) {
            onSwipeRight!();
          } else if (delta.dx < -swipeThreshold && onSwipeLeft != null) {
            onSwipeLeft!();
          }
        } else {
          if (delta.dy > swipeThreshold && onSwipeDown != null) {
            onSwipeDown!();
          } else if (delta.dy < -swipeThreshold && onSwipeUp != null) {
            onSwipeUp!();
          }
        }
      },
      onPanEnd: (details) {
        // Check velocity for quick swipes
        final velocity = details.velocity.pixelsPerSecond;
        final isHorizontal = velocity.dx.abs() > velocity.dy.abs();

        if (isHorizontal) {
          if (velocity.dx > velocityThreshold && onSwipeRight != null) {
            onSwipeRight!();
          } else if (velocity.dx < -velocityThreshold && onSwipeLeft != null) {
            onSwipeLeft!();
          }
        } else {
          if (velocity.dy > velocityThreshold && onSwipeDown != null) {
            onSwipeDown!();
          } else if (velocity.dy < -velocityThreshold && onSwipeUp != null) {
            onSwipeUp!();
          }
        }
      },
      child: child,
    );
  }
}

/// Widget that provides long press and tap feedback
///
/// Example usage:
/// ```dart
/// PressDetector(
///   onTap: () => print('Tapped'),
///   onLongPress: () => showContextMenu(),
///   showFeedback: true,
///   child: ListTile(...),
/// )
/// ```
class PressDetector extends StatefulWidget {
  const PressDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.showFeedback = false,
    this.hapticFeedback = true,
  });

  /// The child widget
  final Widget child;

  /// Called on single tap
  final VoidCallback? onTap;

  /// Called on double tap
  final VoidCallback? onDoubleTap;

  /// Called on long press
  final VoidCallback? onLongPress;

  /// Show visual feedback on press
  final bool showFeedback;

  /// Provide haptic feedback on long press
  final bool hapticFeedback;

  @override
  State<PressDetector> createState() => _PressDetectorState();
}

class _PressDetectorState extends State<PressDetector> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.showFeedback) {
      child = AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.7 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: child,
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: () {
        if (widget.hapticFeedback) {
          HapticFeedback.mediumImpact();
        }
        widget.onLongPress?.call();
      },
      onTapDown: (_) {
        if (widget.showFeedback) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.showFeedback) {
          setState(() => _isPressed = false);
        }
      },
      onTapCancel: () {
        if (widget.showFeedback) {
          setState(() => _isPressed = false);
        }
      },
      child: child,
    );
  }
}

/// Widget that provides drag-to-dismiss functionality
///
/// Commonly used for dismissible list items or cards.
///
/// Example usage:
/// ```dart
/// DragToDismiss(
///   onDismissed: (direction) {
///     if (direction == DismissDirection.endToStart) {
///       deleteItem();
///     }
///   },
///   child: ListTile(...),
/// )
/// ```
class DragToDismiss extends StatelessWidget {
  const DragToDismiss({
    super.key,
    required this.child,
    required this.onDismissed,
    this.background,
    this.secondaryBackground,
    this.confirmDismiss,
    this.direction = DismissDirection.horizontal,
    this.dismissThreshold = 0.4,
  });

  /// The child widget
  final Widget child;

  /// Called when the item is dismissed
  final void Function(DismissDirection) onDismissed;

  /// Widget to show behind the child when swiping right
  final Widget? background;

  /// Widget to show behind the child when swiping left
  final Widget? secondaryBackground;

  /// Optional callback to confirm dismissal
  final Future<bool?> Function(DismissDirection)? confirmDismiss;

  /// Direction(s) in which dismissal is allowed
  final DismissDirection direction;

  /// Threshold for triggering dismissal (0.0 to 1.0)
  final double dismissThreshold;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: direction,
      onDismissed: onDismissed,
      confirmDismiss: confirmDismiss,
      dismissThresholds: {
        DismissDirection.startToEnd: dismissThreshold,
        DismissDirection.endToStart: dismissThreshold,
      },
      background: background ??
          Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.check, color: Colors.white),
          ),
      secondaryBackground: secondaryBackground ??
          Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
      child: child,
    );
  }
}

/// Widget that detects pinch-to-zoom gestures
///
/// Example usage:
/// ```dart
/// PinchZoomDetector(
///   onZoomStart: () => print('Zoom started'),
///   onZoomUpdate: (scale) => print('Scale: $scale'),
///   onZoomEnd: () => print('Zoom ended'),
///   child: Image.asset('photo.jpg'),
/// )
/// ```
class PinchZoomDetector extends StatefulWidget {
  const PinchZoomDetector({
    super.key,
    required this.child,
    this.onZoomStart,
    this.onZoomUpdate,
    this.onZoomEnd,
    this.minScale = 0.5,
    this.maxScale = 4.0,
  });

  /// The child widget
  final Widget child;

  /// Called when zoom gesture starts
  final VoidCallback? onZoomStart;

  /// Called during zoom with current scale factor
  final void Function(double scale)? onZoomUpdate;

  /// Called when zoom gesture ends
  final VoidCallback? onZoomEnd;

  /// Minimum scale factor
  final double minScale;

  /// Maximum scale factor
  final double maxScale;

  @override
  State<PinchZoomDetector> createState() => _PinchZoomDetectorState();
}

class _PinchZoomDetectorState extends State<PinchZoomDetector> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _previousScale = _scale;
        widget.onZoomStart?.call();
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_previousScale * details.scale)
              .clamp(widget.minScale, widget.maxScale);
        });
        widget.onZoomUpdate?.call(_scale);
      },
      onScaleEnd: (details) {
        widget.onZoomEnd?.call();
      },
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

/// Provides context menu functionality with long press
///
/// Shows a popup menu on long press with customizable options.
///
/// Example usage:
/// ```dart
/// ContextMenuDetector(
///   menuItems: [
///     ContextMenuItem(
///       label: 'Copy',
///       icon: Icons.copy,
///       onTap: () => copyText(),
///     ),
///     ContextMenuItem(
///       label: 'Share',
///       icon: Icons.share,
///       onTap: () => shareText(),
///     ),
///   ],
///   child: Text('Long press me'),
/// )
/// ```
class ContextMenuDetector extends StatelessWidget {
  const ContextMenuDetector({
    super.key,
    required this.child,
    required this.menuItems,
    this.hapticFeedback = true,
  });

  /// The child widget
  final Widget child;

  /// Menu items to display
  final List<ContextMenuItem> menuItems;

  /// Provide haptic feedback on menu open
  final bool hapticFeedback;

  void _showContextMenu(BuildContext context, LongPressStartDetails details) {
    if (hapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final menuPosition = details.globalPosition;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        menuPosition.dx,
        menuPosition.dy,
        overlay.size.width - menuPosition.dx,
        overlay.size.height - menuPosition.dy,
      ),
      items: menuItems.map((item) {
        return PopupMenuItem<void>(
          onTap: item.onTap,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 20),
                const SizedBox(width: 12),
              ],
              Text(item.label),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => _showContextMenu(context, details),
      child: child,
    );
  }
}

/// Data class for context menu items
class ContextMenuItem {
  const ContextMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
  });

  /// Menu item label
  final String label;

  /// Icon to display (optional)
  final IconData? icon;

  /// Callback when item is tapped
  final VoidCallback onTap;
}

/// Helper class for haptic feedback patterns
class HapticFeedback {
  /// Light impact feedback (selection change)
  static void lightImpact() {
    // Note: Flutter's HapticFeedback.lightImpact() is platform-specific
    // On iOS: Triggers light haptic feedback
    // On Android: May not be supported on all devices
    SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.lightImpact',
    );
  }

  /// Medium impact feedback (notification, action confirmation)
  static void mediumImpact() {
    SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.mediumImpact',
    );
  }

  /// Heavy impact feedback (significant action)
  static void heavyImpact() {
    SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.heavyImpact',
    );
  }

  /// Selection click feedback (list item selection)
  static void selectionClick() {
    SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.selectionClick',
    );
  }
}

/// Extension for quick gesture detection on any widget
extension GestureExtensions on Widget {
  /// Add tap gesture
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }

  /// Add long press gesture
  Widget onLongPress(VoidCallback onLongPress) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: this,
    );
  }

  /// Add swipe left gesture
  Widget onSwipeLeft(VoidCallback onSwipeLeft) {
    return SwipeDetector(
      onSwipeLeft: onSwipeLeft,
      child: this,
    );
  }

  /// Add swipe right gesture
  Widget onSwipeRight(VoidCallback onSwipeRight) {
    return SwipeDetector(
      onSwipeRight: onSwipeRight,
      child: this,
    );
  }
}
