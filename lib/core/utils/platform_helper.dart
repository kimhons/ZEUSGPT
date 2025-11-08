import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Platform detection utility for cross-platform support
/// 
/// Provides static methods to detect the current platform and make
/// platform-specific decisions throughout the app.
/// 
/// Example usage:
/// ```dart
/// if (PlatformHelper.isMobile) {
///   // Show mobile UI
/// } else if (PlatformHelper.isDesktop) {
///   // Show desktop UI
/// }
/// ```
class PlatformHelper {
  /// Private constructor to prevent instantiation
  PlatformHelper._();

  // ============== Platform Categories ==============

  /// Returns true if running on web platform
  static bool get isWeb => kIsWeb;

  /// Returns true if running on mobile (iOS or Android)
  static bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  /// Returns true if running on desktop (macOS, Windows, or Linux)
  static bool get isDesktop => 
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  // ============== Specific Platforms ==============

  /// Returns true if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Returns true if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Returns true if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Returns true if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Returns true if running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  // ============== Platform Features ==============

  /// Returns true if platform supports native biometrics
  static bool get supportsBiometrics => isMobile || isMacOS;

  /// Returns true if platform has physical keyboard (typically)
  static bool get hasPhysicalKeyboard => isDesktop || isWeb;

  /// Returns true if platform supports window management
  static bool get supportsWindowManagement => isDesktop;

  /// Returns true if platform typically uses touch input
  static bool get isTouchPrimary => isMobile;

  /// Returns true if platform typically uses mouse/trackpad
  static bool get isPointerPrimary => isDesktop || isWeb;

  // ============== Platform Info ==============

  /// Returns a human-readable platform name
  static String get platformName {
    if (isWeb) return 'Web';
    if (isIOS) return 'iOS';
    if (isAndroid) return 'Android';
    if (isMacOS) return 'macOS';
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Returns platform category name (Mobile/Desktop/Web)
  static String get platformCategory {
    if (isWeb) return 'Web';
    if (isMobile) return 'Mobile';
    if (isDesktop) return 'Desktop';
    return 'Unknown';
  }

  // ============== Layout Helpers ==============

  /// Returns true if platform should use bottom navigation
  static bool get useBottomNavigation => isMobile;

  /// Returns true if platform should use sidebar navigation
  static bool get useSidebarNavigation => isDesktop;

  /// Returns true if platform should use top navigation bar
  static bool get useTopNavigation => isWeb;

  /// Returns true if platform should show window controls
  static bool get showWindowControls => isDesktop && !isMacOS;

  // ============== Platform-Specific Features ==============

  /// Returns true if platform supports app review prompts
  static bool get supportsAppReview => isMobile;

  /// Returns true if platform supports push notifications
  static bool get supportsPushNotifications => !isWeb;

  /// Returns true if platform supports file system access
  static bool get supportsFileSystem => !isWeb;

  /// Returns true if platform supports share sheet
  static bool get supportsNativeShare => isMobile;

  /// Returns true if platform should use material design
  static bool get useMaterialDesign => isAndroid || isWeb || isWindows || isLinux;

  /// Returns true if platform should use cupertino design
  static bool get useCupertinoDesign => isIOS || isMacOS;
}
