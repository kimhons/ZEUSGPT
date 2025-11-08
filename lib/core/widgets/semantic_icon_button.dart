import 'package:flutter/material.dart';

/// A wrapper around [IconButton] that includes semantic labels for screen readers.
///
/// This widget ensures all icon buttons are accessible to users with visual
/// impairments by providing descriptive labels that screen readers can announce.
///
/// Example usage:
/// ```dart
/// SemanticIconButton(
///   icon: Icons.favorite,
///   label: 'Add to favorites',
///   onPressed: _toggleFavorite,
/// )
/// ```
///
/// For state-dependent labels:
/// ```dart
/// SemanticIconButton(
///   icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
///   label: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
///   onPressed: _toggleFavorite,
/// )
/// ```
class SemanticIconButton extends StatelessWidget {
  /// The icon to display in the button.
  final IconData icon;

  /// The semantic label that describes the button's action.
  /// This will be read by screen readers.
  final String label;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// The color to use for the icon.
  final Color? color;

  /// The size of the icon.
  final double? iconSize;

  /// The tooltip to show when the button is long-pressed.
  /// If not provided, uses the [label].
  final String? tooltip;

  /// Optional padding around the icon.
  final EdgeInsetsGeometry? padding;

  /// Optional constraints for the button size.
  final BoxConstraints? constraints;

  /// Optional splash radius for the button.
  final double? splashRadius;

  const SemanticIconButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.iconSize,
    this.tooltip,
    this.padding,
    this.constraints,
    this.splashRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: color,
        iconSize: iconSize,
        tooltip: tooltip ?? label,
        padding: padding ?? const EdgeInsets.all(8.0),
        constraints: constraints,
        splashRadius: splashRadius,
      ),
    );
  }
}

/// A wrapper around [IconButton] with a custom icon widget and semantic label.
///
/// Use this when you need more control over the icon appearance
/// (e.g., SVG icons, custom widgets) while still maintaining accessibility.
///
/// Example usage:
/// ```dart
/// SemanticIconButtonWidget(
///   icon: SvgPicture.asset('assets/icons/custom_icon.svg'),
///   label: 'Custom action',
///   onPressed: _handleAction,
/// )
/// ```
class SemanticIconButtonWidget extends StatelessWidget {
  /// The widget to display as the icon.
  final Widget icon;

  /// The semantic label that describes the button's action.
  final String label;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// The tooltip to show when the button is long-pressed.
  final String? tooltip;

  /// Optional padding around the icon.
  final EdgeInsetsGeometry? padding;

  /// Optional constraints for the button size.
  final BoxConstraints? constraints;

  /// Optional splash radius for the button.
  final double? splashRadius;

  const SemanticIconButtonWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tooltip,
    this.padding,
    this.constraints,
    this.splashRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        tooltip: tooltip ?? label,
        padding: padding ?? const EdgeInsets.all(8.0),
        constraints: constraints,
        splashRadius: splashRadius,
      ),
    );
  }
}
