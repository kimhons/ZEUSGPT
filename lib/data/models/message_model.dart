import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// Message model representing a chat message
@freezed
class MessageModel with _$MessageModel {
  const MessageModel._();

  const factory MessageModel({
    required String messageId,
    required String role, // user, assistant, system
    required String content,
    @Default('text') String contentType, // text, image, audio, file
    @Default('sent') String status, // sending, sent, delivered, failed, streaming
    String? errorMessage,
    MessageMetadata? metadata,
    @Default([]) List<MessageAttachment> attachments,
    MessageReactions? reactions,
    MessageVoice? voice,
    @Default([]) List<MessageSource> sources,
    required DateTime timestamp,
    DateTime? editedAt,
    DateTime? deletedAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// Check if message is from user
  bool get isFromUser => role == 'user';

  /// Check if message is from AI
  bool get isFromAI => role == 'assistant';

  /// Check if message is system message
  bool get isSystemMessage => role == 'system';

  /// Check if message is still sending
  bool get isSending => status == 'sending';

  /// Check if message failed
  bool get hasFailed => status == 'failed';

  /// Check if message is streaming
  bool get isStreaming => status == 'streaming';

  /// Get cost in USD (0 if not available)
  double get cost => metadata?.cost ?? 0.0;

  /// Get tokens used (0 if not available)
  int get tokensUsed => metadata?.tokensUsed.total ?? 0;
}

@freezed
class MessageMetadata with _$MessageMetadata {
  const factory MessageMetadata({
    required String model,
    required String provider,
    required MessageTokens tokensUsed,
    required double cost, // in USD
    required int latency, // in milliseconds
    @Default('stop') String finishReason, // stop, length, content_filter
  }) = _MessageMetadata;

  factory MessageMetadata.fromJson(Map<String, dynamic> json) =>
      _$MessageMetadataFromJson(json);
}

@freezed
class MessageTokens with _$MessageTokens {
  const factory MessageTokens({
    required int prompt,
    required int completion,
    required int total,
  }) = _MessageTokens;

  factory MessageTokens.fromJson(Map<String, dynamic> json) =>
      _$MessageTokensFromJson(json);
}

@freezed
class MessageAttachment with _$MessageAttachment {
  const factory MessageAttachment({
    @Default('file') String type, // image, file, audio
    required String url,
    required String name,
    required int size,
    required String mimeType,
  }) = _MessageAttachment;

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentFromJson(json);
}

@freezed
class MessageReactions with _$MessageReactions {
  const factory MessageReactions({
    @Default(false) bool thumbsUp,
    @Default(false) bool thumbsDown,
    @Default(false) bool copied,
    @Default(false) bool regenerated,
  }) = _MessageReactions;

  factory MessageReactions.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionsFromJson(json);
}

@freezed
class MessageVoice with _$MessageVoice {
  const factory MessageVoice({
    required String audioURL,
    required int duration, // in seconds
    required String transcript,
    required String voiceId,
  }) = _MessageVoice;

  factory MessageVoice.fromJson(Map<String, dynamic> json) =>
      _$MessageVoiceFromJson(json);
}

@freezed
class MessageSource with _$MessageSource {
  const factory MessageSource({
    @Default('web') String type, // web, document, memory
    required String title,
    String? url,
    String? snippet,
  }) = _MessageSource;

  factory MessageSource.fromJson(Map<String, dynamic> json) =>
      _$MessageSourceFromJson(json);
}
