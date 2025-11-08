import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/logger_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/conversation_repository.dart';
import '../../../../data/services/ai_api_service.dart';

part 'conversation_provider.freezed.dart';

/// Conversation list state
@freezed
class ConversationListState with _$ConversationListState {
  const factory ConversationListState({
    @Default([]) List<ConversationModel> conversations,
    @Default(true) bool isLoading,
    String? errorMessage,
  }) = _ConversationListState;

  const ConversationListState._();

  /// Get pinned conversations
  List<ConversationModel> get pinnedConversations =>
      conversations.where((c) => c.isPinned && c.isActive).toList();

  /// Get active conversations (not pinned, not archived)
  List<ConversationModel> get activeConversations =>
      conversations.where((c) => !c.isPinned && c.isActive).toList();

  /// Get archived conversations
  List<ConversationModel> get archivedConversations =>
      conversations.where((c) => c.isArchived).toList();
}

/// Single conversation state
@freezed
class ConversationState with _$ConversationState {
  const factory ConversationState({
    ConversationModel? conversation,
    @Default([]) List<MessageModel> messages,
    @Default(false) bool isLoading,
    @Default(false) bool isSending,
    String? errorMessage,
  }) = _ConversationState;
}

/// Conversation repository provider
final conversationRepositoryProvider =
    Provider<IConversationRepository>((ref) {
  return ConversationRepository();
});

/// AI API service provider
final aiApiServiceProvider = Provider<AIAPIService>((ref) {
  return AIAPIService();
});

/// Conversation list provider
final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>(
        (ref) {
  final repository = ref.watch(conversationRepositoryProvider);
  final authState = ref.watch(authProvider);
  return ConversationListNotifier(repository, authState.user?.userId);
});

/// Conversation list notifier
class ConversationListNotifier extends StateNotifier<ConversationListState> {
  ConversationListNotifier(this._repository, this._userId)
      : super(const ConversationListState()) {
    if (_userId != null) {
      _subscribeToConversations();
    }
  }

  final IConversationRepository _repository;
  final String? _userId;

  void _subscribeToConversations() {
    if (_userId == null) return;

    try {
      _repository.getConversationsStream(_userId!).listen(
        (conversations) {
          state = state.copyWith(
            conversations: conversations,
            isLoading: false,
            errorMessage: null,
          );
        },
        onError: (error) {
          LoggerService.e('Error in conversations stream', error: error);
          state = state.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          );
        },
      );
    } catch (e) {
      LoggerService.e('Failed to subscribe to conversations', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Create a new conversation
  Future<ConversationModel> createConversation({
    required String title,
    required String modelId,
    required String provider,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      LoggerService.i('Creating new conversation: $title');

      final conversation = ConversationModel(
        conversationId: const Uuid().v4(),
        userId: _userId!,
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        modelId: modelId,
        provider: provider,
        systemPrompt: systemPrompt,
        temperature: temperature,
        maxTokens: maxTokens,
      );

      await _repository.createConversation(conversation);
      LoggerService.i('Conversation created: ${conversation.conversationId}');

      return conversation;
    } catch (e) {
      LoggerService.e('Failed to create conversation', error: e);
      rethrow;
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);
      LoggerService.i('Conversation deleted: $conversationId');
    } catch (e) {
      LoggerService.e('Failed to delete conversation', error: e);
      rethrow;
    }
  }

  /// Archive a conversation
  Future<void> archiveConversation(String conversationId) async {
    try {
      await _repository.archiveConversation(conversationId);
    } catch (e) {
      LoggerService.e('Failed to archive conversation', error: e);
      rethrow;
    }
  }

  /// Unarchive a conversation
  Future<void> unarchiveConversation(String conversationId) async {
    try {
      await _repository.unarchiveConversation(conversationId);
    } catch (e) {
      LoggerService.e('Failed to unarchive conversation', error: e);
      rethrow;
    }
  }

  /// Pin a conversation
  Future<void> pinConversation(String conversationId) async {
    try {
      await _repository.pinConversation(conversationId);
    } catch (e) {
      LoggerService.e('Failed to pin conversation', error: e);
      rethrow;
    }
  }

  /// Unpin a conversation
  Future<void> unpinConversation(String conversationId) async {
    try {
      await _repository.unpinConversation(conversationId);
    } catch (e) {
      LoggerService.e('Failed to unpin conversation', error: e);
      rethrow;
    }
  }

  /// Search conversations
  Future<List<ConversationModel>> searchConversations(String query) async {
    if (_userId == null) return [];

    try {
      return await _repository.searchConversations(_userId!, query);
    } catch (e) {
      LoggerService.e('Failed to search conversations', error: e);
      return [];
    }
  }

  /// Update conversation title
  Future<void> updateConversationTitle(
    String conversationId,
    String newTitle,
  ) async {
    try {
      // Get the current conversation
      final conversation = await _repository.getConversation(conversationId);
      if (conversation == null) {
        throw Exception('Conversation not found');
      }

      // Update with new title
      final updatedConversation = conversation.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );

      await _repository.updateConversation(updatedConversation);
      LoggerService.i('Conversation title updated: $newTitle');
    } catch (e) {
      LoggerService.e('Failed to update conversation title', error: e);
      rethrow;
    }
  }

  /// Update a conversation with the provided ConversationModel
  Future<void> updateConversation(ConversationModel conversation) async {
    try {
      await _repository.updateConversation(conversation);
      LoggerService.i('Conversation updated: ${conversation.conversationId}');
    } catch (e) {
      LoggerService.e('Failed to update conversation', error: e);
      rethrow;
    }
  }
}

/// Single conversation provider (family provider for specific conversation)
final conversationProvider = StateNotifierProvider.family<
    ConversationNotifier, ConversationState, String>((ref, conversationId) {
  final repository = ref.watch(conversationRepositoryProvider);
  final aiApiService = ref.watch(aiApiServiceProvider);
  return ConversationNotifier(repository, aiApiService, conversationId);
});

/// Conversation notifier for a single conversation
class ConversationNotifier extends StateNotifier<ConversationState> {
  ConversationNotifier(this._repository, this._aiApiService, this._conversationId)
      : super(const ConversationState()) {
    _loadConversation();
    _subscribeToMessages();
  }

  final IConversationRepository _repository;
  final AIAPIService _aiApiService;
  final String _conversationId;

  Future<void> _loadConversation() async {
    try {
      state = state.copyWith(isLoading: true);

      final conversation = await _repository.getConversation(_conversationId);

      state = state.copyWith(
        conversation: conversation,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      LoggerService.e('Failed to load conversation', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void _subscribeToMessages() {
    try {
      _repository.getMessagesStream(_conversationId).listen(
        (messages) {
          state = state.copyWith(
            messages: messages,
            errorMessage: null,
          );
        },
        onError: (error) {
          LoggerService.e('Error in messages stream', error: error);
          state = state.copyWith(
            errorMessage: error.toString(),
          );
        },
      );
    } catch (e) {
      LoggerService.e('Failed to subscribe to messages', error: e);
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String content,
    List<MessageAttachment> attachments = const [],
  }) async {
    if (state.conversation == null) {
      throw Exception('Conversation not loaded');
    }

    try {
      state = state.copyWith(isSending: true);

      // Create user message
      final userMessage = MessageModel(
        messageId: const Uuid().v4(),
        conversationId: _conversationId,
        role: MessageRole.user,
        content: content,
        createdAt: DateTime.now(),
        status: MessageStatus.sending,
        attachments: attachments,
      );

      // Add user message to Firestore
      await _repository.addMessage(userMessage);

      // Update message status to sent
      await _repository.updateMessage(
        userMessage.copyWith(status: MessageStatus.sent),
      );

      // Create placeholder assistant message
      final assistantMessage = MessageModel(
        messageId: const Uuid().v4(),
        conversationId: _conversationId,
        role: MessageRole.assistant,
        content: '',
        createdAt: DateTime.now(),
        status: MessageStatus.generating,
        modelId: state.conversation!.modelId,
        provider: state.conversation!.provider,
      );

      await _repository.addMessage(assistantMessage);

      try {
        // Call AI API to get response
        final aiResponse = await _aiApiService.sendMessage(
          modelId: state.conversation!.modelId,
          messages: [...state.messages, userMessage],
          provider: state.conversation!.provider,
          systemPrompt: state.conversation!.systemPrompt,
          temperature: state.conversation!.temperature,
          maxTokens: state.conversation!.maxTokens,
        );

        // Update assistant message with AI response
        await _repository.updateMessage(
          assistantMessage.copyWith(
            content: aiResponse,
            status: MessageStatus.completed,
          ),
        );

        LoggerService.i('AI response received and saved');
      } catch (e) {
        LoggerService.e('Failed to get AI response', error: e);

        // Update message with error status
        await _repository.updateMessage(
          assistantMessage.copyWith(
            content: 'Sorry, I encountered an error generating a response. Please try again.',
            status: MessageStatus.failed,
          ),
        );

        rethrow;
      }

      state = state.copyWith(isSending: false);
    } catch (e) {
      LoggerService.e('Failed to send message', error: e);
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Regenerate last assistant message
  Future<void> regenerateMessage(String messageId) async {
    // TODO: Implement message regeneration
    LoggerService.i('Regenerating message: $messageId');
  }

  /// Edit a message
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      final message = state.messages.firstWhere((m) => m.messageId == messageId);

      final editHistory = [...message.editHistory, message.content];

      final updatedMessage = message.copyWith(
        content: newContent,
        isEdited: true,
        editHistory: editHistory,
        updatedAt: DateTime.now(),
      );

      await _repository.updateMessage(updatedMessage);
    } catch (e) {
      LoggerService.e('Failed to edit message', error: e);
      rethrow;
    }
  }

  /// Update a message with the provided MessageModel
  Future<void> updateMessage(MessageModel message) async {
    try {
      await _repository.updateMessage(message);
    } catch (e) {
      LoggerService.e('Failed to update message', error: e);
      rethrow;
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _repository.deleteMessage(messageId);
    } catch (e) {
      LoggerService.e('Failed to delete message', error: e);
      rethrow;
    }
  }

  /// Clear all messages in the conversation
  Future<void> clearHistory() async {
    try {
      LoggerService.i('Clearing conversation history: $_conversationId');

      // Delete all messages
      for (final message in state.messages) {
        await _repository.deleteMessage(message.messageId);
      }

      LoggerService.i('Conversation history cleared');
    } catch (e) {
      LoggerService.e('Failed to clear conversation history', error: e);
      rethrow;
    }
  }

  /// Get conversation as shareable text
  String getShareableText() {
    if (state.conversation == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('Conversation: ${state.conversation!.title}');
    buffer.writeln('Model: ${state.conversation!.modelId}');
    buffer.writeln('Date: ${DateTime.now().toLocal()}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    for (final message in state.messages) {
      final role = message.role == MessageRole.user ? 'You' : 'Assistant';
      buffer.writeln('$role:');
      buffer.writeln(message.content);
      buffer.writeln();
    }

    buffer.writeln('---');
    buffer.writeln('Generated by Zeus GPT');

    return buffer.toString();
  }

  /// Get conversation as exportable JSON
  Map<String, dynamic> getExportableData() {
    return {
      'conversation': state.conversation?.toJson(),
      'messages': state.messages.map((m) => m.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'messageCount': state.messages.length,
    };
  }
}
