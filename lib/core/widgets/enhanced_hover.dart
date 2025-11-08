import 'package:flutter/material.dart';
import '../utils/platform_helper.dart';

/// A widget that provides enhanced hover effects for desktop platforms
///
/// This widget adds visual feedback when the mouse hovers over it,
/// including scale animations, elevation changes, and custom effects.
///
/// Usage:
/// ```dart
/// EnhancedHover(
///   child: Text('Hover me'),
///   onTap: () => handleTap(),
/// )
/// ```
class EnhancedHover extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final double scale;
  final double elevation;
  final Color? hoverColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool enableHaptics;
  final MouseCursor cursor;
  final Duration animationDuration;

  const EnhancedHover({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.scale = 1.02,
    this.elevation = 0,
    this.hoverColor,
    this.borderRadius,
    this.padding,
    this.enableHaptics = false,
    this.cursor = SystemMouseCursors.click,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<EnhancedHover> createState() => _EnhancedHoverState();
}

class _EnhancedHoverState extends State<EnhancedHover>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only enable hover effects on desktop
    if (!PlatformHelper.isDesktop) {
      return GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onDoubleTap: widget.onDoubleTap,
        child: widget.child,
      );
    }

    Widget content = widget.child;

    // Wrap with padding if specified
    if (widget.padding != null) {
      content = Padding(
        padding: widget.padding!,
        child: content,
      );
    }

    // Apply scale animation
    content = ScaleTransition(
      scale: _scaleAnimation,
      child: content,
    );

    // Apply elevation if specified
    if (widget.elevation > 0) {
      content = Material(
        elevation: _isHovered ? widget.elevation : 0,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        child: content,
      );
    }

    // Apply hover color if specified
    if (widget.hoverColor != null) {
      content = AnimatedContainer(
        duration: widget.animationDuration,
        decoration: BoxDecoration(
          color: _isHovered ? widget.hoverColor : Colors.transparent,
          borderRadius: widget.borderRadius,
        ),
        child: content,
      );
    }

    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => _handleHoverChange(true),
      onExit: (_) => _handleHoverChange(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onDoubleTap: widget.onDoubleTap,
        child: content,
      ),
    );
  }
}

/// Pre-built hover effect presets for common use cases
class HoverPresets {
  /// Subtle scale effect
  static const subtle = EnhancedHover(
    scale: 1.01,
    child: SizedBox(),
  );

  /// Medium scale effect
  static const medium = EnhancedHover(
    scale: 1.03,
    child: SizedBox(),
  );

  /// Strong scale effect with elevation
  static EnhancedHover strong({required Widget child}) => EnhancedHover(
        scale: 1.05,
        elevation: 4,
        child: child,
      );

  /// Card hover effect
  static EnhancedHover card({required Widget child}) => EnhancedHover(
        scale: 1.02,
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: child,
      );

  /// Button hover effect
  static EnhancedHover button({
    required Widget child,
    VoidCallback? onTap,
    Color? hoverColor,
  }) =>
      EnhancedHover(
        scale: 1.05,
        hoverColor: hoverColor,
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: child,
      );

  /// List item hover effect
  static EnhancedHover listItem({
    required Widget child,
    VoidCallback? onTap,
    Color? hoverColor,
  }) =>
      EnhancedHover(
        scale: 1.0,
        hoverColor: hoverColor,
        onTap: onTap,
        child: child,
      );
}
