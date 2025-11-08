import 'package:freezed_annotation/freezed_annotation.dart';
import 'message_model.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

/// Conversation model representing a chat conversation
@freezed
class ConversationModel with _$ConversationModel {
  const ConversationModel._();

  const factory ConversationModel({
    required String conversationId,
    required String userId,
    String? teamId,
    required String title,
    String? summary,
    @Default('gpt-4o') String modelId,
    @Default('openai') String modelProvider,
    @Default(0.7) double temperature,
    @Default(2048) int maxTokens,
    String? systemPrompt,
    required ConversationContext context,
    String? folderId,
    @Default([]) List<String> tags,
    @Default(false) bool isPinned,
    @Default(false) bool isArchived,
    @Default([]) List<ConversationCollaborator> collaborators,
    @Default(0) int messageCount,
    @Default(0) int totalTokens,
    @Default(0.0) double estimatedCost,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime lastMessageAt,
    DateTime? deletedAt,
  }) = _ConversationModel;

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  /// Check if conversation is a team conversation
  bool get isTeamConversation => teamId != null;

  /// Check if conversation has collaborators
  bool get hasCollaborators => collaborators.isNotEmpty;

  /// Get formatted last message time (e.g., "5 min ago", "Yesterday", "Jan 15")
  String get formattedLastMessageTime {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastMessageAt.month}/${lastMessageAt.day}';
    }
  }

  /// Get conversation status indicator
  String get statusIndicator {
    if (isArchived) return 'Archived';
    if (isPinned) return 'Pinned';
    if (isTeamConversation) return 'Team';
    return 'Personal';
  }
}

@freezed
class ConversationContext with _$ConversationContext {
  const factory ConversationContext({
    @Default(true) bool enableWebSearch,
    @Default(true) bool enableMemory,
    @Default([]) List<ConversationFile> attachedFiles,
  }) = _ConversationContext;

  factory ConversationContext.fromJson(Map<String, dynamic> json) =>
      _$ConversationContextFromJson(json);
}

@freezed
class ConversationFile with _$ConversationFile {
  const factory ConversationFile({
    required String fileId,
    required String fileName,
    required String fileURL,
    required String fileType,
    required int fileSize,
  }) = _ConversationFile;

  factory ConversationFile.fromJson(Map<String, dynamic> json) =>
      _$ConversationFileFromJson(json);
}

@freezed
class ConversationCollaborator with _$ConversationCollaborator {
  const factory ConversationCollaborator({
    required String userId,
    @Default('viewer') String role, // owner, editor, viewer
    required DateTime addedAt,
  }) = _ConversationCollaborator;

  factory ConversationCollaborator.fromJson(Map<String, dynamic> json) =>
      _$ConversationCollaboratorFromJson(json);
}

/// Lightweight conversation summary for list views
@freezed
class ConversationSummary with _$ConversationSummary {
  const ConversationSummary._();

  const factory ConversationSummary({
    required String conversationId,
    required String title,
    String? lastMessage,
    required DateTime lastMessageAt,
    @Default(0) int unreadCount,
    @Default(false) bool isPinned,
    @Default(false) bool isArchived,
    String? modelId,
  }) = _ConversationSummary;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) =>
      _$ConversationSummaryFromJson(json);

  /// Check if there are unread messages
  bool get hasUnread => unreadCount > 0;
}
