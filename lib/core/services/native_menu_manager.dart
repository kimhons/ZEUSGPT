import 'package:flutter/foundation.dart';

/// Simple manager for desktop menus - callbacks only
/// Platform-specific menu rendering is handled by DesktopMenuWrapper widget
/// 
/// This service manages callback registration and execution.
/// The actual menu structure is defined in DesktopMenuWrapper.
class NativeMenuManager {
  NativeMenuManager._();
  static final NativeMenuManager instance = NativeMenuManager._();

  /// Callback functions for menu actions
  final Map<String, VoidCallback> _menuCallbacks = {};

  /// Initialize native menus
  Future<void> initialize() async {
    debugPrint('NativeMenuManager: Initialized');
  }

  /// Register a callback for a menu action
  void registerCallback(String actionKey, VoidCallback callback) {
    _menuCallbacks[actionKey] = callback;
  }

  /// Unregister a callback
  void unregisterCallback(String actionKey) {
    _menuCallbacks.remove(actionKey);
  }

  /// Execute a menu action
  void executeAction(String actionKey) {
    final callback = _menuCallbacks[actionKey];
    if (callback != null) {
      callback();
    }
  }

  /// Dispose resources
  void dispose() {
    _menuCallbacks.clear();
  }
}
