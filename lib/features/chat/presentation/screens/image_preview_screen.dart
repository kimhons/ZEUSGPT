import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';

/// Preview image data
class PreviewImage {
  const PreviewImage({
    required this.id,
    required this.path,
    this.caption,
    this.width,
    this.height,
    this.size,
  });

  final String id;
  final String path;
  final String? caption;
  final int? width;
  final int? height;
  final int? size;

  PreviewImage copyWith({
    String? caption,
  }) {
    return PreviewImage(
      id: id,
      path: path,
      caption: caption ?? this.caption,
      width: width,
      height: height,
      size: size,
    );
  }

  String get formattedSize {
    if (size == null) return '';
    const kb = 1024;
    const mb = kb * 1024;

    if (size! >= mb) {
      return '${(size! / mb).toStringAsFixed(2)} MB';
    } else if (size! >= kb) {
      return '${(size! / kb).toStringAsFixed(2)} KB';
    } else {
      return '$size B';
    }
  }

  String get resolution {
    if (width == null || height == null) return '';
    return '${width}x$height';
  }
}

/// Edit mode for image preview
enum ImageEditMode {
  none,
  crop,
  rotate,
  draw,
  text,
}

/// Screen for previewing and editing images before sending
class ImagePreviewScreen extends ConsumerStatefulWidget {
  const ImagePreviewScreen({
    required this.images,
    this.initialIndex = 0,
    super.key,
  });

  final List<PreviewImage> images;
  final int initialIndex;

  @override
  ConsumerState<ImagePreviewScreen> createState() =>
      _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends ConsumerState<ImagePreviewScreen> {
  late int _currentIndex;
  late List<PreviewImage> _images;
  final PageController _pageController = PageController();
  final TextEditingController _captionController = TextEditingController();
  ImageEditMode _editMode = ImageEditMode.none;
  bool _showControls = true;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _images = List.from(widget.images);
    _pageController.addListener(_onPageChanged);
    _updateCaption();

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Image Preview');
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _captionController.dispose();
    _transformationController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentIndex) {
      setState(() {
        _currentIndex = page;
        _editMode = ImageEditMode.none;
        _transformationController.value = Matrix4.identity();
      });
      _updateCaption();
    }
  }

  void _updateCaption() {
    _captionController.text = _images[_currentIndex].caption ?? '';
  }

  void _saveCaption() {
    setState(() {
      _images[_currentIndex] = _images[_currentIndex].copyWith(
        caption: _captionController.text.trim(),
      );
    });
  }

  Future<void> _deleteCurrentImage() async {
    if (_images.length == 1) {
      // Last image - cancel everything
      final shouldDelete = await _showDeleteDialog(isLast: true);
      if (shouldDelete == true && mounted) {
        context.pop();
      }
      return;
    }

    final shouldDelete = await _showDeleteDialog(isLast: false);
    if (shouldDelete == true) {
      setState(() {
        _images.removeAt(_currentIndex);
        if (_currentIndex >= _images.length) {
          _currentIndex = _images.length - 1;
        }
        _pageController.jumpToPage(_currentIndex);
      });
      _updateCaption();
    }
  }

  Future<bool?> _showDeleteDialog({required bool isLast}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: Text(
          isLast
              ? 'This is the last image. Deleting it will close the preview.'
              : 'Are you sure you want to remove this image?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sendImages() {
    _saveCaption();
    context.pop(_images);
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _setEditMode(ImageEditMode mode) {
    setState(() {
      _editMode = _editMode == mode ? ImageEditMode.none : mode;
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1200 : double.infinity,
          child: GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
            // Image viewer
            PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                return _buildImageView(image);
              },
            ),

            // Controls overlay
            if (_showControls) ...[
              _buildTopBar(),
              _buildBottomBar(),
            ],

            // Edit mode overlay
            if (_editMode != ImageEditMode.none) _buildEditModeOverlay(),

            // Page indicator
            if (_images.length > 1 && _showControls)
              _buildPageIndicator(),
          ],
      ),  // Close Stack
    ),  // Close GestureDetector
  ),  // Close ResponsiveCenter
),  // Close SafeArea
    );
  }

  Widget _buildImageView(PreviewImage image) {
    return Center(
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          image.path,
          fit: BoxFit.contain,
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 48),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                SemanticIconButton(
                  icon: Icons.close,
                  label: 'Cancel and close preview',
                  onPressed: () => context.pop(),
                  color: Colors.white,
                ),
                const Spacer(),
                SemanticIconButton(
                  icon: Icons.delete,
                  label: 'Delete current image',
                  onPressed: _deleteCurrentImage,
                  color: Colors.white,
                ),
                SemanticIconButton(
                  icon: Icons.zoom_out_map,
                  label: 'Reset zoom',
                  onPressed: _resetZoom,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit tools
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEditTool(
                      icon: Icons.crop,
                      label: 'Crop',
                      mode: ImageEditMode.crop,
                    ),
                    _buildEditTool(
                      icon: Icons.rotate_right,
                      label: 'Rotate',
                      mode: ImageEditMode.rotate,
                    ),
                    _buildEditTool(
                      icon: Icons.edit,
                      label: 'Draw',
                      mode: ImageEditMode.draw,
                    ),
                    _buildEditTool(
                      icon: Icons.text_fields,
                      label: 'Text',
                      mode: ImageEditMode.text,
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white24, height: 1),

              // Caption input
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          prefixIcon: const Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                        ),
                        maxLines: 3,
                        minLines: 1,
                        onChanged: (value) => _saveCaption(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Semantics(
                      label: 'Send ${_images.length} ${_images.length == 1 ? "image" : "images"}',
                      button: true,
                      child: FloatingActionButton(
                        onPressed: _sendImages,
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Image info
              if (_images[_currentIndex].resolution.isNotEmpty ||
                  _images[_currentIndex].formattedSize.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_images[_currentIndex].resolution.isNotEmpty) ...[
                        const Icon(
                          Icons.photo_size_select_actual,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _images[_currentIndex].resolution,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      if (_images[_currentIndex].formattedSize.isNotEmpty) ...[
                        const Icon(
                          Icons.file_present,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _images[_currentIndex].formattedSize,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditTool({
    required IconData icon,
    required String label,
    required ImageEditMode mode,
  }) {
    final isActive = _editMode == mode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SemanticIconButton(
          icon: icon,
          label: isActive ? 'Disable $label mode' : 'Enable $label mode',
          onPressed: () => _setEditMode(mode),
          color: isActive ? AppColors.primary : Colors.white,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_images.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: index == _currentIndex ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentIndex
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildEditModeOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(AppSpacing.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getEditModeIcon(),
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _getEditModeTitle(),
                  style: AppTextStyles.h4().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _getEditModeDescription(),
                  style: AppTextStyles.bodyMedium().copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _editMode = ImageEditMode.none),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Apply edit
                        final editTitle = _getEditModeTitle();
                        setState(() => _editMode = ImageEditMode.none);
                        showAccessibleSnackBar(
                          context,
                          '$editTitle applied',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getEditModeIcon() {
    switch (_editMode) {
      case ImageEditMode.crop:
        return Icons.crop;
      case ImageEditMode.rotate:
        return Icons.rotate_right;
      case ImageEditMode.draw:
        return Icons.edit;
      case ImageEditMode.text:
        return Icons.text_fields;
      case ImageEditMode.none:
        return Icons.image;
    }
  }

  String _getEditModeTitle() {
    switch (_editMode) {
      case ImageEditMode.crop:
        return 'Crop Image';
      case ImageEditMode.rotate:
        return 'Rotate Image';
      case ImageEditMode.draw:
        return 'Draw on Image';
      case ImageEditMode.text:
        return 'Add Text';
      case ImageEditMode.none:
        return 'Edit';
    }
  }

  String _getEditModeDescription() {
    switch (_editMode) {
      case ImageEditMode.crop:
        return 'Crop functionality will be implemented with image_cropper package';
      case ImageEditMode.rotate:
        return 'Rotate functionality will be implemented with image package';
      case ImageEditMode.draw:
        return 'Drawing functionality will be implemented with custom painter';
      case ImageEditMode.text:
        return 'Text overlay functionality will be implemented';
      case ImageEditMode.none:
        return '';
    }
  }
}
