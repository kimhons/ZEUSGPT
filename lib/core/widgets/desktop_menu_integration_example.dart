/// Example of how to integrate desktop native menus into your app
///
/// This file demonstrates best practices for menu integration
/// with the ZeusGPT application structure.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'desktop_menu_wrapper.dart';
import '../utils/platform_helper.dart';
import '../services/window_state_manager.dart' if (dart.library.html) '../services/window_state_manager_web.dart';

/// Example: Wrapping MaterialApp.router with desktop menus
///
/// Usage in main.dart:
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   final router = ref.watch(appRouterProvider);
///
///   return DesktopMenuWrapper(
///     // Navigation actions
///     onNewChat: () => context.go('/chat/new'),
///     onOpenSettings: () => context.go('/settings'),
///
///     // Chat actions
///     onExportChat: () => _handleExportChat(context),
///     onClearChat: () => _handleClearChat(context),
///     onDeleteChat: () => _handleDeleteChat(context),
///
///     // Theme actions
///     onToggleTheme: () => ref.read(themeModeProvider.notifier).toggle(),
///     onToggleSidebar: () => ref.read(sidebarProvider.notifier).toggle(),
///
///     // Window actions (desktop only)
///     onMinimizeWindow: () => WindowStateManager.instance.minimize(),
///     onMaximizeWindow: () => WindowStateManager.instance.maximize(),
///     onRestoreWindow: () => WindowStateManager.instance.restore(),
///
///     // Help actions
///     onShowShortcuts: () => _showShortcutsDialog(context),
///     onShowAbout: () => _showAboutDialog(context),
///     onShowDocumentation: () => _launchDocumentation(),
///
///     // Wrap the MaterialApp
///     child: MaterialApp.router(
///       title: 'ZeusGPT',
///       theme: AppTheme.lightTheme(),
///       darkTheme: AppTheme.darkTheme(),
///       routerConfig: router,
///     ),
///   );
/// }
/// ```

/// Example action handlers
class MenuActionHandlers {
  /// Handle export chat action
  static void handleExportChat(BuildContext context) {
    // TODO: Implement chat export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export chat functionality coming soon')),
    );
  }

  /// Handle clear chat action
  static void handleClearChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear chat logic
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Handle delete chat action
  static void handleDeleteChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete chat logic
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show keyboard shortcuts dialog
  static void showShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShortcutRow('New Chat', PlatformHelper.isMacOS ? '⌘N' : 'Ctrl+N'),
              _buildShortcutRow('Open Search', PlatformHelper.isMacOS ? '⌘K' : 'Ctrl+K'),
              _buildShortcutRow('Settings', PlatformHelper.isMacOS ? '⌘,' : 'Ctrl+,'),
              const Divider(),
              _buildShortcutRow('Toggle Sidebar', PlatformHelper.isMacOS ? '⌘B' : 'Ctrl+B'),
              _buildShortcutRow('Toggle Theme', PlatformHelper.isMacOS ? '⌘D' : 'Ctrl+D'),
              const Divider(),
              _buildShortcutRow('Zoom In', PlatformHelper.isMacOS ? '⌘+' : 'Ctrl++'),
              _buildShortcutRow('Zoom Out', PlatformHelper.isMacOS ? '⌘-' : 'Ctrl+-'),
              _buildShortcutRow('Reset Zoom', PlatformHelper.isMacOS ? '⌘0' : 'Ctrl+0'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildShortcutRow(String action, String shortcut) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  /// Show about dialog
  static void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'ZeusGPT',
        applicationVersion: '0.1.0',
        applicationIcon: const FlutterLogo(size: 48),
        children: const [
          Text('The most powerful multi-LLM AI assistant.'),
          SizedBox(height: 8),
          Text('Access 500+ models in one beautiful app.'),
        ],
      ),
    );
  }

  /// Launch documentation
  static void launchDocumentation() {
    // TODO: Implement documentation launch
    debugPrint('Opening documentation...');
  }

  /// Handle window minimize
  static Future<void> handleMinimizeWindow() async {
    if (PlatformHelper.isDesktop) {
      try {
        await WindowStateManager.instance.minimize();
      } catch (e) {
        debugPrint('Failed to minimize window: $e');
      }
    }
  }

  /// Handle window maximize
  static Future<void> handleMaximizeWindow() async {
    if (PlatformHelper.isDesktop) {
      try {
        await WindowStateManager.instance.maximize();
      } catch (e) {
        debugPrint('Failed to maximize window: $e');
      }
    }
  }

  /// Handle window restore
  static Future<void> handleRestoreWindow() async {
    if (PlatformHelper.isDesktop) {
      try {
        await WindowStateManager.instance.restore();
      } catch (e) {
        debugPrint('Failed to restore window: $e');
      }
    }
  }
}

/// Example of a minimal menu integration
///
/// For apps that don't need all menu options:
/// ```dart
/// return DesktopMenuWrapper(
///   onNewChat: () => context.go('/chat/new'),
///   onOpenSettings: () => context.go('/settings'),
///   onToggleTheme: () => ref.read(themeModeProvider.notifier).toggle(),
///   onShowAbout: () => MenuActionHandlers.showAboutDialog(context),
///   child: MaterialApp.router(
///     routerConfig: router,
///   ),
/// );
/// ```
///
/// The wrapper will only show menu items for which callbacks are provided.
