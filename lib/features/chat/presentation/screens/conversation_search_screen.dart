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
import '../../data/models/message_model.dart';
import '../providers/conversation_provider.dart';

/// Search result item containing conversation and matching message
class SearchResult {
  const SearchResult({
    required this.conversation,
    required this.message,
    required this.matchedText,
  });

  final ConversationModel conversation;
  final MessageModel message;
  final String matchedText;
}

/// Search filter options
enum SearchFilter {
  all,
  userMessages,
  assistantMessages,
  today,
  thisWeek,
  thisMonth,
}

/// Advanced conversation and message search screen
class ConversationSearchScreen extends ConsumerStatefulWidget {
  const ConversationSearchScreen({super.key});

  @override
  ConsumerState<ConversationSearchScreen> createState() =>
      _ConversationSearchScreenState();
}

class _ConversationSearchScreenState
    extends ConsumerState<ConversationSearchScreen> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  SearchFilter _filter = SearchFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode.requestFocus();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Search Conversations');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    // Simulate search delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    final conversationsAsync = ref.read(conversationListProvider);
    final conversations = conversationsAsync.conversations;

    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();

    for (final conversation in conversations) {
      if (conversation.isArchived) continue;

      // Search in conversation title
      if (conversation.title.toLowerCase().contains(lowerQuery)) {
        // Get first message as representative
        final conversationState =
            ref.read(conversationProvider(conversation.conversationId));
        final messages = conversationState.messages;

        if (messages.isNotEmpty) {
          results.add(SearchResult(
            conversation: conversation,
            message: messages.first,
            matchedText: conversation.title,
          ));
        }
      }

      // Search in messages
      final conversationState =
          ref.read(conversationProvider(conversation.conversationId));
      final messages = conversationState.messages;

      for (final message in messages) {
        if (!_matchesFilter(message, conversation)) continue;

        if (message.content.toLowerCase().contains(lowerQuery)) {
          results.add(SearchResult(
            conversation: conversation,
            message: message,
            matchedText: _extractMatchedText(message.content, query),
          ));
        }
      }
    }

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  bool _matchesFilter(MessageModel message, ConversationModel conversation) {
    final now = DateTime.now();

    switch (_filter) {
      case SearchFilter.userMessages:
        return message.role == MessageRole.user;
      case SearchFilter.assistantMessages:
        return message.role == MessageRole.assistant;
      case SearchFilter.today:
        return now.difference(message.createdAt).inHours < 24;
      case SearchFilter.thisWeek:
        return now.difference(message.createdAt).inDays < 7;
      case SearchFilter.thisMonth:
        return now.difference(message.createdAt).inDays < 30;
      case SearchFilter.all:
        return true;
    }
  }

  String _extractMatchedText(String content, String query) {
    final lowerContent = content.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerContent.indexOf(lowerQuery);

    if (index == -1) return content.substring(0, 100.clamp(0, content.length));

    const contextLength = 50;
    final start = (index - contextLength).clamp(0, content.length);
    final end = (index + query.length + contextLength).clamp(0, content.length);

    var excerpt = content.substring(start, end);
    if (start > 0) excerpt = '...$excerpt';
    if (end < content.length) excerpt = '$excerpt...';

    return excerpt;
  }

  String _highlightMatches(String text, String query) {
    if (query.isEmpty) return text;

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) return text;

    return text; // Will be styled with RichText in the UI
  }

  void _showFilterSheet() {
    showModalBottomSheet(
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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Filters',
                  style: AppTextStyles.h3().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _filter = SearchFilter.all);
                    Navigator.pop(context);
                    _performSearch(_searchController.text);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Filter options
            ...SearchFilter.values.map((filter) => RadioListTile(
                  title: Text(_getFilterLabel(filter)),
                  value: filter,
                  groupValue: _filter,
                  onChanged: (value) {
                    setState(() => _filter = value!);
                    Navigator.pop(context);
                    _performSearch(_searchController.text);
                  },
                )),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(SearchFilter filter) {
    switch (filter) {
      case SearchFilter.all:
        return 'All Messages';
      case SearchFilter.userMessages:
        return 'Your Messages Only';
      case SearchFilter.assistantMessages:
        return 'AI Responses Only';
      case SearchFilter.today:
        return 'Today';
      case SearchFilter.thisWeek:
        return 'This Week';
      case SearchFilter.thisMonth:
        return 'This Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: SemanticIconButton(
          icon: Icons.arrow_back,
          label: 'Go back',
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintStyle: AppTextStyles.bodyMedium().copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          style: AppTextStyles.bodyMedium(),
          onChanged: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            SemanticIconButton(
              icon: Icons.clear,
              label: 'Clear search',
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
          SemanticIconButton(
            icon: Icons.filter_list,
            label: _filter != SearchFilter.all
              ? 'Filter search (active: ${_getFilterLabel(_filter)})'
              : 'Filter search',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1000 : double.infinity,
          child: Column(
            children: [
          // Search info bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
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
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'Enter keywords to search across all conversations'
                        : _isSearching
                            ? 'Searching...'
                            : 'Found ${_searchResults.length} result(s) for "$_searchQuery"',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                if (_filter != SearchFilter.all)
                  Chip(
                    label: Text(_getFilterLabel(_filter)),
                    onDeleted: () {
                      setState(() => _filter = SearchFilter.all);
                      _performSearch(_searchController.text);
                    },
                    deleteIcon: const Icon(Icons.close, size: 14),
                    labelStyle: AppTextStyles.labelSmall(),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),

          // Search results
          Expanded(
            child: _buildSearchResults(isDark),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState(
        isDark,
        Icons.search,
        'Start Searching',
        'Type keywords to search across all your conversations and messages.',
      );
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        isDark,
        Icons.search_off,
        'No Results Found',
        'Try different keywords or adjust your filters.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _SearchResultCard(
          result: result,
          searchQuery: _searchQuery,
          isDark: isDark,
          onTap: () {
            context.push(
              '/chat/${result.conversation.conversationId}',
              extra: {'highlightMessageId': result.message.messageId},
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
  ) {
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
              child: Icon(icon, size: 64, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTextStyles.h3().copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium().copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Search result card widget
class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.result,
    required this.searchQuery,
    required this.isDark,
    required this.onTap,
  });

  final SearchResult result;
  final String searchQuery;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUserMessage = result.message.role == MessageRole.user;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Conversation header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.zeusGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          result.conversation.title,
                          style: AppTextStyles.labelSmall().copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isUserMessage ? 'You' : 'AI',
                      style: AppTextStyles.labelSmall().copyWith(
                        color: isUserMessage ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTimestamp(result.message.createdAt),
                    style: AppTextStyles.labelSmall().copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Matched text preview
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surface(false)
                      : AppColors.surface(true).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RichText(
                  text: _buildHighlightedText(
                    context,
                    result.matchedText,
                    searchQuery,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Action row
              Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Jump to message',
                    style: AppTextStyles.labelSmall().copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    result.conversation.provider,
                    style: AppTextStyles.labelSmall().copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _buildHighlightedText(
    BuildContext context,
    String text,
    String query,
  ) {
    if (query.isEmpty) {
      return TextSpan(
        text: text,
        style: AppTextStyles.bodySmall(),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    var currentIndex = 0;
    while (currentIndex < text.length) {
      final matchIndex = lowerText.indexOf(lowerQuery, currentIndex);

      if (matchIndex == -1) {
        // No more matches, add remaining text
        spans.add(TextSpan(
          text: text.substring(currentIndex),
          style: AppTextStyles.bodySmall(),
        ));
        break;
      }

      // Add text before match
      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          style: AppTextStyles.bodySmall(),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + query.length),
        style: AppTextStyles.bodySmall().copyWith(
          backgroundColor: Colors.yellow.withOpacity(0.3),
          fontWeight: FontWeight.bold,
        ),
      ));

      currentIndex = matchIndex + query.length;
    }

    return TextSpan(children: spans);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
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
