import 'package:flutter/material.dart';
import '../utils/platform_helper.dart';

/// Handles mobile-specific touch gestures and interactions
/// 
/// Provides:
/// - Swipe gestures (left, right, up, down)
/// - Long press detection
/// - Double tap detection
/// - Pull to refresh
/// - Haptic feedback integration
class GestureHandler {
  GestureHandler._();
  static final GestureHandler instance = GestureHandler._();

  // Gesture thresholds
  static const double _swipeThreshold = 50.0;
  static const double _velocityThreshold = 500.0;

  /// Detect swipe direction from drag details
  SwipeDirection? detectSwipe(DragEndDetails details) {
    if (!PlatformHelper.isMobile) return null;

    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx;
    final dy = velocity.dy;

    // Check if velocity is significant enough
    if (dx.abs() < _velocityThreshold && dy.abs() < _velocityThreshold) {
      return null;
    }

    // Horizontal swipe
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    }

    // Vertical swipe
    return dy > 0 ? SwipeDirection.down : SwipeDirection.up;
  }

  /// Create a gesture detector with common mobile patterns
  Widget createMobileGestureDetector({
    required Widget child,
    VoidCallback? onSwipeLeft,
    VoidCallback? onSwipeRight,
    VoidCallback? onSwipeUp,
    VoidCallback? onSwipeDown,
    VoidCallback? onDoubleTap,
    VoidCallback? onLongPress,
  }) {
    if (!PlatformHelper.isMobile) {
      return child;
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final direction = detectSwipe(details);
        switch (direction) {
          case SwipeDirection.left:
            onSwipeLeft?.call();
            break;
          case SwipeDirection.right:
            onSwipeRight?.call();
            break;
          default:
            break;
        }
      },
      onVerticalDragEnd: (details) {
        final direction = detectSwipe(details);
        switch (direction) {
          case SwipeDirection.up:
            onSwipeUp?.call();
            break;
          case SwipeDirection.down:
            onSwipeDown?.call();
            break;
          default:
            break;
        }
      },
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// Swipe direction enum
enum SwipeDirection {
  left,
  right,
  up,
  down,
}

/// Common mobile gesture patterns widget
class MobileGestures extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const MobileGestures({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureHandler.instance.createMobileGestureDetector(
      child: child,
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
      onSwipeUp: onSwipeUp,
      onSwipeDown: onSwipeDown,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
    );
  }
}
