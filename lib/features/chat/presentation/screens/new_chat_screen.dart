import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeus_button.dart';
import '../../../../core/widgets/zeus_text_field.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';
import '../providers/conversation_provider.dart';

/// New chat screen for starting conversations
class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  String _selectedModel = 'gpt-4';
  String _selectedProvider = 'openai';
  String? _systemPrompt;
  double _temperature = 0.7;
  int _maxTokens = 2048;
  bool _isCreating = false;

  // Popular models
  final List<Map<String, dynamic>> _popularModels = [
    {
      'id': 'gpt-4',
      'name': 'GPT-4',
      'provider': 'openai',
      'description': 'Most capable model, best for complex tasks',
      'icon': Icons.psychology,
    },
    {
      'id': 'gpt-3.5-turbo',
      'name': 'GPT-3.5 Turbo',
      'provider': 'openai',
      'description': 'Fast and efficient for most tasks',
      'icon': Icons.psychology,
    },
    {
      'id': 'claude-3-opus',
      'name': 'Claude 3 Opus',
      'provider': 'anthropic',
      'description': 'Powerful reasoning and analysis',
      'icon': Icons.smart_toy,
    },
    {
      'id': 'gemini-pro',
      'name': 'Gemini Pro',
      'provider': 'google',
      'description': 'Google\'s advanced AI model',
      'icon': Icons.school,
    },
    {
      'id': 'llama-2-70b',
      'name': 'Llama 2 70B',
      'provider': 'meta',
      'description': 'Open-source large language model',
      'icon': Icons.facebook,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('New Chat');
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createConversation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final title = _titleController.text.trim().isEmpty
          ? 'New Conversation'
          : _titleController.text.trim();

      final conversation = await ref
          .read(conversationListProvider.notifier)
          .createConversation(
            title: title,
            modelId: _selectedModel,
            provider: _selectedProvider,
            systemPrompt: _systemPrompt,
            temperature: _temperature,
            maxTokens: _maxTokens,
          );

      if (mounted) {
        context.go('/home/chat/${conversation.conversationId}');
      }
    } catch (e) {
      if (mounted) {
        showAccessibleErrorSnackBar(
          context,
          'Unable to create conversation. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
        leading: SemanticIconButton(
          icon: Icons.close,
          label: 'Close',
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 600 : double.infinity,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
            // Zeus logo and welcome
            Center(
              child: Column(
                children: [
                  Semantics(
                    label: 'Zeus GPT Logo',
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.zeusGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Start a New Conversation',
                    style: AppTextStyles.h3().copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Choose an AI model and start chatting',
                    style: AppTextStyles.bodyMedium().copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Conversation title
            Text(
              'Conversation Title (Optional)',
              style: AppTextStyles.bodyLarge().copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ZeusTextField(
              controller: _titleController,
              label: 'Title',
              prefixIcon: Icons.edit_outlined,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Model selection
            Text(
              'Choose AI Model',
              style: AppTextStyles.bodyLarge().copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            ..._popularModels.map((model) {
              final isSelected = _selectedModel == model['id'];

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Semantics(
                  label: '${model['name']}. ${model['description']}. ${isSelected ? "Selected" : "Not selected"}',
                  selected: isSelected,
                  button: true,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedModel = model['id'] as String;
                        _selectedProvider = model['provider'] as String;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDark
                                ? AppColors.surface(false)
                                : AppColors.surface(true).withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1)),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              model['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model['name'] as String,
                                  style: AppTextStyles.bodyLarge().copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primary
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  model['description'] as String,
                                  style: AppTextStyles.bodySmall().copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            ExcludeSemantics(
                              child: const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Browse all models button
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to models screen
              },
              icon: const Icon(Icons.explore),
              label: const Text('Browse 500+ Models'),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Advanced settings (collapsible)
            ExpansionTile(
              title: Text(
                'Advanced Settings',
                style: AppTextStyles.bodyLarge().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Temperature
                      Text(
                        'Temperature: ${_temperature.toStringAsFixed(1)}',
                        style: AppTextStyles.bodyMedium(),
                      ),
                      Semantics(
                        label: 'Temperature: ${_temperature.toStringAsFixed(1)}. Higher values make output more random',
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

                      // Max tokens
                      Text(
                        'Max Tokens: $_maxTokens',
                        style: AppTextStyles.bodyMedium(),
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

                      // System prompt
                      ZeusTextField(
                        label: 'System Prompt (Optional)',
                        maxLines: 3,
                        onChanged: (value) {
                          _systemPrompt = value.trim().isEmpty ? null : value;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Create button
            ZeusButton.primary(
              text: 'Start Chatting',
              onPressed: _isCreating ? null : _createConversation,
              isLoading: _isCreating,
              fullWidth: true,
              size: ZeusButtonSize.large,
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}
