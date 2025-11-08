import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeusgpt/features/chat/presentation/providers/conversation_provider.dart';
import 'package:zeusgpt/features/chat/data/repositories/conversation_repository.dart';
import 'package:zeusgpt/features/chat/data/models/conversation_model.dart';
import 'package:zeusgpt/features/chat/data/models/message_model.dart';
import 'package:zeusgpt/data/services/ai_api_service.dart';

// Mock classes
class MockConversationRepository extends Mock
    implements IConversationRepository {}

class MockAIAPIService extends Mock implements AIAPIService {}

void main() {
  // Test fixtures
  final testConversation = ConversationModel(
    conversationId: 'test-conversation-id',
    userId: 'test-user-id',
    title: 'Test Conversation',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 15),
    modelId: 'gpt-4',
    provider: 'openai',
  );

  final testMessage = MessageModel(
    messageId: 'test-message-id',
    conversationId: 'test-conversation-id',
    role: MessageRole.user,
    content: 'Test message content',
    createdAt: DateTime(2024, 1, 1),
    status: MessageStatus.sent,
  );

  // Register fallback values
  setUpAll(() {
    registerFallbackValue(testConversation);
    registerFallbackValue(testMessage);
  });

  group('ConversationListState', () {
    test('has correct default values', () {
      const state = ConversationListState();

      expect(state.conversations, isEmpty);
      expect(state.isLoading, isTrue);
      expect(state.errorMessage, isNull);
    });

    test('pinnedConversations returns only pinned and active conversations', () {
      final pinnedConversation = testConversation.copyWith(
        conversationId: 'pinned-1',
        isPinned: true,
        isArchived: false,
      );
      final archivedPinnedConversation = testConversation.copyWith(
        conversationId: 'pinned-2',
        isPinned: true,
        isArchived: true,
      );
      final regularConversation = testConversation.copyWith(
        conversationId: 'regular-1',
        isPinned: false,
      );

      final state = ConversationListState(
        conversations: [
          pinnedConversation,
          archivedPinnedConversation,
          regularConversation,
        ],
      );

      final pinned = state.pinnedConversations;
      expect(pinned.length, equals(1));
      expect(pinned.first.conversationId, equals('pinned-1'));
    });

    test('activeConversations returns only non-pinned active conversations',
        () {
      final pinnedConversation = testConversation.copyWith(
        conversationId: 'pinned-1',
        isPinned: true,
      );
      final activeConversation = testConversation.copyWith(
        conversationId: 'active-1',
        isPinned: false,
        isArchived: false,
      );
      final archivedConversation = testConversation.copyWith(
        conversationId: 'archived-1',
        isPinned: false,
        isArchived: true,
      );

      final state = ConversationListState(
        conversations: [
          pinnedConversation,
          activeConversation,
          archivedConversation,
        ],
      );

      final active = state.activeConversations;
      expect(active.length, equals(1));
      expect(active.first.conversationId, equals('active-1'));
    });

    test('archivedConversations returns only archived conversations', () {
      final activeConversation = testConversation.copyWith(
        conversationId: 'active-1',
        isArchived: false,
      );
      final archivedConversation = testConversation.copyWith(
        conversationId: 'archived-1',
        isArchived: true,
      );

      final state = ConversationListState(
        conversations: [activeConversation, archivedConversation],
      );

      final archived = state.archivedConversations;
      expect(archived.length, equals(1));
      expect(archived.first.conversationId, equals('archived-1'));
    });
  });

  group('ConversationState', () {
    test('has correct default values', () {
      const state = ConversationState();

      expect(state.conversation, isNull);
      expect(state.messages, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isSending, isFalse);
      expect(state.errorMessage, isNull);
    });
  });

  group('ConversationListNotifier', () {
    late MockConversationRepository mockRepository;
    late ProviderContainer container;
    late StreamController<List<ConversationModel>> conversationsStreamController;

    setUp(() {
      mockRepository = MockConversationRepository();
      conversationsStreamController =
          StreamController<List<ConversationModel>>.broadcast();

      when(() => mockRepository.getConversationsStream(any()))
          .thenAnswer((_) => conversationsStreamController.stream);

      container = ProviderContainer(
        overrides: [
          conversationRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() async {
      await conversationsStreamController.close();
      await Future.delayed(Duration.zero);
      container.dispose();
    });

    group('initialization', () {
      test('initializes with loading state when userId is provided', () {
        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        expect(notifier.state.isLoading, isTrue);
        expect(notifier.state.conversations, isEmpty);
        verify(() => mockRepository.getConversationsStream('test-user'))
            .called(1);
      });

      test('does not subscribe when userId is null', () {
        final notifier = ConversationListNotifier(mockRepository, null);

        expect(notifier.state.isLoading, isTrue);
        verifyNever(() => mockRepository.getConversationsStream(any()));
      });

      test('updates state when conversations stream emits', () async {
        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        conversationsStreamController.add([testConversation]);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.conversations.length, equals(1));
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.errorMessage, isNull);
      });

      test('handles stream error', () async {
        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        conversationsStreamController.addError(Exception('Stream error'));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.errorMessage, contains('Stream error'));
      });
    });

    group('createConversation', () {
      test('creates conversation and returns it', () async {
        when(() => mockRepository.createConversation(any()))
            .thenAnswer((invocation) async => invocation.positionalArguments[0] as ConversationModel);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        final result = await notifier.createConversation(
          title: 'New Chat',
          modelId: 'gpt-4',
          provider: 'openai',
        );

        expect(result.title, equals('New Chat'));
        expect(result.modelId, equals('gpt-4'));
        expect(result.provider, equals('openai'));
        expect(result.userId, equals('test-user'));
        verify(() => mockRepository.createConversation(any())).called(1);
      });

      test('throws when userId is null', () async {
        final notifier = ConversationListNotifier(mockRepository, null);

        expect(
          () => notifier.createConversation(
            title: 'New Chat',
            modelId: 'gpt-4',
            provider: 'openai',
          ),
          throwsException,
        );
      });

      test('rethrows on failure', () async {
        final exception = Exception('Create failed');
        when(() => mockRepository.createConversation(any()))
            .thenThrow(exception);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        expect(
          () => notifier.createConversation(
            title: 'New Chat',
            modelId: 'gpt-4',
            provider: 'openai',
          ),
          throwsException,
        );
      });
    });

    group('deleteConversation', () {
      test('deletes conversation successfully', () async {
        when(() => mockRepository.deleteConversation(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        await notifier.deleteConversation('conversation-id');

        verify(() => mockRepository.deleteConversation('conversation-id'))
            .called(1);
      });

      test('rethrows on failure', () async {
        final exception = Exception('Delete failed');
        when(() => mockRepository.deleteConversation(any()))
            .thenThrow(exception);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        expect(
          () => notifier.deleteConversation('conversation-id'),
          throwsException,
        );
      });
    });

    group('archiveConversation', () {
      test('archives conversation successfully', () async {
        when(() => mockRepository.archiveConversation(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        await notifier.archiveConversation('conversation-id');

        verify(() => mockRepository.archiveConversation('conversation-id'))
            .called(1);
      });

      test('rethrows on failure', () async {
        final exception = Exception('Archive failed');
        when(() => mockRepository.archiveConversation(any()))
            .thenThrow(exception);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        expect(
          () => notifier.archiveConversation('conversation-id'),
          throwsException,
        );
      });
    });

    group('unarchiveConversation', () {
      test('unarchives conversation successfully', () async {
        when(() => mockRepository.unarchiveConversation(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        await notifier.unarchiveConversation('conversation-id');

        verify(() => mockRepository.unarchiveConversation('conversation-id'))
            .called(1);
      });

      test('rethrows on failure', () async {
        final exception = Exception('Unarchive failed');
        when(() => mockRepository.unarchiveConversation(any()))
            .thenThrow(exception);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        expect(
          () => notifier.unarchiveConversation('conversation-id'),
          throwsException,
        );
      });
    });

    group('pinConversation', () {
      test('pins conversation successfully', () async {
        when(() => mockRepository.pinConversation(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        await notifier.pinConversation('conversation-id');

        verify(() => mockRepository.pinConversation('conversation-id'))
            .called(1);
      });

      test('rethrows on failure', () async {
        final exception = Exception('Pin failed');
        when(() => mockRepository.pinConversation(any())).thenThrow(exception);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        expect(
          () => notifier.pinConversation('conversation-id'),
          throwsException,
        );
      });
    });

    group('unpinConversation', () {
      test('unpins conversation successfully', () async {
        when(() => mockRepository.unpinConversation(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        await notifier.unpinConversation('conversation-id');

        verify(() => mockRepository.unpinConversation('conversation-id'))
            .called(1);
      });

      test('rethrows on failure', () async {
        final exception = Exception('Unpin failed');
        when(() => mockRepository.unpinConversation(any()))
            .thenThrow(exception);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        expect(
          () => notifier.unpinConversation('conversation-id'),
          throwsException,
        );
      });
    });

    group('searchConversations', () {
      test('searches conversations successfully', () async {
        when(() => mockRepository.searchConversations(any(), any()))
            .thenAnswer((_) async => [testConversation]);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        final results = await notifier.searchConversations('test query');

        expect(results.length, equals(1));
        verify(() => mockRepository.searchConversations('test-user', 'test query'))
            .called(1);
      });

      test('returns empty list when userId is null', () async {
        final notifier = ConversationListNotifier(mockRepository, null);

        final results = await notifier.searchConversations('test query');

        expect(results, isEmpty);
        verifyNever(() => mockRepository.searchConversations(any(), any()));
      });

      test('returns empty list on error', () async {
        when(() => mockRepository.searchConversations(any(), any()))
            .thenThrow(Exception('Search failed'));

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        final results = await notifier.searchConversations('test query');

        expect(results, isEmpty);
      });
    });

    group('updateConversationTitle', () {
      test('updates conversation title successfully', () async {
        when(() => mockRepository.getConversation(any()))
            .thenAnswer((_) async => testConversation);
        when(() => mockRepository.updateConversation(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        await notifier.updateConversationTitle('conversation-id', 'New Title');

        verify(() => mockRepository.getConversation('conversation-id'))
            .called(1);
        verify(() => mockRepository.updateConversation(any())).called(1);
      });

      test('throws when conversation not found', () async {
        when(() => mockRepository.getConversation(any()))
            .thenAnswer((_) async => null);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        expect(
          () => notifier.updateConversationTitle('conversation-id', 'New Title'),
          throwsException,
        );
      });
    });

    group('updateConversation', () {
      test('updates conversation successfully', () async {
        when(() => mockRepository.updateConversation(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        await notifier.updateConversation(testConversation);

        verify(() => mockRepository.updateConversation(testConversation))
            .called(1);
      });

      test('rethrows on failure', () async {
        final exception = Exception('Update failed');
        when(() => mockRepository.updateConversation(any()))
            .thenThrow(exception);

        final notifier = ConversationListNotifier(mockRepository, 'test-user');

        expect(
          () => notifier.updateConversation(testConversation),
          throwsException,
        );
      });
    });
  });

  group('ConversationNotifier', () {
    late MockConversationRepository mockRepository;
    late MockAIAPIService mockAIAPIService;
    late ProviderContainer container;
    late StreamController<List<MessageModel>> messagesStreamController;

    setUp(() {
      mockRepository = MockConversationRepository();
      mockAIAPIService = MockAIAPIService();
      messagesStreamController =
          StreamController<List<MessageModel>>.broadcast();

      when(() => mockRepository.getConversation(any()))
          .thenAnswer((_) async => testConversation);
      when(() => mockRepository.getMessagesStream(any()))
          .thenAnswer((_) => messagesStreamController.stream);

      container = ProviderContainer(
        overrides: [
          conversationRepositoryProvider.overrideWithValue(mockRepository),
          aiApiServiceProvider.overrideWithValue(mockAIAPIService),
        ],
      );
    });

    tearDown(() async {
      await messagesStreamController.close();
      await Future.delayed(Duration.zero);
      container.dispose();
    });

    group('initialization', () {
      test('loads conversation and subscribes to messages', () async {
        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.conversation, equals(testConversation));
        expect(notifier.state.isLoading, isFalse);
        verify(() => mockRepository.getConversation('test-conversation-id'))
            .called(1);
        verify(() => mockRepository.getMessagesStream('test-conversation-id'))
            .called(1);
      });

      test('handles load error', () async {
        when(() => mockRepository.getConversation(any()))
            .thenThrow(Exception('Load failed'));

        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.errorMessage, contains('Load failed'));
      });

      test('updates messages when stream emits', () async {
        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        messagesStreamController.add([testMessage]);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.messages.length, equals(1));
        expect(notifier.state.errorMessage, isNull);
      });

      test('handles messages stream error', () async {
        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        messagesStreamController.addError(Exception('Messages error'));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.errorMessage, contains('Messages error'));
      });
    });

    group('sendMessage', () {
      test('sends message and gets AI response successfully', () async {
        when(() => mockRepository.addMessage(any()))
            .thenAnswer((invocation) async =>
                invocation.positionalArguments[0] as MessageModel);
        when(() => mockRepository.updateMessage(any()))
            .thenAnswer((_) async {});
        when(() => mockAIAPIService.sendMessage(
              modelId: any(named: 'modelId'),
              messages: any(named: 'messages'),
              provider: any(named: 'provider'),
              systemPrompt: any(named: 'systemPrompt'),
              temperature: any(named: 'temperature'),
              maxTokens: any(named: 'maxTokens'),
            )).thenAnswer((_) async => 'AI response text');

        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        // Load conversation first
        await Future.delayed(const Duration(milliseconds: 100));

        await notifier.sendMessage(content: 'Test message');

        expect(notifier.state.isSending, isFalse);
        verify(() => mockRepository.addMessage(any())).called(2); // user + assistant
        verify(() => mockRepository.updateMessage(any())).called(2); // sent + completed
        verify(() => mockAIAPIService.sendMessage(
              modelId: any(named: 'modelId'),
              messages: any(named: 'messages'),
              provider: any(named: 'provider'),
              systemPrompt: any(named: 'systemPrompt'),
              temperature: any(named: 'temperature'),
              maxTokens: any(named: 'maxTokens'),
            )).called(1);
      });

      test('throws when conversation is not loaded', () async {
        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        notifier.state = const ConversationState(conversation: null);

        expect(
          () => notifier.sendMessage(content: 'Test'),
          throwsException,
        );
      });

      test('handles AI API error and marks message as failed', () async {
        when(() => mockRepository.addMessage(any()))
            .thenAnswer((invocation) async =>
                invocation.positionalArguments[0] as MessageModel);
        when(() => mockRepository.updateMessage(any()))
            .thenAnswer((_) async {});
        when(() => mockAIAPIService.sendMessage(
              modelId: any(named: 'modelId'),
              messages: any(named: 'messages'),
              provider: any(named: 'provider'),
              systemPrompt: any(named: 'systemPrompt'),
              temperature: any(named: 'temperature'),
              maxTokens: any(named: 'maxTokens'),
            )).thenThrow(Exception('AI error'));

        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        await Future.delayed(const Duration(milliseconds: 100));

        try {
          await notifier.sendMessage(content: 'Test message');
          fail('Should have thrown exception');
        } catch (e) {
          expect(e.toString(), contains('AI error'));
        }

        expect(notifier.state.isSending, isFalse);
        expect(notifier.state.errorMessage, contains('AI error'));
      });
    });

    group('editMessage', () {
      test('edits message successfully', () async {
        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        // Set up state with test message
        notifier.state = ConversationState(
          conversation: testConversation,
          messages: [testMessage],
        );

        when(() => mockRepository.updateMessage(any()))
            .thenAnswer((_) async {});

        await notifier.editMessage('test-message-id', 'Edited content');

        verify(() => mockRepository.updateMessage(any())).called(1);
      });

      test('rethrows on failure', () async {
        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        notifier.state = ConversationState(
          conversation: testConversation,
          messages: [testMessage],
        );

        when(() => mockRepository.updateMessage(any()))
            .thenThrow(Exception('Edit failed'));

        expect(
          () => notifier.editMessage('test-message-id', 'Edited content'),
          throwsException,
        );
      });
    });

    group('updateMessage', () {
      test('updates message successfully', () async {
        when(() => mockRepository.updateMessage(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        await notifier.updateMessage(testMessage);

        verify(() => mockRepository.updateMessage(testMessage)).called(1);
      });

      test('rethrows on failure', () async {
        final exception = Exception('Update failed');
        when(() => mockRepository.updateMessage(any())).thenThrow(exception);

        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        expect(
          () => notifier.updateMessage(testMessage),
          throwsException,
        );
      });
    });

    group('deleteMessage', () {
      test('deletes message successfully', () async {
        when(() => mockRepository.deleteMessage(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        await notifier.deleteMessage('message-id');

        verify(() => mockRepository.deleteMessage('message-id')).called(1);
      });

      test('rethrows on failure', () async {
        final exception = Exception('Delete failed');
        when(() => mockRepository.deleteMessage(any())).thenThrow(exception);

        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        expect(
          () => notifier.deleteMessage('message-id'),
          throwsException,
        );
      });
    });

    group('clearHistory', () {
      test('clears all messages successfully', () async {
        when(() => mockRepository.deleteMessage(any()))
            .thenAnswer((_) async {});

        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        notifier.state = ConversationState(
          messages: [testMessage, testMessage.copyWith(messageId: 'msg-2')],
        );

        await notifier.clearHistory();

        verify(() => mockRepository.deleteMessage(any())).called(2);
      });

      test('rethrows on failure', () async {
        when(() => mockRepository.deleteMessage(any()))
            .thenThrow(Exception('Delete failed'));

        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        notifier.state = ConversationState(messages: [testMessage]);

        expect(
          () => notifier.clearHistory(),
          throwsException,
        );
      });
    });

    group('getShareableText', () {
      test('returns formatted shareable text', () {
        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        notifier.state = ConversationState(
          conversation: testConversation,
          messages: [
            testMessage,
            testMessage.copyWith(
              messageId: 'msg-2',
              role: MessageRole.assistant,
              content: 'AI response',
            ),
          ],
        );

        final text = notifier.getShareableText();

        expect(text, contains('Test Conversation'));
        expect(text, contains('gpt-4'));
        expect(text, contains('You:'));
        expect(text, contains('Test message content'));
        expect(text, contains('Assistant:'));
        expect(text, contains('AI response'));
        expect(text, contains('Zeus GPT'));
      });

      test('returns empty string when conversation is null', () {
        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        notifier.state = const ConversationState(conversation: null);

        final text = notifier.getShareableText();

        expect(text, isEmpty);
      });
    });

    group('getExportableData', () {
      test('returns exportable JSON data', () {
        final notifier = ConversationNotifier(
          mockRepository,
          mockAIAPIService,
          'test-conversation-id',
        );

        notifier.state = ConversationState(
          conversation: testConversation,
          messages: [testMessage],
        );

        final data = notifier.getExportableData();

        expect(data['conversation'], isNotNull);
        expect(data['messages'], isA<List>());
        expect(data['messageCount'], equals(1));
        expect(data['exportedAt'], isNotNull);
      });
    });
  });
}
