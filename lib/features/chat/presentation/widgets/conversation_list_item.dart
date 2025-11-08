import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/conversation_model.dart';
import '../providers/conversation_provider.dart';

/// Conversation list item widget
class ConversationListItem extends ConsumerWidget {
  const ConversationListItem({
    required this.conversation,
    required this.onTap,
    super.key,
  });

  final ConversationModel conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(conversation.conversationId),
      background: _buildSwipeBackground(
        context,
        color: Colors.blue,
        icon: Icons.archive,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        color: Colors.red,
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Archive
          await ref
              .read(conversationListProvider.notifier)
              .archiveConversation(conversation.conversationId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Conversation archived'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    ref
                        .read(conversationListProvider.notifier)
                        .unarchiveConversation(conversation.conversationId);
                  },
                ),
              ),
            );
          }
          return true;
        } else if (direction == DismissDirection.endToStart) {
          // Delete - show confirmation
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Conversation'),
              content: const Text(
                'Are you sure you want to delete this conversation? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (shouldDelete == true) {
            await ref
                .read(conversationListProvider.notifier)
                .deleteConversation(conversation.conversationId);
          }

          return shouldDelete ?? false;
        }
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showConversationOptions(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Model icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surface(false)
                        : AppColors.surface(true).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getProviderIcon(conversation.provider),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Title
                          Expanded(
                            child: Text(
                              conversation.title,
                              style: AppTextStyles.bodyLarge().copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),

                          // Pin icon
                          if (conversation.isPinned)
                            Icon(
                              Icons.push_pin,
                              size: 16,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Preview
                      Text(
                        conversation.preview,
                        style: AppTextStyles.bodyMedium().copyWith(
                          color: isDark
                              ? AppColors.textSecondary(isDark)
                              : AppColors.textSecondary(!isDark),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Metadata
                      Row(
                        children: [
                          // Model name
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              conversation.modelId,
                              style: AppTextStyles.labelSmall().copyWith(
                                color: AppColors.primary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),

                          // Message count
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${conversation.messageCount}',
                            style: AppTextStyles.labelSmall().copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),

                          // Time ago
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            conversation.timeAgo,
                            style: AppTextStyles.labelSmall().copyWith(
                              color: Colors.grey.shade500,
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
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  IconData _getProviderIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return Icons.psychology;
      case 'anthropic':
        return Icons.smart_toy;
      case 'google':
        return Icons.school;
      case 'meta':
        return Icons.facebook;
      case 'cohere':
        return Icons.cloud;
      case 'mistral':
        return Icons.wind_power;
      default:
        return Icons.psychology_outlined;
    }
  }

  void _showConversationOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                conversation.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(conversation.isPinned ? 'Unpin' : 'Pin'),
              onTap: () async {
                Navigator.pop(context);
                if (conversation.isPinned) {
                  await ref
                      .read(conversationListProvider.notifier)
                      .unpinConversation(conversation.conversationId);
                } else {
                  await ref
                      .read(conversationListProvider.notifier)
                      .pinConversation(conversation.conversationId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show rename dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show share options
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Move to Folder'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show folder selection
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(conversationListProvider.notifier)
                    .archiveConversation(conversation.conversationId);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Conversation'),
                    content: const Text(
                      'Are you sure you want to delete this conversation?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  await ref
                      .read(conversationListProvider.notifier)
                      .deleteConversation(conversation.conversationId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
