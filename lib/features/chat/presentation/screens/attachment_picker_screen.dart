import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive.dart';

/// Attachment category
enum AttachmentCategory {
  all,
  images,
  videos,
  documents,
  audio,
}

extension AttachmentCategoryExtension on AttachmentCategory {
  String get label {
    switch (this) {
      case AttachmentCategory.all:
        return 'All';
      case AttachmentCategory.images:
        return 'Images';
      case AttachmentCategory.videos:
        return 'Videos';
      case AttachmentCategory.documents:
        return 'Documents';
      case AttachmentCategory.audio:
        return 'Audio';
    }
  }

  IconData get icon {
    switch (this) {
      case AttachmentCategory.all:
        return Icons.attachment;
      case AttachmentCategory.images:
        return Icons.image;
      case AttachmentCategory.videos:
        return Icons.videocam;
      case AttachmentCategory.documents:
        return Icons.description;
      case AttachmentCategory.audio:
        return Icons.audiotrack;
    }
  }
}

/// Attachable file model
class AttachableFile {
  const AttachableFile({
    required this.id,
    required this.name,
    required this.path,
    required this.category,
    this.size,
    this.thumbnailUrl,
    this.modifiedAt,
  });

  final String id;
  final String name;
  final String path;
  final AttachmentCategory category;
  final int? size;
  final String? thumbnailUrl;
  final DateTime? modifiedAt;

  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }

  String get formattedSize {
    if (size == null) return '';
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

  IconData get fileIcon {
    switch (category) {
      case AttachmentCategory.images:
        return Icons.image;
      case AttachmentCategory.videos:
        return Icons.videocam;
      case AttachmentCategory.documents:
        return _getDocumentIcon();
      case AttachmentCategory.audio:
        return Icons.audiotrack;
      case AttachmentCategory.all:
        return Icons.insert_drive_file;
    }
  }

  IconData _getDocumentIcon() {
    final ext = extension.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (['doc', 'docx'].contains(ext)) return Icons.description;
    if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart;
    if (['ppt', 'pptx'].contains(ext)) return Icons.slideshow;
    if (['txt', 'md'].contains(ext)) return Icons.text_snippet;
    return Icons.insert_drive_file;
  }
}

/// Screen for picking attachments to send in chat
class AttachmentPickerScreen extends ConsumerStatefulWidget {
  const AttachmentPickerScreen({
    this.allowMultiple = true,
    this.maxSelections = 10,
    super.key,
  });

  final bool allowMultiple;
  final int maxSelections;

  @override
  ConsumerState<AttachmentPickerScreen> createState() =>
      _AttachmentPickerScreenState();
}

class _AttachmentPickerScreenState
    extends ConsumerState<AttachmentPickerScreen>
    with SingleTickerProviderStateMixin {
  AttachmentCategory _selectedCategory = AttachmentCategory.all;
  final Set<String> _selectedFiles = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  // Simulated file list - in real implementation, use file_picker or similar packages
  final List<AttachableFile> _allFiles = [
    const AttachableFile(
      id: '1',
      name: 'vacation_photo.jpg',
      path: '/storage/photos/vacation_photo.jpg',
      category: AttachmentCategory.images,
      size: 2048000,
      thumbnailUrl: 'https://via.placeholder.com/150',
      modifiedAt: null,
    ),
    const AttachableFile(
      id: '2',
      name: 'project_proposal.pdf',
      path: '/storage/documents/project_proposal.pdf',
      category: AttachmentCategory.documents,
      size: 1024000,
    ),
    const AttachableFile(
      id: '3',
      name: 'presentation.mp4',
      path: '/storage/videos/presentation.mp4',
      category: AttachmentCategory.videos,
      size: 15360000,
    ),
    const AttachableFile(
      id: '4',
      name: 'voice_note.m4a',
      path: '/storage/audio/voice_note.m4a',
      category: AttachmentCategory.audio,
      size: 512000,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AttachmentCategory.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = AttachmentCategory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<AttachableFile> get _filteredFiles {
    var files = _allFiles;

    // Filter by category
    if (_selectedCategory != AttachmentCategory.all) {
      files = files.where((f) => f.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      files = files
          .where((f) =>
              f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return files;
  }

  void _toggleFileSelection(String fileId) {
    setState(() {
      if (_selectedFiles.contains(fileId)) {
        _selectedFiles.remove(fileId);
        final file = _allFiles.firstWhere((f) => f.id == fileId);
        SemanticsService.announce(
          '${file.name} deselected',
          TextDirection.ltr,
        );
      } else {
        if (widget.allowMultiple) {
          if (_selectedFiles.length < widget.maxSelections) {
            _selectedFiles.add(fileId);
            final file = _allFiles.firstWhere((f) => f.id == fileId);
            SemanticsService.announce(
              '${file.name} selected',
              TextDirection.ltr,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Maximum ${widget.maxSelections} files can be selected',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
            SemanticsService.announce(
              'Maximum ${widget.maxSelections} files can be selected',
              TextDirection.ltr,
            );
          }
        } else {
          _selectedFiles.clear();
          _selectedFiles.add(fileId);
          final file = _allFiles.firstWhere((f) => f.id == fileId);
          SemanticsService.announce(
            '${file.name} selected',
            TextDirection.ltr,
          );
        }
      }
    });
  }

  Future<void> _capturePhoto() async {
    // In a real implementation, use image_picker package
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera'),
        content: const Text('Camera capture will be implemented with image_picker package.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    // In a real implementation, use image_picker package
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gallery'),
        content: const Text('Gallery picker will be implemented with image_picker package.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDocument() async {
    // In a real implementation, use file_picker package
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Documents'),
        content: const Text('Document picker will be implemented with file_picker package.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one file'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      SemanticsService.announce(
        'Please select at least one file',
        TextDirection.ltr,
      );
      return;
    }

    final selectedFileObjects = _allFiles
        .where((f) => _selectedFiles.contains(f.id))
        .toList();

    context.pop(selectedFileObjects);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedFiles.isEmpty
              ? 'Select Attachments'
              : '${_selectedFiles.length} selected',
        ),
        actions: [
          if (_selectedFiles.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _selectedFiles.clear());
              },
              child: const Text('Clear'),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search files...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),

              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: AttachmentCategory.values.map((category) {
                  return Tab(
                    icon: Icon(category.icon, size: 20),
                    text: category.label,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 600 : double.infinity,
          child: Column(
            children: [
          // Quick actions
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: AppColors.zeusGradient.scale(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: _capturePhoto,
                ),
                _buildQuickAction(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: _pickFromGallery,
                ),
                _buildQuickAction(
                  icon: Icons.folder,
                  label: 'Files',
                  onTap: _pickDocument,
                ),
              ],
            ),
          ),

          // File list
          Expanded(
            child: _filteredFiles.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _filteredFiles.length,
                    itemBuilder: (context, index) {
                      final file = _filteredFiles[index];
                      final isSelected = _selectedFiles.contains(file.id);

                      return _buildFileCard(file, isSelected);
                    },
                  ),
          ),
        ],
      ),  // Close Column
    ),  // Close ResponsiveCenter
  ),  // Close SafeArea
      bottomNavigationBar: _selectedFiles.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: _confirmSelection,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    'Attach ${_selectedFiles.length} ${_selectedFiles.length == 1 ? "file" : "files"}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: label,
      button: true,
      hint: 'Open $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelSmall(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileCard(AttachableFile file, bool isSelected) {
    return Semantics(
      label: '${file.name}. ${file.extension} file. ${file.formattedSize}. ${isSelected ? "Selected" : "Not selected"}',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _toggleFileSelection(file.id),
        child: Card(
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail or icon
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: file.thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                file.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFileIcon(file);
                                },
                              ),
                            )
                          : _buildFileIcon(file),
                    ),

                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),

                    // File extension badge
                    if (file.extension.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            file.extension,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // File info
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: AppTextStyles.bodySmall().copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (file.formattedSize.isNotEmpty)
                      Text(
                        file.formattedSize,
                        style: AppTextStyles.labelSmall().copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(AttachableFile file) {
    return Center(
      child: Icon(
        file.fileIcon,
        size: 48,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.zeusGradient.scale(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedCategory.icon,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No ${_selectedCategory.label} Found',
              style: AppTextStyles.h4().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No files match your search query.\nTry a different search term.'
                  : 'There are no files in this category yet.\nUse the quick actions above to add files.',
              style: AppTextStyles.bodyMedium().copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
