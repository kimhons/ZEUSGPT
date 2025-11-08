import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeus_button.dart';
import '../../data/models/conversation_model.dart';
import '../providers/conversation_provider.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';

/// Conversation detail and settings screen
class ConversationDetailScreen extends ConsumerStatefulWidget {
  const ConversationDetailScreen({
    required this.conversationId,
    super.key,
  });

  final String conversationId;

  @override
  ConsumerState<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState
    extends ConsumerState<ConversationDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _systemPromptController;
  double _temperature = 0.7;
  int _maxTokens = 2048;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _systemPromptController = TextEditingController();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Conversation Details');
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  void _initializeControllers(ConversationModel conversation) {
    if (_titleController.text.isEmpty) {
      _titleController.text = conversation.title;
      _systemPromptController.text = conversation.systemPrompt ?? '';
      _temperature = conversation.temperature ?? 0.7;
      _maxTokens = conversation.maxTokens ?? 2048;
    }
  }

  Future<void> _saveChanges(ConversationModel conversation) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedConversation = conversation.copyWith(
        title: _titleController.text.trim(),
        systemPrompt: _systemPromptController.text.trim().isEmpty
            ? null
            : _systemPromptController.text.trim(),
        temperature: _temperature,
        maxTokens: _maxTokens,
      );

      await ref
          .read(conversationListProvider.notifier)
          .updateConversation(updatedConversation);

      if (mounted) {
        showAccessibleSuccessSnackBar(
          context,
          'Conversation updated',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('validation')) {
          errorMessage = 'Invalid settings. Please check your inputs.';
        } else {
          errorMessage = 'Unable to update conversation. Please try again.';
        }

        showAccessibleErrorSnackBar(
          context,
          errorMessage,
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

  Future<void> _showExportDialog(ConversationModel conversation) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Conversation'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'txt'),
            child: const Text('TXT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'md'),
            child: const Text('Markdown'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'pdf'),
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      showAccessibleSnackBar(
        context,
        'Exporting as $result... (Not implemented yet)',
      );
      // TODO: Implement export functionality
    }
  }

  Future<void> _showShareDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Conversation'),
        content: const Text('Share via:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showAccessibleSnackBar(
                context,
                'Copy link... (Not implemented yet)',
              );
            },
            child: const Text('Copy Link'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showAccessibleSnackBar(
                context,
                'Share via email... (Not implemented yet)',
              );
            },
            child: const Text('Email'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(ConversationModel conversation) async {
    final confirmed = await showDialog<bool>(
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(conversationListProvider.notifier)
          .deleteConversation(conversation.conversationId);

      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversationState = ref.watch(conversationProvider(widget.conversationId));

    final conversation = conversationState.conversation;
    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conversation Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _initializeControllers(conversation);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation Details'),
        actions: [
          SemanticIconButton(
            icon: Icons.check,
            label: 'Save changes',
            onPressed: _isUpdating ? null : () => _saveChanges(conversation),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 600 : double.infinity,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.zeusGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Semantics(
                  label: 'Conversation settings',
                  child: const Icon(
                    Icons.settings_outlined,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Conversation Settings',
                  style: AppTextStyles.h3().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Basic Info Section
          _buildSectionHeader(context, 'Basic Information'),
          const SizedBox(height: AppSpacing.md),
          _buildInfoCard(
            context,
            isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Conversation title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium(),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(context, 'Model', conversation.modelId),
                _buildInfoRow(context, 'Provider', conversation.provider),
                _buildInfoRow(
                  context,
                  'Created',
                  conversation.timeAgo,
                ),
                _buildInfoRow(
                  context,
                  'Messages',
                  '${conversation.messageCount}',
                ),
                _buildInfoRow(
                  context,
                  'Tokens Used',
                  '${conversation.tokenCount}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Model Settings Section
          _buildSectionHeader(context, 'Model Settings'),
          const SizedBox(height: AppSpacing.md),
          _buildInfoCard(
            context,
            isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Temperature
                Text(
                  'Temperature: ${_temperature.toStringAsFixed(1)}',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Semantics(
                  label: 'Temperature: ${_temperature.toStringAsFixed(1)}. Higher values make output more random, lower values more focused',
                  child: Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    label: _temperature.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _temperature = value;
                      });
                    },
                  ),
                ),
                Text(
                  'Higher values make output more random, lower values more focused',
                  style: AppTextStyles.labelSmall().copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Max Tokens
                Text(
                  'Max Tokens: $_maxTokens',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Semantics(
                  label: 'Max Tokens: $_maxTokens. Maximum length of the generated response',
                  child: Slider(
                    value: _maxTokens.toDouble(),
                    min: 256,
                    max: 4096,
                    divisions: 15,
                    label: _maxTokens.toString(),
                    onChanged: (value) {
                      setState(() {
                        _maxTokens = value.toInt();
                      });
                    },
                  ),
                ),
                Text(
                  'Maximum length of the generated response',
                  style: AppTextStyles.labelSmall().copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // System Prompt
                Text(
                  'System Prompt',
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _systemPromptController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'You are a helpful assistant...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Actions Section
          _buildSectionHeader(context, 'Actions'),
          const SizedBox(height: AppSpacing.md),
          _buildActionButton(
            context,
            icon: Icons.share_outlined,
            label: 'Share Conversation',
            onTap: _showShareDialog,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(
            context,
            icon: Icons.download_outlined,
            label: 'Export Conversation',
            onTap: () => _showExportDialog(conversation),
            color: Colors.blue,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(
            context,
            icon: Icons.archive_outlined,
            label: conversation.isArchived ? 'Unarchive' : 'Archive',
            onTap: () async {
              if (conversation.isArchived) {
                await ref
                    .read(conversationListProvider.notifier)
                    .unarchiveConversation(conversation.conversationId);
              } else {
                await ref
                    .read(conversationListProvider.notifier)
                    .archiveConversation(conversation.conversationId);
              }
              if (mounted) {
                context.pop();
              }
            },
            color: Colors.orange,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActionButton(
            context,
            icon: Icons.delete_outline,
            label: 'Delete Conversation',
            onTap: () => _showDeleteDialog(conversation),
            color: Colors.red,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.h4().copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isDark, {
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surface(false)
            : AppColors.surface(true).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium().copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              ExcludeSemantics(child: Icon(icon, color: color)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge().copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ExcludeSemantics(child: Icon(Icons.chevron_right, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

