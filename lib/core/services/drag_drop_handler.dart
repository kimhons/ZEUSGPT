import 'package:flutter/foundation.dart';
// TODO: Add desktop_drop and cross_file packages to enable drag-and-drop
// import 'package:desktop_drop/desktop_drop.dart';
// import 'package:cross_file/cross_file.dart';
import '../utils/platform_helper.dart';

/// Stub class to replace XFile until cross_file package is added
class XFile {
  final String name;
  final String path;

  const XFile(this.path, {this.name = ''});

  Future<int> length() async => 0;
}

/// Service for handling drag-and-drop operations on desktop platforms
///
/// This service provides functionality for handling file drops,
/// validating file types, and managing drop events.
///
/// CURRENTLY STUBBED: Requires desktop_drop and cross_file packages
///
/// Usage:
/// ```dart
/// final handler = DragDropHandler.instance;
/// handler.initialize(
///   onFilesDropped: (files) => handleFiles(files),
///   allowedExtensions: ['.pdf', '.txt', '.jpg'],
/// );
/// ```
class DragDropHandler {
  DragDropHandler._();
  static final DragDropHandler instance = DragDropHandler._();

  /// Callback when files are dropped
  Function(List<XFile>)? _onFilesDropped;

  /// Callback when invalid files are dropped
  Function(List<XFile>, String)? _onInvalidFiles;

  /// Allowed file extensions (null means all files allowed)
  Set<String>? _allowedExtensions;

  /// Maximum file size in bytes (null means no limit)
  int? _maxFileSize;

  /// Maximum number of files allowed in a single drop
  int _maxFiles = 10;

  /// Whether drag-and-drop is currently enabled
  bool _isEnabled = true;

  bool get isSupported => PlatformHelper.isDesktop;
  bool get isEnabled => _isEnabled && isSupported;

  /// Initialize the drag-drop handler
  void initialize({
    required Function(List<XFile>) onFilesDropped,
    Function(List<XFile>, String)? onInvalidFiles,
    Set<String>? allowedExtensions,
    int? maxFileSize,
    int maxFiles = 10,
  }) {
    _onFilesDropped = onFilesDropped;
    _onInvalidFiles = onInvalidFiles;
    _allowedExtensions = allowedExtensions?.map((e) => e.toLowerCase()).toSet();
    _maxFileSize = maxFileSize;
    _maxFiles = maxFiles;
  }

  /// Handle files dropped by the user
  Future<void> handleDrop(List<XFile> files) async {
    if (!isEnabled) return;

    // Check number of files
    if (files.length > _maxFiles) {
      _onInvalidFiles?.call(
        files,
        'Too many files. Maximum allowed: $_maxFiles',
      );
      return;
    }

    final validFiles = <XFile>[];
    final invalidFiles = <XFile>[];
    String? errorMessage;

    for (final file in files) {
      // Check file extension
      if (_allowedExtensions != null) {
        final extension = _getFileExtension(file.name).toLowerCase();
        if (!_allowedExtensions!.contains(extension)) {
          invalidFiles.add(file);
          errorMessage = 'File type not allowed. Allowed types: ${_allowedExtensions!.join(', ')}';
          continue;
        }
      }

      // Check file size
      if (_maxFileSize != null) {
        final fileSize = await file.length();
        if (fileSize > _maxFileSize!) {
          invalidFiles.add(file);
          errorMessage = 'File too large. Maximum size: ${_formatFileSize(_maxFileSize!)}';
          continue;
        }
      }

      validFiles.add(file);
    }

    // Notify about invalid files
    if (invalidFiles.isNotEmpty && errorMessage != null) {
      _onInvalidFiles?.call(invalidFiles, errorMessage);
    }

    // Process valid files
    if (validFiles.isNotEmpty) {
      _onFilesDropped?.call(validFiles);
    }
  }

  /// Enable drag-and-drop
  void enable() {
    _isEnabled = true;
  }

  /// Disable drag-and-drop
  void disable() {
    _isEnabled = false;
  }

  /// Update allowed file extensions
  void setAllowedExtensions(Set<String>? extensions) {
    _allowedExtensions = extensions?.map((e) => e.toLowerCase()).toSet();
  }

  /// Update maximum file size
  void setMaxFileSize(int? maxSize) {
    _maxFileSize = maxSize;
  }

  /// Update maximum number of files
  void setMaxFiles(int maxFiles) {
    _maxFiles = maxFiles;
  }

  /// Check if a file type is allowed
  bool isFileTypeAllowed(String filename) {
    if (_allowedExtensions == null) return true;
    final extension = _getFileExtension(filename).toLowerCase();
    return _allowedExtensions!.contains(extension);
  }

  /// Get file extension from filename
  String _getFileExtension(String filename) {
    final lastDot = filename.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filename.substring(lastDot);
  }

  /// Format file size for display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Clear all callbacks and reset to defaults
  void dispose() {
    _onFilesDropped = null;
    _onInvalidFiles = null;
    _allowedExtensions = null;
    _maxFileSize = null;
    _maxFiles = 10;
    _isEnabled = true;
  }
}

/// Predefined file type sets for common use cases
class FileTypePresets {
  /// Image files
  static const Set<String> images = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.svg',
  };

  /// Document files
  static const Set<String> documents = {
    '.pdf',
    '.doc',
    '.docx',
    '.txt',
    '.rtf',
    '.odt',
  };

  /// Text files
  static const Set<String> text = {
    '.txt',
    '.md',
    '.json',
    '.xml',
    '.csv',
  };

  /// Code files
  static const Set<String> code = {
    '.dart',
    '.js',
    '.ts',
    '.tsx',
    '.jsx',
    '.py',
    '.java',
    '.cpp',
    '.c',
    '.h',
    '.css',
    '.html',
    '.go',
    '.rs',
  };

  /// Archive files
  static const Set<String> archives = {
    '.zip',
    '.rar',
    '.7z',
    '.tar',
    '.gz',
  };

  /// All common file types
  static Set<String> get all => {
        ...images,
        ...documents,
        ...text,
        ...code,
        ...archives,
      };
}
