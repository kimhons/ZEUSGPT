import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/widgets/accessible_card.dart';
import '../../../../core/responsive.dart';

/// Markdown content data
class MarkdownContent {
  const MarkdownContent({
    required this.markdown,
    this.title,
    this.author,
    this.timestamp,
  });

  final String markdown;
  final String? title;
  final String? author;
  final DateTime? timestamp;

  int get wordCount => markdown.split(RegExp(r'\s+')).length;
  int get characterCount => markdown.length;
  int get lineCount => markdown.split('\n').length;
}

/// View mode for markdown display
enum MarkdownViewMode {
  rendered,
  raw,
  sideBySide,
}

extension MarkdownViewModeExtension on MarkdownViewMode {
  String get label {
    switch (this) {
      case MarkdownViewMode.rendered:
        return 'Rendered';
      case MarkdownViewMode.raw:
        return 'Raw';
      case MarkdownViewMode.sideBySide:
        return 'Side by Side';
    }
  }

  IconData get icon {
    switch (this) {
      case MarkdownViewMode.rendered:
        return Icons.visibility;
      case MarkdownViewMode.raw:
        return Icons.code;
      case MarkdownViewMode.sideBySide:
        return Icons.compare;
    }
  }
}

/// Screen for displaying markdown content with proper formatting
class MarkdownPreviewScreen extends ConsumerStatefulWidget {
  const MarkdownPreviewScreen({
    required this.content,
    super.key,
  });

  final MarkdownContent content;

  @override
  ConsumerState<MarkdownPreviewScreen> createState() =>
      _MarkdownPreviewScreenState();
}

class _MarkdownPreviewScreenState extends ConsumerState<MarkdownPreviewScreen>
    with SingleTickerProviderStateMixin {
  MarkdownViewMode _viewMode = MarkdownViewMode.rendered;
  bool _showStats = false;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Markdown Preview');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copyContent() async {
    await Clipboard.setData(ClipboardData(text: widget.content.markdown));

    if (mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Content copied to clipboard',
      );
    }
  }

  Future<void> _shareContent() async {
    // In a real implementation, use share_plus package
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Content'),
        content: const Text('Share functionality will be implemented with share_plus package.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportContent() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ExportBottomSheet(
        content: widget.content,
      ),
    );
  }

  void _toggleStats() {
    setState(() => _showStats = !_showStats);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.title ?? 'Markdown Preview'),
        actions: [
          SemanticIconButton(
            icon: _showStats ? Icons.analytics : Icons.analytics_outlined,
            label: _showStats ? 'Hide statistics' : 'Show statistics',
            onPressed: _toggleStats,
          ),
          SemanticIconButton(
            icon: Icons.copy,
            label: 'Copy markdown content',
            onPressed: _copyContent,
          ),
          SemanticIconButton(
            icon: Icons.share,
            label: 'Share markdown content',
            onPressed: _shareContent,
          ),
          Semantics(
            label: 'View mode menu',
            hint: 'Change how markdown is displayed',
            child: PopupMenuButton<MarkdownViewMode>(
              icon: const Icon(Icons.more_vert),
              initialValue: _viewMode,
              onSelected: (mode) {
                setState(() => _viewMode = mode);
              },
              itemBuilder: (context) => MarkdownViewMode.values.map((mode) {
                return PopupMenuItem(
                  value: mode,
                  child: Row(
                    children: [
                      Icon(mode.icon, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(mode.label),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1000 : double.infinity,
          child: Column(
            children: [
            // Stats bar
            if (_showStats) _buildStatsBar(),

            // Content
            Expanded(
              child: _buildContent(isDark),
            ),
          ],
      ),  // Close Column
    ),  // Close ResponsiveCenter
  ),  // Close SafeArea
      floatingActionButton: Semantics(
        label: 'Export markdown content',
        hint: 'Choose export format',
        button: true,
        child: FloatingActionButton.extended(
          onPressed: _exportContent,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
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
          _buildStatItem(
            icon: Icons.text_fields,
            label: 'Words',
            value: widget.content.wordCount.toString(),
          ),
          _buildStatItem(
            icon: Icons.abc,
            label: 'Characters',
            value: widget.content.characterCount.toString(),
          ),
          _buildStatItem(
            icon: Icons.format_list_numbered,
            label: 'Lines',
            value: widget.content.lineCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium().copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall().copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(bool isDark) {
    switch (_viewMode) {
      case MarkdownViewMode.rendered:
        return _buildRenderedView(isDark);
      case MarkdownViewMode.raw:
        return _buildRawView(isDark);
      case MarkdownViewMode.sideBySide:
        return _buildSideBySideView(isDark);
    }
  }

  Widget _buildRenderedView(bool isDark) {
    // In a real implementation, use flutter_markdown package
    // For now, showing a simplified version
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          if (widget.content.author != null || widget.content.timestamp != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      if (widget.content.author != null) ...[
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            widget.content.author![0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.content.author!,
                                style: AppTextStyles.bodyMedium().copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.content.timestamp != null)
                                Text(
                                  _formatTimestamp(widget.content.timestamp!),
                                  style: AppTextStyles.bodySmall().copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // Markdown content note
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Full markdown rendering will be implemented with flutter_markdown package',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Show formatted markdown text as placeholder
          Text(
            widget.content.markdown,
            style: AppTextStyles.bodyMedium(),
          ),
        ],
      ),
    );
  }

  Widget _buildRawView(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SelectableText(
          widget.content.markdown,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSideBySideView(bool isDark) {
    return Row(
      children: [
        // Raw view
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.code, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Raw Markdown',
                      style: AppTextStyles.labelSmall().copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      widget.content.markdown,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 2,
          color: Colors.grey.shade300,
        ),

        // Rendered view
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Rendered',
                      style: AppTextStyles.labelSmall().copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    widget.content.markdown,
                    style: AppTextStyles.bodyMedium(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Export options bottom sheet
class _ExportBottomSheet extends StatelessWidget {
  const _ExportBottomSheet({
    required this.content,
  });

  final MarkdownContent content;

  Future<void> _exportAs(BuildContext context, String format) async {
    Navigator.pop(context);

    // In a real implementation, use file_saver or path_provider
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Exported as $format',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Export Options',
                style: AppTextStyles.h4().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Export formats
          _ExportOption(
            icon: Icons.description,
            title: 'Markdown (.md)',
            description: 'Export as markdown file',
            onTap: () => _exportAs(context, 'Markdown'),
          ),
          _ExportOption(
            icon: Icons.text_snippet,
            title: 'Plain Text (.txt)',
            description: 'Export as plain text file',
            onTap: () => _exportAs(context, 'Plain Text'),
          ),
          _ExportOption(
            icon: Icons.html,
            title: 'HTML (.html)',
            description: 'Export as HTML file',
            onTap: () => _exportAs(context, 'HTML'),
          ),
          _ExportOption(
            icon: Icons.picture_as_pdf,
            title: 'PDF (.pdf)',
            description: 'Export as PDF document',
            onTap: () => _exportAs(context, 'PDF'),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Export option tile
class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AccessibleListItem(
      label: '$title, $description',
      onTap: onTap,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium().copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
