import 'dart:async';
import 'dart:math';
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

/// AI Model data class
class AIModel {
  const AIModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.provider,
    required this.contextWindow,
    required this.inputPricePerMillion,
    required this.outputPricePerMillion,
  });

  final String id;
  final String name;
  final String displayName;
  final AIProvider provider;
  final int contextWindow;
  final double inputPricePerMillion;
  final double outputPricePerMillion;

  double get costPer1KTokens =>
      (inputPricePerMillion + outputPricePerMillion) / 1000;

  String get contextWindowFormatted {
    if (contextWindow >= 1000000) {
      return '${(contextWindow / 1000000).toStringAsFixed(1)}M';
    } else if (contextWindow >= 1000) {
      return '${(contextWindow / 1000).toStringAsFixed(0)}K';
    }
    return contextWindow.toString();
  }
}

/// Model response state
enum ResponseState {
  idle,
  streaming,
  completed,
  error,
}

/// Model response data
class ModelResponse {
  ModelResponse({
    required this.modelId,
    required this.content,
    required this.state,
    this.tokenCount = 0,
    this.responseTime,
    this.error,
    this.votes = 0,
  });

  final String modelId;
  final String content;
  final ResponseState state;
  final int tokenCount;
  final Duration? responseTime;
  final String? error;
  final int votes;

  ModelResponse copyWith({
    String? content,
    ResponseState? state,
    int? tokenCount,
    Duration? responseTime,
    String? error,
    int? votes,
  }) {
    return ModelResponse(
      modelId: modelId,
      content: content ?? this.content,
      state: state ?? this.state,
      tokenCount: tokenCount ?? this.tokenCount,
      responseTime: responseTime ?? this.responseTime,
      error: error ?? this.error,
      votes: votes ?? this.votes,
    );
  }

  double calculateCost(AIModel model) {
    // Approximate: assume equal input/output tokens
    final avgTokens = tokenCount / 2;
    final inputCost = (avgTokens / 1000000) * model.inputPricePerMillion;
    final outputCost = (avgTokens / 1000000) * model.outputPricePerMillion;
    return inputCost + outputCost;
  }
}

/// Message in multi-model chat
class MultiModelMessage {
  const MultiModelMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.responses = const {},
  });

  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, ModelResponse> responses; // modelId -> response

  MultiModelMessage copyWith({
    Map<String, ModelResponse>? responses,
  }) {
    return MultiModelMessage(
      id: id,
      content: content,
      isUser: isUser,
      timestamp: timestamp,
      responses: responses ?? this.responses,
    );
  }
}

/// Screen for chatting with multiple models simultaneously
class MultiModelChatScreen extends ConsumerStatefulWidget {
  const MultiModelChatScreen({
    this.initialModels = const [],
    super.key,
  });

  final List<AIModel> initialModels;

  @override
  ConsumerState<MultiModelChatScreen> createState() =>
      _MultiModelChatScreenState();
}

class _MultiModelChatScreenState extends ConsumerState<MultiModelChatScreen> {
  final List<AIModel> _selectedModels = [];
  final List<MultiModelMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;
  bool _showMetrics = true;
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    // Initialize with provided models or defaults
    if (widget.initialModels.isNotEmpty) {
      _selectedModels.addAll(widget.initialModels.take(4));
    } else {
      _selectedModels.addAll(_sampleModels.take(2));
    }

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Multi-Model Chat');
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectModels() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ModelSelectionSheet(
        selectedModels: _selectedModels,
        onModelsSelected: (models) {
          setState(() {
            _selectedModels.clear();
            _selectedModels.addAll(models);
          });
        },
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedModels.isEmpty || _isProcessing) return;

    _messageController.clear();
    setState(() => _isProcessing = true);

    // Add user message
    final userMessage = MultiModelMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() => _messages.add(userMessage));
    _scrollToBottom();

    // Create response message
    final responseMessage = MultiModelMessage(
      id: '${userMessage.id}_response',
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      responses: {},
    );

    setState(() => _messages.add(responseMessage));

    // Simulate parallel model execution
    await _executeModelsParallel(text, responseMessage);

    setState(() => _isProcessing = false);
  }

  Future<void> _executeModelsParallel(
    String prompt,
    MultiModelMessage responseMessage,
  ) async {
    // Start all models simultaneously
    final futures = _selectedModels.map((model) {
      return _simulateModelResponse(prompt, model);
    });

    // Track responses as they complete
    var completedCount = 0;
    for (final future in futures) {
      final response = await future;
      setState(() {
        final updatedResponses = Map<String, ModelResponse>.from(
          responseMessage.responses,
        );
        updatedResponses[response.modelId] = response;

        final index = _messages.indexOf(responseMessage);
        if (index != -1) {
          _messages[index] = responseMessage.copyWith(
            responses: updatedResponses,
          );
        }
      });

      completedCount++;
      if (_autoScroll) _scrollToBottom();
    }
  }

  Future<ModelResponse> _simulateModelResponse(
    String prompt,
    AIModel model,
  ) async {
    final startTime = DateTime.now();
    final random = Random();

    // Simulate different response speeds
    final baseDelay = Duration(milliseconds: 100 + random.nextInt(100));
    final chunks = 10 + random.nextInt(20);

    var content = '';
    var response = ModelResponse(
      modelId: model.id,
      content: content,
      state: ResponseState.streaming,
    );

    // Simulate streaming
    for (var i = 0; i < chunks; i++) {
      await Future.delayed(baseDelay);

      content += _generateResponseChunk(prompt, model, i, chunks);

      final tokenCount = content.split(' ').length;
      response = response.copyWith(
        content: content,
        tokenCount: tokenCount,
      );

      // Update UI periodically (not every chunk to avoid too many rebuilds)
      if (i % 3 == 0) {
        setState(() {
          final message = _messages.last;
          final updatedResponses = Map<String, ModelResponse>.from(
            message.responses,
          );
          updatedResponses[model.id] = response;

          final index = _messages.indexOf(message);
          if (index != -1) {
            _messages[index] = message.copyWith(
              responses: updatedResponses,
            );
          }
        });
      }
    }

    final responseTime = DateTime.now().difference(startTime);

    return response.copyWith(
      state: ResponseState.completed,
      responseTime: responseTime,
    );
  }

  String _generateResponseChunk(
    String prompt,
    AIModel model,
    int chunkIndex,
    int totalChunks,
  ) {
    // Generate contextual response based on model and prompt
    final sampleResponses = {
      'gpt-4': [
        'Based on my analysis, ',
        'I can help you with that. ',
        'Let me break this down: ',
        'Here\'s what I recommend: ',
        'The key points to consider are: ',
        'In summary, ',
        'This approach would be effective because ',
        'Additionally, you might want to ',
        'From my perspective, ',
        'To conclude, ',
      ],
      'claude-3-opus': [
        'I\'d be happy to assist. ',
        'Let me think about this carefully. ',
        'Here\'s my detailed analysis: ',
        'I\'ll provide a comprehensive answer. ',
        'Based on the context, ',
        'It\'s worth noting that ',
        'I should also mention ',
        'Furthermore, ',
        'In this case, ',
        'To wrap up, ',
      ],
      'gemini-pro': [
        'Sure, let me help. ',
        'Here\'s what I found: ',
        'According to my knowledge, ',
        'I can explain this as follows: ',
        'The main factors are: ',
        'It\'s important to understand ',
        'Another aspect to consider is ',
        'This relates to ',
        'In addition, ',
        'Overall, ',
      ],
    };

    final responses = sampleResponses[model.name] ?? [
      'Here is my response: ',
      'Let me explain: ',
      'Based on your question, ',
    ];

    if (chunkIndex < responses.length) {
      return responses[chunkIndex];
    }

    return 'This is a detailed explanation that provides valuable insights. ';
  }

  void _voteForResponse(String modelId) {
    final message = _messages.last;
    if (message.isUser) return;

    final response = message.responses[modelId];
    if (response == null) return;

    setState(() {
      final updatedResponses = Map<String, ModelResponse>.from(
        message.responses,
      );
      updatedResponses[modelId] = response.copyWith(
        votes: response.votes + 1,
      );

      final index = _messages.indexOf(message);
      if (index != -1) {
        _messages[index] = message.copyWith(
          responses: updatedResponses,
        );
      }
    });

    final model = _selectedModels.firstWhere((m) => m.id == modelId);
    showAccessibleSuccessSnackBar(
      context,
      'Voted for ${model.displayName}',
    );
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

  Future<void> _clearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'Are you sure you want to clear all messages?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _messages.clear());
    }
  }

  Future<void> _saveComparison() async {
    if (_messages.isEmpty) {
      showAccessibleErrorSnackBar(
        context,
        'No messages to save',
      );
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      showAccessibleSuccessSnackBar(
        context,
        'Comparison saved',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multi-Model Chat'),
            if (_selectedModels.isNotEmpty)
              Text(
                '${_selectedModels.length} models active',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          SemanticIconButton(
            icon: _showMetrics ? Icons.analytics : Icons.analytics_outlined,
            label: _showMetrics ? 'Hide metrics' : 'Show metrics',
            onPressed: () => setState(() => _showMetrics = !_showMetrics),
          ),
          SemanticIconButton(
            icon: Icons.save_outlined,
            label: 'Save comparison',
            onPressed: _saveComparison,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Clear Chat'),
                  ],
                ),
                onTap: _clearChat,
              ),
              PopupMenuItem(
                value: 'auto_scroll',
                child: Row(
                  children: [
                    Icon(
                      _autoScroll ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text('Auto Scroll'),
                  ],
                ),
                onTap: () => setState(() => _autoScroll = !_autoScroll),
              ),
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
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1000 : double.infinity,
          child: Column(
            children: [
            // Model selector bar
            _buildModelSelectorBar(),

            // Messages
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return message.isUser
                            ? _buildUserMessage(message)
                            : _buildModelResponses(message);
                      },
                    ),
            ),

            // Input bar
            _buildInputBar(),
          ],
            ),  // Close Column
          ),  // Close ResponsiveCenter
      ),  // Close SafeArea
    );
  }

  Widget _buildModelSelectorBar() {
    return Container(
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
          Semantics(
            label: 'Compare multiple models',
            child: const Icon(Icons.compare_arrows, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._selectedModels.map((model) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: Semantics(
                        label: '${model.displayName} by ${model.provider.displayName}. ${_selectedModels.length > 1 ? "Tap to remove" : ""}',
                        button: _selectedModels.length > 1,
                        child: Chip(
                          avatar: ExcludeSemantics(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: model.provider.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          label: Text(model.displayName),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: _selectedModels.length > 1
                              ? () {
                                  setState(() => _selectedModels.remove(model));
                                }
                              : null,
                          backgroundColor: model.provider.color.withValues(alpha: 0.1),
                        ),
                      ),
                    );
                  }),
                  if (_selectedModels.length < 4)
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: const Text('Add Model'),
                      onPressed: _selectModels,
                    ),
                ],
              ),
            ),
          ),
          SemanticIconButton(
            icon: Icons.settings,
            label: 'Configure models',
            iconSize: 20,
            onPressed: _selectModels,
          ),
        ],
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
              label: 'Multi-model chat comparison',
              child: Container(
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
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Multi-Model Chat',
              style: AppTextStyles.h3().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Send one prompt to multiple AI models and compare their responses side by side',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium().copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                Semantics(
                  label: 'Compare response speed across models',
                  child: _buildFeatureChip(Icons.speed, 'Compare Speed'),
                ),
                Semantics(
                  label: 'Compare cost per token across models',
                  child: _buildFeatureChip(Icons.attach_money, 'Compare Cost'),
                ),
                Semantics(
                  label: 'Vote for the best response',
                  child: _buildFeatureChip(Icons.star, 'Vote Best'),
                ),
                Semantics(
                  label: 'View detailed metrics',
                  child: _buildFeatureChip(Icons.analytics, 'View Metrics'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey.shade100,
    );
  }

  Widget _buildUserMessage(MultiModelMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md, left: 60),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppColors.zeusGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildModelResponses(MultiModelMessage message) {
    if (_selectedModels.length == 1) {
      // Single model - traditional view
      return _buildSingleModelResponse(message);
    }

    // Multiple models - grid view
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedModels.length == 2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildModelResponseCard(
                    message,
                    _selectedModels[0],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildModelResponseCard(
                    message,
                    _selectedModels[1],
                  ),
                ),
              ],
            )
          else if (_selectedModels.length >= 3)
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildModelResponseCard(
                        message,
                        _selectedModels[0],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildModelResponseCard(
                        message,
                        _selectedModels[1],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildModelResponseCard(
                        message,
                        _selectedModels[2],
                      ),
                    ),
                    if (_selectedModels.length >= 4) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildModelResponseCard(
                          message,
                          _selectedModels[3],
                        ),
                      ),
                    ] else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSingleModelResponse(MultiModelMessage message) {
    final model = _selectedModels.first;
    final response = message.responses[model.id];

    if (response == null) {
      return const SizedBox();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md, right: 60),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: model.provider.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  model.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (response.state == ResponseState.streaming) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              response.content,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelResponseCard(
    MultiModelMessage message,
    AIModel model,
  ) {
    final response = message.responses[model.id];
    final isStreaming = response?.state == ResponseState.streaming;
    final isCompleted = response?.state == ResponseState.completed;
    final hasError = response?.state == ResponseState.error;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: model.provider.color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  model.provider.color.withValues(alpha: 0.2),
                  model.provider.color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: model.provider.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    model.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isStreaming)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (isCompleted)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  )
                else if (hasError)
                  Icon(
                    Icons.error,
                    size: 16,
                    color: Colors.red,
                  ),
              ],
            ),
          ),

          // Content
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            constraints: const BoxConstraints(minHeight: 100),
            child: response == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : hasError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade300,
                            size: 32,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            response.error ?? 'Error',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Text(
                        response.content,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 10,
                        overflow: TextOverflow.fade,
                      ),
          ),

          // Metrics and actions
          if (_showMetrics && response != null && !hasError)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        Icons.timer,
                        response.responseTime?.inMilliseconds.toString() ?? '-',
                        'ms',
                      ),
                      _buildMetric(
                        Icons.numbers,
                        response.tokenCount.toString(),
                        'tokens',
                      ),
                      _buildMetric(
                        Icons.attach_money,
                        response.calculateCost(model).toStringAsFixed(4),
                        '',
                      ),
                    ],
                  ),
                  if (isCompleted) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _voteForResponse(model.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: response.votes > 0
                                    ? Colors.green.shade50
                                    : null,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    response.votes > 0
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    size: 14,
                                    color: response.votes > 0
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  if (response.votes > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '${response.votes}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: Colors.grey.shade600),
        const SizedBox(width: 2),
        Text(
          '$value$unit',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    final canSend = _messageController.text.trim().isNotEmpty &&
        _selectedModels.isNotEmpty &&
        !_isProcessing;

    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
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
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Compare models...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) => setState(() {}),
              onSubmitted: canSend ? (_) => _sendMessage() : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            label: canSend ? 'Send message to all models' : 'Enter message to enable send',
            button: true,
            enabled: canSend,
            child: FloatingActionButton(
              onPressed: canSend ? _sendMessage : null,
              mini: true,
              backgroundColor: canSend ? AppColors.primary : Colors.grey.shade300,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, size: 20),
            ),
          ),
        ],
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
      contextWindow: 8192,
      inputPricePerMillion: 30.0,
      outputPricePerMillion: 60.0,
    ),
    const AIModel(
      id: 'claude-3-opus',
      name: 'claude-3-opus-20240229',
      displayName: 'Claude 3 Opus',
      provider: AIProvider.anthropic,
      contextWindow: 200000,
      inputPricePerMillion: 15.0,
      outputPricePerMillion: 75.0,
    ),
    const AIModel(
      id: 'gemini-pro',
      name: 'gemini-pro',
      displayName: 'Gemini Pro',
      provider: AIProvider.google,
      contextWindow: 32768,
      inputPricePerMillion: 0.5,
      outputPricePerMillion: 1.5,
    ),
    const AIModel(
      id: 'llama-3-70b',
      name: 'llama-3-70b',
      displayName: 'Llama 3 70B',
      provider: AIProvider.meta,
      contextWindow: 8192,
      inputPricePerMillion: 0.9,
      outputPricePerMillion: 0.9,
    ),
  ];
}

/// Model selection bottom sheet
class _ModelSelectionSheet extends StatefulWidget {
  const _ModelSelectionSheet({
    required this.selectedModels,
    required this.onModelsSelected,
  });

  final List<AIModel> selectedModels;
  final Function(List<AIModel>) onModelsSelected;

  @override
  State<_ModelSelectionSheet> createState() => _ModelSelectionSheetState();
}

class _ModelSelectionSheetState extends State<_ModelSelectionSheet> {
  late List<AIModel> _tempSelection;

  @override
  void initState() {
    super.initState();
    _tempSelection = List.from(widget.selectedModels);
  }

  void _toggleModel(AIModel model) {
    setState(() {
      if (_tempSelection.contains(model)) {
        if (_tempSelection.length > 1) {
          _tempSelection.remove(model);
        }
      } else {
        if (_tempSelection.length < 4) {
          _tempSelection.add(model);
        }
      }
    });
  }

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
                  Icons.compare_arrows,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Models',
                      style: AppTextStyles.h4().copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_tempSelection.length}/4 selected (min 1, max 4)',
                      style: AppTextStyles.bodySmall().copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: _MultiModelChatScreenState._sampleModels.length,
              itemBuilder: (context, index) {
                final model = _MultiModelChatScreenState._sampleModels[index];
                final isSelected = _tempSelection.contains(model);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) => _toggleModel(model),
                  title: Text(
                    model.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${model.provider.displayName} • ${model.contextWindowFormatted} context',
                  ),
                  secondary: Container(
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
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _tempSelection.isNotEmpty
                  ? () {
                      widget.onModelsSelected(_tempSelection);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: Text('Apply (${_tempSelection.length} models)'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
