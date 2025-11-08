import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';
import '../../data/models/message_model.dart';
import '../providers/conversation_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

/// Chat screen for active conversation
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.conversationId,
    super.key,
  });

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isAtBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Chat conversation');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;
      if (_isAtBottom != isAtBottom) {
        setState(() {
          _isAtBottom = isAtBottom;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    try {
      await ref
          .read(conversationProvider(widget.conversationId).notifier)
          .sendMessage(content: content);

      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e.toString().contains('network')) {
          errorMessage = 'Unable to send message. Please check your internet connection.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Message sending timed out. Please try again.';
        } else {
          errorMessage = 'Unable to send message. Please try again.';
        }

        showAccessibleErrorSnackBar(
          context,
          errorMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationState =
        ref.watch(conversationProvider(widget.conversationId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(context, isDark, conversationState),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1200 : double.infinity,
          child: Column(
            children: [
              // Messages list
              Expanded(
                child: _buildMessageList(context, conversationState),
              ),

              // Input field
              ChatInput(
                controller: _messageController,
                onSend: _sendMessage,
                isLoading: conversationState.isSending,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: !_isAtBottom
          ? FloatingActionButton.small(
              onPressed: _scrollToBottom,
              backgroundColor: AppColors.primary,
              tooltip: 'Scroll to bottom',
              child: const Icon(Icons.arrow_downward, color: Colors.white),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    ConversationState state,
  ) {
    final conversation = state.conversation;

    return AppBar(
      leading: SemanticIconButton(
        icon: Icons.arrow_back,
        label: 'Back to conversations',
        onPressed: () => context.pop(),
      ),
      title: conversation != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  style: AppTextStyles.bodyLarge().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  conversation.modelId,
                  style: AppTextStyles.labelSmall().copyWith(
                    color: isDark
                        ? AppColors.textSecondary(isDark)
                        : AppColors.textSecondary(!isDark),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
      actions: [
        if (conversation != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  _showRenameDialog(context, conversation.title);
                  break;
                case 'share':
                  _shareConversation(context);
                  break;
                case 'export':
                  _exportConversation(context);
                  break;
                case 'clear':
                  _showClearHistoryDialog(context);
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: AppSpacing.sm),
                    Text('Rename'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined),
                    SizedBox(width: AppSpacing.sm),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined),
                    SizedBox(width: AppSpacing.sm),
                    Text('Export'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: AppSpacing.sm),
                    Text('Clear History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: AppSpacing.sm),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    ConversationState state,
  ) {
    if (state.isLoading && state.messages.isEmpty) {
      return const LoadingIndicator();
    }

    if (state.errorMessage != null && state.messages.isEmpty) {
      return ErrorView(
        error: state.errorMessage!,
        message: state.errorMessage!,
        onRetry: () {
          // Conversation will reload automatically
        },
      );
    }

    if (state.messages.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final showAvatar = index == 0 ||
            state.messages[index - 1].role != message.role;

        return MessageBubble(
          message: message,
          showAvatar: showAvatar,
          onRegenerate: message.isAssistant
              ? () => ref
                  .read(conversationProvider(widget.conversationId).notifier)
                  .regenerateMessage(message.messageId)
              : null,
          onEdit: message.isUser
              ? () => _showEditMessageDialog(context, message)
              : null,
          onDelete: () => ref
              .read(conversationProvider(widget.conversationId).notifier)
              .deleteMessage(message.messageId),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final conversation = ref
        .watch(conversationProvider(widget.conversationId))
        .conversation;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Start conversation icon',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Start the conversation',
              style: AppTextStyles.h3().copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ask anything to ${conversation?.modelId ?? "the AI"}',
              style: AppTextStyles.bodyLarge().copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Semantics(
              label: 'Suggested conversation starters',
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionChip(
                    context,
                    'Explain quantum computing',
                  ),
                  _buildSuggestionChip(
                    context,
                    'Write a Python function',
                  ),
                  _buildSuggestionChip(
                    context,
                    'Plan a trip to Japan',
                  ),
                  _buildSuggestionChip(
                    context,
                    'Summarize this article',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
      },
      avatar: const Icon(Icons.lightbulb_outline, size: 18),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != currentTitle) {
                Navigator.pop(context);
                try {
                  await ref
                      .read(conversationListProvider.notifier)
                      .updateConversationTitle(widget.conversationId, newTitle);

                  if (mounted) {
                    showAccessibleSuccessSnackBar(
                      context,
                      'Conversation renamed successfully',
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    showAccessibleErrorSnackBar(
                      context,
                      'Unable to rename conversation. Please try again.',
                    );
                  }
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _showEditMessageDialog(
    BuildContext context,
    MessageModel message,
  ) async {
    final controller = TextEditingController(text: message.content);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Edit your message',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty && newContent != message.content) {
                await ref
                    .read(conversationProvider(widget.conversationId).notifier)
                    .editMessage(message.messageId, newContent);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _showClearHistoryDialog(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all messages in this conversation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldClear == true && mounted) {
      try {
        await ref
            .read(conversationProvider(widget.conversationId).notifier)
            .clearHistory();

        if (mounted) {
          showAccessibleSuccessSnackBar(
            context,
            'Conversation history cleared',
          );
        }
      } catch (e) {
        if (mounted) {
          showAccessibleErrorSnackBar(
            context,
            'Unable to clear message history. Please try again.',
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
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

    if (shouldDelete == true && mounted) {
      await ref
          .read(conversationListProvider.notifier)
          .deleteConversation(widget.conversationId);
      if (mounted) {
        context.pop();
      }
    }
  }

  Future<void> _shareConversation(BuildContext context) async {
    try {
      final shareableText = ref
          .read(conversationProvider(widget.conversationId).notifier)
          .getShareableText();

      if (shareableText.isEmpty) {
        if (mounted) {
          showAccessibleSnackBar(
            context,
            'No messages to share',
            backgroundColor: Colors.orange,
          );
        }
        return;
      }

      await Share.share(shareableText);
    } catch (e) {
      if (mounted) {
        showAccessibleErrorSnackBar(
          context,
          'Unable to share conversation. Make sure you have sharing permissions.',
        );
      }
    }
  }

  Future<void> _exportConversation(BuildContext context) async {
    try {
      final exportData = ref
          .read(conversationProvider(widget.conversationId).notifier)
          .getExportableData();

      if (exportData['messages'] == null ||
          (exportData['messages'] as List).isEmpty) {
        if (mounted) {
          showAccessibleSnackBar(
            context,
            'No messages to export',
            backgroundColor: Colors.orange,
          );
        }
        return;
      }

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'conversation_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${directory.path}/$fileName';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Conversation Export - ${exportData['conversation']?['title'] ?? 'Zeus GPT'}',
      );

      if (mounted) {
        showAccessibleSuccessSnackBar(
          context,
          'Conversation exported successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        showAccessibleErrorSnackBar(
          context,
          'Unable to export conversation. Please try again.',
        );
      }
    }
  }
}
