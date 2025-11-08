import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';
import '../../data/models/message_model.dart';
import '../providers/conversation_provider.dart';

/// Screen for editing a sent message
class MessageEditScreen extends ConsumerStatefulWidget {
  const MessageEditScreen({
    required this.conversationId,
    required this.messageId,
    super.key,
  });

  final String conversationId;
  final String messageId;

  @override
  ConsumerState<MessageEditScreen> createState() => _MessageEditScreenState();
}

class _MessageEditScreenState extends ConsumerState<MessageEditScreen> {
  late TextEditingController _messageController;
  late String _originalContent;
  bool _isUpdating = false;
  bool _showPreview = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageController.addListener(_onTextChanged);

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Edit Message');
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasChanges = _messageController.text.trim() != _originalContent.trim();
    });
  }

  void _initializeContent(MessageModel message) {
    if (_messageController.text.isEmpty) {
      _originalContent = message.content;
      _messageController.text = message.content;
      _hasChanges = false;
    }
  }

  int get _wordCount {
    final text = _messageController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _characterCount => _messageController.text.length;

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  Future<void> _saveMessage(MessageModel message) async {
    if (!_hasChanges) {
      context.pop();
      return;
    }

    final newContent = _messageController.text.trim();
    if (newContent.isEmpty) {
      showAccessibleErrorSnackBar(
        context,
        'Message cannot be empty',
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedMessage = message.copyWith(
        content: newContent,
        isEdited: true,
        editedAt: DateTime.now(),
      );

      await ref
          .read(conversationProvider(widget.conversationId).notifier)
          .updateMessage(updatedMessage);

      if (mounted) {
        showAccessibleSuccessSnackBar(
          context,
          'Message updated',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showAccessibleErrorSnackBar(
          context,
          'Failed to update message: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
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
        appBar: AppBar(title: const Text('Edit Message')),
        body: const Center(
          child: Text('Message not found'),
        ),
      );
    }

    _initializeContent(message);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Message'),
          leading: SemanticIconButton(
            icon: Icons.close,
            label: 'Close without saving',
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                context.pop();
              }
            },
          ),
          actions: [
            if (!_showPreview)
              SemanticIconButton(
                icon: Icons.visibility_outlined,
                label: 'Preview message',
                onPressed: () {
                  setState(() {
                    _showPreview = true;
                  });
                },
              ),
            SemanticIconButton(
              icon: Icons.check,
              label: _isUpdating ? 'Saving message' : 'Save message',
              onPressed:
                  _isUpdating || !_hasChanges ? null : () => _saveMessage(message),
            ),
          ],
        ),
        body: SafeArea(
          child: ResponsiveCenter(
            maxWidth: context.isDesktop ? 600 : double.infinity,
            child: Column(
              children: [
              // Stats bar
              Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surface(false)
                    : AppColors.surface(true).withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildStatItem(
                    context,
                    Icons.text_fields,
                    '$_characterCount characters',
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _buildStatItem(
                    context,
                    Icons.subject,
                    '$_wordCount words',
                  ),
                  const Spacer(),
                  if (_hasChanges)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Unsaved',
                            style: AppTextStyles.labelSmall().copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _showPreview
                  ? _buildPreviewView(isDark)
                  : _buildEditView(isDark),
            ),

            // Bottom actions
            if (_showPreview)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface(false) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showPreview = false;
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Continue Editing'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall().copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEditView(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Original message card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surface(false)
                : AppColors.surface(true).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Original message',
                    style: AppTextStyles.labelSmall().copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _originalContent,
                style: AppTextStyles.bodyMedium().copyWith(
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Edit label
        Text(
          'Edit your message',
          style: AppTextStyles.h4().copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Editor
        TextField(
          controller: _messageController,
          maxLines: null,
          minLines: 8,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            filled: true,
            fillColor: isDark ? AppColors.surface(false) : Colors.white,
          ),
          style: AppTextStyles.bodyMedium(),
        ),
        const SizedBox(height: AppSpacing.md),

        // Tips
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editing Tips',
                      style: AppTextStyles.bodyMedium().copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '• Edited messages will show an "edited" indicator\n'
                      '• The original message is preserved in history\n'
                      '• Changes are saved immediately',
                      style: AppTextStyles.bodySmall().copyWith(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Preview header
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: AppColors.zeusGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.visibility,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Message Preview',
                style: AppTextStyles.h4().copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Preview content
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surface(false)
                : AppColors.surface(true).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'You',
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'edited',
                      style: AppTextStyles.labelSmall().copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _messageController.text.trim().isEmpty
                    ? 'Your message will appear here'
                    : _messageController.text,
                style: AppTextStyles.bodyMedium().copyWith(
                  color: _messageController.text.trim().isEmpty
                      ? Colors.grey.shade500
                      : null,
                  fontStyle: _messageController.text.trim().isEmpty
                      ? FontStyle.italic
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Comparison
        if (_hasChanges) ...[
          Text(
            'Original vs Updated',
            style: AppTextStyles.h4().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Before',
                      style: AppTextStyles.labelSmall().copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _originalContent,
                      style: AppTextStyles.bodySmall().copyWith(
                        color: Colors.red.shade700,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'After',
                      style: AppTextStyles.labelSmall().copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _messageController.text.trim(),
                      style: AppTextStyles.bodySmall().copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
