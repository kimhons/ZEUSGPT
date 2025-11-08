import 'package:flutter/material.dart';
// TODO: Add desktop_drop and cross_file packages to enable drag-and-drop
// import 'package:desktop_drop/desktop_drop.dart';
// import 'package:cross_file/cross_file.dart';
import '../utils/platform_helper.dart';
import '../services/drag_drop_handler.dart';

/// Stub class for drag event details
class _DropDoneDetails {
  final List<XFile> files;
  const _DropDoneDetails(this.files);
}

/// Stub widget to replace DropTarget until desktop_drop package is added
class DropTarget extends StatelessWidget {
  final Widget child;
  final void Function(dynamic)? onDragEntered;
  final void Function(dynamic)? onDragExited;
  final void Function(_DropDoneDetails)? onDragDone;

  const DropTarget({
    super.key,
    required this.child,
    this.onDragEntered,
    this.onDragExited,
    this.onDragDone,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// A zone that accepts drag-and-drop file operations
///
/// This widget provides visual feedback when files are dragged over it
/// and handles the file drop operation.
///
/// CURRENTLY STUBBED: Requires desktop_drop and cross_file packages
///
/// Usage:
/// ```dart
/// DragDropZone(
///   onFilesDropped: (files) => handleFiles(files),
///   child: Container(
///     child: Text('Drop files here'),
///   ),
/// )
/// ```
class DragDropZone extends StatefulWidget {
  final Widget child;
  final Function(List<XFile>) onFilesDropped;
  final Function(List<XFile>, String)? onInvalidFiles;
  final Set<String>? allowedExtensions;
  final int? maxFileSize;
  final int maxFiles;
  final bool enabled;
  final Widget? overlayBuilder;
  final Color? overlayColor;
  final String? overlayMessage;

  const DragDropZone({
    super.key,
    required this.child,
    required this.onFilesDropped,
    this.onInvalidFiles,
    this.allowedExtensions,
    this.maxFileSize,
    this.maxFiles = 10,
    this.enabled = true,
    this.overlayBuilder,
    this.overlayColor,
    this.overlayMessage,
  });

  @override
  State<DragDropZone> createState() => _DragDropZoneState();
}

class _DragDropZoneState extends State<DragDropZone> {
  bool _isDragging = false;
  final DragDropHandler _handler = DragDropHandler.instance;

  @override
  void initState() {
    super.initState();
    _initializeHandler();
  }

  void _initializeHandler() {
    _handler.initialize(
      onFilesDropped: widget.onFilesDropped,
      onInvalidFiles: widget.onInvalidFiles,
      allowedExtensions: widget.allowedExtensions,
      maxFileSize: widget.maxFileSize,
      maxFiles: widget.maxFiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only enable on desktop platforms
    if (!PlatformHelper.isDesktop) {
      return widget.child;
    }

    if (!widget.enabled) {
      return widget.child;
    }

    return DropTarget(
      onDragEntered: (details) {
        setState(() {
          _isDragging = true;
        });
      },
      onDragExited: (details) {
        setState(() {
          _isDragging = false;
        });
      },
      onDragDone: (details) async {
        setState(() {
          _isDragging = false;
        });
        await _handler.handleDrop(details.files);
      },
      child: Stack(
        children: [
          widget.child,
          if (_isDragging) _buildOverlay(context),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    if (widget.overlayBuilder != null) {
      return widget.overlayBuilder!;
    }

    final theme = Theme.of(context);
    final overlayColor = widget.overlayColor ?? 
        theme.colorScheme.primary.withOpacity(0.1);
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: overlayColor,
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                widget.overlayMessage ?? 'Drop files here',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.allowedExtensions != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Allowed types: ${widget.allowedExtensions!.join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
