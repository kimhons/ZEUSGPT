import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/platform_helper.dart';

/// Service for managing window state on desktop platforms
///
/// Handles saving and restoring window size, position, and state
/// across app launches. Only active on desktop platforms (macOS, Windows, Linux).
///
/// Example usage:
/// ```dart
/// final windowManager = WindowStateManager();
/// await windowManager.initialize();
///
/// // Save current window state
/// await windowManager.saveWindowState(
///   size: Size(1200, 800),
///   position: Offset(100, 100),
/// );
///
/// // Restore window state on launch
/// final state = await windowManager.getLastWindowState();
/// ```
class WindowStateManager {
  WindowStateManager._();

  static final WindowStateManager _instance = WindowStateManager._();

  /// Get the singleton instance
  factory WindowStateManager() => _instance;

  SharedPreferences? _prefs;
  WindowState? _currentState;
  final _stateController = StreamController<WindowState>.broadcast();

  // Storage keys
  static const String _keyWindowWidth = 'window_width';
  static const String _keyWindowHeight = 'window_height';
  static const String _keyWindowX = 'window_x';
  static const String _keyWindowY = 'window_y';
  static const String _keyWindowMaximized = 'window_maximized';
  static const String _keyWindowFullscreen = 'window_fullscreen';

  // Default window dimensions
  static const Size _defaultSize = Size(1200, 800);
  static const Offset _defaultPosition = Offset(100, 100);

  /// Initialize the window state manager
  Future<void> initialize() async {
    if (!isSupported) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    _currentState = await getLastWindowState();
  }

  /// Check if window management is supported on current platform
  bool get isSupported {
    return PlatformHelper.isDesktop;
  }

  /// Stream of window state changes
  Stream<WindowState> get stateChanges => _stateController.stream;

  /// Get current window state
  WindowState? get currentState => _currentState;

  /// Save window state to persistent storage
  Future<void> saveWindowState({
    required Size size,
    required Offset position,
    bool isMaximized = false,
    bool isFullscreen = false,
  }) async {
    if (!isSupported || _prefs == null) {
      return;
    }

    await _prefs!.setDouble(_keyWindowWidth, size.width);
    await _prefs!.setDouble(_keyWindowHeight, size.height);
    await _prefs!.setDouble(_keyWindowX, position.dx);
    await _prefs!.setDouble(_keyWindowY, position.dy);
    await _prefs!.setBool(_keyWindowMaximized, isMaximized);
    await _prefs!.setBool(_keyWindowFullscreen, isFullscreen);

    _currentState = WindowState(
      size: size,
      position: position,
      isMaximized: isMaximized,
      isFullscreen: isFullscreen,
    );

    _stateController.add(_currentState!);
  }

  /// Get last saved window state
  Future<WindowState> getLastWindowState() async {
    if (!isSupported || _prefs == null) {
      return WindowState(
        size: _defaultSize,
        position: _defaultPosition,
        isMaximized: false,
        isFullscreen: false,
      );
    }

    final width = _prefs!.getDouble(_keyWindowWidth) ?? _defaultSize.width;
    final height = _prefs!.getDouble(_keyWindowHeight) ?? _defaultSize.height;
    final x = _prefs!.getDouble(_keyWindowX) ?? _defaultPosition.dx;
    final y = _prefs!.getDouble(_keyWindowY) ?? _defaultPosition.dy;
    final isMaximized = _prefs!.getBool(_keyWindowMaximized) ?? false;
    final isFullscreen = _prefs!.getBool(_keyWindowFullscreen) ?? false;

    return WindowState(
      size: Size(width, height),
      position: Offset(x, y),
      isMaximized: isMaximized,
      isFullscreen: isFullscreen,
    );
  }

  /// Reset window state to defaults
  Future<void> resetToDefaults() async {
    await saveWindowState(
      size: _defaultSize,
      position: _defaultPosition,
      isMaximized: false,
      isFullscreen: false,
    );
  }

  /// Clear all saved window state
  Future<void> clearState() async {
    if (!isSupported || _prefs == null) {
      return;
    }

    await _prefs!.remove(_keyWindowWidth);
    await _prefs!.remove(_keyWindowHeight);
    await _prefs!.remove(_keyWindowX);
    await _prefs!.remove(_keyWindowY);
    await _prefs!.remove(_keyWindowMaximized);
    await _prefs!.remove(_keyWindowFullscreen);

    _currentState = null;
  }

  /// Validate and constrain window state to screen bounds
  WindowState constrainToScreen(
    WindowState state,
    Size screenSize,
  ) {
    // Constrain size to screen
    final constrainedWidth = state.size.width.clamp(400.0, screenSize.width);
    final constrainedHeight = state.size.height.clamp(300.0, screenSize.height);

    // Constrain position to screen
    final constrainedX = state.position.dx.clamp(
      0.0,
      (screenSize.width - constrainedWidth).clamp(0.0, screenSize.width),
    );
    final constrainedY = state.position.dy.clamp(
      0.0,
      (screenSize.height - constrainedHeight).clamp(0.0, screenSize.height),
    );

    return WindowState(
      size: Size(constrainedWidth, constrainedHeight),
      position: Offset(constrainedX, constrainedY),
      isMaximized: state.isMaximized,
      isFullscreen: state.isFullscreen,
    );
  }

  /// Dispose resources
  void dispose() {
    _stateController.close();
  }
}

/// Window state data class
@immutable
class WindowState {
  const WindowState({
    required this.size,
    required this.position,
    required this.isMaximized,
    required this.isFullscreen,
  });

  /// Window size
  final Size size;

  /// Window position (top-left corner)
  final Offset position;

  /// Whether window is maximized
  final bool isMaximized;

  /// Whether window is fullscreen
  final bool isFullscreen;

  /// Copy with modifications
  WindowState copyWith({
    Size? size,
    Offset? position,
    bool? isMaximized,
    bool? isFullscreen,
  }) {
    return WindowState(
      size: size ?? this.size,
      position: position ?? this.position,
      isMaximized: isMaximized ?? this.isMaximized,
      isFullscreen: isFullscreen ?? this.isFullscreen,
    );
  }

  @override
  String toString() {
    return 'WindowState('
        'size: $size, '
        'position: $position, '
        'isMaximized: $isMaximized, '
        'isFullscreen: $isFullscreen'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WindowState &&
        other.size == size &&
        other.position == position &&
        other.isMaximized == isMaximized &&
        other.isFullscreen == isFullscreen;
  }

  @override
  int get hashCode {
    return size.hashCode ^
        position.hashCode ^
        isMaximized.hashCode ^
        isFullscreen.hashCode;
  }
}

/// Multi-window coordinator for managing multiple app windows
///
/// Tracks all open windows and coordinates actions across them.
/// Useful for features like "close all windows" or "minimize all windows".
///
/// Example usage:
/// ```dart
/// final coordinator = MultiWindowCoordinator();
///
/// // Register a new window
/// coordinator.registerWindow('main', mainWindowId);
///
/// // Broadcast message to all windows
/// coordinator.broadcastMessage('theme_changed', {'theme': 'dark'});
///
/// // Get list of all windows
/// final windows = coordinator.getAllWindows();
/// ```
class MultiWindowCoordinator {
  MultiWindowCoordinator._();

  static final MultiWindowCoordinator _instance = MultiWindowCoordinator._();

  /// Get the singleton instance
  factory MultiWindowCoordinator() => _instance;

  final Map<String, String> _windows = {};
  final _messageController = StreamController<WindowMessage>.broadcast();

  /// Stream of messages broadcast to all windows
  Stream<WindowMessage> get messages => _messageController.stream;

  /// Register a window with a unique ID
  void registerWindow(String name, String windowId) {
    _windows[name] = windowId;
  }

  /// Unregister a window
  void unregisterWindow(String name) {
    _windows.remove(name);
  }

  /// Get all registered windows
  Map<String, String> getAllWindows() {
    return Map.unmodifiable(_windows);
  }

  /// Get window ID by name
  String? getWindowId(String name) {
    return _windows[name];
  }

  /// Check if a window is registered
  bool hasWindow(String name) {
    return _windows.containsKey(name);
  }

  /// Broadcast a message to all windows
  void broadcastMessage(String type, Map<String, dynamic> data) {
    final message = WindowMessage(
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );
    _messageController.add(message);
  }

  /// Get count of registered windows
  int get windowCount => _windows.length;

  /// Dispose resources
  void dispose() {
    _messageController.close();
    _windows.clear();
  }
}

/// Message data for multi-window communication
class WindowMessage {
  const WindowMessage({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  /// Message type (e.g., 'theme_changed', 'settings_updated')
  final String type;

  /// Message data
  final Map<String, dynamic> data;

  /// Timestamp when message was sent
  final DateTime timestamp;

  @override
  String toString() {
    return 'WindowMessage(type: $type, data: $data, timestamp: $timestamp)';
  }
}

/// Widget that automatically saves window state
///
/// Wraps your app to automatically save window state when
/// window size or position changes.
///
/// Example usage:
/// ```dart
/// WindowStateWidget(
///   child: MaterialApp(
///     home: HomeScreen(),
///   ),
/// )
/// ```
class WindowStateWidget extends StatefulWidget {
  const WindowStateWidget({
    super.key,
    required this.child,
    this.autoSave = true,
    this.saveInterval = const Duration(seconds: 1),
  });

  /// The child widget (typically MaterialApp)
  final Widget child;

  /// Whether to automatically save window state
  final bool autoSave;

  /// Interval for auto-saving window state
  final Duration saveInterval;

  @override
  State<WindowStateWidget> createState() => _WindowStateWidgetState();
}

class _WindowStateWidgetState extends State<WindowStateWidget>
    with WidgetsBindingObserver {
  final _windowManager = WindowStateManager();
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWindowState();

    if (widget.autoSave && _windowManager.isSupported) {
      _startAutoSave();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeWindowState() async {
    await _windowManager.initialize();

    // Restore last window state would happen here
    // This requires integration with window_manager package
    // which provides actual window manipulation APIs
  }

  void _startAutoSave() {
    _saveTimer = Timer.periodic(widget.saveInterval, (_) {
      _saveCurrentWindowState();
    });
  }

  Future<void> _saveCurrentWindowState() async {
    // In a real implementation, this would get actual window size/position
    // from the window_manager package or platform channels

    // For now, we'll use MediaQuery as a placeholder
    final size = MediaQuery.of(context).size;

    await _windowManager.saveWindowState(
      size: size,
      position: const Offset(0, 0), // Would get actual position from window API
      isMaximized: false, // Would get from window API
      isFullscreen: false, // Would get from window API
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (widget.autoSave && _windowManager.isSupported) {
      _saveCurrentWindowState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
