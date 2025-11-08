import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/platform_helper.dart';
import 'dart:js' as js;
import 'dart:html' as html;

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
    
    try {
      return js.context.hasProperty('window') &&
             js.context['window'].hasProperty('showOpenFilePicker');
    } catch (e) {
      return false;
    }
  }

  /// Open a file picker to select a file
  ///
  /// Returns the selected file or null if cancelled
  Future<html.File?> openFile({
    List<String>? acceptedTypes,
    bool multiple = false,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('File System Access API only available on web');
    }

    try {
      if (isSupported) {
        return await _openFileWithFileSystemAPI(acceptedTypes, multiple);
      } else {
        return await _openFileWithInputElement(acceptedTypes, multiple);
      }
    } catch (e) {
      debugPrint('Open file failed: $e');
      return null;
    }
  }

  /// Open file picker using File System Access API
  Future<html.File?> _openFileWithFileSystemAPI(
    List<String>? acceptedTypes,
    bool multiple,
  ) async {
    try {
      final options = <String, dynamic>{
        'multiple': multiple,
      };

      if (acceptedTypes != null && acceptedTypes.isNotEmpty) {
        options['types'] = [
          {
            'description': 'Accepted files',
            'accept': {
              '*/*': acceptedTypes,
            },
          },
        ];
      }

      final result = await js.context['window'].callMethod(
        'showOpenFilePicker',
        [js.JsObject.jsify(options)],
      );

      if (result == null) return null;

      // Get first file handle
      final fileHandle = result[0];
      if (fileHandle == null) return null;

      // Get file from handle
      final file = await fileHandle.callMethod('getFile', []);
      return file as html.File?;
    } catch (e) {
      debugPrint('File System Access API failed: $e');
      return null;
    }
  }

  /// Open file picker using HTML input element (fallback)
  Future<html.File?> _openFileWithInputElement(
    List<String>? acceptedTypes,
    bool multiple,
  ) async {
    final completer = Completer<html.File?>();

    final input = html.FileUploadInputElement();
    input.multiple = multiple;

    if (acceptedTypes != null && acceptedTypes.isNotEmpty) {
      input.accept = acceptedTypes.join(',');
    }

    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        completer.complete(files.first);
      } else {
        completer.complete(null);
      }
    });

    input.click();

    return completer.future;
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

    try {
      if (isSupported) {
        return await _saveFileWithFileSystemAPI(
          content,
          suggestedName,
          acceptedTypes,
        );
      } else {
        return await _saveFileWithDownload(content, suggestedName);
      }
    } catch (e) {
      debugPrint('Save file failed: $e');
      return false;
    }
  }

  /// Save file using File System Access API
  Future<bool> _saveFileWithFileSystemAPI(
    String content,
    String? suggestedName,
    List<String>? acceptedTypes,
  ) async {
    try {
      final options = <String, dynamic>{};

      if (suggestedName != null) {
        options['suggestedName'] = suggestedName;
      }

      if (acceptedTypes != null && acceptedTypes.isNotEmpty) {
        options['types'] = [
          {
            'description': 'Save file',
            'accept': {
              '*/*': acceptedTypes,
            },
          },
        ];
      }

      final fileHandle = await js.context['window'].callMethod(
        'showSaveFilePicker',
        [js.JsObject.jsify(options)],
      );

      if (fileHandle == null) return false;

      // Create writable stream
      final writable = await fileHandle.callMethod('createWritable', []);

      // Write content
      await writable.callMethod('write', [content]);

      // Close stream
      await writable.callMethod('close', []);

      return true;
    } catch (e) {
      debugPrint('File System Access API save failed: $e');
      return false;
    }
  }

  /// Save file using download fallback
  Future<bool> _saveFileWithDownload(String content, String? suggestedName) async {
    try {
      final blob = html.Blob([content]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement()
        ..href = url
        ..download = suggestedName ?? 'download.txt'
        ..style.display = 'none';

      html.document.body?.append(anchor);
      anchor.click();

      // Clean up
      Future.delayed(const Duration(milliseconds: 100), () {
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      });

      return true;
    } catch (e) {
      debugPrint('Download fallback failed: $e');
      return false;
    }
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

    try {
      final dirHandle = await js.context['window'].callMethod(
        'showDirectoryPicker',
        [],
      );

      return dirHandle != null;
    } catch (e) {
      debugPrint('Directory picker failed: $e');
      return false;
    }
  }
}
