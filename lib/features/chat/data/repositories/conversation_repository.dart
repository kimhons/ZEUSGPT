import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Conversation repository interface
abstract class IConversationRepository {
  /// Get all conversations for a user
  Stream<List<ConversationModel>> getConversationsStream(String userId);

  /// Get a single conversation
  Future<ConversationModel?> getConversation(String conversationId);

  /// Create a new conversation
  Future<ConversationModel> createConversation(ConversationModel conversation);

  /// Update a conversation
  Future<void> updateConversation(ConversationModel conversation);

  /// Delete a conversation (soft delete)
  Future<void> deleteConversation(String conversationId);

  /// Permanently delete a conversation
  Future<void> permanentlyDeleteConversation(String conversationId);

  /// Archive a conversation
  Future<void> archiveConversation(String conversationId);

  /// Unarchive a conversation
  Future<void> unarchiveConversation(String conversationId);

  /// Pin a conversation
  Future<void> pinConversation(String conversationId);

  /// Unpin a conversation
  Future<void> unpinConversation(String conversationId);

  /// Add a message to a conversation
  Future<MessageModel> addMessage(MessageModel message);

  /// Update a message
  Future<void> updateMessage(MessageModel message);

  /// Delete a message
  Future<void> deleteMessage(String messageId);

  /// Get messages for a conversation
  Stream<List<MessageModel>> getMessagesStream(String conversationId);

  /// Search conversations
  Future<List<ConversationModel>> searchConversations(
    String userId,
    String query,
  );
}

/// Firestore conversation repository implementation
class ConversationRepository implements IConversationRepository {
  ConversationRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _conversationsCollection = 'conversations';
  static const String _messagesCollection = 'messages';

  @override
  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    try {
      return _firestore
          .collection(_conversationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return ConversationModel.fromJson(data);
        }).toList();
      });
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to get conversations stream',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<ConversationModel?> getConversation(String conversationId) async {
    try {
      LoggerService.d('Getting conversation: $conversationId');

      final doc = await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .get();

      if (!doc.exists) {
        LoggerService.w('Conversation not found: $conversationId');
        return null;
      }

      final data = doc.data();
      if (data == null) return null;

      return ConversationModel.fromJson(data);
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to get conversation',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<ConversationModel> createConversation(
    ConversationModel conversation,
  ) async {
    try {
      LoggerService.i('Creating conversation: ${conversation.title}');

      final docRef = _firestore
          .collection(_conversationsCollection)
          .doc(conversation.conversationId);

      final data = conversation.toJson();
      await docRef.set(data);

      LoggerService.i(
        'Conversation created successfully: ${conversation.conversationId}',
      );
      return conversation;
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to create conversation',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> updateConversation(ConversationModel conversation) async {
    try {
      LoggerService.d('Updating conversation: ${conversation.conversationId}');

      final docRef = _firestore
          .collection(_conversationsCollection)
          .doc(conversation.conversationId);

      final data = conversation.toJson();
      await docRef.update(data);

      LoggerService.d('Conversation updated successfully');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to update conversation',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      LoggerService.w('Soft deleting conversation: $conversationId');

      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.w('Conversation deleted successfully');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to delete conversation',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> permanentlyDeleteConversation(String conversationId) async {
    try {
      LoggerService.w(
        'Permanently deleting conversation: $conversationId',
      );

      // Delete all messages first
      final messagesQuery = await _firestore
          .collection(_messagesCollection)
          .where('conversationId', isEqualTo: conversationId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete conversation
      batch.delete(
        _firestore.collection(_conversationsCollection).doc(conversationId),
      );

      await batch.commit();

      LoggerService.w('Conversation permanently deleted');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to permanently delete conversation',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> archiveConversation(String conversationId) async {
    try {
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update({'isArchived': true});

      LoggerService.d('Conversation archived');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to archive conversation',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> unarchiveConversation(String conversationId) async {
    try {
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update({'isArchived': false});

      LoggerService.d('Conversation unarchived');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to unarchive conversation',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> pinConversation(String conversationId) async {
    try {
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update({'isPinned': true});

      LoggerService.d('Conversation pinned');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to pin conversation',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> unpinConversation(String conversationId) async {
    try {
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update({'isPinned': false});

      LoggerService.d('Conversation unpinned');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to unpin conversation',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<MessageModel> addMessage(MessageModel message) async {
    try {
      LoggerService.d('Adding message to conversation: ${message.conversationId}');

      final docRef = _firestore
          .collection(_messagesCollection)
          .doc(message.messageId);

      final data = message.toJson();
      await docRef.set(data);

      // Update conversation's last message and message count
      await _firestore
          .collection(_conversationsCollection)
          .doc(message.conversationId)
          .update({
        'lastMessage': message.content,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.d('Message added successfully');
      return message;
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to add message',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> updateMessage(MessageModel message) async {
    try {
      LoggerService.d('Updating message: ${message.messageId}');

      final docRef = _firestore
          .collection(_messagesCollection)
          .doc(message.messageId);

      final data = message.toJson();
      await docRef.update(data);

      LoggerService.d('Message updated successfully');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to update message',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      LoggerService.w('Deleting message: $messageId');

      await _firestore.collection(_messagesCollection).doc(messageId).delete();

      LoggerService.w('Message deleted successfully');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to delete message',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    try {
      return _firestore
          .collection(_messagesCollection)
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return MessageModel.fromJson(data);
        }).toList();
      });
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to get messages stream',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<List<ConversationModel>> searchConversations(
    String userId,
    String query,
  ) async {
    try {
      LoggerService.d('Searching conversations: $query');

      // Note: This is a simple implementation
      // For production, consider using Algolia or similar for better search
      final snapshot = await _firestore
          .collection(_conversationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .get();

      final conversations = snapshot.docs
          .map((doc) => ConversationModel.fromJson(doc.data()))
          .where((conversation) {
        final titleMatch =
            conversation.title.toLowerCase().contains(query.toLowerCase());
        final contentMatch = conversation.lastMessage != null &&
            conversation.lastMessage!.toLowerCase().contains(query.toLowerCase());
        return titleMatch || contentMatch;
      }).toList();

      LoggerService.d('Found ${conversations.length} conversations');
      return conversations;
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to search conversations',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }
}
