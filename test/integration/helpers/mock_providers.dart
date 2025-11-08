import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeusgpt/features/auth/domain/entities/user_entity.dart';
import 'package:zeusgpt/features/auth/presentation/providers/auth_provider.dart';
import 'package:zeusgpt/features/chat/data/models/conversation_model.dart';
import 'package:zeusgpt/features/chat/data/models/message_model.dart';
import 'package:zeusgpt/features/chat/presentation/providers/conversation_provider.dart';

/// Mock auth repository for testing
class MockAuthRepository {
  bool _isAuthenticated = false;
  bool _isEmailVerified = false;
  bool _hasCompletedOnboarding = false;
  UserEntity? _currentUser;

  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Simulate successful login
    _isAuthenticated = true;
    _isEmailVerified = true;
    _hasCompletedOnboarding = true;
    _currentUser = UserEntity(
      userId: 'test-user-id',
      email: email,
      displayName: 'Test User',
      photoUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: true,
      hasCompletedOnboarding: true,
    );
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isAuthenticated = false;
    _isEmailVerified = false;
    _currentUser = null;
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isEmailVerified => _isEmailVerified;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  UserEntity? get currentUser => _currentUser;
}

/// Mock conversation repository for testing
class MockConversationRepository {
  final List<ConversationModel> _conversations = [];
  final Map<String, List<MessageModel>> _messages = {};

  Future<List<ConversationModel>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _conversations;
  }

  Future<ConversationModel> createConversation({
    required String title,
    required String modelId,
    required String provider,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final conversation = ConversationModel(
      conversationId: 'conv-${_conversations.length + 1}',
      userId: 'test-user-id',
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      modelId: modelId,
      provider: provider,
      messageCount: 0,
    );

    _conversations.add(conversation);
    _messages[conversation.conversationId] = [];

    return conversation;
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _messages[conversationId] ?? [];
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final message = MessageModel(
      messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.user,
      content: content,
      createdAt: DateTime.now(),
      status: MessageStatus.completed,
    );

    _messages[conversationId]?.add(message);

    // Simulate assistant response
    await Future.delayed(const Duration(milliseconds: 200));

    final response = MessageModel(
      messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: 'This is a test response to: $content',
      createdAt: DateTime.now(),
      status: MessageStatus.completed,
    );

    _messages[conversationId]?.add(response);

    return message;
  }

  Future<void> deleteConversation(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _conversations.removeWhere((c) => c.conversationId == conversationId);
    _messages.remove(conversationId);
  }

  void reset() {
    _conversations.clear();
    _messages.clear();
  }
}

/// Creates a provider scope with mock providers for testing
ProviderScope createMockProviderScope({
  required Widget child,
  MockAuthRepository? mockAuthRepo,
  MockConversationRepository? mockConversationRepo,
}) {
  final authRepo = mockAuthRepo ?? MockAuthRepository();
  final conversationRepo = mockConversationRepo ?? MockConversationRepository();

  return ProviderScope(
    overrides: [
      // Override auth provider with mock
      // Note: This is a simplified example - actual implementation may vary
    ],
    child: child,
  );
}
