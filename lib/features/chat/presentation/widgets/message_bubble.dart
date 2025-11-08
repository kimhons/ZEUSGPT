import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/message_model.dart';

/// Message bubble widget
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.showAvatar,
    this.onRegenerate,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final MessageModel message;
  final bool showAvatar;
  final VoidCallback? onRegenerate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          if (message.isAssistant) ...[
            _buildAvatar(isDark),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (message.isUser) const SizedBox(width: 48),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.surface(false)
                            : AppColors.surface(true).withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content
                      SelectableText(
                        message.content,
                        style: AppTextStyles.bodyMedium().copyWith(
                          color: message.isUser
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),

                      // Loading indicator
                      if (message.isLoading) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  message.isUser
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Generating...',
                              style: AppTextStyles.labelSmall().copyWith(
                                color: message.isUser
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Error message
                      if (message.hasFailed) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                message.errorMessage ?? 'Failed to generate response',
                                style: AppTextStyles.labelSmall().copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Metadata
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.formattedTime,
                      style: AppTextStyles.labelSmall().copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                    if (message.isEdited) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '(edited)',
                        style: AppTextStyles.labelSmall().copyWith(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (message.tokenCount != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '• ${message.tokenCount} tokens',
                        style: AppTextStyles.labelSmall().copyWith(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),

                // Actions
                if (message.isCompleted && !message.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.content_copy,
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: message.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        if (message.isUser && onEdit != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          _buildActionButton(
                            context,
                            icon: Icons.edit_outlined,
                            tooltip: 'Edit',
                            onPressed: onEdit,
                          ),
                        ],
                        if (message.isAssistant && onRegenerate != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          _buildActionButton(
                            context,
                            icon: Icons.refresh,
                            tooltip: 'Regenerate',
                            onPressed: onRegenerate,
                          ),
                        ],
                        if (onDelete != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          _buildActionButton(
                            context,
                            icon: Icons.delete_outline,
                            tooltip: 'Delete',
                            color: Colors.red,
                            onPressed: onDelete,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // User avatar
          if (message.isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            _buildAvatar(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    if (message.isUser) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          size: 20,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: AppColors.zeusGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.flash_on,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: 16),
      tooltip: tooltip,
      color: color ?? Colors.grey.shade600,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 28,
        minHeight: 28,
      ),
      onPressed: onPressed,
    );
  }
}
