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

/// Share format options
enum ShareFormat {
  text,
  markdown,
  json,
  html,
}

extension ShareFormatExtension on ShareFormat {
  String get label {
    switch (this) {
      case ShareFormat.text:
        return 'Plain Text';
      case ShareFormat.markdown:
        return 'Markdown';
      case ShareFormat.json:
        return 'JSON';
      case ShareFormat.html:
        return 'HTML';
    }
  }

  IconData get icon {
    switch (this) {
      case ShareFormat.text:
        return Icons.text_snippet;
      case ShareFormat.markdown:
        return Icons.description;
      case ShareFormat.json:
        return Icons.data_object;
      case ShareFormat.html:
        return Icons.html;
    }
  }
}

/// Share options configuration
class ShareOptions {
  const ShareOptions({
    this.includeAttachments = true,
    this.includeSystemMessages = false,
    this.includeTimestamps = true,
    this.format = ShareFormat.text,
    this.messageRange = const MessageRange.all(),
  });

  final bool includeAttachments;
  final bool includeSystemMessages;
  final bool includeTimestamps;
  final ShareFormat format;
  final MessageRange messageRange;

  ShareOptions copyWith({
    bool? includeAttachments,
    bool? includeSystemMessages,
    bool? includeTimestamps,
    ShareFormat? format,
    MessageRange? messageRange,
  }) {
    return ShareOptions(
      includeAttachments: includeAttachments ?? this.includeAttachments,
      includeSystemMessages: includeSystemMessages ?? this.includeSystemMessages,
      includeTimestamps: includeTimestamps ?? this.includeTimestamps,
      format: format ?? this.format,
      messageRange: messageRange ?? this.messageRange,
    );
  }
}

/// Message range for sharing
class MessageRange {
  const MessageRange.all()
      : start = null,
        end = null,
        type = MessageRangeType.all;

  const MessageRange.custom(this.start, this.end)
      : type = MessageRangeType.custom;

  final int? start;
  final int? end;
  final MessageRangeType type;

  String getLabel(int totalMessages) {
    switch (type) {
      case MessageRangeType.all:
        return 'All messages ($totalMessages)';
      case MessageRangeType.custom:
        return 'Messages $start - $end';
    }
  }
}

enum MessageRangeType {
  all,
  custom,
}

/// Screen for sharing conversations with various options
class ConversationShareScreen extends ConsumerStatefulWidget {
  const ConversationShareScreen({
    required this.conversationId,
    required this.conversationTitle,
    this.totalMessages = 0,
    super.key,
  });

  final String conversationId;
  final String conversationTitle;
  final int totalMessages;

  @override
  ConsumerState<ConversationShareScreen> createState() =>
      _ConversationShareScreenState();
}

class _ConversationShareScreenState
    extends ConsumerState<ConversationShareScreen> {
  ShareOptions _options = const ShareOptions();
  String? _generatedLink;
  bool _isGeneratingLink = false;

  @override
  void initState() {
    super.initState();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Share Conversation');
    });
  }

  Future<void> _generateShareLink() async {
    setState(() => _isGeneratingLink = true);

    // Simulate link generation
    await Future.delayed(const Duration(seconds: 1));

    // In a real implementation, this would create a shareable link
    // using Firebase Dynamic Links or a custom backend
    final link = 'https://zeusgpt.app/shared/${widget.conversationId}';

    setState(() {
      _generatedLink = link;
      _isGeneratingLink = false;
    });
  }

  Future<void> _copyLink() async {
    if (_generatedLink == null) return;

    await Clipboard.setData(ClipboardData(text: _generatedLink!));

    if (mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Link copied to clipboard',
      );
    }
  }

  Future<void> _shareVia(String platform) async {
    // In a real implementation, use share_plus package
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share via $platform'),
        content: Text(
          'Sharing to $platform will be implemented with share_plus package.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
          return _SharePreviewSheet(
            options: _options,
            conversationTitle: widget.conversationTitle,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  void _confirmShare() {
    // In a real implementation, generate the shareable content
    // based on options and share it

    showAccessibleSuccessSnackBar(
      context,
      'Conversation shared successfully',
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Conversation'),
        actions: [
          TextButton.icon(
            onPressed: _showPreview,
            icon: const Icon(Icons.visibility),
            label: const Text('Preview'),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: AppColors.zeusGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 32,
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
            ),

            const SizedBox(height: AppSpacing.xl),

            // Share format
            _buildSectionHeader('Share Format'),
            const SizedBox(height: AppSpacing.md),
            _buildFormatSelector(),

            const SizedBox(height: AppSpacing.xl),

            // Privacy options
            _buildSectionHeader('Privacy Options'),
            const SizedBox(height: AppSpacing.md),
            _buildPrivacyOptions(),

            const SizedBox(height: AppSpacing.xl),

            // Message range
            _buildSectionHeader('Message Range'),
            const SizedBox(height: AppSpacing.md),
            _buildMessageRangeSelector(),

            const SizedBox(height: AppSpacing.xl),

            // Share link section
            _buildSectionHeader('Share Link'),
            const SizedBox(height: AppSpacing.md),
            _buildShareLinkSection(),

            const SizedBox(height: AppSpacing.xl),

            // Quick share platforms
            _buildSectionHeader('Quick Share'),
            const SizedBox(height: AppSpacing.md),
            _buildQuickSharePlatforms(),

            const SizedBox(height: AppSpacing.xl),
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
            onPressed: _confirmShare,
            icon: const Icon(Icons.share),
            label: const Text('Share Conversation'),
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
        children: ShareFormat.values.map((format) {
          return RadioListTile<ShareFormat>(
            value: format,
            groupValue: _options.format,
            title: Row(
              children: [
                Icon(format.icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(format.label),
              ],
            ),
            onChanged: (value) {
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

  Widget _buildPrivacyOptions() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Include Attachments'),
            subtitle: const Text('Share images, files, and other attachments'),
            value: _options.includeAttachments,
            onChanged: (value) {
              setState(() {
                _options = _options.copyWith(includeAttachments: value);
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Include System Messages'),
            subtitle: const Text('Share system notifications and info messages'),
            value: _options.includeSystemMessages,
            onChanged: (value) {
              setState(() {
                _options = _options.copyWith(includeSystemMessages: value);
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Include Timestamps'),
            subtitle: const Text('Show message send times'),
            value: _options.includeTimestamps,
            onChanged: (value) {
              setState(() {
                _options = _options.copyWith(includeTimestamps: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRangeSelector() {
    return Card(
      child: Column(
        children: [
          RadioListTile<MessageRangeType>(
            value: MessageRangeType.all,
            groupValue: _options.messageRange.type,
            title: Text(
              _options.messageRange.getLabel(widget.totalMessages),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _options = _options.copyWith(
                    messageRange: const MessageRange.all(),
                  );
                });
              }
            },
          ),
          const Divider(height: 1),
          RadioListTile<MessageRangeType>(
            value: MessageRangeType.custom,
            groupValue: _options.messageRange.type,
            title: const Text('Custom Range'),
            subtitle: const Text('Select specific message range'),
            onChanged: (value) {
              if (value != null) {
                // Show range picker dialog
                _showRangePicker();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showRangePicker() async {
    // In a real implementation, show a range picker dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Message Range'),
        content: const Text(
          'Range picker will be implemented with proper range selection UI.',
        ),
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
                  messageRange: const MessageRange.custom(1, 50),
                );
              });
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildShareLinkSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Generate Shareable Link',
                  style: AppTextStyles.bodyLarge().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create a secure link that others can use to view this conversation',
              style: AppTextStyles.bodySmall().copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_generatedLink != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _generatedLink!,
                        style: AppTextStyles.bodySmall().copyWith(
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SemanticIconButton(
                      icon: Icons.copy,
                      label: 'Copy link to clipboard',
                      onPressed: _copyLink,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingLink ? null : _generateShareLink,
                icon: _isGeneratingLink
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.link),
                label: Text(
                  _generatedLink != null ? 'Regenerate Link' : 'Generate Link',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSharePlatforms() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlatformButton(
                  icon: Icons.message,
                  label: 'Messages',
                  onTap: () => _shareVia('Messages'),
                ),
                _buildPlatformButton(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () => _shareVia('Email'),
                ),
                _buildPlatformButton(
                  icon: Icons.content_copy,
                  label: 'Copy',
                  onTap: () => _shareVia('Clipboard'),
                ),
                _buildPlatformButton(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () => _shareVia('System Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: 'Share via $label',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: AppColors.zeusGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ExcludeSemantics(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Share preview bottom sheet
class _SharePreviewSheet extends StatelessWidget {
  const _SharePreviewSheet({
    required this.options,
    required this.conversationTitle,
    required this.scrollController,
  });

  final ShareOptions options;
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
              Container(
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
              const SizedBox(width: AppSpacing.md),
              Text(
                'Share Preview',
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
                      conversationTitle,
                      style: AppTextStyles.h4().copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Format: ${options.format.label}',
                      style: AppTextStyles.bodySmall(),
                    ),
                    Text(
                      'Messages: ${options.messageRange.getLabel(0)}',
                      style: AppTextStyles.bodySmall(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Preview of shared conversation content will appear here...',
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
