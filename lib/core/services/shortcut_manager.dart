import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/platform_helper.dart';

/// Service for managing keyboard shortcuts across desktop and web platforms
///
/// Provides a centralized way to register, handle, and display keyboard shortcuts
/// with platform-specific key combinations (Cmd on macOS, Ctrl on others).
///
/// Example usage:
/// ```dart
/// final shortcutManager = ShortcutManager();
///
/// // Register a shortcut
/// shortcutManager.registerShortcut(
///   AppShortcut.newChat,
///   () => Navigator.pushNamed(context, '/new-chat'),
/// );
///
/// // Use in widget
/// FocusableActionDetector(
///   shortcuts: shortcutManager.getShortcuts(),
///   actions: shortcutManager.getActions(),
///   child: MyWidget(),
/// )
/// ```
class ShortcutManager {
  ShortcutManager._();

  static final ShortcutManager _instance = ShortcutManager._();

  /// Get the singleton instance
  factory ShortcutManager() => _instance;

  /// Registered shortcut handlers
  final Map<AppShortcut, VoidCallback> _handlers = {};

  /// Register a shortcut with its handler
  ///
  /// Example:
  /// ```dart
  /// shortcutManager.registerShortcut(
  ///   AppShortcut.newChat,
  ///   () => print('New chat shortcut pressed'),
  /// );
  /// ```
  void registerShortcut(AppShortcut shortcut, VoidCallback handler) {
    _handlers[shortcut] = handler;
  }

  /// Unregister a shortcut
  void unregisterShortcut(AppShortcut shortcut) {
    _handlers.remove(shortcut);
  }

  /// Clear all registered shortcuts
  void clearAll() {
    _handlers.clear();
  }

  /// Get Flutter shortcuts map for FocusableActionDetector
  Map<ShortcutActivator, Intent> getShortcuts() {
    final shortcuts = <ShortcutActivator, Intent>{};

    for (final shortcut in AppShortcut.values) {
      shortcuts[shortcut.activator] = AppShortcutIntent(shortcut);
    }

    return shortcuts;
  }

  /// Get Flutter actions map for FocusableActionDetector
  Map<Type, Action<Intent>> getActions() {
    return {
      AppShortcutIntent: CallbackAction<AppShortcutIntent>(
        onInvoke: (intent) {
          final handler = _handlers[intent.shortcut];
          handler?.call();
          return null;
        },
      ),
    };
  }

  /// Check if shortcuts are supported on current platform
  bool get isSupported {
    return PlatformHelper.isDesktop || PlatformHelper.isWeb;
  }

  /// Get all registered shortcuts with their handlers
  List<AppShortcut> get registeredShortcuts {
    return _handlers.keys.toList();
  }
}

/// Intent for app shortcuts
class AppShortcutIntent extends Intent {
  const AppShortcutIntent(this.shortcut);

  final AppShortcut shortcut;
}

/// Predefined app shortcuts with platform-specific key combinations
enum AppShortcut {
  // Navigation
  newChat,
  openSearch,
  openSettings,
  goBack,

  // Chat actions
  sendMessage,
  clearChat,
  deleteChat,
  exportChat,

  // General
  save,
  undo,
  redo,
  copy,
  paste,
  selectAll,

  // View
  toggleSidebar,
  toggleTheme,
  zoomIn,
  zoomOut,
  resetZoom,

  // Help
  showHelp,
  showShortcuts,
}

/// Extension to get shortcut metadata
extension AppShortcutExtension on AppShortcut {
  /// Get the keyboard shortcut activator
  ShortcutActivator get activator {
    // Use Cmd on macOS, Ctrl on other platforms
    switch (this) {
      // Navigation
      case AppShortcut.newChat:
        return SingleActivator(LogicalKeyboardKey.keyN, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);
      case AppShortcut.openSearch:
        return SingleActivator(LogicalKeyboardKey.keyK, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);
      case AppShortcut.openSettings:
        return SingleActivator(LogicalKeyboardKey.comma, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);
      case AppShortcut.goBack:
        return SingleActivator(LogicalKeyboardKey.bracketLeft, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);

      // Chat actions
      case AppShortcut.sendMessage:
        return const SingleActivator(LogicalKeyboardKey.enter, meta: true);
      case AppShortcut.clearChat:
        return SingleActivator(LogicalKeyboardKey.keyL, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS, shift: true);
      case AppShortcut.deleteChat:
        return SingleActivator(LogicalKeyboardKey.keyD, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS, shift: true);
      case AppShortcut.exportChat:
        return SingleActivator(LogicalKeyboardKey.keyE, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS, shift: true);

      // General
      case AppShortcut.save:
        return SingleActivator(LogicalKeyboardKey.keyS, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);
      case AppShortcut.undo:
        return SingleActivator(LogicalKeyboardKey.keyZ, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);
      case AppShortcut.redo:
        return SingleActivator(LogicalKeyboardKey.keyZ, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS, shift: true);
      case AppShortcut.copy:
        return SingleActivator(LogicalKeyboardKey.keyC, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);
      case AppShortcut.paste:
        return SingleActivator(LogicalKeyboardKey.keyV, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);
      case AppShortcut.selectAll:
        return SingleActivator(LogicalKeyboardKey.keyA, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);

      // View
      case AppShortcut.toggleSidebar:
        return SingleActivator(LogicalKeyboardKey.keyB, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS, shift: true);
      case AppShortcut.toggleTheme:
        return SingleActivator(LogicalKeyboardKey.keyT, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS, shift: true);
      case AppShortcut.zoomIn:
        return SingleActivator(LogicalKeyboardKey.equal, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);
      case AppShortcut.zoomOut:
        return SingleActivator(LogicalKeyboardKey.minus, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);
      case AppShortcut.resetZoom:
        return SingleActivator(LogicalKeyboardKey.digit0, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS);

      // Help
      case AppShortcut.showHelp:
        return const SingleActivator(LogicalKeyboardKey.f1);
      case AppShortcut.showShortcuts:
        return SingleActivator(LogicalKeyboardKey.slash, meta: PlatformHelper.isMacOS, control: !PlatformHelper.isMacOS, shift: true);
    }
  }

  /// Get human-readable label for the shortcut
  String get label {
    switch (this) {
      // Navigation
      case AppShortcut.newChat:
        return 'New Chat';
      case AppShortcut.openSearch:
        return 'Open Search';
      case AppShortcut.openSettings:
        return 'Open Settings';
      case AppShortcut.goBack:
        return 'Go Back';

      // Chat actions
      case AppShortcut.sendMessage:
        return 'Send Message';
      case AppShortcut.clearChat:
        return 'Clear Chat';
      case AppShortcut.deleteChat:
        return 'Delete Chat';
      case AppShortcut.exportChat:
        return 'Export Chat';

      // General
      case AppShortcut.save:
        return 'Save';
      case AppShortcut.undo:
        return 'Undo';
      case AppShortcut.redo:
        return 'Redo';
      case AppShortcut.copy:
        return 'Copy';
      case AppShortcut.paste:
        return 'Paste';
      case AppShortcut.selectAll:
        return 'Select All';

      // View
      case AppShortcut.toggleSidebar:
        return 'Toggle Sidebar';
      case AppShortcut.toggleTheme:
        return 'Toggle Theme';
      case AppShortcut.zoomIn:
        return 'Zoom In';
      case AppShortcut.zoomOut:
        return 'Zoom Out';
      case AppShortcut.resetZoom:
        return 'Reset Zoom';

      // Help
      case AppShortcut.showHelp:
        return 'Show Help';
      case AppShortcut.showShortcuts:
        return 'Show Keyboard Shortcuts';
    }
  }

  /// Get description of what the shortcut does
  String get description {
    switch (this) {
      // Navigation
      case AppShortcut.newChat:
        return 'Start a new chat conversation';
      case AppShortcut.openSearch:
        return 'Open quick search / command palette';
      case AppShortcut.openSettings:
        return 'Open application settings';
      case AppShortcut.goBack:
        return 'Navigate to previous screen';

      // Chat actions
      case AppShortcut.sendMessage:
        return 'Send the current message';
      case AppShortcut.clearChat:
        return 'Clear current chat history';
      case AppShortcut.deleteChat:
        return 'Delete current chat';
      case AppShortcut.exportChat:
        return 'Export chat to file';

      // General
      case AppShortcut.save:
        return 'Save current work';
      case AppShortcut.undo:
        return 'Undo last action';
      case AppShortcut.redo:
        return 'Redo last undone action';
      case AppShortcut.copy:
        return 'Copy selected text';
      case AppShortcut.paste:
        return 'Paste from clipboard';
      case AppShortcut.selectAll:
        return 'Select all text';

      // View
      case AppShortcut.toggleSidebar:
        return 'Show or hide the sidebar';
      case AppShortcut.toggleTheme:
        return 'Switch between light and dark theme';
      case AppShortcut.zoomIn:
        return 'Increase interface size';
      case AppShortcut.zoomOut:
        return 'Decrease interface size';
      case AppShortcut.resetZoom:
        return 'Reset interface to default size';

      // Help
      case AppShortcut.showHelp:
        return 'Open help documentation';
      case AppShortcut.showShortcuts:
        return 'Show this keyboard shortcuts reference';
    }
  }

  /// Get keyboard shortcut display string (e.g., "Cmd+N" or "Ctrl+N")
  String get displayString {
    final modifier = PlatformHelper.isMacOS ? '⌘' : 'Ctrl';

    switch (this) {
      // Navigation
      case AppShortcut.newChat:
        return '$modifier+N';
      case AppShortcut.openSearch:
        return '$modifier+K';
      case AppShortcut.openSettings:
        return '$modifier+,';
      case AppShortcut.goBack:
        return '$modifier+[';

      // Chat actions
      case AppShortcut.sendMessage:
        return PlatformHelper.isMacOS ? '⌘+Enter' : 'Ctrl+Enter';
      case AppShortcut.clearChat:
        return '$modifier+Shift+L';
      case AppShortcut.deleteChat:
        return '$modifier+Shift+D';
      case AppShortcut.exportChat:
        return '$modifier+Shift+E';

      // General
      case AppShortcut.save:
        return '$modifier+S';
      case AppShortcut.undo:
        return '$modifier+Z';
      case AppShortcut.redo:
        return '$modifier+Shift+Z';
      case AppShortcut.copy:
        return '$modifier+C';
      case AppShortcut.paste:
        return '$modifier+V';
      case AppShortcut.selectAll:
        return '$modifier+A';

      // View
      case AppShortcut.toggleSidebar:
        return '$modifier+Shift+B';
      case AppShortcut.toggleTheme:
        return '$modifier+Shift+T';
      case AppShortcut.zoomIn:
        return '$modifier+=';
      case AppShortcut.zoomOut:
        return '$modifier+-';
      case AppShortcut.resetZoom:
        return '$modifier+0';

      // Help
      case AppShortcut.showHelp:
        return 'F1';
      case AppShortcut.showShortcuts:
        return '$modifier+Shift+?';
    }
  }

  /// Get shortcut category for grouping
  ShortcutCategory get category {
    switch (this) {
      case AppShortcut.newChat:
      case AppShortcut.openSearch:
      case AppShortcut.openSettings:
      case AppShortcut.goBack:
        return ShortcutCategory.navigation;

      case AppShortcut.sendMessage:
      case AppShortcut.clearChat:
      case AppShortcut.deleteChat:
      case AppShortcut.exportChat:
        return ShortcutCategory.chat;

      case AppShortcut.save:
      case AppShortcut.undo:
      case AppShortcut.redo:
      case AppShortcut.copy:
      case AppShortcut.paste:
      case AppShortcut.selectAll:
        return ShortcutCategory.general;

      case AppShortcut.toggleSidebar:
      case AppShortcut.toggleTheme:
      case AppShortcut.zoomIn:
      case AppShortcut.zoomOut:
      case AppShortcut.resetZoom:
        return ShortcutCategory.view;

      case AppShortcut.showHelp:
      case AppShortcut.showShortcuts:
        return ShortcutCategory.help;
    }
  }
}

/// Categories for organizing shortcuts
enum ShortcutCategory {
  navigation,
  chat,
  general,
  view,
  help,
}

/// Extension for shortcut category labels
extension ShortcutCategoryExtension on ShortcutCategory {
  String get label {
    switch (this) {
      case ShortcutCategory.navigation:
        return 'Navigation';
      case ShortcutCategory.chat:
        return 'Chat Actions';
      case ShortcutCategory.general:
        return 'General';
      case ShortcutCategory.view:
        return 'View';
      case ShortcutCategory.help:
        return 'Help';
    }
  }

  IconData get icon {
    switch (this) {
      case ShortcutCategory.navigation:
        return Icons.explore;
      case ShortcutCategory.chat:
        return Icons.chat;
      case ShortcutCategory.general:
        return Icons.apps;
      case ShortcutCategory.view:
        return Icons.visibility;
      case ShortcutCategory.help:
        return Icons.help;
    }
  }
}
