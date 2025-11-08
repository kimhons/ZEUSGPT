import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Utilities for keyboard navigation on desktop and web platforms
///
/// Provides focus management, arrow key navigation, and
/// keyboard accessibility features.

/// Widget that enables keyboard navigation for a list of items
///
/// Handles arrow keys, Enter, Escape, and provides visual focus indicators.
///
/// Example usage:
/// ```dart
/// KeyboardNavigableList(
///   itemCount: 10,
///   itemBuilder: (context, index, isFocused) {
///     return ListTile(
///       title: Text('Item $index'),
///       selected: isFocused,
///     );
///   },
///   onItemSelected: (index) => print('Selected item $index'),
/// )
/// ```
class KeyboardNavigableList extends StatefulWidget {
  const KeyboardNavigableList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onItemSelected,
    this.initialFocusIndex = 0,
    this.scrollController,
    this.autoScroll = true,
  });

  /// Number of items in the list
  final int itemCount;

  /// Builder for each list item
  /// Parameters: context, index, isFocused
  final Widget Function(BuildContext, int, bool) itemBuilder;

  /// Called when an item is selected (Enter key or click)
  final void Function(int index)? onItemSelected;

  /// Initial focus index
  final int initialFocusIndex;

  /// Optional scroll controller
  final ScrollController? scrollController;

  /// Automatically scroll to focused item
  final bool autoScroll;

  @override
  State<KeyboardNavigableList> createState() => _KeyboardNavigableListState();
}

class _KeyboardNavigableListState extends State<KeyboardNavigableList> {
  late int _focusedIndex;
  late ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusedIndex = widget.initialFocusIndex;
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _moveFocus(int delta) {
    setState(() {
      _focusedIndex = (_focusedIndex + delta).clamp(0, widget.itemCount - 1);
    });

    if (widget.autoScroll) {
      // Scroll to focused item
      final itemHeight = 56.0; // Approximate height
      _scrollController.animateTo(
        _focusedIndex * itemHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectItem() {
    widget.onItemSelected?.call(_focusedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _moveFocus(1);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _moveFocus(-1);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            _selectItem();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.home) {
            setState(() => _focusedIndex = 0);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.end) {
            setState(() => _focusedIndex = widget.itemCount - 1);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          final isFocused = index == _focusedIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _focusedIndex = index);
              _selectItem();
            },
            child: widget.itemBuilder(context, index, isFocused),
          );
        },
      ),
    );
  }
}

/// Widget that enables tab navigation through form fields
///
/// Handles Tab, Shift+Tab, and Enter key navigation.
///
/// Example usage:
/// ```dart
/// KeyboardNavigableForm(
///   onSubmit: () => submitForm(),
///   children: [
///     TextField(...),
///     TextField(...),
///     ElevatedButton(onPressed: submitForm, child: Text('Submit')),
///   ],
/// )
/// ```
class KeyboardNavigableForm extends StatelessWidget {
  const KeyboardNavigableForm({
    super.key,
    required this.children,
    this.onSubmit,
    this.padding,
  });

  /// Form fields and buttons
  final List<Widget> children;

  /// Called when Enter is pressed on last field
  final VoidCallback? onSubmit;

  /// Padding around form
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

/// Mixin that adds keyboard navigation support to any widget
///
/// Example usage:
/// ```dart
/// class MyWidget extends StatefulWidget with KeyboardNavigationMixin {
///   @override
///   Widget build(BuildContext context) {
///     return buildWithKeyboardSupport(
///       child: Container(...),
///       onArrowUp: () => print('Up pressed'),
///       onArrowDown: () => print('Down pressed'),
///     );
///   }
/// }
/// ```
mixin KeyboardNavigationMixin {
  /// Wrap a widget with keyboard event handling
  Widget buildWithKeyboardSupport({
    required Widget child,
    VoidCallback? onArrowUp,
    VoidCallback? onArrowDown,
    VoidCallback? onArrowLeft,
    VoidCallback? onArrowRight,
    VoidCallback? onEnter,
    VoidCallback? onEscape,
    VoidCallback? onSpace,
    bool autofocus = false,
  }) {
    return Focus(
      autofocus: autofocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp && onArrowUp != null) {
            onArrowUp();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
              onArrowDown != null) {
            onArrowDown();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
              onArrowLeft != null) {
            onArrowLeft();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
              onArrowRight != null) {
            onArrowRight();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter && onEnter != null) {
            onEnter();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape &&
              onEscape != null) {
            onEscape();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.space && onSpace != null) {
            onSpace();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// Focus manager for keyboard navigation state
///
/// Tracks which widget has keyboard focus and provides
/// helpers for focus management.
class KeyboardFocusManager {
  KeyboardFocusManager._();

  static final KeyboardFocusManager _instance = KeyboardFocusManager._();

  /// Get singleton instance
  factory KeyboardFocusManager() => _instance;

  /// Request focus for a specific focus node
  void requestFocus(FocusNode node) {
    node.requestFocus();
  }

  /// Clear all focus
  void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Move focus to next field
  void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous field
  void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Check if a specific node has focus
  bool hasFocus(FocusNode node) {
    return node.hasFocus;
  }
}

/// Widget that provides visual focus indicator
///
/// Shows a border or highlight when widget has keyboard focus.
///
/// Example usage:
/// ```dart
/// FocusIndicator(
///   focusNode: myFocusNode,
///   borderColor: Colors.blue,
///   child: TextField(...),
/// )
/// ```
class FocusIndicator extends StatefulWidget {
  const FocusIndicator({
    super.key,
    required this.child,
    required this.focusNode,
    this.borderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 4.0,
  });

  /// The child widget
  final Widget child;

  /// Focus node to monitor
  final FocusNode focusNode;

  /// Border color when focused
  final Color? borderColor;

  /// Border width
  final double borderWidth;

  /// Border radius
  final double borderRadius;

  @override
  State<FocusIndicator> createState() => _FocusIndicatorState();
}

class _FocusIndicatorState extends State<FocusIndicator> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ?? Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        border: widget.focusNode.hasFocus
            ? Border.all(color: borderColor, width: widget.borderWidth)
            : null,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: widget.child,
    );
  }
}

/// Helper class for common keyboard shortcuts
class KeyboardShortcuts {
  /// Check if Cmd (macOS) or Ctrl (other) is pressed
  static bool isModifierPressed(RawKeyEvent event) {
    return event.isMetaPressed || event.isControlPressed;
  }

  /// Check if Shift is pressed
  static bool isShiftPressed(RawKeyEvent event) {
    return event.isShiftPressed;
  }

  /// Check if Alt/Option is pressed
  static bool isAltPressed(RawKeyEvent event) {
    return event.isAltPressed;
  }

  /// Get modifier key label for current platform
  static String get modifierLabel {
    return defaultTargetPlatform == TargetPlatform.macOS ? 'Cmd' : 'Ctrl';
  }

  /// Get modifier key symbol for current platform
  static String get modifierSymbol {
    return defaultTargetPlatform == TargetPlatform.macOS ? '⌘' : 'Ctrl';
  }
}

/// Extension for keyboard focus on any widget
extension KeyboardFocusExtensions on Widget {
  /// Make widget focusable
  Widget focusable({
    FocusNode? focusNode,
    bool autofocus = false,
    VoidCallback? onFocusChange,
  }) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange != null ? (_) => onFocusChange() : null,
      child: this,
    );
  }

  /// Add focus indicator
  Widget withFocusIndicator({
    required FocusNode focusNode,
    Color? borderColor,
    double borderWidth = 2.0,
    double borderRadius = 4.0,
  }) {
    return FocusIndicator(
      focusNode: focusNode,
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      child: this,
    );
  }
}
