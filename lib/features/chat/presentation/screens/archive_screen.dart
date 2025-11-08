import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';
import '../../data/models/conversation_model.dart';
import '../providers/conversation_provider.dart';
import '../widgets/conversation_list_item.dart';

/// Screen displaying archived conversations
class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  String _searchQuery = '';
  bool _isSelectionMode = false;
  final Set<String> _selectedConversations = {};

  @override
  void initState() {
    super.initState();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Archive');
    });
  }

  List<ConversationModel> _filterArchivedConversations(
    List<ConversationModel> conversations,
  ) {
    final archived = conversations.where((conv) => conv.isArchived).toList();

    if (_searchQuery.isEmpty) {
      return archived;
    }

    return archived
        .where((conv) =>
            conv.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleSelection(String conversationId) {
    setState(() {
      if (_selectedConversations.contains(conversationId)) {
        _selectedConversations.remove(conversationId);
        if (_selectedConversations.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedConversations.add(conversationId);
      }
    });
  }

  void _startSelectionMode(String conversationId) {
    setState(() {
      _isSelectionMode = true;
      _selectedConversations.add(conversationId);
    });
  }

  Future<void> _unarchiveSelected() async {
    final notifier = ref.read(conversationListProvider.notifier);

    for (final id in _selectedConversations) {
      await notifier.unarchiveConversation(id);
    }

    final count = _selectedConversations.length;

    setState(() {
      _selectedConversations.clear();
      _isSelectionMode = false;
    });

    if (mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Unarchived $count conversation(s)',
      );
    }
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversations'),
        content: Text(
          'Are you sure you want to permanently delete ${_selectedConversations.length} conversation(s)? This action cannot be undone.',
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
      final notifier = ref.read(conversationListProvider.notifier);

      for (final id in _selectedConversations) {
        await notifier.deleteConversation(id);
      }

      setState(() {
        _selectedConversations.clear();
        _isSelectionMode = false;
      });

      if (mounted) {
        showAccessibleErrorSnackBar(
          context,
          'Conversations deleted permanently',
        );
      }
    }
  }

  Future<void> _showConversationOptions(ConversationModel conversation) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
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

            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                conversation.title,
                style: AppTextStyles.h4(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Divider(),

            // Unarchive option
            ListTile(
              leading: const Icon(Icons.unarchive_outlined, color: Colors.blue),
              title: const Text('Unarchive'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(conversationListProvider.notifier)
                    .unarchiveConversation(conversation.conversationId);

                if (mounted) {
                  showAccessibleSuccessSnackBar(
                    context,
                    'Conversation unarchived',
                  );
                }
              },
            ),

            // Delete option
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Permanently'),
              textColor: Colors.red,
              onTap: () async {
                Navigator.pop(context);

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Conversation'),
                    content: const Text(
                      'Are you sure you want to permanently delete this conversation? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
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
                    showAccessibleErrorSnackBar(
                      context,
                      'Conversation deleted permanently',
                    );
                  }
                }
              },
            ),

            // View details option
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                context.push('/conversation/${conversation.conversationId}/details');
              },
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversationsAsync = ref.watch(conversationListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: SemanticIconButton(
          icon: Icons.arrow_back,
          label: 'Go back',
          onPressed: () => context.pop(),
        ),
        title: _isSelectionMode
            ? Text('${_selectedConversations.length} selected')
            : const Text('Archive'),
        actions: _isSelectionMode
            ? [
                SemanticIconButton(
                  icon: Icons.unarchive_outlined,
                  label: 'Unarchive selected',
                  onPressed: _unarchiveSelected,
                ),
                SemanticIconButton(
                  icon: Icons.delete_outline,
                  label: 'Delete selected',
                  onPressed: _deleteSelected,
                ),
                SemanticIconButton(
                  icon: Icons.close,
                  label: 'Cancel selection',
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      _selectedConversations.clear();
                    });
                  },
                ),
              ]
            : [
                SemanticIconButton(
                  icon: Icons.search,
                  label: 'Search archived',
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: _ArchiveSearchDelegate(
                        conversations: conversationsAsync.conversations,
                        onConversationTap: (conv) {
                          context.push('/chat/${conv.conversationId}');
                        },
                        onConversationLongPress: _showConversationOptions,
                      ),
                    );
                  },
                ),
              ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1000 : double.infinity,
          child: () {
            if (conversationsAsync.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

          if (conversationsAsync.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Error loading conversations',
                    style: AppTextStyles.body(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    conversationsAsync.errorMessage!,
                    style: AppTextStyles.caption(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final archivedConversations =
              _filterArchivedConversations(conversationsAsync.conversations);

          if (archivedConversations.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return Column(
            children: [
              // Archive info banner
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.archive_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Archived Conversations',
                            style: AppTextStyles.bodyLarge().copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${archivedConversations.length} conversation(s)',
                            style: AppTextStyles.bodySmall().copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Conversations list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: archivedConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = archivedConversations[index];
                    final isSelected = _selectedConversations
                        .contains(conversation.conversationId);

                    return ConversationListItem(
                      conversation: conversation,
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelection(conversation.conversationId);
                        } else {
                          context.push('/chat/${conversation.conversationId}');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zeus themed empty state
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.zeusGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.archive_outlined,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'No Archived Conversations',
              style: AppTextStyles.h3().copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              'Conversations you archive will appear here. Archive conversations to declutter your main list while keeping them accessible.',
              style: AppTextStyles.bodyMedium().copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Conversations'),
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
}

/// Search delegate for archived conversations
class _ArchiveSearchDelegate extends SearchDelegate<ConversationModel?> {
  _ArchiveSearchDelegate({
    required this.conversations,
    required this.onConversationTap,
    required this.onConversationLongPress,
  });

  final List<ConversationModel> conversations;
  final Function(ConversationModel) onConversationTap;
  final Function(ConversationModel) onConversationLongPress;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        SemanticIconButton(
          icon: Icons.clear,
          label: 'Clear search',
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return SemanticIconButton(
      icon: Icons.arrow_back,
      label: 'Close search',
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final archivedConversations =
        conversations.where((conv) => conv.isArchived).toList();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search archived conversations',
              style: AppTextStyles.bodyLarge().copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    final results = archivedConversations
        .where((conv) =>
            conv.title.toLowerCase().contains(query.toLowerCase()) ||
            (conv.systemPrompt?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No results found for "$query"',
              style: AppTextStyles.bodyLarge().copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final conversation = results[index];
        return ConversationListItem(
          conversation: conversation,
          onTap: () {
            close(context, null);
            onConversationTap(conversation);
          },
        );
      },
    );
  }
}
