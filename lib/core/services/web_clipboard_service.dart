import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/platform_helper.dart';
// TODO: Re-enable when dart:html is properly configured for web
// import 'dart:html' as html;

/// Service for enhanced clipboard operations on web
///
/// Provides access to modern Clipboard API features on web platforms,
/// including reading/writing text, HTML, and images.
///
/// Usage:
/// ```dart
/// final service = WebClipboardService.instance;
/// await service.writeText('Hello World');
/// final text = await service.readText();
/// ```
class WebClipboardService {
  WebClipboardService._();
  static final WebClipboardService instance = WebClipboardService._();

  /// Check if Clipboard API is supported
  bool get isSupported {
    if (!kIsWeb) return false;
    if (!PlatformHelper.isWeb) return false;

    // TODO: Re-enable when dart:html is properly configured
    // Fall back to Flutter's clipboard which works on all platforms
    return true; // Flutter Clipboard is always available
  }

  /// Write text to clipboard
  Future<bool> writeText(String text) async {
    try {
      // Use Flutter's cross-platform clipboard API
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      debugPrint('Write to clipboard failed: $e');
      return false;
    }
  }

  /// Read text from clipboard
  Future<String?> readText() async {
    try {
      // Use Flutter's cross-platform clipboard API
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      debugPrint('Read from clipboard failed: $e');
      return null;
    }
  }

  /// Check if clipboard contains text
  Future<bool> hasText() async {
    try {
      final data = await Clipboard.hasStrings();
      return data;
    } catch (e) {
      return false;
    }
  }

  /// Copy text with user feedback
  Future<bool> copyWithFeedback(String text, {
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    final success = await writeText(text);

    if (success) {
      onSuccess?.call();
    } else {
      onError?.call('Failed to copy to clipboard');
    }

    return success;
  }
}
