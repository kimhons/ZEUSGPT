import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/conversation_provider.dart';
import '../widgets/conversation_list_item.dart';
import '../widgets/empty_conversation_state.dart';

/// Home screen with conversation list
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Home');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults = [];
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final results = await ref
          .read(conversationListProvider.notifier)
          .searchConversations(query);

      setState(() {
        _searchResults = results.map((c) => c.conversationId).toList();
      });
    } catch (e) {
      // Handle error
      if (mounted) {
        showAccessibleErrorSnackBar(
          context,
          'Unable to search conversations. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationListState = ref.watch(conversationListProvider);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(context, isDark, authState),
      drawer: _buildDrawer(context, isDark, authState),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1000 : double.infinity,
          child: _buildBody(context, conversationListState),
        ),
      ),
      floatingActionButton: _buildNewChatButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDark,
    AuthState authState,
  ) {
    if (_isSearching) {
      return AppBar(
        leading: SemanticIconButton(
          icon: Icons.arrow_back,
          label: 'Cancel search',
          onPressed: _cancelSearch,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search conversations...',
            border: InputBorder.none,
          ),
          style: AppTextStyles.bodyLarge(),
          onChanged: _performSearch,
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
        ],
      );
    }

    return AppBar(
      title: Row(
        children: [
          Semantics(
            label: 'Zeus GPT Logo',
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.zeusGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'ZeusGPT',
            style: AppTextStyles.h3().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        SemanticIconButton(
          icon: Icons.search,
          label: 'Search conversations',
          onPressed: _startSearch,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'archive':
                context.push('${AppRoutes.home}/archive');
                break;
              case 'settings':
                context.push(AppRoutes.settings);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(Icons.archive_outlined),
                  SizedBox(width: AppSpacing.sm),
                  Text('Archive'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined),
                  SizedBox(width: AppSpacing.sm),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    bool isDark,
    AuthState authState,
  ) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // User profile section
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.zeusGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Profile picture for ${authState.user?.displayName ?? "User"}',
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      backgroundImage: authState.user?.photoURL != null
                          ? NetworkImage(authState.user!.photoURL!)
                          : null,
                      child: authState.user?.photoURL == null
                          ? Text(
                              authState.user?.displayName?.substring(0, 1).toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    authState.user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    authState.user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'Conversations',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.psychology_outlined,
                    title: 'AI Models',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.models);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.history,
                    title: 'History',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.history);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.image_outlined,
                    title: 'Image Generation',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to image generation
                    },
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.archive_outlined,
                    title: 'Archive',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to archive
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.folder_outlined,
                    title: 'Folders',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to folders
                    },
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.settings);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to help
                    },
                  ),
                ],
              ),
            ),

            // Sign out button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  final shouldSignOut = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldSignOut == true && mounted) {
                    await ref.read(authProvider.notifier).signOut();
                    if (mounted) {
                      context.go(AppRoutes.login);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildBody(
    BuildContext context,
    ConversationListState state,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.errorMessage != null) {
      return ErrorView(
        error: state.errorMessage!,
        message: state.errorMessage!,
        onRetry: () {
          // Refresh will happen automatically through stream
        },
      );
    }

    if (_isSearching && _searchResults.isEmpty && _searchController.text.isNotEmpty) {
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
              'No conversations found',
              style: AppTextStyles.bodyLarge().copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try a different search term',
              style: AppTextStyles.bodyMedium().copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final conversationsToShow = _isSearching && _searchResults.isNotEmpty
        ? state.conversations
            .where((c) => _searchResults.contains(c.conversationId))
            .toList()
        : state.conversations;

    if (conversationsToShow.isEmpty && !_isSearching) {
      return const EmptyConversationState();
    }

    final pinnedConversations =
        conversationsToShow.where((c) => c.isPinned && c.isActive).toList();
    final activeConversations =
        conversationsToShow.where((c) => !c.isPinned && c.isActive).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // Conversations will refresh automatically through stream
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          if (pinnedConversations.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Text(
                'Pinned',
                style: AppTextStyles.labelSmall().copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...pinnedConversations.map(
              (conversation) => ConversationListItem(
                conversation: conversation,
                onTap: () {
                  context.push(
                    '/home/chat/${conversation.conversationId}',
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (activeConversations.isNotEmpty) ...[
            if (pinnedConversations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Text(
                  'All Conversations',
                  style: AppTextStyles.labelSmall().copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ...activeConversations.map(
              (conversation) => ConversationListItem(
                conversation: conversation,
                onTap: () {
                  context.push(
                    '/home/chat/${conversation.conversationId}',
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        context.push('/home/new-chat');
      },
      icon: const Icon(Icons.add),
      label: const Text('New Chat'),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }
}
