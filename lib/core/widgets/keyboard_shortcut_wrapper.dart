import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/keyboard_shortcut_manager.dart';
import '../utils/platform_helper.dart';

/// Wraps the app with keyboard shortcut handling
///
/// This widget should wrap the entire app (usually at the MaterialApp level)
/// to enable global keyboard shortcuts on desktop and web platforms.
///
/// Usage:
/// ```dart
/// KeyboardShortcutWrapper(
///   child: MaterialApp(...),
/// );
/// ```
class KeyboardShortcutWrapper extends StatefulWidget {
  final Widget child;

  const KeyboardShortcutWrapper({
    super.key,
    required this.child,
  });

  @override
  State<KeyboardShortcutWrapper> createState() => _KeyboardShortcutWrapperState();
}

class _KeyboardShortcutWrapperState extends State<KeyboardShortcutWrapper> {
  @override
  Widget build(BuildContext context) {
    // Only enable shortcuts on desktop and web
    if (!PlatformHelper.isDesktop && !PlatformHelper.isWeb) {
      return widget.child;
    }

    return CallbackShortcuts(
      bindings: _buildShortcutBindings(),
      child: Focus(
        autofocus: true,
        child: widget.child,
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> _buildShortcutBindings() {
    final manager = KeyboardShortcutManager.instance;
    final Map<ShortcutActivator, VoidCallback> bindings = {};

    // Build bindings for all shortcut actions
    for (final action in ShortcutAction.values) {
      bindings[action.activator] = () {
        manager.executeShortcut(action);
      };
    }

    return bindings;
  }
}

/// Widget that registers shortcuts for a specific context
///
/// Use this to register shortcuts that should only be active
/// within a specific screen or widget subtree.
///
/// Usage:
/// ```dart
/// ScopedShortcuts(
///   shortcuts: {
///     ShortcutAction.newChat: () => createNewChat(),
///     ShortcutAction.search: () => openSearch(),
///   },
///   child: MyScreen(),
/// );
/// ```
class ScopedShortcuts extends StatefulWidget {
  final Widget child;
  final Map<ShortcutAction, VoidCallback> shortcuts;

  const ScopedShortcuts({
    super.key,
    required this.child,
    required this.shortcuts,
  });

  @override
  State<ScopedShortcuts> createState() => _ScopedShortcutsState();
}

class _ScopedShortcutsState extends State<ScopedShortcuts> {
  @override
  void initState() {
    super.initState();
    _registerShortcuts();
  }

  @override
  void dispose() {
    _unregisterShortcuts();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScopedShortcuts oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If shortcuts changed, re-register
    if (widget.shortcuts != oldWidget.shortcuts) {
      _unregisterShortcuts();
      _registerShortcuts();
    }
  }

  void _registerShortcuts() {
    final manager = KeyboardShortcutManager.instance;
    widget.shortcuts.forEach((action, callback) {
      manager.registerShortcut(action, callback);
    });
  }

  void _unregisterShortcuts() {
    final manager = KeyboardShortcutManager.instance;
    widget.shortcuts.forEach((action, _) {
      manager.unregisterShortcut(action);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Shows a tooltip with the keyboard shortcut for an action
///
/// Use this to display keyboard shortcuts on buttons and menu items.
///
/// Usage:
/// ```dart
/// ShortcutTooltip(
///   action: ShortcutAction.newChat,
///   child: IconButton(
///     icon: Icon(Icons.add),
///     onPressed: () => createNewChat(),
///   ),
/// );
/// ```
class ShortcutTooltip extends StatelessWidget {
  final ShortcutAction action;
  final Widget child;
  final String? customMessage;

  const ShortcutTooltip({
    super.key,
    required this.action,
    required this.child,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Only show shortcuts on desktop/web
    if (!PlatformHelper.isDesktop && !PlatformHelper.isWeb) {
      return child;
    }

    final message = customMessage ?? action.displayName;
    final shortcut = action.keyboardDisplay;

    return Tooltip(
      message: '$message ($shortcut)',
      child: child,
    );
  }
}
