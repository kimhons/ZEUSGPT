import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive.dart';
import '../../data/models/conversation_model.dart';
import '../providers/conversation_provider.dart';
import '../widgets/conversation_list_item.dart';

/// Filter options for conversations
enum ConversationFilter {
  all,
  today,
  thisWeek,
  thisMonth,
  older,
}

/// Sort options for conversations
enum ConversationSort {
  newest,
  oldest,
  mostActive,
  alphabetical,
}

/// Provider filter options
enum ProviderFilter {
  all,
  openai,
  anthropic,
  google,
  meta,
  mistral,
  other,
}

/// Comprehensive conversation list screen with filtering and sorting
class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  ConversationFilter _dateFilter = ConversationFilter.all;
  ConversationSort _sortOption = ConversationSort.newest;
  ProviderFilter _providerFilter = ProviderFilter.all;
  bool _isSelectionMode = false;
  final Set<String> _selectedConversations = {};
  String _searchQuery = '';

  List<ConversationModel> _filterAndSortConversations(
    List<ConversationModel> conversations,
  ) {
    var filtered = conversations.where((conv) => !conv.isArchived).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((conv) =>
              conv.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (conv.systemPrompt
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    // Apply date filter
    final now = DateTime.now();
    switch (_dateFilter) {
      case ConversationFilter.today:
        filtered = filtered.where((conv) {
          final diff = now.difference(conv.createdAt);
          return diff.inHours < 24;
        }).toList();
        break;
      case ConversationFilter.thisWeek:
        filtered = filtered.where((conv) {
          final diff = now.difference(conv.createdAt);
          return diff.inDays < 7;
        }).toList();
        break;
      case ConversationFilter.thisMonth:
        filtered = filtered.where((conv) {
          final diff = now.difference(conv.createdAt);
          return diff.inDays < 30;
        }).toList();
        break;
      case ConversationFilter.older:
        filtered = filtered.where((conv) {
          final diff = now.difference(conv.createdAt);
          return diff.inDays >= 30;
        }).toList();
        break;
      case ConversationFilter.all:
        break;
    }

    // Apply provider filter
    if (_providerFilter != ProviderFilter.all) {
      filtered = filtered.where((conv) {
        final provider = conv.provider.toLowerCase();
        switch (_providerFilter) {
          case ProviderFilter.openai:
            return provider.contains('openai') || provider.contains('gpt');
          case ProviderFilter.anthropic:
            return provider.contains('anthropic') || provider.contains('claude');
          case ProviderFilter.google:
            return provider.contains('google') ||
                provider.contains('gemini') ||
                provider.contains('palm');
          case ProviderFilter.meta:
            return provider.contains('meta') || provider.contains('llama');
          case ProviderFilter.mistral:
            return provider.contains('mistral');
          case ProviderFilter.other:
            return !provider.contains('openai') &&
                !provider.contains('anthropic') &&
                !provider.contains('google') &&
                !provider.contains('meta') &&
                !provider.contains('mistral');
          case ProviderFilter.all:
            return true;
        }
      }).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case ConversationSort.newest:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case ConversationSort.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ConversationSort.mostActive:
        filtered.sort((a, b) => b.messageCount.compareTo(a.messageCount));
        break;
      case ConversationSort.alphabetical:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return filtered;
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

  Future<void> _archiveSelected() async {
    final notifier = ref.read(conversationListProvider.notifier);
    final count = _selectedConversations.length;

    for (final id in _selectedConversations) {
      await notifier.archiveConversation(id);
    }

    setState(() {
      _selectedConversations.clear();
      _isSelectionMode = false;
    });

    if (mounted) {
      final message = 'Archived $count conversation(s)';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
      SemanticsService.announce(
        message,
        TextDirection.ltr,
      );
    }
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversations'),
        content: Text(
          'Are you sure you want to delete ${_selectedConversations.length} conversation(s)? This action cannot be undone.',
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
      final count = _selectedConversations.length;

      for (final id in _selectedConversations) {
        await notifier.deleteConversation(id);
      }

      setState(() {
        _selectedConversations.clear();
        _isSelectionMode = false;
      });

      if (mounted) {
        final message = 'Deleted $count conversation(s)';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
        SemanticsService.announce(
          message,
          TextDirection.ltr,
        );
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _FilterBottomSheet(
          dateFilter: _dateFilter,
          providerFilter: _providerFilter,
          sortOption: _sortOption,
          onDateFilterChanged: (filter) {
            setState(() => _dateFilter = filter);
            Navigator.pop(context);
          },
          onProviderFilterChanged: (filter) {
            setState(() => _providerFilter = filter);
            Navigator.pop(context);
          },
          onSortOptionChanged: (option) {
            setState(() => _sortOption = option);
            Navigator.pop(context);
          },
          onResetFilters: () {
            setState(() {
              _dateFilter = ConversationFilter.all;
              _providerFilter = ProviderFilter.all;
              _sortOption = ConversationSort.newest;
            });
            Navigator.pop(context);
          },
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversationsAsync = ref.watch(conversationListProvider);

    final hasActiveFilters = _dateFilter != ConversationFilter.all ||
        _providerFilter != ProviderFilter.all ||
        _sortOption != ConversationSort.newest;

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedConversations.length} selected')
            : const Text('All Conversations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: _archiveSelected,
                  tooltip: 'Archive selected',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteSelected,
                  tooltip: 'Delete selected',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = false;
                      _selectedConversations.clear();
                    });
                  },
                  tooltip: 'Cancel selection',
                ),
              ]
            : [
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.filter_list),
                      if (hasActiveFilters)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: ExcludeSemantics(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _showFilterSheet,
                  tooltip: 'Filter & Sort',
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: _ConversationSearchDelegate(
                        conversations: conversationsAsync.conversations,
                      ),
                    );
                  },
                  tooltip: 'Search',
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
                  Semantics(
                    label: 'Error loading conversations',
                    child: const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Failed to load conversations',
                    style: AppTextStyles.h4(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    conversationsAsync.errorMessage!,
                    style: AppTextStyles.bodySmall(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(conversationListProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredConversations =
              _filterAndSortConversations(conversationsAsync.conversations);

          if (filteredConversations.isEmpty) {
            return _buildEmptyState(isDark, hasActiveFilters);
          }

          return Column(
            children: [
              // Active filters chip bar
              if (hasActiveFilters)
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surface(false)
                        : AppColors.surface(true).withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_dateFilter != ConversationFilter.all)
                        _buildFilterChip(
                          context,
                          _getDateFilterLabel(_dateFilter),
                          () => setState(() =>
                              _dateFilter = ConversationFilter.all),
                        ),
                      if (_providerFilter != ProviderFilter.all)
                        _buildFilterChip(
                          context,
                          _getProviderFilterLabel(_providerFilter),
                          () => setState(() =>
                              _providerFilter = ProviderFilter.all),
                        ),
                      if (_sortOption != ConversationSort.newest)
                        _buildFilterChip(
                          context,
                          _getSortOptionLabel(_sortOption),
                          () => setState(() =>
                              _sortOption = ConversationSort.newest),
                        ),
                    ],
                  ),
                ),

              // Results count
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Text(
                      '${filteredConversations.length} conversation(s)',
                      style: AppTextStyles.bodyMedium().copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (hasActiveFilters)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _dateFilter = ConversationFilter.all;
                            _providerFilter = ProviderFilter.all;
                            _sortOption = ConversationSort.newest;
                          });
                        },
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear filters'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
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
                  itemCount: filteredConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = filteredConversations[index];
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

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    VoidCallback onRemove,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 16),
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        labelStyle: AppTextStyles.labelSmall().copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: hasFilters
                  ? 'No matching conversations icon'
                  : 'No conversations icon',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFilters ? Icons.filter_list_off : Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              hasFilters ? 'No Matching Conversations' : 'No Conversations Yet',
              style: AppTextStyles.h3().copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilters
                  ? 'Try adjusting your filters to see more conversations.'
                  : 'Start a new conversation to begin chatting with AI models.',
              style: AppTextStyles.bodyMedium().copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _dateFilter = ConversationFilter.all;
                    _providerFilter = ProviderFilter.all;
                    _sortOption = ConversationSort.newest;
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All Filters'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => context.push('/chat/new'),
                icon: const Icon(Icons.add),
                label: const Text('Start New Chat'),
                style: ElevatedButton.styleFrom(
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

  String _getDateFilterLabel(ConversationFilter filter) {
    switch (filter) {
      case ConversationFilter.today:
        return 'Today';
      case ConversationFilter.thisWeek:
        return 'This Week';
      case ConversationFilter.thisMonth:
        return 'This Month';
      case ConversationFilter.older:
        return 'Older';
      case ConversationFilter.all:
        return 'All Time';
    }
  }

  String _getProviderFilterLabel(ProviderFilter filter) {
    switch (filter) {
      case ProviderFilter.openai:
        return 'OpenAI';
      case ProviderFilter.anthropic:
        return 'Anthropic';
      case ProviderFilter.google:
        return 'Google';
      case ProviderFilter.meta:
        return 'Meta';
      case ProviderFilter.mistral:
        return 'Mistral';
      case ProviderFilter.other:
        return 'Other';
      case ProviderFilter.all:
        return 'All Providers';
    }
  }

  String _getSortOptionLabel(ConversationSort option) {
    switch (option) {
      case ConversationSort.newest:
        return 'Newest First';
      case ConversationSort.oldest:
        return 'Oldest First';
      case ConversationSort.mostActive:
        return 'Most Active';
      case ConversationSort.alphabetical:
        return 'A-Z';
    }
  }
}

/// Filter bottom sheet widget
class _FilterBottomSheet extends StatelessWidget {
  const _FilterBottomSheet({
    required this.dateFilter,
    required this.providerFilter,
    required this.sortOption,
    required this.onDateFilterChanged,
    required this.onProviderFilterChanged,
    required this.onSortOptionChanged,
    required this.onResetFilters,
    required this.scrollController,
  });

  final ConversationFilter dateFilter;
  final ProviderFilter providerFilter;
  final ConversationSort sortOption;
  final Function(ConversationFilter) onDateFilterChanged;
  final Function(ProviderFilter) onProviderFilterChanged;
  final Function(ConversationSort) onSortOptionChanged;
  final VoidCallback onResetFilters;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: AppTextStyles.h3().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onResetFilters,
                child: const Text('Reset All'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Date Filter Section
          Text(
            'Date Range',
            style: AppTextStyles.h4().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...ConversationFilter.values.map((filter) => RadioListTile(
                title: Text(_getDateFilterLabel(filter)),
                value: filter,
                groupValue: dateFilter,
                onChanged: (value) => onDateFilterChanged(value!),
              )),
          const Divider(height: AppSpacing.xl),

          // Provider Filter Section
          Text(
            'AI Provider',
            style: AppTextStyles.h4().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...ProviderFilter.values.map((filter) => RadioListTile(
                title: Text(_getProviderFilterLabel(filter)),
                value: filter,
                groupValue: providerFilter,
                onChanged: (value) => onProviderFilterChanged(value!),
              )),
          const Divider(height: AppSpacing.xl),

          // Sort Section
          Text(
            'Sort By',
            style: AppTextStyles.h4().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...ConversationSort.values.map((option) => RadioListTile(
                title: Text(_getSortOptionLabel(option)),
                value: option,
                groupValue: sortOption,
                onChanged: (value) => onSortOptionChanged(value!),
              )),
        ],
      ),
    );
  }

  String _getDateFilterLabel(ConversationFilter filter) {
    switch (filter) {
      case ConversationFilter.today:
        return 'Today';
      case ConversationFilter.thisWeek:
        return 'This Week';
      case ConversationFilter.thisMonth:
        return 'This Month';
      case ConversationFilter.older:
        return 'Older than 30 days';
      case ConversationFilter.all:
        return 'All Time';
    }
  }

  String _getProviderFilterLabel(ProviderFilter filter) {
    switch (filter) {
      case ProviderFilter.openai:
        return 'OpenAI (GPT models)';
      case ProviderFilter.anthropic:
        return 'Anthropic (Claude)';
      case ProviderFilter.google:
        return 'Google (Gemini/PaLM)';
      case ProviderFilter.meta:
        return 'Meta (Llama)';
      case ProviderFilter.mistral:
        return 'Mistral AI';
      case ProviderFilter.other:
        return 'Other providers';
      case ProviderFilter.all:
        return 'All Providers';
    }
  }

  String _getSortOptionLabel(ConversationSort option) {
    switch (option) {
      case ConversationSort.newest:
        return 'Newest First';
      case ConversationSort.oldest:
        return 'Oldest First';
      case ConversationSort.mostActive:
        return 'Most Active';
      case ConversationSort.alphabetical:
        return 'Alphabetical (A-Z)';
    }
  }
}

/// Search delegate for conversations
class _ConversationSearchDelegate extends SearchDelegate<ConversationModel?> {
  _ConversationSearchDelegate({required this.conversations});

  final List<ConversationModel> conversations;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
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
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search conversations',
              style: AppTextStyles.bodyLarge().copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    final results = conversations
        .where((conv) =>
            !conv.isArchived &&
            (conv.title.toLowerCase().contains(query.toLowerCase()) ||
                (conv.systemPrompt
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false)))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
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
            context.push('/chat/${conversation.conversationId}');
          },
        );
      },
    );
  }
}
