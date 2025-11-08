import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/platform_helper.dart';

/// Service for providing haptic feedback across platforms
/// 
/// Supports:
/// - iOS: Rich haptic engine with multiple feedback types
/// - Android: Vibration-based haptic feedback
/// - Desktop/Web: Gracefully disabled (no errors)
/// 
/// Usage:
/// ```dart
/// HapticFeedbackService.instance.light();  // Light impact
/// HapticFeedbackService.instance.medium(); // Medium impact
/// HapticFeedbackService.instance.heavy();  // Heavy impact
/// HapticFeedbackService.instance.selection(); // Selection change
/// HapticFeedbackService.instance.success(); // Success action
/// HapticFeedbackService.instance.warning(); // Warning/error
/// ```
class HapticFeedbackService {
  HapticFeedbackService._();
  static final HapticFeedbackService instance = HapticFeedbackService._();

  bool _isEnabled = true;
  bool _isInitialized = false;

  /// Check if haptic feedback is enabled
  bool get isEnabled => _isEnabled;

  /// Check if haptics are supported on this platform
  bool get isSupported => PlatformHelper.isMobile;

  /// Initialize the haptic feedback service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Haptic feedback only supported on mobile
    if (!PlatformHelper.isMobile) {
      debugPrint('HapticFeedbackService: Not supported on this platform');
      _isInitialized = true;
      return;
    }

    debugPrint('HapticFeedbackService: Initialized');
    _isInitialized = true;
  }

  /// Enable or disable haptic feedback
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    debugPrint('HapticFeedbackService: Haptic feedback ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Light impact feedback - Use for UI interactions
  /// Examples: Button taps, toggles, selections
  Future<void> light() async {
    if (!_shouldProvideHaptic()) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('HapticFeedbackService: Error providing light feedback: $e');
    }
  }

  /// Medium impact feedback - Use for important actions
  /// Examples: Refreshing content, completing forms, sending messages
  Future<void> medium() async {
    if (!_shouldProvideHaptic()) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('HapticFeedbackService: Error providing medium feedback: $e');
    }
  }

  /// Heavy impact feedback - Use for significant actions
  /// Examples: Deleting items, confirming destructive actions
  Future<void> heavy() async {
    if (!_shouldProvideHaptic()) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('HapticFeedbackService: Error providing heavy feedback: $e');
    }
  }

  /// Selection feedback - Use for picker/selector changes
  /// Examples: Scrolling through options, changing tabs
  Future<void> selection() async {
    if (!_shouldProvideHaptic()) return;
    
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('HapticFeedbackService: Error providing selection feedback: $e');
    }
  }

  /// Vibrate feedback - Standard vibration pattern
  /// Examples: Notifications, alerts, timers
  Future<void> vibrate() async {
    if (!_shouldProvideHaptic()) return;
    
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('HapticFeedbackService: Error providing vibrate feedback: $e');
    }
  }

  /// Success feedback - Positive confirmation
  /// Examples: Message sent, file uploaded, action completed
  /// 
  /// On iOS: Uses notification feedback (success)
  /// On Android: Uses medium impact
  Future<void> success() async {
    if (!_shouldProvideHaptic()) return;
    
    try {
      // Flutter doesn't have built-in success haptic
      // Use medium impact as a positive feedback
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('HapticFeedbackService: Error providing success feedback: $e');
    }
  }

  /// Warning feedback - Negative confirmation or error
  /// Examples: Failed action, validation error, destructive action
  /// 
  /// On iOS: Uses notification feedback (warning)
  /// On Android: Uses heavy impact
  Future<void> warning() async {
    if (!_shouldProvideHaptic()) return;
    
    try {
      // Use heavy impact for warning/error feedback
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('HapticFeedbackService: Error providing warning feedback: $e');
    }
  }

  /// Error feedback - Critical error or failure
  /// Examples: Network error, critical failure, data loss prevention
  /// 
  /// Provides double heavy impact for emphasis
  Future<void> error() async {
    if (!_shouldProvideHaptic()) return;
    
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('HapticFeedbackService: Error providing error feedback: $e');
    }
  }

  /// Custom pattern - Sequence of haptic feedbacks
  /// 
  /// Example:
  /// ```dart
  /// await hapticService.pattern([
  ///   HapticType.light,
  ///   HapticType.medium,
  ///   HapticType.heavy,
  /// ], duration: Duration(milliseconds: 100));
  /// ```
  Future<void> pattern(
    List<HapticType> types, {
    Duration duration = const Duration(milliseconds: 100),
  }) async {
    if (!_shouldProvideHaptic()) return;

    for (int i = 0; i < types.length; i++) {
      try {
        await _performHapticByType(types[i]);
        if (i < types.length - 1) {
          await Future.delayed(duration);
        }
      } catch (e) {
        debugPrint('HapticFeedbackService: Error in pattern: $e');
      }
    }
  }

  /// Perform haptic feedback by type
  Future<void> _performHapticByType(HapticType type) async {
    switch (type) {
      case HapticType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticType.vibrate:
        await HapticFeedback.vibrate();
        break;
    }
  }

  /// Check if haptic feedback should be provided
  bool _shouldProvideHaptic() {
    if (!_isEnabled) {
      return false;
    }
    
    if (!PlatformHelper.isMobile) {
      return false;
    }
    
    return true;
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
    debugPrint('HapticFeedbackService: Disposed');
  }
}

/// Types of haptic feedback
enum HapticType {
  /// Light impact - Subtle feedback for minor interactions
  light,
  
  /// Medium impact - Moderate feedback for standard interactions
  medium,
  
  /// Heavy impact - Strong feedback for significant interactions
  heavy,
  
  /// Selection feedback - Feedback for selection changes
  selection,
  
  /// Vibrate - Standard vibration
  vibrate,
}

/// Extension methods for convenient haptic feedback
extension HapticFeedbackExtension on HapticType {
  /// Trigger this haptic feedback type
  Future<void> trigger() async {
    final service = HapticFeedbackService.instance;
    
    switch (this) {
      case HapticType.light:
        await service.light();
        break;
      case HapticType.medium:
        await service.medium();
        break;
      case HapticType.heavy:
        await service.heavy();
        break;
      case HapticType.selection:
        await service.selection();
        break;
      case HapticType.vibrate:
        await service.vibrate();
        break;
    }
  }
}
