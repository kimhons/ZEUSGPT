import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';

/// Attachment type enum
enum AttachmentType {
  image,
  pdf,
  document,
  video,
  audio,
  other,
}

/// Attachment model
class Attachment {
  const Attachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.size,
    this.mimeType,
    this.thumbnailUrl,
  });

  final String id;
  final String name;
  final String url;
  final AttachmentType type;
  final int? size;
  final String? mimeType;
  final String? thumbnailUrl;

  static AttachmentType getTypeFromExtension(String filename) {
    final ext = path.extension(filename).toLowerCase();

    if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].contains(ext)) {
      return AttachmentType.image;
    } else if (ext == '.pdf') {
      return AttachmentType.pdf;
    } else if (['.doc', '.docx', '.txt', '.rtf'].contains(ext)) {
      return AttachmentType.document;
    } else if (['.mp4', '.mov', '.avi', '.mkv'].contains(ext)) {
      return AttachmentType.video;
    } else if (['.mp3', '.wav', '.m4a', '.flac'].contains(ext)) {
      return AttachmentType.audio;
    } else {
      return AttachmentType.other;
    }
  }

  String get formattedSize {
    if (size == null) return 'Unknown size';

    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (size! >= gb) {
      return '${(size! / gb).toStringAsFixed(2)} GB';
    } else if (size! >= mb) {
      return '${(size! / mb).toStringAsFixed(2)} MB';
    } else if (size! >= kb) {
      return '${(size! / kb).toStringAsFixed(2)} KB';
    } else {
      return '$size B';
    }
  }
}

/// Attachment viewer screen with support for multiple file types
class AttachmentViewerScreen extends ConsumerStatefulWidget {
  const AttachmentViewerScreen({
    required this.attachments,
    this.initialIndex = 0,
    super.key,
  });

  final List<Attachment> attachments;
  final int initialIndex;

  @override
  ConsumerState<AttachmentViewerScreen> createState() =>
      _AttachmentViewerScreenState();
}

class _AttachmentViewerScreenState
    extends ConsumerState<AttachmentViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Hide system UI for immersive viewing
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Attachment Viewer');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Attachment get _currentAttachment => widget.attachments[_currentIndex];

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  Future<void> _downloadAttachment() async {
    setState(() => _isDownloading = true);

    try {
      // TODO: Implement actual download logic
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        showAccessibleSuccessSnackBar(
          context,
          'Downloaded ${_currentAttachment.name}',
        );
      }
    } catch (e) {
      if (mounted) {
        showAccessibleErrorSnackBar(
          context,
          'Failed to download: ${_currentAttachment.name}. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _shareAttachment() async {
    // TODO: Implement share functionality
    showAccessibleSnackBar(
      context,
      'Sharing ${_currentAttachment.name}...',
    );
  }

  void _showAttachmentInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AttachmentInfoSheet(
        attachment: _currentAttachment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1200 : double.infinity,
          child: Stack(
            children: [
          // Main content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.attachments.length,
            itemBuilder: (context, index) {
              final attachment = widget.attachments[index];
              return GestureDetector(
                onTap: _toggleControls,
                child: _buildAttachmentView(attachment),
              );
            },
          ),

          // Top controls
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopControls(),
            ),

          // Bottom controls
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(),
            ),

          // Download progress
          if (_isDownloading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        ],
      ),  // Close Stack
    ),  // Close ResponsiveCenter
  ),  // Close SafeArea
    );
  }

  Widget _buildTopControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        bottom: AppSpacing.xl,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Row(
        children: [
          SemanticIconButton(
            icon: Icons.close,
            label: 'Close attachment viewer',
            onPressed: () => context.pop(),
            color: Colors.white,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentAttachment.name,
                  style: AppTextStyles.bodyLarge().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.attachments.length > 1)
                  Text(
                    '${_currentIndex + 1} of ${widget.attachments.length}',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          SemanticIconButton(
            icon: Icons.info_outline,
            label: 'Show attachment details',
            onPressed: _showAttachmentInfo,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
        top: AppSpacing.xl,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.download,
            label: 'Download',
            onPressed: _downloadAttachment,
          ),
          _buildControlButton(
            icon: Icons.share,
            label: 'Share',
            onPressed: _shareAttachment,
          ),
          if (_currentAttachment.type == AttachmentType.image)
            _buildControlButton(
              icon: Icons.zoom_in,
              label: 'Zoom',
              onPressed: () {
                // TODO: Implement zoom functionality
              },
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SemanticIconButton(
          icon: icon,
          label: label,
          onPressed: onPressed,
          color: Colors.white,
          iconSize: 28,
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall().copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentView(Attachment attachment) {
    switch (attachment.type) {
      case AttachmentType.image:
        return _buildImageView(attachment);
      case AttachmentType.pdf:
        return _buildPdfView(attachment);
      case AttachmentType.document:
        return _buildDocumentView(attachment);
      case AttachmentType.video:
        return _buildVideoView(attachment);
      case AttachmentType.audio:
        return _buildAudioView(attachment);
      case AttachmentType.other:
        return _buildGenericView(attachment);
    }
  }

  Widget _buildImageView(Attachment attachment) {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          attachment.url,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorView('Failed to load image');
          },
        ),
      ),
    );
  }

  Widget _buildPdfView(Attachment attachment) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.zeusGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            attachment.name,
            style: AppTextStyles.h4().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'PDF Document',
            style: AppTextStyles.bodyMedium().copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: _downloadAttachment,
            icon: const Icon(Icons.download),
            label: const Text('Download to View'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentView(Attachment attachment) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.zeusGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            attachment.name,
            style: AppTextStyles.h4().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Document',
            style: AppTextStyles.bodyMedium().copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: _downloadAttachment,
            icon: const Icon(Icons.download),
            label: const Text('Download to View'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView(Attachment attachment) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.zeusGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            attachment.name,
            style: AppTextStyles.h4().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Video',
            style: AppTextStyles.bodyMedium().copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement video playback
              showAccessibleSnackBar(
                context,
                'Video playback not implemented yet',
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play Video'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioView(Attachment attachment) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.zeusGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.audiotrack,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            attachment.name,
            style: AppTextStyles.h4().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Audio',
            style: AppTextStyles.bodyMedium().copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement audio playback
              showAccessibleSnackBar(
                context,
                'Audio playback not implemented yet',
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play Audio'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericView(Attachment attachment) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.zeusGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insert_drive_file,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            attachment.name,
            style: AppTextStyles.h4().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'File',
            style: AppTextStyles.bodyMedium().copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: _downloadAttachment,
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTextStyles.bodyLarge().copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Attachment info bottom sheet
class _AttachmentInfoSheet extends StatelessWidget {
  const _AttachmentInfoSheet({required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Attachment Details',
            style: AppTextStyles.h3().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildInfoRow('Name', attachment.name),
          _buildInfoRow('Type', attachment.type.toString().split('.').last),
          if (attachment.size != null)
            _buildInfoRow('Size', attachment.formattedSize),
          if (attachment.mimeType != null)
            _buildInfoRow('MIME Type', attachment.mimeType!),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
