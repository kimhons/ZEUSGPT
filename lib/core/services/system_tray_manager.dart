import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import '../utils/platform_helper.dart';

/// Manages the system tray icon and menu for desktop platforms
/// 
/// This service handles:
/// - System tray icon initialization
/// - Tray menu creation and updates
/// - Tray menu action handling
/// - Platform-specific tray behavior
class SystemTrayManager with TrayListener {
  SystemTrayManager._();
  static final SystemTrayManager instance = SystemTrayManager._();

  /// Callback functions for tray actions
  final Map<String, VoidCallback> _trayCallbacks = {};

  bool _initialized = false;

  /// Initialize the system tray
  Future<void> initialize() async {
    if (!PlatformHelper.isDesktop) {
      debugPrint('SystemTrayManager: Not a desktop platform, skipping');
      return;
    }

    if (_initialized) {
      debugPrint('SystemTrayManager: Already initialized');
      return;
    }

    try {
      trayManager.addListener(this);

      // Set tray icon
      await trayManager.setIcon(
        PlatformHelper.isMacOS
            ? 'assets/icons/tray_icon_macos.png'
            : 'assets/icons/tray_icon.png',
      );

      // Set tooltip
      await trayManager.setToolTip('ZeusGPT');

      // Build and set tray menu
      await _updateTrayMenu();

      _initialized = true;
      debugPrint('SystemTrayManager: Initialized successfully');
    } catch (e) {
      debugPrint('SystemTrayManager: Failed to initialize - $e');
    }
  }

  /// Register a callback for a tray action
  void registerCallback(String actionKey, VoidCallback callback) {
    _trayCallbacks[actionKey] = callback;
  }

  /// Unregister a callback
  void unregisterCallback(String actionKey) {
    _trayCallbacks.remove(actionKey);
  }

  /// Update the tray menu
  Future<void> _updateTrayMenu() async {
    try {
      final menu = Menu(
        items: [
          MenuItem(
            key: 'show_window',
            label: 'Show ZeusGPT',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'new_chat',
            label: 'New Chat',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'settings',
            label: 'Settings',
          ),
          MenuItem(
            key: 'about',
            label: 'About',
          ),
          MenuItem.separator(),
          MenuItem(
            key: 'quit',
            label: 'Quit ZeusGPT',
          ),
        ],
      );

      await trayManager.setContextMenu(menu);
    } catch (e) {
      debugPrint('SystemTrayManager: Failed to update menu - $e');
    }
  }

  // TrayListener overrides

  @override
  void onTrayIconMouseDown() {
    debugPrint('SystemTrayManager: Tray icon clicked');
  }

  @override
  void onTrayIconRightMouseDown() {
    debugPrint('SystemTrayManager: Tray icon right-clicked');
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    debugPrint('SystemTrayManager: Menu item clicked - ${menuItem.key}');
    
    final callback = _trayCallbacks[menuItem.key];
    if (callback != null) {
      callback();
    } else {
      debugPrint('SystemTrayManager: No callback registered for ${menuItem.key}');
    }
  }

  /// Dispose resources
  void dispose() {
    trayManager.removeListener(this);
    _trayCallbacks.clear();
    _initialized = false;
  }
}
