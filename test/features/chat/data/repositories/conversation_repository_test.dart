import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeusgpt/features/chat/data/repositories/conversation_repository.dart';
import 'package:zeusgpt/features/chat/data/models/conversation_model.dart';
import 'package:zeusgpt/features/chat/data/models/message_model.dart';
import 'package:zeusgpt/core/utils/error_handler.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference<T> extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot<T> extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuerySnapshot<T> extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQuery<T> extends Mock implements Query<Map<String, dynamic>> {}

class MockWriteBatch extends Mock implements WriteBatch {}

class MockQueryDocumentSnapshot<T> extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

// Fake classes for fallback values
class FakeQuery extends Fake implements Query<Map<String, dynamic>> {}

class FakeDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockConversationsCollection;
  late MockCollectionReference<Map<String, dynamic>> mockMessagesCollection;
  late ConversationRepository repository;

  // Test fixtures
  final testConversation = ConversationModel(
    conversationId: 'test-conversation-id',
    userId: 'test-user-id',
    title: 'Test Conversation',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 15),
    modelId: 'gpt-4',
    provider: 'openai',
    messageCount: 5,
    lastMessage: 'Last message content',
    lastMessageAt: DateTime(2024, 1, 15),
  );

  final testMessage = MessageModel(
    messageId: 'test-message-id',
    conversationId: 'test-conversation-id',
    role: MessageRole.user,
    content: 'Test message content',
    createdAt: DateTime(2024, 1, 15),
    status: MessageStatus.sent,
    userId: 'test-user-id',
  );

  setUpAll(() {
    registerFallbackValue(FakeQuery());
    registerFallbackValue(FakeDocumentReference());
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockConversationsCollection = MockCollectionReference<Map<String, dynamic>>();
    mockMessagesCollection = MockCollectionReference<Map<String, dynamic>>();
    repository = ConversationRepository(firestore: mockFirestore);

    // Default setup for collections
    when(() => mockFirestore.collection('conversations'))
        .thenReturn(mockConversationsCollection);
    when(() => mockFirestore.collection('messages'))
        .thenReturn(mockMessagesCollection);
  });

  group('ConversationRepository', () {
    group('getConversationsStream', () {
      test('returns stream of conversations', () async {
        final mockQuery1 = MockQuery<Map<String, dynamic>>();
        final mockQuery2 = MockQuery<Map<String, dynamic>>();
        final mockQuery3 = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockQueryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockConversationsCollection.where('userId', isEqualTo: 'test-user-id'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.where('isDeleted', isEqualTo: false))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.orderBy('updatedAt', descending: true))
            .thenReturn(mockQuery3);
        when(() => mockQuery3.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
        when(() => mockQueryDoc.data()).thenReturn(testConversation.toJson());

        final stream = repository.getConversationsStream('test-user-id');
        final result = await stream.first;

        expect(result, isA<List<ConversationModel>>());
        expect(result.length, equals(1));
        expect(result.first.conversationId, equals('test-conversation-id'));
      });
    });

    group('getMessagesStream', () {
      test('returns stream of messages', () async {
        final mockQuery1 = MockQuery<Map<String, dynamic>>();
        final mockQuery2 = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockQueryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockMessagesCollection.where('conversationId', isEqualTo: 'test-conversation-id'))
            .thenReturn(mockQuery1);
        when(() => mockQuery1.orderBy('createdAt', descending: false))
            .thenReturn(mockQuery2);
        when(() => mockQuery2.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
        when(() => mockQueryDoc.data()).thenReturn(testMessage.toJson());

        final stream = repository.getMessagesStream('test-conversation-id');
        final result = await stream.first;

        expect(result, isA<List<MessageModel>>());
        expect(result.length, equals(1));
        expect(result.first.messageId, equals('test-message-id'));
      });
    });

    group('getConversation', () {
      test('returns ConversationModel when document exists', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
        final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-conversation-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.get())
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn(testConversation.toJson());

        final result = await repository.getConversation('test-conversation-id');

        expect(result, isA<ConversationModel>());
        expect(result?.conversationId, equals('test-conversation-id'));
        expect(result?.title, equals('Test Conversation'));
      });

      test('returns null when document does not exist', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
        final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('non-existent-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.get())
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        final result = await repository.getConversation('non-existent-id');

        expect(result, isNull);
      });

      test('returns null when document data is null', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
        final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.get())
            .thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.data()).thenReturn(null);

        final result = await repository.getConversation('test-id');

        expect(result, isNull);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.get())
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.getConversation('test-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('createConversation', () {
      test('creates conversation successfully', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc(testConversation.conversationId))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.set(any()))
            .thenAnswer((_) async => {});

        final result = await repository.createConversation(testConversation);

        expect(result, equals(testConversation));
        verify(() => mockDocRef.set(testConversation.toJson())).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc(testConversation.conversationId))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.set(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.createConversation(testConversation),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('updateConversation', () {
      test('updates conversation successfully', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc(testConversation.conversationId))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenAnswer((_) async => {});

        await repository.updateConversation(testConversation);

        verify(() => mockDocRef.update(testConversation.toJson())).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc(testConversation.conversationId))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.updateConversation(testConversation),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('deleteConversation', () {
      test('soft deletes conversation successfully', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-conversation-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenAnswer((_) async => {});

        await repository.deleteConversation('test-conversation-id');

        verify(() => mockDocRef.update(any())).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.deleteConversation('test-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('permanentlyDeleteConversation', () {
      test('permanently deletes conversation and messages', () async {
        final mockMessagesQuery = MockQuery<Map<String, dynamic>>();
        final mockMessagesSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockConversationDocRef = MockDocumentReference<Map<String, dynamic>>();
        final mockBatch = MockWriteBatch();

        when(() => mockMessagesCollection.where('conversationId', isEqualTo: 'test-id'))
            .thenReturn(mockMessagesQuery);
        when(() => mockMessagesQuery.get())
            .thenAnswer((_) async => mockMessagesSnapshot);
        when(() => mockMessagesSnapshot.docs).thenReturn([]);
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockConversationDocRef);
        when(() => mockBatch.delete(any())).thenReturn(mockBatch);
        when(() => mockBatch.commit()).thenAnswer((_) async => {});

        await repository.permanentlyDeleteConversation('test-id');

        verify(() => mockBatch.delete(mockConversationDocRef)).called(1);
        verify(() => mockBatch.commit()).called(1);
      });

      test('throws AppException on Firestore error', () async {
        when(() => mockMessagesCollection.where('conversationId', isEqualTo: 'test-id'))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.permanentlyDeleteConversation('test-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('archiveConversation', () {
      test('archives conversation successfully', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenAnswer((_) async => {});

        await repository.archiveConversation('test-id');

        verify(() => mockDocRef.update(any())).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.archiveConversation('test-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('unarchiveConversation', () {
      test('unarchives conversation successfully', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenAnswer((_) async => {});

        await repository.unarchiveConversation('test-id');

        verify(() => mockDocRef.update(any())).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.unarchiveConversation('test-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('pinConversation', () {
      test('pins conversation successfully', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenAnswer((_) async => {});

        await repository.pinConversation('test-id');

        verify(() => mockDocRef.update(any())).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.pinConversation('test-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('unpinConversation', () {
      test('unpins conversation successfully', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenAnswer((_) async => {});

        await repository.unpinConversation('test-id');

        verify(() => mockDocRef.update(any())).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockConversationsCollection.doc('test-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.unpinConversation('test-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('addMessage', () {
      test('adds message and updates conversation successfully', () async {
        final mockMessageDocRef = MockDocumentReference<Map<String, dynamic>>();
        final mockConversationDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockMessagesCollection.doc(testMessage.messageId))
            .thenReturn(mockMessageDocRef);
        when(() => mockMessageDocRef.set(any()))
            .thenAnswer((_) async => {});
        when(() => mockConversationsCollection.doc(testMessage.conversationId))
            .thenReturn(mockConversationDocRef);
        when(() => mockConversationDocRef.update(any()))
            .thenAnswer((_) async => {});

        final result = await repository.addMessage(testMessage);

        expect(result, equals(testMessage));
        verify(() => mockMessageDocRef.set(testMessage.toJson())).called(1);
        verify(() => mockConversationDocRef.update(any())).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockMessageDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockMessagesCollection.doc(testMessage.messageId))
            .thenReturn(mockMessageDocRef);
        when(() => mockMessageDocRef.set(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.addMessage(testMessage),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('updateMessage', () {
      test('updates message successfully', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockMessagesCollection.doc(testMessage.messageId))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenAnswer((_) async => {});

        await repository.updateMessage(testMessage);

        verify(() => mockDocRef.update(testMessage.toJson())).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockMessagesCollection.doc(testMessage.messageId))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.update(any()))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.updateMessage(testMessage),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('deleteMessage', () {
      test('deletes message successfully', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockMessagesCollection.doc('test-message-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.delete())
            .thenAnswer((_) async => {});

        await repository.deleteMessage('test-message-id');

        verify(() => mockDocRef.delete()).called(1);
      });

      test('throws AppException on Firestore error', () async {
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(() => mockMessagesCollection.doc('test-message-id'))
            .thenReturn(mockDocRef);
        when(() => mockDocRef.delete())
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        expect(
          () => repository.deleteMessage('test-message-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('searchConversations', () {
      test('searches and filters conversations successfully', () async {
        final mockQuery = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockQueryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        final searchableConversation = testConversation.copyWith(
          title: 'Search Test Conversation',
          lastMessage: 'This contains search term',
        );

        when(() => mockConversationsCollection.where('userId', isEqualTo: 'test-user-id'))
            .thenReturn(mockQuery);
        when(() => mockQuery.where('isDeleted', isEqualTo: false))
            .thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
        when(() => mockQueryDoc.data()).thenReturn(searchableConversation.toJson());

        final result = await repository.searchConversations('test-user-id', 'search');

        expect(result, isA<List<ConversationModel>>());
        expect(result.isNotEmpty, isTrue);
      });

      test('returns empty list when no matches found', () async {
        final mockQuery = MockQuery<Map<String, dynamic>>();
        final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockQueryDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        final nonMatchingConversation = testConversation.copyWith(
          title: 'Different Title',
          lastMessage: 'No match here',
        );

        when(() => mockConversationsCollection.where('userId', isEqualTo: 'test-user-id'))
            .thenReturn(mockQuery);
        when(() => mockQuery.where('isDeleted', isEqualTo: false))
            .thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);
        when(() => mockQueryDoc.data()).thenReturn(nonMatchingConversation.toJson());

        final result = await repository.searchConversations('test-user-id', 'nonexistent');

        expect(result, isEmpty);
      });
    });
  });
}
