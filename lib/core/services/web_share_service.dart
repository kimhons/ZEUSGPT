import 'package:flutter/foundation.dart';
import '../utils/platform_helper.dart';
// TODO: Re-enable when dart:html/dart:js are properly configured for web
// import 'dart:js' as js;
// import 'dart:html' as html;

/// Service for integrating with Web Share API
///
/// Provides access to the native share functionality on web platforms.
/// Falls back to clipboard copy on unsupported browsers.
///
/// Usage:
/// ```dart
/// final service = WebShareService.instance;
/// await service.share(
///   title: 'Check this out',
///   text: 'Interesting content',
///   url: 'https://example.com',
/// );
/// ```
class WebShareService {
  WebShareService._();
  static final WebShareService instance = WebShareService._();

  /// Check if Web Share API is supported
  bool get isSupported {
    if (!kIsWeb) return false;
    if (!PlatformHelper.isWeb) return false;

    // TODO: Re-enable when dart:html/dart:js are properly configured
    return false;
    // try {
    //   return js.context.hasProperty('navigator') &&
    //          js.context['navigator'].hasProperty('share');
    // } catch (e) {
    //   return false;
    // }
  }

  /// Check if sharing files is supported
  bool get canShareFiles {
    if (!isSupported) return false;

    // TODO: Re-enable when dart:html/dart:js are properly configured
    return false;
    // try {
    //   return js.context['navigator'].hasProperty('canShare');
    // } catch (e) {
    //   return false;
    // }
  }

  /// Share text, URL, or title using Web Share API
  ///
  /// Falls back to clipboard if Web Share API is not available
  Future<bool> share({
    String? title,
    String? text,
    String? url,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Web Share API only available on web platform');
    }

    if (title == null && text == null && url == null) {
      throw ArgumentError('At least one of title, text, or url must be provided');
    }

    // TODO: Re-enable when dart:html/dart:js are properly configured
    debugPrint('Web Share API not available - feature disabled');
    return false;

    // if (isSupported) {
    //   try {
    //     final shareData = <String, dynamic>{};
    //     if (title != null) shareData['title'] = title;
    //     if (text != null) shareData['text'] = text;
    //     if (url != null) shareData['url'] = url;

    //     await js.context['navigator'].callMethod('share', [js.JsObject.jsify(shareData)]);
    //     return true;
    //   } catch (e) {
    //     // User cancelled or error occurred
    //     debugPrint('Share failed: $e');
    //     return _fallbackToCopyToClipboard(text ?? url ?? title ?? '');
    //   }
    // } else {
    //   // Fallback to clipboard
    //   return _fallbackToCopyToClipboard(text ?? url ?? title ?? '');
    // }
  }

  /// Share files using Web Share API
  ///
  /// Only works on browsers that support file sharing
  Future<bool> shareFiles({
    required List<dynamic> files, // Changed from html.File to dynamic
    String? title,
    String? text,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Web Share API only available on web platform');
    }

    // TODO: Re-enable when dart:html/dart:js are properly configured
    debugPrint('File sharing not available - feature disabled');
    return false;

    // if (!canShareFiles) {
    //   throw UnsupportedError('File sharing not supported in this browser');
    // }

    // try {
    //   final shareData = <String, dynamic>{
    //     'files': files,
    //   };
    //   if (title != null) shareData['title'] = title;
    //   if (text != null) shareData['text'] = text;

    //   // Check if can share these files
    //   final canShare = await js.context['navigator'].callMethod(
    //     'canShare',
    //     [js.JsObject.jsify(shareData)],
    //   );

    //   if (canShare) {
    //     await js.context['navigator'].callMethod('share', [js.JsObject.jsify(shareData)]);
    //     return true;
    //   }
    //   return false;
    // } catch (e) {
    //   debugPrint('File share failed: $e');
    //   return false;
    // }
  }

  /// Fallback to copying text to clipboard
  Future<bool> _fallbackToCopyToClipboard(String text) async {
    // TODO: Re-enable when dart:html is properly configured
    debugPrint('Clipboard fallback not available - feature disabled');
    return false;

    // try {
    //   await html.window.navigator.clipboard?.writeText(text);
    //   debugPrint('Copied to clipboard as fallback');
    //   return true;
    // } catch (e) {
    //   debugPrint('Clipboard fallback failed: $e');
    //   return false;
    // }
  }
}
