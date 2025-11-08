import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/platform_helper.dart';

/// Manages keyboard shortcuts for desktop and web platforms
///
/// This service provides a centralized way to register and handle
/// keyboard shortcuts across the application. It's only active on
/// desktop (macOS, Windows, Linux) and web platforms.
///
/// Usage:
/// ```dart
/// // Register a shortcut
/// KeyboardShortcutManager.instance.registerShortcut(
///   ShortcutAction.newChat,
///   () => navigateToNewChat(),
/// );
///
/// // Unregister when done
/// KeyboardShortcutManager.instance.unregisterShortcut(ShortcutAction.newChat);
/// ```
class KeyboardShortcutManager {
  KeyboardShortcutManager._();
  static final KeyboardShortcutManager instance = KeyboardShortcutManager._();

  /// Callbacks registered for each shortcut action
  final Map<ShortcutAction, VoidCallback> _callbacks = {};

  bool _isInitialized = false;
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;
  bool get isSupported => PlatformHelper.isDesktop || PlatformHelper.isWeb;

  /// Initialize the keyboard shortcut manager
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!isSupported) {
      debugPrint('KeyboardShortcutManager: Not supported on this platform');
      _isInitialized = true;
      return;
    }

    debugPrint('KeyboardShortcutManager: Initialized');
    _isInitialized = true;
  }

  /// Enable or disable all keyboard shortcuts
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    debugPrint('KeyboardShortcutManager: Shortcuts ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Register a callback for a shortcut action
  void registerShortcut(ShortcutAction action, VoidCallback callback) {
    if (!isSupported) return;

    _callbacks[action] = callback;
    debugPrint('KeyboardShortcutManager: Registered ${action.name}');
  }

  /// Unregister a shortcut callback
  void unregisterShortcut(ShortcutAction action) {
    if (!isSupported) return;

    _callbacks.remove(action);
    debugPrint('KeyboardShortcutManager: Unregistered ${action.name}');
  }

  /// Execute a shortcut action if registered
  bool executeShortcut(ShortcutAction action) {
    if (!_isEnabled || !isSupported) return false;

    final callback = _callbacks[action];
    if (callback != null) {
      debugPrint('KeyboardShortcutManager: Executing ${action.name}');
      callback();
      return true;
    }

    return false;
  }

  /// Get all registered shortcuts with their bindings
  Map<ShortcutAction, SingleActivator> getAllShortcuts() {
    return Map.fromEntries(
      ShortcutAction.values.map((action) => MapEntry(action, action.activator)),
    );
  }

  /// Get shortcuts organized by category
  Map<String, List<ShortcutAction>> getShortcutsByCategory() {
    return {
      'Navigation': [
        ShortcutAction.newChat,
        ShortcutAction.search,
        ShortcutAction.openSettings,
      ],
      'Chat': [
        ShortcutAction.sendMessage,
        ShortcutAction.navigateUp,
        ShortcutAction.navigateDown,
        ShortcutAction.modelSelector,
      ],
      'Editing': [
        ShortcutAction.copy,
        ShortcutAction.paste,
        ShortcutAction.cut,
        ShortcutAction.selectAll,
        ShortcutAction.undo,
        ShortcutAction.redo,
      ],
      'Window': [
        ShortcutAction.closeWindow,
        ShortcutAction.minimizeWindow,
        ShortcutAction.fullScreen,
        ShortcutAction.quit,
      ],
      'View': [
        ShortcutAction.toggleSidebar,
        ShortcutAction.toggleTheme,
        ShortcutAction.zoomIn,
        ShortcutAction.zoomOut,
        ShortcutAction.resetZoom,
      ],
      'Help': [
        ShortcutAction.showShortcuts,
        ShortcutAction.showHelp,
      ],
      'Other': [
        ShortcutAction.closeDialog,
      ],
    };
  }

  /// Dispose resources
  void dispose() {
    _callbacks.clear();
    _isInitialized = false;
    debugPrint('KeyboardShortcutManager: Disposed');
  }
}

/// Enum of all available shortcut actions
enum ShortcutAction {
  // Navigation
  newChat,
  search,
  openSettings,

  // Chat
  sendMessage,
  navigateUp,
  navigateDown,
  modelSelector,

  // Editing
  copy,
  paste,
  cut,
  selectAll,
  undo,
  redo,

  // Window
  closeWindow,
  minimizeWindow,
  fullScreen,
  quit,

  // View
  toggleSidebar,
  toggleTheme,
  zoomIn,
  zoomOut,
  resetZoom,

  // Help
  showShortcuts,
  showHelp,

  // Other
  closeDialog,
}

/// Extension to get keyboard activator and metadata for each action
extension ShortcutActionExtension on ShortcutAction {
  /// Get the keyboard activator for this shortcut
  SingleActivator get activator {
    final isMac = PlatformHelper.isMacOS;
    final ctrl = isMac ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;

    switch (this) {
      // Navigation
      case ShortcutAction.newChat:
        return SingleActivator(LogicalKeyboardKey.keyN, control: !isMac, meta: isMac);
      case ShortcutAction.search:
        return SingleActivator(LogicalKeyboardKey.keyF, control: !isMac, meta: isMac);
      case ShortcutAction.openSettings:
        return SingleActivator(LogicalKeyboardKey.comma, control: !isMac, meta: isMac);

      // Chat
      case ShortcutAction.sendMessage:
        return SingleActivator(LogicalKeyboardKey.enter, control: !isMac, meta: isMac);
      case ShortcutAction.navigateUp:
        return const SingleActivator(LogicalKeyboardKey.arrowUp);
      case ShortcutAction.navigateDown:
        return const SingleActivator(LogicalKeyboardKey.arrowDown);
      case ShortcutAction.modelSelector:
        return SingleActivator(LogicalKeyboardKey.keyK, control: !isMac, meta: isMac);

      // Editing
      case ShortcutAction.copy:
        return SingleActivator(LogicalKeyboardKey.keyC, control: !isMac, meta: isMac);
      case ShortcutAction.paste:
        return SingleActivator(LogicalKeyboardKey.keyV, control: !isMac, meta: isMac);
      case ShortcutAction.cut:
        return SingleActivator(LogicalKeyboardKey.keyX, control: !isMac, meta: isMac);
      case ShortcutAction.selectAll:
        return SingleActivator(LogicalKeyboardKey.keyA, control: !isMac, meta: isMac);
      case ShortcutAction.undo:
        return SingleActivator(LogicalKeyboardKey.keyZ, control: !isMac, meta: isMac);
      case ShortcutAction.redo:
        return SingleActivator(LogicalKeyboardKey.keyZ, control: !isMac, meta: isMac, shift: true);

      // Window
      case ShortcutAction.closeWindow:
        return SingleActivator(LogicalKeyboardKey.keyW, control: !isMac, meta: isMac);
      case ShortcutAction.minimizeWindow:
        return SingleActivator(LogicalKeyboardKey.keyM, control: !isMac, meta: isMac);
      case ShortcutAction.fullScreen:
        return SingleActivator(LogicalKeyboardKey.keyF, control: !isMac, meta: isMac, shift: true);
      case ShortcutAction.quit:
        return SingleActivator(LogicalKeyboardKey.keyQ, control: !isMac, meta: isMac);

      // View
      case ShortcutAction.toggleSidebar:
        return SingleActivator(LogicalKeyboardKey.backslash, control: !isMac, meta: isMac);
      case ShortcutAction.toggleTheme:
        return SingleActivator(LogicalKeyboardKey.keyD, control: !isMac, meta: isMac, shift: true);
      case ShortcutAction.zoomIn:
        return SingleActivator(LogicalKeyboardKey.equal, control: !isMac, meta: isMac);
      case ShortcutAction.zoomOut:
        return SingleActivator(LogicalKeyboardKey.minus, control: !isMac, meta: isMac);
      case ShortcutAction.resetZoom:
        return SingleActivator(LogicalKeyboardKey.digit0, control: !isMac, meta: isMac);

      // Help
      case ShortcutAction.showShortcuts:
        return SingleActivator(LogicalKeyboardKey.slash, control: !isMac, meta: isMac, shift: true);
      case ShortcutAction.showHelp:
        return const SingleActivator(LogicalKeyboardKey.f1);

      // Other
      case ShortcutAction.closeDialog:
        return const SingleActivator(LogicalKeyboardKey.escape);
    }
  }

  /// Get human-readable name for this shortcut
  String get displayName {
    switch (this) {
      case ShortcutAction.newChat: return 'New Chat';
      case ShortcutAction.search: return 'Search';
      case ShortcutAction.openSettings: return 'Open Settings';
      case ShortcutAction.sendMessage: return 'Send Message';
      case ShortcutAction.navigateUp: return 'Navigate Up';
      case ShortcutAction.navigateDown: return 'Navigate Down';
      case ShortcutAction.modelSelector: return 'Model Selector';
      case ShortcutAction.copy: return 'Copy';
      case ShortcutAction.paste: return 'Paste';
      case ShortcutAction.cut: return 'Cut';
      case ShortcutAction.selectAll: return 'Select All';
      case ShortcutAction.undo: return 'Undo';
      case ShortcutAction.redo: return 'Redo';
      case ShortcutAction.closeWindow: return 'Close Window';
      case ShortcutAction.minimizeWindow: return 'Minimize Window';
      case ShortcutAction.fullScreen: return 'Full Screen';
      case ShortcutAction.quit: return 'Quit';
      case ShortcutAction.toggleSidebar: return 'Toggle Sidebar';
      case ShortcutAction.toggleTheme: return 'Toggle Theme';
      case ShortcutAction.zoomIn: return 'Zoom In';
      case ShortcutAction.zoomOut: return 'Zoom Out';
      case ShortcutAction.resetZoom: return 'Reset Zoom';
      case ShortcutAction.showShortcuts: return 'Show Shortcuts';
      case ShortcutAction.showHelp: return 'Show Help';
      case ShortcutAction.closeDialog: return 'Close Dialog';
    }
  }

  /// Get description of what this shortcut does
  String get description {
    switch (this) {
      case ShortcutAction.newChat: return 'Create a new chat conversation';
      case ShortcutAction.search: return 'Search through conversations';
      case ShortcutAction.openSettings: return 'Open application settings';
      case ShortcutAction.sendMessage: return 'Send the current message';
      case ShortcutAction.navigateUp: return 'Navigate to previous message';
      case ShortcutAction.navigateDown: return 'Navigate to next message';
      case ShortcutAction.modelSelector: return 'Open model selection dialog';
      case ShortcutAction.copy: return 'Copy selected text';
      case ShortcutAction.paste: return 'Paste from clipboard';
      case ShortcutAction.cut: return 'Cut selected text';
      case ShortcutAction.selectAll: return 'Select all text';
      case ShortcutAction.undo: return 'Undo last action';
      case ShortcutAction.redo: return 'Redo last action';
      case ShortcutAction.closeWindow: return 'Close current window';
      case ShortcutAction.minimizeWindow: return 'Minimize window';
      case ShortcutAction.fullScreen: return 'Toggle full screen mode';
      case ShortcutAction.quit: return 'Quit the application';
      case ShortcutAction.toggleSidebar: return 'Show/hide sidebar';
      case ShortcutAction.toggleTheme: return 'Switch between light and dark theme';
      case ShortcutAction.zoomIn: return 'Increase interface size';
      case ShortcutAction.zoomOut: return 'Decrease interface size';
      case ShortcutAction.resetZoom: return 'Reset interface size to default';
      case ShortcutAction.showShortcuts: return 'Show this shortcuts help screen';
      case ShortcutAction.showHelp: return 'Open help documentation';
      case ShortcutAction.closeDialog: return 'Close current dialog or modal';
    }
  }

  /// Get the formatted shortcut key combination string for display
  String get keyboardDisplay {
    final isMac = PlatformHelper.isMacOS;
    final activator = this.activator;

    List<String> keys = [];

    if (activator.control && !isMac) keys.add('Ctrl');
    if (activator.meta && isMac) keys.add('⌘');
    if (activator.alt) keys.add(isMac ? '⌥' : 'Alt');
    if (activator.shift) keys.add(isMac ? '⇧' : 'Shift');

    // Add the main key
    final trigger = activator.trigger;
    if (trigger == LogicalKeyboardKey.enter) {
      keys.add(isMac ? '↵' : 'Enter');
    } else if (trigger == LogicalKeyboardKey.escape) {
      keys.add('Esc');
    } else if (trigger == LogicalKeyboardKey.arrowUp) {
      keys.add('↑');
    } else if (trigger == LogicalKeyboardKey.arrowDown) {
      keys.add('↓');
    } else if (trigger == LogicalKeyboardKey.comma) {
      keys.add(',');
    } else if (trigger == LogicalKeyboardKey.slash) {
      keys.add('/');
    } else if (trigger == LogicalKeyboardKey.backslash) {
      keys.add('\\');
    } else if (trigger == LogicalKeyboardKey.equal) {
      keys.add('+');
    } else if (trigger == LogicalKeyboardKey.minus) {
      keys.add('-');
    } else if (trigger == LogicalKeyboardKey.digit0) {
      keys.add('0');
    } else if (trigger == LogicalKeyboardKey.f1) {
      keys.add('F1');
    } else {
      // For letter keys, extract the letter
      final keyLabel = trigger.keyLabel.toUpperCase();
      keys.add(keyLabel);
    }

    return keys.join(isMac ? '' : '+');
  }
}
