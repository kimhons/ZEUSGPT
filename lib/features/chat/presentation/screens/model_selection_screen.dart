import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';

/// AI Model provider
enum AIProvider {
  openai,
  anthropic,
  google,
  meta,
  mistral,
  cohere,
  other,
  all,
}

extension AIProviderExtension on AIProvider {
  String get label {
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
      case AIProvider.all:
        return 'All Providers';
    }
  }

  Color get color {
    switch (this) {
      case AIProvider.openai:
        return const Color(0xFF00A67E);
      case AIProvider.anthropic:
        return const Color(0xFFD97757);
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
      case AIProvider.all:
        return AppColors.primary;
    }
  }
}

/// Model capability
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
        return Icons.chat;
      case ModelCapability.code:
        return Icons.code;
      case ModelCapability.vision:
        return Icons.visibility;
      case ModelCapability.audio:
        return Icons.audiotrack;
      case ModelCapability.reasoning:
        return Icons.psychology;
      case ModelCapability.longContext:
        return Icons.description;
    }
  }
}

/// Sort option for models
enum ModelSort {
  popular,
  priceLowToHigh,
  priceHighToLow,
  newest,
  contextLength,
  speed,
}

extension ModelSortExtension on ModelSort {
  String get label {
    switch (this) {
      case ModelSort.popular:
        return 'Most Popular';
      case ModelSort.priceLowToHigh:
        return 'Price: Low to High';
      case ModelSort.priceHighToLow:
        return 'Price: High to Low';
      case ModelSort.newest:
        return 'Newest First';
      case ModelSort.contextLength:
        return 'Context Length';
      case ModelSort.speed:
        return 'Speed';
    }
  }
}

/// AI Model data
class AIModel {
  const AIModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.provider,
    required this.capabilities,
    this.contextWindow = 4096,
    this.inputPricePerMillion = 0.0,
    this.outputPricePerMillion = 0.0,
    this.description,
    this.isPopular = false,
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
  final bool isPopular;
  final DateTime? releaseDate;

  String get contextWindowFormatted {
    if (contextWindow >= 1000000) {
      return '${(contextWindow / 1000000).toStringAsFixed(1)}M';
    } else if (contextWindow >= 1000) {
      return '${(contextWindow / 1000).toStringAsFixed(0)}K';
    } else {
      return contextWindow.toString();
    }
  }

  String get priceFormatted {
    if (inputPricePerMillion == 0 && outputPricePerMillion == 0) {
      return 'Free';
    }
    return '\$${inputPricePerMillion.toStringAsFixed(2)}/\$${outputPricePerMillion.toStringAsFixed(2)}';
  }
}

/// Screen for selecting AI models
class ModelSelectionScreen extends ConsumerStatefulWidget {
  const ModelSelectionScreen({
    this.currentModelId,
    super.key,
  });

  final String? currentModelId;

  @override
  ConsumerState<ModelSelectionScreen> createState() =>
      _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends ConsumerState<ModelSelectionScreen>
    with SingleTickerProviderStateMixin {
  AIProvider _selectedProvider = AIProvider.all;
  ModelSort _sortOption = ModelSort.popular;
  final Set<ModelCapability> _selectedCapabilities = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  // Sample models - in real implementation, fetch from provider/API
  final List<AIModel> _allModels = [
    const AIModel(
      id: 'gpt-4',
      name: 'gpt-4',
      displayName: 'GPT-4',
      provider: AIProvider.openai,
      capabilities: [ModelCapability.chat, ModelCapability.code, ModelCapability.reasoning],
      contextWindow: 8192,
      inputPricePerMillion: 30.0,
      outputPricePerMillion: 60.0,
      description: 'Most capable GPT-4 model, great for complex tasks',
      isPopular: true,
    ),
    const AIModel(
      id: 'claude-3-opus',
      name: 'claude-3-opus-20240229',
      displayName: 'Claude 3 Opus',
      provider: AIProvider.anthropic,
      capabilities: [ModelCapability.chat, ModelCapability.code, ModelCapability.vision, ModelCapability.reasoning],
      contextWindow: 200000,
      inputPricePerMillion: 15.0,
      outputPricePerMillion: 75.0,
      description: 'Anthropic\'s most capable model with long context',
      isPopular: true,
    ),
    const AIModel(
      id: 'gemini-pro',
      name: 'gemini-pro',
      displayName: 'Gemini Pro',
      provider: AIProvider.google,
      capabilities: [ModelCapability.chat, ModelCapability.code, ModelCapability.reasoning],
      contextWindow: 32768,
      inputPricePerMillion: 0.5,
      outputPricePerMillion: 1.5,
      description: 'Google\'s efficient and capable model',
      isPopular: true,
    ),
    const AIModel(
      id: 'llama-3-70b',
      name: 'llama-3-70b',
      displayName: 'Llama 3 70B',
      provider: AIProvider.meta,
      capabilities: [ModelCapability.chat, ModelCapability.code],
      contextWindow: 8192,
      inputPricePerMillion: 0.0,
      outputPricePerMillion: 0.0,
      description: 'Meta\'s open-source model',
      isPopular: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AIProvider.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedProvider = AIProvider.values[_tabController.index];
        });
      }
    });

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Model Selection');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<AIModel> get _filteredModels {
    var models = _allModels;

    // Filter by provider
    if (_selectedProvider != AIProvider.all) {
      models = models.where((m) => m.provider == _selectedProvider).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      models = models
          .where((m) =>
              m.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (m.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }

    // Filter by capabilities
    if (_selectedCapabilities.isNotEmpty) {
      models = models
          .where((m) => _selectedCapabilities
              .every((cap) => m.capabilities.contains(cap)))
          .toList();
    }

    // Sort
    switch (_sortOption) {
      case ModelSort.popular:
        models.sort((a, b) => b.isPopular ? 1 : -1);
        break;
      case ModelSort.priceLowToHigh:
        models.sort((a, b) => a.inputPricePerMillion.compareTo(b.inputPricePerMillion));
        break;
      case ModelSort.priceHighToLow:
        models.sort((a, b) => b.inputPricePerMillion.compareTo(a.inputPricePerMillion));
        break;
      case ModelSort.contextLength:
        models.sort((a, b) => b.contextWindow.compareTo(a.contextWindow));
        break;
      case ModelSort.newest:
        // Would sort by release date if available
        break;
      case ModelSort.speed:
        // Would sort by speed metrics if available
        break;
    }

    return models;
  }

  void _selectModel(AIModel model) {
    context.pop(model);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        sortOption: _sortOption,
        selectedCapabilities: _selectedCapabilities,
        onSortChanged: (sort) {
          setState(() => _sortOption = sort);
        },
        onCapabilitiesChanged: (capabilities) {
          setState(() {
            _selectedCapabilities.clear();
            _selectedCapabilities.addAll(capabilities);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select AI Model'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search models...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchQuery.isNotEmpty)
                          SemanticIconButton(
                            icon: Icons.clear,
                            label: 'Clear search',
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          ),
                        SemanticIconButton(
                          icon: Icons.tune,
                          label: 'Open filter options',
                          onPressed: _showFilterSheet,
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),

              // Provider tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: AIProvider.values.map((provider) {
                  return Tab(text: provider.label);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1000 : double.infinity,
          child: Column(
            children: [
              // Active filters
              if (_selectedCapabilities.isNotEmpty || _sortOption != ModelSort.popular)
                _buildActiveFiltersBar(),

              // Model list
              Expanded(
                child: _filteredModels.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _filteredModels.length,
                        itemBuilder: (context, index) {
                          final model = _filteredModels[index];
                          final isSelected = model.id == widget.currentModelId;

                          return _buildModelCard(model, isSelected);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Sort chip
            if (_sortOption != ModelSort.popular)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: Chip(
                  label: Text(_sortOption.label),
                  avatar: const Icon(Icons.sort, size: 16),
                  onDeleted: () {
                    setState(() => _sortOption = ModelSort.popular);
                  },
                ),
              ),

            // Capability chips
            ..._selectedCapabilities.map(
              (cap) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: Chip(
                  label: Text(cap.label),
                  avatar: Icon(cap.icon, size: 16),
                  onDeleted: () {
                    setState(() => _selectedCapabilities.remove(cap));
                  },
                ),
              ),
            ),

            // Clear all
            if (_selectedCapabilities.isNotEmpty || _sortOption != ModelSort.popular)
              TextButton(
                onPressed: () {
                  setState(() {
                    _sortOption = ModelSort.popular;
                    _selectedCapabilities.clear();
                  });
                },
                child: const Text('Clear All'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(AIModel model, bool isSelected) {
    return Semantics(
      label: '${model.displayName} by ${model.provider.label}. ${model.description ?? ""}. ${isSelected ? "Currently selected" : "Tap to select"}',
      selected: isSelected,
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? BorderSide(color: AppColors.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => _selectModel(model),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: model.provider.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.smart_toy,
                      color: model.provider.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              model.displayName,
                              style: AppTextStyles.bodyLarge().copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (model.isPopular) ...[
                              const SizedBox(width: AppSpacing.xs),
                              ExcludeSemantics(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.zeusGradient,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'POPULAR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (isSelected) ...[
                              const SizedBox(width: AppSpacing.xs),
                              ExcludeSemantics(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'CURRENT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          model.provider.label,
                          style: AppTextStyles.bodySmall().copyWith(
                            color: model.provider.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (model.description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  model.description!,
                  style: AppTextStyles.bodySmall().copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),

              // Capabilities
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: model.capabilities.map((cap) {
                  return Semantics(
                    label: '${cap.label} capability',
                    child: Chip(
                      label: Text(cap.label),
                      avatar: Icon(cap.icon, size: 14),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Stats
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.account_tree,
                    label: model.contextWindowFormatted,
                    tooltip: 'Context Window',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildStatChip(
                    icon: Icons.attach_money,
                    label: model.priceFormatted,
                    tooltip: 'Input/Output Price per 1M tokens',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'No models found',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient.scale(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No Models Found',
              style: AppTextStyles.h4().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Try adjusting your search or filters',
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

/// Filter bottom sheet
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({
    required this.sortOption,
    required this.selectedCapabilities,
    required this.onSortChanged,
    required this.onCapabilitiesChanged,
  });

  final ModelSort sortOption;
  final Set<ModelCapability> selectedCapabilities;
  final ValueChanged<ModelSort> onSortChanged;
  final ValueChanged<Set<ModelCapability>> onCapabilitiesChanged;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late ModelSort _sortOption;
  late Set<ModelCapability> _selectedCapabilities;

  @override
  void initState() {
    super.initState();
    _sortOption = widget.sortOption;
    _selectedCapabilities = Set.from(widget.selectedCapabilities);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Semantics(
                label: 'Filter and sort options',
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: AppColors.zeusGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Filter & Sort',
                style: AppTextStyles.h4().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Sort section
          Text(
            'Sort By',
            style: AppTextStyles.bodyLarge().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...ModelSort.values.map(
            (sort) => RadioListTile<ModelSort>(
              value: sort,
              groupValue: _sortOption,
              title: Text(sort.label),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortOption = value);
                }
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Capabilities section
          Text(
            'Capabilities',
            style: AppTextStyles.bodyLarge().copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...ModelCapability.values.map(
            (cap) => CheckboxListTile(
              value: _selectedCapabilities.contains(cap),
              title: Row(
                children: [
                  Icon(cap.icon, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(cap.label),
                ],
              ),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedCapabilities.add(cap);
                  } else {
                    _selectedCapabilities.remove(cap);
                  }
                });
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSortChanged(_sortOption);
                widget.onCapabilitiesChanged(_selectedCapabilities);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('Apply Filters'),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
