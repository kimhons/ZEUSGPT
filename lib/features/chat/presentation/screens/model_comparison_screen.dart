import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
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
    this.version,
    this.speedRating = 0.0,
    this.popularityRating = 0.0,
    this.releaseDate,
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
  final String? version;
  final double speedRating; // 0.0 - 5.0
  final double popularityRating; // 0.0 - 5.0
  final DateTime? releaseDate;

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
    return '\$${inputPricePerMillion.toStringAsFixed(2)}/\$${outputPricePerMillion.toStringAsFixed(2)}';
  }

  double get costPer1KTokens => (inputPricePerMillion + outputPricePerMillion) / 1000;
}

/// Comparison category
enum ComparisonCategory {
  overview,
  pricing,
  performance,
  capabilities,
}

extension ComparisonCategoryExtension on ComparisonCategory {
  String get label {
    switch (this) {
      case ComparisonCategory.overview:
        return 'Overview';
      case ComparisonCategory.pricing:
        return 'Pricing';
      case ComparisonCategory.performance:
        return 'Performance';
      case ComparisonCategory.capabilities:
        return 'Capabilities';
    }
  }

  IconData get icon {
    switch (this) {
      case ComparisonCategory.overview:
        return Icons.info_outline;
      case ComparisonCategory.pricing:
        return Icons.attach_money;
      case ComparisonCategory.performance:
        return Icons.speed;
      case ComparisonCategory.capabilities:
        return Icons.stars;
    }
  }
}

/// Screen for comparing multiple AI models side by side
class ModelComparisonScreen extends ConsumerStatefulWidget {
  const ModelComparisonScreen({
    this.initialModels = const [],
    super.key,
  });

  final List<AIModel> initialModels;

  @override
  ConsumerState<ModelComparisonScreen> createState() =>
      _ModelComparisonScreenState();
}

class _ModelComparisonScreenState extends ConsumerState<ModelComparisonScreen>
    with SingleTickerProviderStateMixin {
  late List<AIModel?> _comparisonModels;
  ComparisonCategory _selectedCategory = ComparisonCategory.overview;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ComparisonCategory.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = ComparisonCategory.values[_tabController.index];
      });
    });

    // Initialize with provided models or empty slots (max 4 models)
    _comparisonModels = List<AIModel?>.filled(4, null);
    for (var i = 0; i < widget.initialModels.length && i < 4; i++) {
      _comparisonModels[i] = widget.initialModels[i];
    }

    // If no models provided, add sample models
    if (_comparisonModels.every((m) => m == null)) {
      _comparisonModels[0] = _sampleModels[0];
      _comparisonModels[1] = _sampleModels[1];
    }

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Compare Models');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<AIModel> get _selectedModels =>
      _comparisonModels.whereType<AIModel>().toList();

  Future<void> _addModel(int index) async {
    // In a real implementation, navigate to model selection
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ModelSelectionSheet(
        onModelSelected: (model) {
          setState(() => _comparisonModels[index] = model);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeModel(int index) {
    setState(() => _comparisonModels[index] = null);
  }

  void _clearAll() {
    setState(() {
      for (var i = 0; i < _comparisonModels.length; i++) {
        _comparisonModels[i] = null;
      }
    });
  }

  Future<void> _saveComparison() async {
    if (_selectedModels.isEmpty) {
      showAccessibleErrorSnackBar(
        context,
        'Add models to save comparison',
      );
      return;
    }

    // Simulate saving
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Comparison saved (${_selectedModels.length} models)',
      );
    }
  }

  Future<void> _exportComparison() async {
    if (_selectedModels.isEmpty) {
      showAccessibleErrorSnackBar(
        context,
        'Add models to export comparison',
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ExportBottomSheet(
        modelCount: _selectedModels.length,
      ),
    );
  }

  Future<void> _shareComparison() async {
    if (_selectedModels.isEmpty) {
      showAccessibleErrorSnackBar(
        context,
        'Add models to share comparison',
      );
      return;
    }

    // In a real implementation, use share_plus package
    final models = _selectedModels.map((m) => m.displayName).join(', ');
    await Clipboard.setData(
      ClipboardData(text: 'Comparing: $models on ZeusGPT'),
    );

    if (mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Comparison link copied to clipboard',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Models'),
        actions: [
          if (_selectedModels.isNotEmpty) ...[
            SemanticIconButton(
              icon: Icons.save_outlined,
              label: 'Save comparison',
              onPressed: _saveComparison,
            ),
            SemanticIconButton(
              icon: Icons.share,
              label: 'Share comparison',
              onPressed: _shareComparison,
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text('Export'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'export') {
                  _exportComparison();
                } else if (value == 'clear') {
                  _clearAll();
                }
              },
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: ComparisonCategory.values.map((category) {
            return Tab(
              icon: Icon(category.icon, size: 20),
              text: category.label,
            );
          }).toList(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1000 : double.infinity,
          child: Column(
            children: [
            // Model count indicator
            if (_selectedModels.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.zeusGradient.scale(0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      gradient: AppColors.zeusGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_selectedModels.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_selectedModels.length} ${_selectedModels.length == 1 ? "model" : "models"} selected',
                    style: AppTextStyles.bodySmall().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Comparison content
          Expanded(
            child: _selectedModels.isEmpty
                ? _buildEmptyState()
                : _buildComparisonContent(),
          ),
        ],
          ),  // Close Column
        ),  // Close ResponsiveCenter
      ),  // Close SafeArea
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.zeusGradient.scale(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.compare_arrows,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Models Selected',
              style: AppTextStyles.h3().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add 2-4 models to start comparing their features, pricing, and performance',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium().copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _addModel(0),
              icon: const Icon(Icons.add),
              label: const Text('Add First Model'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model cards row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_comparisonModels.length, (index) {
                final model = _comparisonModels[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _comparisonModels.length - 1
                        ? AppSpacing.md
                        : 0,
                  ),
                  child: model == null
                      ? _buildAddModelCard(index)
                      : _buildModelCard(model, index),
                );
              }),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Comparison content based on category
          _buildCategoryContent(),
        ],
      ),
    );
  }

  Widget _buildAddModelCard(int index) {
    return Container(
      width: 280,
      height: 180,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addModel(index),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 32,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Add Model',
                style: AppTextStyles.bodyMedium().copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelCard(AIModel model, int index) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            model.provider.color.withValues(alpha: 0.1),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: model.provider.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with provider and remove button
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  model.provider.color.withValues(alpha: 0.8),
                  model.provider.color,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    model.provider.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SemanticIconButton(
                  icon: Icons.close,
                  label: 'Remove ${model.displayName}',
                  color: Colors.white,
                  iconSize: 20,
                  onPressed: () => _removeModel(index),
                ),
              ],
            ),
          ),

          // Model info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.displayName,
                  style: AppTextStyles.bodyLarge().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (model.version != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'v${model.version}',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),

                // Quick stats
                Row(
                  children: [
                    Icon(Icons.article, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      model.contextWindowFormatted,
                      style: AppTextStyles.bodySmall(),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        model.priceFormatted,
                        style: AppTextStyles.bodySmall(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Ratings
                Row(
                  children: [
                    _buildRating(
                      Icons.speed,
                      model.speedRating,
                      'Speed',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _buildRating(
                      Icons.star,
                      model.popularityRating,
                      'Popular',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating(IconData icon, double rating, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.bodySmall().copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryContent() {
    switch (_selectedCategory) {
      case ComparisonCategory.overview:
        return _buildOverviewComparison();
      case ComparisonCategory.pricing:
        return _buildPricingComparison();
      case ComparisonCategory.performance:
        return _buildPerformanceComparison();
      case ComparisonCategory.capabilities:
        return _buildCapabilitiesComparison();
    }
  }

  Widget _buildOverviewComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Basic Information'),
        const SizedBox(height: AppSpacing.md),
        _buildComparisonTable([
          _ComparisonRow(
            'Provider',
            _selectedModels.map((m) => m.provider.displayName).toList(),
          ),
          _ComparisonRow(
            'Model Name',
            _selectedModels.map((m) => m.displayName).toList(),
          ),
          _ComparisonRow(
            'Version',
            _selectedModels.map((m) => m.version ?? 'N/A').toList(),
          ),
          _ComparisonRow(
            'Release Date',
            _selectedModels
                .map((m) => m.releaseDate != null
                    ? '${m.releaseDate!.month}/${m.releaseDate!.year}'
                    : 'N/A')
                .toList(),
          ),
        ]),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionHeader('Description'),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(_selectedModels.length, (index) {
          final model = _selectedModels[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                model.provider.color,
                                model.provider.color.withValues(alpha: 0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          model.displayName,
                          style: AppTextStyles.bodyMedium().copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      model.description ?? 'No description available',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPricingComparison() {
    // Find max price for bar chart scaling
    final maxPrice = _selectedModels
        .map((m) => m.costPer1KTokens)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Price per Million Tokens'),
        const SizedBox(height: AppSpacing.md),
        _buildComparisonTable([
          _ComparisonRow(
            'Input',
            _selectedModels
                .map((m) => '\$${m.inputPricePerMillion.toStringAsFixed(2)}')
                .toList(),
          ),
          _ComparisonRow(
            'Output',
            _selectedModels
                .map((m) => '\$${m.outputPricePerMillion.toStringAsFixed(2)}')
                .toList(),
          ),
          _ComparisonRow(
            'Combined',
            _selectedModels.map((m) => m.priceFormatted).toList(),
            highlight: true,
          ),
        ]),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionHeader('Cost per 1K Tokens'),
        const SizedBox(height: AppSpacing.md),
        ..._selectedModels.map((model) {
          final percentage = (model.costPer1KTokens / maxPrice);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        model.displayName,
                        style: AppTextStyles.bodySmall().copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    model.provider.color.withValues(alpha: 0.7),
                                    model.provider.color,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '\$${model.costPer1KTokens.toStringAsFixed(3)}',
                        style: AppTextStyles.bodySmall().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Prices shown are per million tokens. Actual costs may vary based on usage patterns.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceComparison() {
    // Find max context window for scaling
    final maxContext = _selectedModels
        .map((m) => m.contextWindow)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Context Window'),
        const SizedBox(height: AppSpacing.md),
        ..._selectedModels.map((model) {
          final percentage = model.contextWindow / maxContext;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    model.displayName,
                    style: AppTextStyles.bodySmall().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                model.provider.color.withValues(alpha: 0.7),
                                model.provider.color,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 60,
                  child: Text(
                    model.contextWindowFormatted,
                    style: AppTextStyles.bodySmall().copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionHeader('Speed Rating'),
        const SizedBox(height: AppSpacing.md),
        ..._selectedModels.map((model) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    model.displayName,
                    style: AppTextStyles.bodySmall().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < model.speedRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                ),
                Text(
                  model.speedRating.toStringAsFixed(1),
                  style: AppTextStyles.bodySmall().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionHeader('Popularity Rating'),
        const SizedBox(height: AppSpacing.md),
        ..._selectedModels.map((model) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    model.displayName,
                    style: AppTextStyles.bodySmall().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < model.popularityRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                ),
                Text(
                  model.popularityRating.toStringAsFixed(1),
                  style: AppTextStyles.bodySmall().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCapabilitiesComparison() {
    // Get all unique capabilities across selected models
    final allCapabilities = <ModelCapability>{};
    for (final model in _selectedModels) {
      allCapabilities.addAll(model.capabilities);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Capabilities Matrix'),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              AppColors.primary.withValues(alpha: 0.1),
            ),
            columns: [
              const DataColumn(
                label: Text(
                  'Capability',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ..._selectedModels.map((model) {
                return DataColumn(
                  label: SizedBox(
                    width: 100,
                    child: Text(
                      model.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ],
            rows: allCapabilities.map((capability) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Icon(capability.icon, size: 16),
                        const SizedBox(width: AppSpacing.xs),
                        Text(capability.label),
                      ],
                    ),
                  ),
                  ..._selectedModels.map((model) {
                    final hasCapability = model.capabilities.contains(capability);
                    return DataCell(
                      Center(
                        child: Icon(
                          hasCapability ? Icons.check_circle : Icons.cancel,
                          color: hasCapability ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionHeader('Capability Count'),
        const SizedBox(height: AppSpacing.md),
        ..._selectedModels.map((model) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            model.provider.color,
                            model.provider.color.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.displayName,
                            style: AppTextStyles.bodyMedium().copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: model.capabilities.map((cap) {
                              return Chip(
                                label: Text(
                                  cap.label,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                avatar: Icon(cap.icon, size: 12),
                                backgroundColor: model.provider.color.withValues(alpha: 0.1),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: AppColors.zeusGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${model.capabilities.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
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

  Widget _buildComparisonTable(List<_ComparisonRow> rows) {
    return Card(
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          final isLast = index == rows.length - 1;

          return Container(
            decoration: BoxDecoration(
              color: row.highlight
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : null,
              border: !isLast
                  ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      row.label,
                      style: AppTextStyles.bodySmall().copyWith(
                        fontWeight: FontWeight.w600,
                        color: row.highlight ? AppColors.primary : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: List.generate(row.values.length, (i) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: i > 0 ? AppSpacing.sm : 0,
                            ),
                            child: Text(
                              row.values[i],
                              style: AppTextStyles.bodySmall().copyWith(
                                fontWeight: row.highlight
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Sample data
  static final List<AIModel> _sampleModels = [
    const AIModel(
      id: 'gpt-4',
      name: 'gpt-4',
      displayName: 'GPT-4',
      provider: AIProvider.openai,
      capabilities: [
        ModelCapability.chat,
        ModelCapability.code,
        ModelCapability.reasoning,
      ],
      contextWindow: 8192,
      inputPricePerMillion: 30.0,
      outputPricePerMillion: 60.0,
      description:
          'Most capable GPT-4 model with advanced reasoning and instruction following',
      version: '0613',
      speedRating: 3.5,
      popularityRating: 4.8,
      releaseDate: null,
    ),
    const AIModel(
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
      ],
      contextWindow: 200000,
      inputPricePerMillion: 15.0,
      outputPricePerMillion: 75.0,
      description:
          'Most intelligent Claude model with best-in-class performance on complex tasks',
      version: '3.0',
      speedRating: 3.8,
      popularityRating: 4.9,
      releaseDate: null,
    ),
    const AIModel(
      id: 'gemini-pro',
      name: 'gemini-pro',
      displayName: 'Gemini Pro',
      provider: AIProvider.google,
      capabilities: [
        ModelCapability.chat,
        ModelCapability.code,
        ModelCapability.vision,
      ],
      contextWindow: 32768,
      inputPricePerMillion: 0.5,
      outputPricePerMillion: 1.5,
      description: 'Google\'s most capable AI model for complex reasoning',
      version: '1.0',
      speedRating: 4.2,
      popularityRating: 4.3,
      releaseDate: null,
    ),
    const AIModel(
      id: 'llama-3-70b',
      name: 'llama-3-70b',
      displayName: 'Llama 3 70B',
      provider: AIProvider.meta,
      capabilities: [
        ModelCapability.chat,
        ModelCapability.code,
      ],
      contextWindow: 8192,
      inputPricePerMillion: 0.9,
      outputPricePerMillion: 0.9,
      description: 'Meta\'s powerful open-source language model',
      version: '3.0',
      speedRating: 4.5,
      popularityRating: 4.5,
      releaseDate: null,
    ),
  ];
}

/// Comparison row data
class _ComparisonRow {
  const _ComparisonRow(
    this.label,
    this.values, {
    this.highlight = false,
  });

  final String label;
  final List<String> values;
  final bool highlight;
}

/// Model selection bottom sheet
class _ModelSelectionSheet extends StatelessWidget {
  const _ModelSelectionSheet({
    required this.onModelSelected,
  });

  final Function(AIModel) onModelSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Select Model',
                style: AppTextStyles.h4().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: _ModelComparisonScreenState._sampleModels.length,
              itemBuilder: (context, index) {
                final model = _ModelComparisonScreenState._sampleModels[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: model.provider.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      color: model.provider.color,
                    ),
                  ),
                  title: Text(
                    model.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    model.provider.displayName,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onModelSelected(model),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Export options bottom sheet
class _ExportBottomSheet extends StatelessWidget {
  const _ExportBottomSheet({
    required this.modelCount,
  });

  final int modelCount;

  Future<void> _export(BuildContext context, String format) async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Exported comparison as $format',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Export Comparison',
                style: AppTextStyles.h4().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Export $modelCount ${modelCount == 1 ? "model" : "models"} comparison',
            style: AppTextStyles.bodySmall().copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          _ExportOption(
            icon: Icons.picture_as_pdf,
            title: 'PDF Document',
            description: 'Full comparison with charts',
            onTap: () => _export(context, 'PDF'),
          ),
          _ExportOption(
            icon: Icons.table_chart,
            title: 'CSV Spreadsheet',
            description: 'Data in tabular format',
            onTap: () => _export(context, 'CSV'),
          ),
          _ExportOption(
            icon: Icons.code,
            title: 'JSON Data',
            description: 'Structured data format',
            onTap: () => _export(context, 'JSON'),
          ),
          _ExportOption(
            icon: Icons.image,
            title: 'PNG Image',
            description: 'Visual comparison snapshot',
            onTap: () => _export(context, 'PNG'),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Export option tile
class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium().copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
