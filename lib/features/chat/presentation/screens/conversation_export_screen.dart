import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';

/// Export format options
enum ExportFormat {
  txt,
  markdown,
  pdf,
  json,
  html,
  csv,
}

extension ExportFormatExtension on ExportFormat {
  String get label {
    switch (this) {
      case ExportFormat.txt:
        return 'Plain Text (.txt)';
      case ExportFormat.markdown:
        return 'Markdown (.md)';
      case ExportFormat.pdf:
        return 'PDF (.pdf)';
      case ExportFormat.json:
        return 'JSON (.json)';
      case ExportFormat.html:
        return 'HTML (.html)';
      case ExportFormat.csv:
        return 'CSV (.csv)';
    }
  }

  String get extension {
    return name;
  }

  IconData get icon {
    switch (this) {
      case ExportFormat.txt:
        return Icons.text_snippet;
      case ExportFormat.markdown:
        return Icons.description;
      case ExportFormat.pdf:
        return Icons.picture_as_pdf;
      case ExportFormat.json:
        return Icons.data_object;
      case ExportFormat.html:
        return Icons.html;
      case ExportFormat.csv:
        return Icons.table_chart;
    }
  }

  String get description {
    switch (this) {
      case ExportFormat.txt:
        return 'Simple plain text format';
      case ExportFormat.markdown:
        return 'Formatted markdown with syntax';
      case ExportFormat.pdf:
        return 'Portable document format';
      case ExportFormat.json:
        return 'Structured data format';
      case ExportFormat.html:
        return 'Web page format';
      case ExportFormat.csv:
        return 'Spreadsheet compatible format';
    }
  }
}

/// Export scope
enum ExportScope {
  all,
  dateRange,
  lastN,
}

/// Export options configuration
class ExportOptions {
  const ExportOptions({
    this.format = ExportFormat.txt,
    this.scope = ExportScope.all,
    this.includeAttachments = false,
    this.includeMetadata = true,
    this.includeSystemMessages = false,
    this.includeTimestamps = true,
    this.fileName,
    this.dateRangeStart,
    this.dateRangeEnd,
    this.lastNMessages,
  });

  final ExportFormat format;
  final ExportScope scope;
  final bool includeAttachments;
  final bool includeMetadata;
  final bool includeSystemMessages;
  final bool includeTimestamps;
  final String? fileName;
  final DateTime? dateRangeStart;
  final DateTime? dateRangeEnd;
  final int? lastNMessages;

  ExportOptions copyWith({
    ExportFormat? format,
    ExportScope? scope,
    bool? includeAttachments,
    bool? includeMetadata,
    bool? includeSystemMessages,
    bool? includeTimestamps,
    String? fileName,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
    int? lastNMessages,
  }) {
    return ExportOptions(
      format: format ?? this.format,
      scope: scope ?? this.scope,
      includeAttachments: includeAttachments ?? this.includeAttachments,
      includeMetadata: includeMetadata ?? this.includeMetadata,
      includeSystemMessages: includeSystemMessages ?? this.includeSystemMessages,
      includeTimestamps: includeTimestamps ?? this.includeTimestamps,
      fileName: fileName ?? this.fileName,
      dateRangeStart: dateRangeStart ?? this.dateRangeStart,
      dateRangeEnd: dateRangeEnd ?? this.dateRangeEnd,
      lastNMessages: lastNMessages ?? this.lastNMessages,
    );
  }

  String get estimatedSize {
    // Simplified estimation
    const baseSize = 50; // KB base
    var size = baseSize;

    if (includeAttachments) size += 200;
    if (includeMetadata) size += 20;

    return '~${size}KB';
  }
}

/// Screen for exporting conversations in various formats
class ConversationExportScreen extends ConsumerStatefulWidget {
  const ConversationExportScreen({
    required this.conversationId,
    required this.conversationTitle,
    this.totalMessages = 0,
    super.key,
  });

  final String conversationId;
  final String conversationTitle;
  final int totalMessages;

  @override
  ConsumerState<ConversationExportScreen> createState() =>
      _ConversationExportScreenState();
}

class _ConversationExportScreenState
    extends ConsumerState<ConversationExportScreen> {
  late ExportOptions _options;
  final TextEditingController _fileNameController = TextEditingController();
  bool _isExporting = false;
  double _exportProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _options = ExportOptions(
      fileName: _generateFileName(),
    );
    _fileNameController.text = _options.fileName!;

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Export Conversation');
    });
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  String _generateFileName() {
    final date = DateTime.now();
    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final title = widget.conversationTitle.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    return '${title}_$dateStr';
  }

  Future<void> _startExport() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
    });

    // Update file name from controller
    _options = _options.copyWith(fileName: _fileNameController.text);

    // Simulate export process
    for (var i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() => _exportProgress = i / 100);
      }
    }

    if (mounted) {
      setState(() => _isExporting = false);

      showAccessibleSuccessSnackBar(
        context,
        'Exported as ${_options.fileName}.${_options.format.extension}',
      );

      context.pop();
    }
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return _ExportPreviewSheet(
            options: _options,
            conversationTitle: widget.conversationTitle,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Conversation'),
        actions: [
          Semantics(
            button: true,
            label: 'Preview export',
            child: TextButton.icon(
              onPressed: _isExporting ? null : _showPreview,
              icon: const Icon(Icons.visibility),
              label: const Text('Preview'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 600 : double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Header card
            _buildHeaderCard(),

            const SizedBox(height: AppSpacing.xl),

            // Export format
            _buildSectionHeader('Export Format'),
            const SizedBox(height: AppSpacing.md),
            _buildFormatSelector(),

            const SizedBox(height: AppSpacing.xl),

            // File name
            _buildSectionHeader('File Name'),
            const SizedBox(height: AppSpacing.md),
            _buildFileNameInput(),

            const SizedBox(height: AppSpacing.xl),

            // Export scope
            _buildSectionHeader('Export Scope'),
            const SizedBox(height: AppSpacing.md),
            _buildScopeSelector(),

            const SizedBox(height: AppSpacing.xl),

            // Include options
            _buildSectionHeader('Include Options'),
            const SizedBox(height: AppSpacing.md),
            _buildIncludeOptions(),

            const SizedBox(height: AppSpacing.xl),

            // Export info
            _buildExportInfo(),

            const SizedBox(height: AppSpacing.xl),

            // Export progress
            if (_isExporting) _buildExportProgress(),
          ],
        ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
            onPressed: _isExporting ? null : _startExport,
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
            label: Text(_isExporting ? 'Exporting...' : 'Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Semantics(
              label: 'Export icon',
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversationTitle,
                    style: AppTextStyles.bodyLarge().copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.totalMessages} messages',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h4().copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Card(
      child: Column(
        children: ExportFormat.values.map((format) {
          return RadioListTile<ExportFormat>(
            value: format,
            groupValue: _options.format,
            title: Row(
              children: [
                Icon(format.icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(format.label),
              ],
            ),
            subtitle: Text(format.description),
            onChanged: _isExporting
                ? null
                : (value) {
                    if (value != null) {
                      setState(() {
                        _options = _options.copyWith(format: value);
                      });
                    }
                  },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFileNameInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fileNameController,
              enabled: !_isExporting,
              decoration: InputDecoration(
                labelText: 'File name',
                suffixText: '.${_options.format.extension}',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Full name: ${_fileNameController.text}.${_options.format.extension}',
              style: AppTextStyles.bodySmall().copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeSelector() {
    return Card(
      child: Column(
        children: [
          RadioListTile<ExportScope>(
            value: ExportScope.all,
            groupValue: _options.scope,
            title: const Text('All Messages'),
            subtitle: Text('Export all ${widget.totalMessages} messages'),
            onChanged: _isExporting
                ? null
                : (value) {
                    if (value != null) {
                      setState(() {
                        _options = _options.copyWith(scope: value);
                      });
                    }
                  },
          ),
          const Divider(height: 1),
          RadioListTile<ExportScope>(
            value: ExportScope.dateRange,
            groupValue: _options.scope,
            title: const Text('Date Range'),
            subtitle: const Text('Select specific date range'),
            onChanged: _isExporting
                ? null
                : (value) {
                    if (value != null) {
                      // Show date picker
                      _showDateRangePicker();
                    }
                  },
          ),
          const Divider(height: 1),
          RadioListTile<ExportScope>(
            value: ExportScope.lastN,
            groupValue: _options.scope,
            title: const Text('Last N Messages'),
            subtitle: const Text('Export most recent messages'),
            onChanged: _isExporting
                ? null
                : (value) {
                    if (value != null) {
                      // Show number picker
                      _showMessageCountPicker();
                    }
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    // In a real implementation, show date range picker
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Range'),
        content: const Text('Date range picker will be implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _options = _options.copyWith(
                  scope: ExportScope.dateRange,
                  dateRangeStart: DateTime.now().subtract(const Duration(days: 7)),
                  dateRangeEnd: DateTime.now(),
                );
              });
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMessageCountPicker() async {
    // In a real implementation, show number picker
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Number of Messages'),
        content: const Text('Message count picker will be implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _options = _options.copyWith(
                  scope: ExportScope.lastN,
                  lastNMessages: 50,
                );
              });
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildIncludeOptions() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Include Attachments'),
            subtitle: const Text('Export images, files, and other attachments'),
            value: _options.includeAttachments,
            onChanged: _isExporting
                ? null
                : (value) {
                    setState(() {
                      _options = _options.copyWith(includeAttachments: value);
                    });
                  },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Include Metadata'),
            subtitle: const Text('Message IDs, model info, token counts'),
            value: _options.includeMetadata,
            onChanged: _isExporting
                ? null
                : (value) {
                    setState(() {
                      _options = _options.copyWith(includeMetadata: value);
                    });
                  },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Include System Messages'),
            subtitle: const Text('System notifications and info messages'),
            value: _options.includeSystemMessages,
            onChanged: _isExporting
                ? null
                : (value) {
                    setState(() {
                      _options = _options.copyWith(includeSystemMessages: value);
                    });
                  },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Include Timestamps'),
            subtitle: const Text('Message send times'),
            value: _options.includeTimestamps,
            onChanged: _isExporting
                ? null
                : (value) {
                    setState(() {
                      _options = _options.copyWith(includeTimestamps: value);
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildExportInfo() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(Icons.info_outline, color: Colors.blue.shade700),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Export Information',
                  style: AppTextStyles.bodyLarge().copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow('Format', _options.format.label),
            _buildInfoRow('Estimated Size', _options.estimatedSize),
            _buildInfoRow('Scope', _getScopeLabel()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall().copyWith(
              color: Colors.blue.shade700,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall().copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  String _getScopeLabel() {
    switch (_options.scope) {
      case ExportScope.all:
        return 'All messages';
      case ExportScope.dateRange:
        return 'Date range';
      case ExportScope.lastN:
        return 'Last ${_options.lastNMessages ?? 0} messages';
    }
  }

  Widget _buildExportProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exporting...',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(_exportProgress * 100).toInt()}%',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: _exportProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Export preview bottom sheet
class _ExportPreviewSheet extends StatelessWidget {
  const _ExportPreviewSheet({
    required this.options,
    required this.conversationTitle,
    required this.scrollController,
  });

  final ExportOptions options;
  final String conversationTitle;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: AppColors.zeusGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.visibility,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Export Preview',
                style: AppTextStyles.h4().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              SemanticIconButton(
                icon: Icons.close,
                label: 'Close preview',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Preview content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${options.fileName}.${options.format.extension}',
                      style: AppTextStyles.h4().copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      conversationTitle,
                      style: AppTextStyles.bodyLarge().copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Preview of exported content will appear here...',
                      style: AppTextStyles.bodyMedium().copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
