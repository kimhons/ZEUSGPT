import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../utils/platform_helper.dart';

/// Service for handling biometric authentication
/// 
/// Supports:
/// - iOS: Face ID, Touch ID
/// - Android: Fingerprint, Face unlock, Iris scan
/// - Desktop: Not supported (gracefully disabled)
/// - Web: Not supported (gracefully disabled)
class BiometricAuthService {
  BiometricAuthService._();
  static final BiometricAuthService instance = BiometricAuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isInitialized = false;
  bool _isAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  /// Check if biometric authentication is available
  bool get isAvailable => _isAvailable;

  /// Get list of available biometric types
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  /// Initialize biometric authentication service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Biometrics only supported on mobile
    if (!PlatformHelper.isMobile) {
      debugPrint('BiometricAuthService: Not available on this platform');
      _isInitialized = true;
      return;
    }

    try {
      // Check if device supports biometric authentication
      _isAvailable = await _localAuth.canCheckBiometrics;
      
      if (_isAvailable) {
        // Get list of available biometric types
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
        debugPrint('BiometricAuthService: Available biometrics: $_availableBiometrics');
      }

      _isInitialized = true;
      debugPrint('BiometricAuthService: Initialized successfully');
    } catch (e) {
      debugPrint('BiometricAuthService: Initialization failed: $e');
      _isAvailable = false;
      _isInitialized = true;
    }
  }

  /// Authenticate using biometrics
  /// 
  /// Returns true if authentication was successful
  /// Returns false if authentication failed or was cancelled
  Future<BiometricAuthResult> authenticate({
    String localizedReason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    // Ensure initialized
    if (!_isInitialized) {
      await initialize();
    }

    // Check if available
    if (!_isAvailable) {
      return BiometricAuthResult.notAvailable();
    }

    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      if (authenticated) {
        return BiometricAuthResult.success();
      } else {
        return BiometricAuthResult.failed('Authentication failed');
      }
    } on PlatformException catch (e) {
      // Handle specific error codes
      if (e.code == auth_error.notAvailable) {
        return BiometricAuthResult.notAvailable();
      } else if (e.code == auth_error.notEnrolled) {
        return BiometricAuthResult.notEnrolled();
      } else if (e.code == auth_error.passcodeNotSet) {
        return BiometricAuthResult.passcodeNotSet();
      } else if (e.code == auth_error.lockedOut || 
                 e.code == auth_error.permanentlyLockedOut) {
        return BiometricAuthResult.lockedOut();
      } else {
        return BiometricAuthResult.failed(e.message ?? 'Unknown error');
      }
    } catch (e) {
      return BiometricAuthResult.failed('Unexpected error: $e');
    }
  }

  /// Check if specific biometric type is available
  bool isBiometricAvailable(BiometricType type) {
    return _availableBiometrics.contains(type);
  }

  /// Get friendly name for available biometric type
  String getBiometricName() {
    if (_availableBiometrics.isEmpty) {
      return 'None';
    }

    if (_availableBiometrics.contains(BiometricType.face)) {
      return PlatformHelper.isIOS ? 'Face ID' : 'Face Unlock';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return PlatformHelper.isIOS ? 'Touch ID' : 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Scan';
    } else if (_availableBiometrics.contains(BiometricType.strong)) {
      return 'Biometric Authentication';
    } else if (_availableBiometrics.contains(BiometricType.weak)) {
      return 'Biometric Authentication';
    }

    return 'Biometric Authentication';
  }

  /// Stop biometric authentication (if in progress)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      debugPrint('BiometricAuthService: Error stopping authentication: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    // LocalAuthentication doesn't require disposal
    _isInitialized = false;
    _isAvailable = false;
    _availableBiometrics.clear();
  }
}

/// Result of biometric authentication attempt
class BiometricAuthResult {
  final bool success;
  final BiometricAuthFailureReason? failureReason;
  final String? message;

  const BiometricAuthResult._({
    required this.success,
    this.failureReason,
    this.message,
  });

  factory BiometricAuthResult.success() {
    return const BiometricAuthResult._(success: true);
  }

  factory BiometricAuthResult.failed(String message) {
    return BiometricAuthResult._(
      success: false,
      failureReason: BiometricAuthFailureReason.authenticationFailed,
      message: message,
    );
  }

  factory BiometricAuthResult.notAvailable() {
    return const BiometricAuthResult._(
      success: false,
      failureReason: BiometricAuthFailureReason.notAvailable,
      message: 'Biometric authentication is not available on this device',
    );
  }

  factory BiometricAuthResult.notEnrolled() {
    return const BiometricAuthResult._(
      success: false,
      failureReason: BiometricAuthFailureReason.notEnrolled,
      message: 'No biometric credentials enrolled. Please set up biometrics in device settings',
    );
  }

  factory BiometricAuthResult.passcodeNotSet() {
    return const BiometricAuthResult._(
      success: false,
      failureReason: BiometricAuthFailureReason.passcodeNotSet,
      message: 'Device passcode not set. Please set up a passcode in device settings',
    );
  }

  factory BiometricAuthResult.lockedOut() {
    return const BiometricAuthResult._(
      success: false,
      failureReason: BiometricAuthFailureReason.lockedOut,
      message: 'Too many failed attempts. Biometric authentication is temporarily locked',
    );
  }

  @override
  String toString() {
    if (success) {
      return 'BiometricAuthResult.success';
    } else {
      return 'BiometricAuthResult.failed(reason: $failureReason, message: $message)';
    }
  }
}

/// Reasons why biometric authentication might fail
enum BiometricAuthFailureReason {
  /// Biometric authentication not available on device
  notAvailable,
  
  /// No biometric credentials enrolled
  notEnrolled,
  
  /// Device passcode not set
  passcodeNotSet,
  
  /// Authentication failed (wrong biometric)
  authenticationFailed,
  
  /// Temporarily locked out due to too many failed attempts
  lockedOut,
}
