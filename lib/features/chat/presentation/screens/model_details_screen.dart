import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/widgets/accessible_card.dart';
import '../../../../core/responsive.dart';

/// AI Provider enumeration
enum AIProvider {
  openai,
  anthropic,
  google,
  meta,
  mistral,
  cohere,
  other,
}

extension AIProviderExtension on AIProvider {
  String get displayName {
    switch (this) {
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.anthropic:
        return 'Anthropic';
      case AIProvider.google:
        return 'Google';
      case AIProvider.meta:
        return 'Meta';
      case AIProvider.mistral:
        return 'Mistral';
      case AIProvider.cohere:
        return 'Cohere';
      case AIProvider.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case AIProvider.openai:
        return const Color(0xFF10A37F);
      case AIProvider.anthropic:
        return const Color(0xFFD4A574);
      case AIProvider.google:
        return const Color(0xFF4285F4);
      case AIProvider.meta:
        return const Color(0xFF0668E1);
      case AIProvider.mistral:
        return const Color(0xFFFF7000);
      case AIProvider.cohere:
        return const Color(0xFF39594D);
      case AIProvider.other:
        return Colors.grey;
    }
  }
}

/// Model capability enumeration
enum ModelCapability {
  chat,
  code,
  vision,
  audio,
  reasoning,
  longContext,
  functionCalling,
  streaming,
}

extension ModelCapabilityExtension on ModelCapability {
  String get label {
    switch (this) {
      case ModelCapability.chat:
        return 'Chat';
      case ModelCapability.code:
        return 'Code';
      case ModelCapability.vision:
        return 'Vision';
      case ModelCapability.audio:
        return 'Audio';
      case ModelCapability.reasoning:
        return 'Reasoning';
      case ModelCapability.longContext:
        return 'Long Context';
      case ModelCapability.functionCalling:
        return 'Function Calling';
      case ModelCapability.streaming:
        return 'Streaming';
    }
  }

  IconData get icon {
    switch (this) {
      case ModelCapability.chat:
        return Icons.chat_bubble_outline;
      case ModelCapability.code:
        return Icons.code;
      case ModelCapability.vision:
        return Icons.visibility;
      case ModelCapability.audio:
        return Icons.mic;
      case ModelCapability.reasoning:
        return Icons.psychology;
      case ModelCapability.longContext:
        return Icons.article;
      case ModelCapability.functionCalling:
        return Icons.functions;
      case ModelCapability.streaming:
        return Icons.stream;
    }
  }

  String get description {
    switch (this) {
      case ModelCapability.chat:
        return 'Natural language conversations';
      case ModelCapability.code:
        return 'Programming and code generation';
      case ModelCapability.vision:
        return 'Image understanding and analysis';
      case ModelCapability.audio:
        return 'Speech recognition and generation';
      case ModelCapability.reasoning:
        return 'Complex problem solving';
      case ModelCapability.longContext:
        return 'Large context window support';
      case ModelCapability.functionCalling:
        return 'External function integration';
      case ModelCapability.streaming:
        return 'Real-time response streaming';
    }
  }
}

/// Use case category
enum UseCase {
  contentCreation,
  codeAssistance,
  dataAnalysis,
  customerSupport,
  translation,
  summarization,
  research,
  education,
}

extension UseCaseExtension on UseCase {
  String get label {
    switch (this) {
      case UseCase.contentCreation:
        return 'Content Creation';
      case UseCase.codeAssistance:
        return 'Code Assistance';
      case UseCase.dataAnalysis:
        return 'Data Analysis';
      case UseCase.customerSupport:
        return 'Customer Support';
      case UseCase.translation:
        return 'Translation';
      case UseCase.summarization:
        return 'Summarization';
      case UseCase.research:
        return 'Research';
      case UseCase.education:
        return 'Education';
    }
  }

  IconData get icon {
    switch (this) {
      case UseCase.contentCreation:
        return Icons.edit_note;
      case UseCase.codeAssistance:
        return Icons.code;
      case UseCase.dataAnalysis:
        return Icons.analytics;
      case UseCase.customerSupport:
        return Icons.support_agent;
      case UseCase.translation:
        return Icons.translate;
      case UseCase.summarization:
        return Icons.summarize;
      case UseCase.research:
        return Icons.science;
      case UseCase.education:
        return Icons.school;
    }
  }
}

/// AI Model data class
class AIModel {
  const AIModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.provider,
    required this.capabilities,
    required this.contextWindow,
    required this.inputPricePerMillion,
    required this.outputPricePerMillion,
    this.description,
    this.detailedDescription,
    this.version,
    this.releaseDate,
    this.speedRating = 0.0,
    this.popularityRating = 0.0,
    this.qualityRating = 0.0,
    this.useCases = const [],
    this.strengths = const [],
    this.limitations = const [],
    this.trainingData,
    this.apiEndpoint,
    this.documentation,
    this.maxOutputTokens,
    this.isDeprecated = false,
  });

  final String id;
  final String name;
  final String displayName;
  final AIProvider provider;
  final List<ModelCapability> capabilities;
  final int contextWindow;
  final double inputPricePerMillion;
  final double outputPricePerMillion;
  final String? description;
  final String? detailedDescription;
  final String? version;
  final DateTime? releaseDate;
  final double speedRating; // 0.0 - 5.0
  final double popularityRating; // 0.0 - 5.0
  final double qualityRating; // 0.0 - 5.0
  final List<UseCase> useCases;
  final List<String> strengths;
  final List<String> limitations;
  final String? trainingData;
  final String? apiEndpoint;
  final String? documentation;
  final int? maxOutputTokens;
  final bool isDeprecated;

  String get contextWindowFormatted {
    if (contextWindow >= 1000000) {
      return '${(contextWindow / 1000000).toStringAsFixed(1)}M';
    } else if (contextWindow >= 1000) {
      return '${(contextWindow / 1000).toStringAsFixed(0)}K';
    }
    return contextWindow.toString();
  }

  String get priceFormatted {
    if (inputPricePerMillion == 0 && outputPricePerMillion == 0) {
      return 'Free';
    }
    return '\$${inputPricePerMillion.toStringAsFixed(2)} / \$${outputPricePerMillion.toStringAsFixed(2)}';
  }

  double get costPer1KTokens =>
      (inputPricePerMillion + outputPricePerMillion) / 1000;

  double get averageRating =>
      (speedRating + popularityRating + qualityRating) / 3;
}

/// Screen for displaying detailed information about an AI model
class ModelDetailsScreen extends ConsumerStatefulWidget {
  const ModelDetailsScreen({
    required this.model,
    super.key,
  });

  final AIModel model;

  @override
  ConsumerState<ModelDetailsScreen> createState() =>
      _ModelDetailsScreenState();
}

class _ModelDetailsScreenState extends ConsumerState<ModelDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isFavorite = false;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Model Details');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    showAccessibleSnackBar(
      context,
      _isFavorite ? 'Added to favorites' : 'Removed from favorites',
    );
  }

  Future<void> _shareModel() async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${widget.model.displayName} by ${widget.model.provider.displayName} - Available on ZeusGPT',
      ),
    );

    if (mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Model link copied to clipboard',
      );
    }
  }

  Future<void> _tryModel() async {
    // In a real implementation, navigate to chat with this model selected
    showAccessibleSnackBar(
      context,
      'Starting chat with ${widget.model.displayName}...',
    );
    // context.push('/chat', extra: widget.model);
  }

  void _selectModel() {
    setState(() => _isSelected = !_isSelected);
    showAccessibleSnackBar(
      context,
      _isSelected
          ? '${widget.model.displayName} selected as default'
          : '${widget.model.displayName} deselected',
    );
  }

  Future<void> _compareWith() async {
    // In a real implementation, navigate to comparison screen
    showAccessibleSnackBar(
      context,
      'Opening model comparison...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero header
          _buildHeroHeader(),

          // Content
          SliverToBoxAdapter(
            child: ResponsiveCenter(
              maxWidth: context.isDesktop ? 1000 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats
                  _buildQuickStats(),

                const SizedBox(height: AppSpacing.lg),

                // Tabs
                _buildTabBar(),

                // Tab content
                _buildTabContent(),
              ],
            ),
          ),
        ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.model.provider.color.withValues(alpha: 0.8),
                    widget.model.provider.color,
                  ],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Provider badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.model.provider.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Model name
                    Text(
                      widget.model.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Version
                    if (widget.model.version != null)
                      Text(
                        'Version ${widget.model.version}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        SemanticIconButton(
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
          label: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          onPressed: _toggleFavorite,
          color: _isFavorite ? Colors.pink : Colors.white,
        ),
        SemanticIconButton(
          icon: Icons.share,
          label: 'Share model details',
          onPressed: _shareModel,
          color: Colors.white,
        ),
        Semantics(
          label: 'More options menu',
          hint: 'Compare, documentation, and API details',
          child: PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'compare',
                child: Row(
                  children: [
                    Icon(Icons.compare_arrows, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Compare with...'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'docs',
                child: Row(
                  children: [
                    Icon(Icons.description, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Documentation'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'api',
                child: Row(
                  children: [
                    Icon(Icons.api, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('API Details'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'compare') _compareWith();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.article,
              label: 'Context',
              value: widget.model.contextWindowFormatted,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildStatCard(
              icon: Icons.attach_money,
              label: 'Price/1M',
              value: widget.model.priceFormatted,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star,
              label: 'Rating',
              value: widget.model.averageRating.toStringAsFixed(1),
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.bodyLarge().copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall().copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Capabilities'),
          Tab(text: 'Performance'),
          Tab(text: 'Details'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCapabilitiesTab(),
          _buildPerformanceTab(),
          _buildDetailsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildSectionHeader('Description'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.model.detailedDescription ??
                widget.model.description ??
                'No description available',
            style: AppTextStyles.bodyMedium(),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Strengths
          if (widget.model.strengths.isNotEmpty) ...[
            _buildSectionHeader('Strengths'),
            const SizedBox(height: AppSpacing.sm),
            ...widget.model.strengths.map((strength) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        strength,
                        style: AppTextStyles.bodyMedium(),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Limitations
          if (widget.model.limitations.isNotEmpty) ...[
            _buildSectionHeader('Limitations'),
            const SizedBox(height: AppSpacing.sm),
            ...widget.model.limitations.map((limitation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        limitation,
                        style: AppTextStyles.bodyMedium(),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Use cases
          if (widget.model.useCases.isNotEmpty) ...[
            _buildSectionHeader('Best For'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: widget.model.useCases.map((useCase) {
                return Chip(
                  avatar: Icon(useCase.icon, size: 16),
                  label: Text(useCase.label),
                  backgroundColor:
                      widget.model.provider.color.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapabilitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Supported Capabilities'),
          const SizedBox(height: AppSpacing.md),

          ...widget.model.capabilities.map((capability) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: AppColors.zeusGradient.scale(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    capability.icon,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  capability.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(capability.description),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            );
          }),

          if (widget.model.capabilities.length < ModelCapability.values.length) ...[
            const SizedBox(height: AppSpacing.md),
            _buildSectionHeader('Not Supported'),
            const SizedBox(height: AppSpacing.md),
            ...ModelCapability.values
                .where((cap) => !widget.model.capabilities.contains(cap))
                .map((capability) {
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                color: Colors.grey.shade50,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      capability.icon,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  title: Text(
                    capability.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  subtitle: Text(
                    capability.description,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  trailing: Icon(
                    Icons.cancel,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ratings
          _buildSectionHeader('Performance Ratings'),
          const SizedBox(height: AppSpacing.md),

          _buildRatingBar(
            label: 'Speed',
            rating: widget.model.speedRating,
            icon: Icons.speed,
            color: Colors.blue,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRatingBar(
            label: 'Quality',
            rating: widget.model.qualityRating,
            icon: Icons.verified,
            color: Colors.green,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRatingBar(
            label: 'Popularity',
            rating: widget.model.popularityRating,
            icon: Icons.trending_up,
            color: Colors.purple,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Context window details
          _buildSectionHeader('Context Window'),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Max Input Tokens',
                        style: AppTextStyles.bodyMedium(),
                      ),
                      Text(
                        widget.model.contextWindowFormatted,
                        style: AppTextStyles.bodyLarge().copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (widget.model.maxOutputTokens != null) ...[
                    const Divider(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Max Output Tokens',
                          style: AppTextStyles.bodyMedium(),
                        ),
                        Text(
                          widget.model.maxOutputTokens!
                              .toString()
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: AppTextStyles.bodyLarge().copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Pricing breakdown
          _buildSectionHeader('Pricing Breakdown'),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildPricingRow(
                    'Input (per 1M tokens)',
                    '\$${widget.model.inputPricePerMillion.toStringAsFixed(2)}',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildPricingRow(
                    'Output (per 1M tokens)',
                    '\$${widget.model.outputPricePerMillion.toStringAsFixed(2)}',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildPricingRow(
                    'Average per 1K tokens',
                    '\$${widget.model.costPer1KTokens.toStringAsFixed(3)}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Pricing examples
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calculate, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Example Costs',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '10K tokens: \$${(widget.model.costPer1KTokens * 10).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
                Text(
                  '100K tokens: \$${(widget.model.costPer1KTokens * 100).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
                Text(
                  '1M tokens: \$${((widget.model.inputPricePerMillion + widget.model.outputPricePerMillion) / 2).toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic info
          _buildSectionHeader('Basic Information'),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildDetailRow('Model ID', widget.model.name),
                  const Divider(height: AppSpacing.lg),
                  _buildDetailRow('Provider', widget.model.provider.displayName),
                  if (widget.model.version != null) ...[
                    const Divider(height: AppSpacing.lg),
                    _buildDetailRow('Version', widget.model.version!),
                  ],
                  if (widget.model.releaseDate != null) ...[
                    const Divider(height: AppSpacing.lg),
                    _buildDetailRow(
                      'Release Date',
                      '${widget.model.releaseDate!.month}/${widget.model.releaseDate!.day}/${widget.model.releaseDate!.year}',
                    ),
                  ],
                  if (widget.model.trainingData != null) ...[
                    const Divider(height: AppSpacing.lg),
                    _buildDetailRow('Training Data', widget.model.trainingData!),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // API Information
          if (widget.model.apiEndpoint != null) ...[
            _buildSectionHeader('API Information'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Endpoint',
                      style: AppTextStyles.bodySmall().copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.model.apiEndpoint!,
                            style: AppTextStyles.bodyMedium().copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        SemanticIconButton(
                          icon: Icons.copy,
                          label: 'Copy API endpoint',
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: widget.model.apiEndpoint!),
                            );
                            if (mounted) {
                              showAccessibleSuccessSnackBar(
                                context,
                                'Endpoint copied',
                              );
                            }
                          },
                          iconSize: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Documentation link
          if (widget.model.documentation != null) ...[
            _buildSectionHeader('Resources'),
            const SizedBox(height: AppSpacing.sm),
            AccessibleListItem(
              label: 'Official Documentation, View full API documentation',
              onTap: () {
                // Open documentation URL
              },
              child: Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.description, color: Colors.blue.shade700),
                  ),
                  title: const Text('Official Documentation'),
                  subtitle: const Text('View full API documentation'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    // Open documentation URL
                  },
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // Related models
          _buildSectionHeader('Related Models'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  child: AccessibleListItem(
                    label: 'Similar Model ${index + 1}, Rating 4.${5 + index}',
                    index: index,
                    totalCount: 3,
                    onTap: () {},
                    child: Card(
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.model.provider.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.model.provider.displayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: widget.model.provider.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Similar Model ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 12, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.${5 + index}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.zeusGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h4().copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar({
    required String label,
    required double rating,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodyMedium().copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${rating.toStringAsFixed(1)} / 5.0',
              style: AppTextStyles.bodyMedium().copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: rating / 5.0,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.7),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium().copyWith(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight ? AppColors.primary : null,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge().copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodySmall().copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _selectModel,
              icon: Icon(_isSelected ? Icons.check_circle : Icons.radio_button_unchecked),
              label: Text(_isSelected ? 'Selected' : 'Select Model'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                side: BorderSide(
                  color: _isSelected ? Colors.green : Colors.grey.shade300,
                ),
                foregroundColor: _isSelected ? Colors.green : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _tryModel,
              icon: const Icon(Icons.chat_bubble),
              label: const Text('Try Model'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sample model data for testing
final sampleModel = AIModel(
  id: 'claude-3-opus',
  name: 'claude-3-opus-20240229',
  displayName: 'Claude 3 Opus',
  provider: AIProvider.anthropic,
  capabilities: [
    ModelCapability.chat,
    ModelCapability.code,
    ModelCapability.vision,
    ModelCapability.reasoning,
    ModelCapability.longContext,
    ModelCapability.functionCalling,
    ModelCapability.streaming,
  ],
  contextWindow: 200000,
  inputPricePerMillion: 15.0,
  outputPricePerMillion: 75.0,
  description: 'Most intelligent Claude model',
  detailedDescription:
      'Claude 3 Opus is Anthropic\'s most intelligent model, with best-in-class performance on highly complex tasks. It can navigate open-ended prompts and sight-unseen scenarios with remarkable fluency and human-like understanding.',
  version: '3.0',
  releaseDate: DateTime(2024, 2, 29),
  speedRating: 3.8,
  popularityRating: 4.9,
  qualityRating: 4.9,
  useCases: [
    UseCase.contentCreation,
    UseCase.codeAssistance,
    UseCase.research,
    UseCase.dataAnalysis,
  ],
  strengths: [
    'Exceptional reasoning and problem-solving abilities',
    'Strong performance on complex, multi-step tasks',
    'Excellent at following nuanced instructions',
    'Superior code generation and analysis',
    'Very large context window (200K tokens)',
  ],
  limitations: [
    'Higher cost compared to smaller models',
    'Slower response time than lighter models',
    'May be overkill for simple tasks',
  ],
  trainingData: 'Up to December 2023',
  apiEndpoint: 'https://api.anthropic.com/v1/messages',
  documentation: 'https://docs.anthropic.com',
  maxOutputTokens: 4096,
  isDeprecated: false,
);
