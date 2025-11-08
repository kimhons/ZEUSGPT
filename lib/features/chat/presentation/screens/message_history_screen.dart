import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/widgets/accessible_card.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';
import '../../data/models/message_model.dart';
import '../providers/conversation_provider.dart';

/// Message edit history entry
class MessageHistoryEntry {
  const MessageHistoryEntry({
    required this.content,
    required this.editedAt,
    required this.version,
  });

  final String content;
  final DateTime editedAt;
  final int version;
}

/// Screen displaying the edit history of a message
class MessageHistoryScreen extends ConsumerStatefulWidget {
  const MessageHistoryScreen({
    required this.conversationId,
    required this.messageId,
    super.key,
  });

  final String conversationId;
  final String messageId;

  @override
  ConsumerState<MessageHistoryScreen> createState() =>
      _MessageHistoryScreenState();
}

class _MessageHistoryScreenState extends ConsumerState<MessageHistoryScreen> {
  int _selectedVersion = 0;
  bool _showComparison = false;

  @override
  void initState() {
    super.initState();
    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Edit History');
    });
  }

  List<MessageHistoryEntry> _getMessageHistory(MessageModel message) {
    // In a real implementation, this would fetch the history from Firestore
    // For now, we'll simulate it
    final history = <MessageHistoryEntry>[];

    // Add current version
    history.add(MessageHistoryEntry(
      content: message.content,
      editedAt: message.editedAt ?? message.timestamp,
      version: 0,
    ));

    // Add previous versions from metadata if available
    if (message.metadata != null && message.metadata!.containsKey('history')) {
      final historyData = message.metadata!['history'] as List<dynamic>;
      for (var i = 0; i < historyData.length; i++) {
        final entry = historyData[i] as Map<String, dynamic>;
        history.add(MessageHistoryEntry(
          content: entry['content'] as String,
          editedAt: DateTime.parse(entry['editedAt'] as String),
          version: i + 1,
        ));
      }
    }

    return history;
  }

  Future<void> _restoreVersion(MessageModel message, int version) async {
    final history = _getMessageHistory(message);
    if (version >= history.length) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Version'),
        content: Text(
          'Are you sure you want to restore to version ${history.length - version}?'
          '\n\nThis will replace the current message content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final versionContent = history[version].content;
        final updatedMessage = message.copyWith(
          content: versionContent,
          isEdited: true,
          editedAt: DateTime.now(),
        );

        await ref
            .read(conversationProvider(widget.conversationId).notifier)
            .updateMessage(updatedMessage);

        if (mounted) {
          showAccessibleSuccessSnackBar(
            context,
            'Version restored successfully',
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          showAccessibleErrorSnackBar(
            context,
            'Failed to restore version. Please try again.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversationState =
        ref.watch(conversationProvider(widget.conversationId));

    final message = conversationState.messages.firstWhere(
      (msg) => msg.messageId == widget.messageId,
      orElse: () => MessageModel(
        messageId: '',
        conversationId: '',
        content: '',
        role: MessageRole.user,
        createdAt: DateTime.now(),
        status: MessageStatus.completed,
      ),
    );

    if (message.messageId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit History')),
        body: const Center(child: Text('Message not found')),
      );
    }

    final history = _getMessageHistory(message);

    if (history.length <= 1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit History')),
        body: _buildNoHistoryState(isDark),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit History'),
        actions: [
          SemanticIconButton(
            icon: _showComparison ? Icons.view_list : Icons.compare_arrows,
            label: _showComparison ? 'Switch to list view' : 'Switch to comparison view',
            onPressed: () {
              setState(() {
                _showComparison = !_showComparison;
                // Reset selected version when switching to comparison view
                if (_showComparison) {
                  final historyLength = ref
                      .read(conversationProvider(widget.conversationId))
                      .messages
                      .firstWhere((msg) => msg.messageId == widget.messageId,
                          orElse: () => MessageModel(
                                messageId: '',
                                conversationId: '',
                                content: '',
                                role: MessageRole.user,
                                createdAt: DateTime.now(),
                                status: MessageStatus.completed,
                              ))
                      .metadata?['history']
                      ?.length ??
                      0;
                  _selectedVersion = _selectedVersion.clamp(0, historyLength as num).toInt();
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1000 : double.infinity,
          child: Column(
            children: [
          // Header card
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: AppColors.zeusGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit History',
                        style: AppTextStyles.h4().copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${history.length} version(s)',
                        style: AppTextStyles.bodySmall().copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.role == 'user' ? 'You' : 'AI',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _showComparison
                ? _buildComparisonView(history, isDark)
                : _buildListView(history, message, isDark),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(
    List<MessageHistoryEntry> history,
    MessageModel message,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        final versionNumber = history.length - index;
        final isCurrent = index == 0;

        return AccessibleListItem(
          label: isCurrent
              ? 'Current version, ${entry.content.length} characters, edited ${_formatDateTime(entry.editedAt)}'
              : 'Version $versionNumber, ${entry.content.length} characters, edited ${_formatDateTime(entry.editedAt)}, double tap to restore',
          index: index,
          totalCount: history.length,
          child: Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Version header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primary : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCurrent ? 'Current' : 'Version $versionNumber',
                        style: AppTextStyles.labelSmall().copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _formatDateTime(entry.editedAt),
                      style: AppTextStyles.bodySmall().copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    if (!isCurrent)
                      TextButton.icon(
                        onPressed: () => _restoreVersion(message, index),
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text('Restore'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.content,
                      style: AppTextStyles.bodyMedium(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(
                          Icons.text_fields,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.content.length} characters',
                          style: AppTextStyles.labelSmall().copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(
                          Icons.subject,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.content.split(RegExp(r'\s+')).length} words',
                          style: AppTextStyles.labelSmall().copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonView(
    List<MessageHistoryEntry> history,
    bool isDark,
  ) {
    // Clamp selected version to valid range (avoid setState in build)
    final clampedVersion = _selectedVersion.clamp(0, history.length - 2);

    final currentEntry = history[0];
    final selectedEntry = history[clampedVersion + 1];

    return Column(
      children: [
        // Version selector
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text(
                'Compare with:',
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DropdownButton<int>(
                  value: clampedVersion,
                  isExpanded: true,
                  items: List.generate(
                    history.length - 1,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text(
                        'Version ${history.length - index - 1} - ${_formatDateTime(history[index + 1].editedAt)}',
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedVersion = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Comparison
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  context,
                  'Current Version',
                  currentEntry,
                  isDark,
                  Colors.green,
                ),
              ),
              Container(
                width: 2,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: _buildComparisonCard(
                  context,
                  'Version ${history.length - clampedVersion - 1}',
                  selectedEntry,
                  isDark,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(
    BuildContext context,
    String title,
    MessageHistoryEntry entry,
    bool isDark,
    Color accentColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: AppTextStyles.bodyMedium().copyWith(
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _formatDateTime(entry.editedAt),
            style: AppTextStyles.labelSmall().copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              entry.content,
              style: AppTextStyles.bodyMedium(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.text_fields, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${entry.content.length} chars',
                style: AppTextStyles.labelSmall().copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoHistoryState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
                Icons.history,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Edit History',
              style: AppTextStyles.h3().copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This message has not been edited yet. Edit history will appear here once you make changes.',
              style: AppTextStyles.bodyMedium().copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
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
