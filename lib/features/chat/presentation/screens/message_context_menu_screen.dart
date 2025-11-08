import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/message_model.dart';
import '../providers/conversation_provider.dart';
import '../../../../core/widgets/accessible_card.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';

/// Context menu options for a message
enum MessageAction {
  copy,
  edit,
  delete,
  regenerate,
  share,
  pin,
  viewHistory,
  viewDetails,
  report,
}

/// Message context menu screen shown as bottom sheet
class MessageContextMenuScreen extends ConsumerStatefulWidget {
  const MessageContextMenuScreen({
    required this.conversationId,
    required this.message,
    super.key,
  });

  final String conversationId;
  final MessageModel message;

  @override
  ConsumerState<MessageContextMenuScreen> createState() =>
      _MessageContextMenuScreenState();
}

class _MessageContextMenuScreenState
    extends ConsumerState<MessageContextMenuScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Announce modal opening for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messageType = widget.message.role == 'user' ? 'your message' : 'AI response';
      announcePageChange('Message options for $messageType');
    });
  }

  Future<void> _handleAction(MessageAction action) async {
    switch (action) {
      case MessageAction.copy:
        await _copyMessage();
        break;
      case MessageAction.edit:
        _editMessage();
        break;
      case MessageAction.delete:
        await _deleteMessage();
        break;
      case MessageAction.regenerate:
        await _regenerateResponse();
        break;
      case MessageAction.share:
        _shareMessage();
        break;
      case MessageAction.pin:
        await _pinMessage();
        break;
      case MessageAction.viewHistory:
        _viewHistory();
        break;
      case MessageAction.viewDetails:
        _viewDetails();
        break;
      case MessageAction.report:
        _reportMessage();
        break;
    }
  }

  Future<void> _copyMessage() async {
    await Clipboard.setData(ClipboardData(text: widget.message.content));

    if (mounted) {
      Navigator.pop(context);
      showAccessibleSuccessSnackBar(
        context,
        'Message copied to clipboard',
      );
    }
  }

  void _editMessage() {
    Navigator.pop(context);
    context.push(
      '/conversation/${widget.conversationId}/message/${widget.message.messageId}/edit',
    );
  }

  Future<void> _deleteMessage() async {
    Navigator.pop(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
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

    if (confirmed == true && mounted) {
      setState(() => _isProcessing = true);

      try {
        await ref
            .read(conversationProvider(widget.conversationId).notifier)
            .deleteMessage(widget.message.messageId);

        if (mounted) {
          showAccessibleSnackBar(
            context,
            'Message deleted',
          );
        }
      } catch (e) {
        if (mounted) {
          showAccessibleErrorSnackBar(
            context,
            'Failed to delete message: $e',
          );
        }
      } finally{
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _regenerateResponse() async {
    Navigator.pop(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Response'),
        content: const Text(
          'This will generate a new AI response. The current response will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      showAccessibleSnackBar(
        context,
        'Regenerating response...',
      );

      // TODO: Implement regeneration logic
      // This would involve:
      // 1. Getting the previous user message
      // 2. Calling the AI API again
      // 3. Replacing the current assistant message
    }
  }

  void _shareMessage() {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Message'),
        content: const Text('Choose how to share this message:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _copyMessage();
            },
            child: const Text('Copy to Clipboard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showAccessibleSnackBar(
                context,
                'Share via... (Not implemented yet)',
              );
            },
            child: const Text('Share via...'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pinMessage() async {
    setState(() => _isProcessing = true);

    try {
      final updatedMessage = widget.message.copyWith(
        isPinned: !widget.message.isPinned,
      );

      await ref
          .read(conversationProvider(widget.conversationId).notifier)
          .updateMessage(updatedMessage);

      if (mounted) {
        Navigator.pop(context);
        showAccessibleSuccessSnackBar(
          context,
          widget.message.isPinned
              ? 'Message unpinned'
              : 'Message pinned',
        );
      }
    } catch (e) {
      if (mounted) {
        showAccessibleErrorSnackBar(
          context,
          'Failed to pin message: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _viewHistory() {
    Navigator.pop(context);
    context.push(
      '/conversation/${widget.conversationId}/message/${widget.message.messageId}/history',
    );
  }

  void _viewDetails() {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => _MessageDetailsDialog(message: widget.message),
    );
  }

  void _reportMessage() {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Why are you reporting this message?'),
            const SizedBox(height: AppSpacing.md),
            AccessibleListItem(
              label: 'Report for inappropriate content',
              onTap: () {
                Navigator.pop(context);
                _submitReport('Inappropriate content');
              },
              child: ListTile(
                title: const Text('Inappropriate content'),
                onTap: () {
                  Navigator.pop(context);
                  _submitReport('Inappropriate content');
                },
              ),
            ),
            AccessibleListItem(
              label: 'Report for inaccurate information',
              onTap: () {
                Navigator.pop(context);
                _submitReport('Inaccurate information');
              },
              child: ListTile(
                title: const Text('Inaccurate information'),
                onTap: () {
                  Navigator.pop(context);
                  _submitReport('Inaccurate information');
                },
              ),
            ),
            AccessibleListItem(
              label: 'Report as harmful or dangerous',
              onTap: () {
                Navigator.pop(context);
                _submitReport('Harmful or dangerous');
              },
              child: ListTile(
                title: const Text('Harmful or dangerous'),
                onTap: () {
                  Navigator.pop(context);
                  _submitReport('Harmful or dangerous');
                },
              ),
            ),
            AccessibleListItem(
              label: 'Report for other reason',
              onTap: () {
                Navigator.pop(context);
                _submitReport('Other');
              },
              child: ListTile(
                title: const Text('Other'),
                onTap: () {
                  Navigator.pop(context);
                  _submitReport('Other');
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(String reason) async {
    // TODO: Implement report submission
    showAccessibleSuccessSnackBar(
      context,
      'Report submitted: $reason',
    );
  }

  List<MessageAction> _getAvailableActions() {
    final actions = <MessageAction>[
      MessageAction.copy,
    ];

    if (widget.message.role == 'user') {
      actions.addAll([
        MessageAction.edit,
        MessageAction.delete,
      ]);
    }

    if (widget.message.role == 'assistant') {
      actions.addAll([
        MessageAction.regenerate,
        MessageAction.report,
      ]);
    }

    actions.addAll([
      MessageAction.share,
      MessageAction.pin,
    ]);

    if (widget.message.isEdited) {
      actions.add(MessageAction.viewHistory);
    }

    actions.add(MessageAction.viewDetails);

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableActions = _getAvailableActions();

    return ResponsiveCenter(
      maxWidth: context.isDesktop ? 600 : double.infinity,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
        color: isDark ? AppColors.surface(true) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Row(
            children: [
              Semantics(
                label: widget.message.role == 'user' ? 'User message' : 'AI message',
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: AppColors.zeusGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.message.role == 'user'
                        ? Icons.person
                        : Icons.smart_toy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.role == 'user' ? 'Your Message' : 'AI Response',
                      style: AppTextStyles.h4().copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimestamp(widget.message.timestamp),
                      style: AppTextStyles.labelSmall().copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Message preview
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surface(false)
                  : AppColors.surface(true).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.message.content,
              style: AppTextStyles.bodySmall(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Actions
          if (_isProcessing)
            const Center(child: CircularProgressIndicator())
          else
            ...availableActions.map((action) => _buildActionTile(
                  context,
                  action,
                  isDark,
                )),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),  // Close Container
    );  // Close ResponsiveCenter
  }

  Widget _buildActionTile(
    BuildContext context,
    MessageAction action,
    bool isDark,
  ) {
    final config = _getActionConfig(action);

    final semanticLabel = config.subtitle != null
        ? '${config.label}, ${config.subtitle}'
        : config.label;

    return AccessibleListItem(
      label: semanticLabel,
      onTap: () => _handleAction(action),
      child: ListTile(
        leading: Icon(config.icon, color: config.color),
        title: Text(config.label),
        subtitle: config.subtitle != null ? Text(config.subtitle!) : null,
        onTap: () => _handleAction(action),
      ),
    );
  }

  _ActionConfig _getActionConfig(MessageAction action) {
    switch (action) {
      case MessageAction.copy:
        return const _ActionConfig(
          icon: Icons.copy,
          label: 'Copy',
          color: Colors.blue,
        );
      case MessageAction.edit:
        return const _ActionConfig(
          icon: Icons.edit,
          label: 'Edit',
          color: Colors.orange,
        );
      case MessageAction.delete:
        return const _ActionConfig(
          icon: Icons.delete_outline,
          label: 'Delete',
          color: Colors.red,
          subtitle: 'This cannot be undone',
        );
      case MessageAction.regenerate:
        return const _ActionConfig(
          icon: Icons.refresh,
          label: 'Regenerate Response',
          color: Colors.purple,
        );
      case MessageAction.share:
        return const _ActionConfig(
          icon: Icons.share,
          label: 'Share',
          color: Colors.green,
        );
      case MessageAction.pin:
        return _ActionConfig(
          icon: widget.message.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          label: widget.message.isPinned ? 'Unpin' : 'Pin',
          color: Colors.amber,
        );
      case MessageAction.viewHistory:
        return const _ActionConfig(
          icon: Icons.history,
          label: 'View Edit History',
          color: Colors.cyan,
        );
      case MessageAction.viewDetails:
        return const _ActionConfig(
          icon: Icons.info_outline,
          label: 'View Details',
          color: Colors.grey,
        );
      case MessageAction.report:
        return const _ActionConfig(
          icon: Icons.flag_outlined,
          label: 'Report',
          color: Colors.red,
          subtitle: 'Report inappropriate content',
        );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
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

/// Action configuration
class _ActionConfig {
  const _ActionConfig({
    required this.icon,
    required this.label,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String? subtitle;
}

/// Message details dialog
class _MessageDetailsDialog extends StatelessWidget {
  const _MessageDetailsDialog({required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Message Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Message ID', message.messageId),
            _buildDetailRow('Role', message.role.name),
            _buildDetailRow('Created', _formatDateTime(message.timestamp)),
            if (message.isEdited && message.editedAt != null)
              _buildDetailRow('Edited', _formatDateTime(message.editedAt!)),
            if (message.tokenCount != null)
              _buildDetailRow('Tokens', message.tokenCount.toString()),
            _buildDetailRow(
              'Character Count',
              message.content.length.toString(),
            ),
            _buildDetailRow(
              'Word Count',
              message.content.split(RegExp(r'\s+')).length.toString(),
            ),
            if (message.metadata != null && message.metadata!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    'Metadata',
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...message.metadata!.entries.map(
                    (entry) => _buildDetailRow(entry.key, entry.value.toString()),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Helper function to show message context menu
Future<void> showMessageContextMenu({
  required BuildContext context,
  required String conversationId,
  required MessageModel message,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MessageContextMenuScreen(
      conversationId: conversationId,
      message: message,
    ),
  );
}
