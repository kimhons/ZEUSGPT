import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/platform_helper.dart';
// TODO: Re-enable when dart:html/dart:js are properly configured for web
// import 'dart:js' as js;
// import 'dart:html' as html;

/// Service for File System Access API on web
///
/// Provides access to the File System Access API for reading and writing
/// files directly from the user's file system.
///
/// Usage:
/// ```dart
/// final service = WebFileSystemService.instance;
/// final file = await service.openFile();
/// final content = await file.readAsString();
/// ```
class WebFileSystemService {
  WebFileSystemService._();
  static final WebFileSystemService instance = WebFileSystemService._();

  /// Check if File System Access API is supported
  bool get isSupported {
    if (!kIsWeb) return false;
    if (!PlatformHelper.isWeb) return false;

    // TODO: Re-enable when dart:html/dart:js are properly configured
    return false;
    // try {
    //   return js.context.hasProperty('window') &&
    //          js.context['window'].hasProperty('showOpenFilePicker');
    // } catch (e) {
    //   return false;
    // }
  }

  /// Open a file picker to select a file
  ///
  /// Returns the selected file or null if cancelled
  Future<dynamic> openFile({
    List<String>? acceptedTypes,
    bool multiple = false,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('File System Access API only available on web');
    }

    // TODO: Re-enable when dart:html/dart:js are properly configured
    debugPrint('File System Access API not available - feature disabled');
    return null;
  }

  /// Save a file using File System Access API
  ///
  /// Returns true if successful, false otherwise
  Future<bool> saveFile({
    required String content,
    String? suggestedName,
    List<String>? acceptedTypes,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('File System Access API only available on web');
    }

    // TODO: Re-enable when dart:html/dart:js are properly configured
    debugPrint('File save not available - feature disabled');
    return false;
  }

  /// Open a directory picker
  ///
  /// Returns true if successful, false otherwise
  Future<bool> openDirectory() async {
    if (!kIsWeb) {
      throw UnsupportedError('File System Access API only available on web');
    }

    if (!isSupported) {
      debugPrint('Directory picker not supported on this browser');
      return false;
    }

    // TODO: Re-enable when dart:html/dart:js are properly configured
    debugPrint('Directory picker not available - feature disabled');
    return false;
  }
}
