import 'package:freezed_annotation/freezed_annotation.dart';
import 'message_model.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

/// Conversation model
@freezed
class ConversationModel with _$ConversationModel {
  const factory ConversationModel({
    required String conversationId,
    required String userId,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String modelId,
    required String provider,
    @Default([]) List<MessageModel> messages,
    @Default([]) List<String> tags,
    String? folderId,
    String? folderName,
    @Default(false) bool isPinned,
    @Default(false) bool isArchived,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
    @Default(0) int messageCount,
    @Default(0) int tokenCount,
    Map<String, dynamic>? metadata,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
    @Default(false) bool isShared,
    @Default([]) List<String> sharedWithUserIds,
    @Default([]) List<String> sharedWithTeamIds,
  }) = _ConversationModel;

  const ConversationModel._();

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  /// Get conversation preview (first 100 chars)
  String get preview {
    if (lastMessage != null && lastMessage!.isNotEmpty) {
      return lastMessage!.length > 100
          ? '${lastMessage!.substring(0, 100)}...'
          : lastMessage!;
    }
    return 'No messages yet';
  }

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt ?? updatedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  /// Check if conversation is active (not deleted or archived)
  bool get isActive => !isDeleted && !isArchived;
}
