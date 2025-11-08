import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// Message role enum
enum MessageRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
}

/// Message status enum
enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('generating')
  generating,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

/// Attachment type enum
enum AttachmentType {
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
  @JsonValue('audio')
  audio,
  @JsonValue('video')
  video,
}

/// Message attachment model
@freezed
class MessageAttachment with _$MessageAttachment {
  const factory MessageAttachment({
    required String attachmentId,
    required AttachmentType type,
    required String url,
    String? fileName,
    String? mimeType,
    int? fileSize,
    int? width,
    int? height,
    int? duration,
    String? thumbnailUrl,
  }) = _MessageAttachment;

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentFromJson(json);
}

/// Message model
@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String messageId,
    required String conversationId,
    required MessageRole role,
    required String content,
    required DateTime createdAt,
    required MessageStatus status,
    String? userId,
    String? modelId,
    String? provider,
    DateTime? updatedAt,
    DateTime? completedAt,
    @Default([]) List<MessageAttachment> attachments,
    int? tokenCount,
    int? promptTokens,
    int? completionTokens,
    double? cost,
    String? errorMessage,
    String? parentMessageId,
    @Default([]) List<String> editHistory,
    @Default(false) bool isEdited,
    @Default(false) bool isRegeneratedFrom,
    String? regeneratedFromMessageId,
    Map<String, dynamic>? metadata,
    @Default(false) bool isFavorite,
    @Default(false) bool isHidden,
    @Default(false) bool isPinned,
    DateTime? editedAt,
  }) = _MessageModel;

  const MessageModel._();

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// Check if message is from user
  bool get isUser => role == MessageRole.user;

  /// Check if message is from assistant
  bool get isAssistant => role == MessageRole.assistant;

  /// Check if message is system message
  bool get isSystem => role == MessageRole.system;

  /// Check if message is still sending/generating
  bool get isLoading =>
      status == MessageStatus.sending || status == MessageStatus.generating;

  /// Check if message failed
  bool get hasFailed => status == MessageStatus.failed;

  /// Check if message is completed successfully
  bool get isCompleted => status == MessageStatus.completed;

  /// Check if message has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Alias for createdAt (for backwards compatibility)
  DateTime get timestamp => createdAt;

  /// Get image attachments only
  List<MessageAttachment> get imageAttachments =>
      attachments.where((a) => a.type == AttachmentType.image).toList();

  /// Get file attachments only
  List<MessageAttachment> get fileAttachments =>
      attachments.where((a) => a.type == AttachmentType.file).toList();

  /// Get audio attachments only
  List<MessageAttachment> get audioAttachments =>
      attachments.where((a) => a.type == AttachmentType.audio).toList();

  /// Get formatted timestamp
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get content preview (first 50 chars)
  String get preview {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }
}
