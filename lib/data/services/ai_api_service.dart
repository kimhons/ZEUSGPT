import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger_service.dart';
import '../../core/utils/error_handler.dart';
import '../../features/chat/data/models/message_model.dart';

/// AI API Service for interacting with AIMLAPI and AltogetherAI
class AIAPIService {
  AIAPIService({
    http.Client? client,
    String? aimlApiKey,
    String? togetherApiKey,
  })  : _client = client ?? http.Client(),
        _aimlApiKey = aimlApiKey ?? _getAIMLAPIKey(),
        _togetherApiKey = togetherApiKey ?? _getTogetherAPIKey();

  final http.Client _client;
  final String _aimlApiKey;
  final String _togetherApiKey;

  // TODO: Load from environment variables
  static String _getAIMLAPIKey() {
    // For now, return empty string - will need proper env loading
    LoggerService.w('AIMLAPI key not configured - using placeholder');
    return const String.fromEnvironment('AIMLAPI_KEY', defaultValue: '');
  }

  static String _getTogetherAPIKey() {
    LoggerService.w('Together API key not configured - using placeholder');
    return const String.fromEnvironment('ALTOGETHER_AI_KEY', defaultValue: '');
  }

  /// Send a message and get AI response
  /// Returns the assistant's response content
  Future<String> sendMessage({
    required String modelId,
    required List<MessageModel> messages,
    String? provider,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
  }) async {
    try {
      // Determine which API to use based on provider
      final useTogetherAI = provider?.toLowerCase() == 'together' ||
                            modelId.contains('together');

      final apiKey = useTogetherAI ? _togetherApiKey : _aimlApiKey;
      final baseUrl = useTogetherAI
          ? AppConstants.togetherApiBaseUrl
          : AppConstants.aimlApiBaseUrl;

      if (apiKey.isEmpty) {
        throw Exception('API key not configured for ${useTogetherAI ? "Together" : "AIMLAPI"}');
      }

      LoggerService.i('Sending message to $modelId via ${useTogetherAI ? "Together" : "AIMLAPI"}');

      // Build message array for API
      final apiMessages = _buildMessageArray(messages, systemPrompt);

      // Build request body
      final requestBody = {
        'model': modelId,
        'messages': apiMessages,
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
        'stream': false, // For now, no streaming
      };

      // Make API call
      final response = await _client
          .post(
            Uri.parse('$baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['choices']?[0]?['message']?['content'] as String?;

        if (content == null) {
          throw Exception('Invalid response format from API');
        }

        LoggerService.i('Received response from AI: ${content.length} characters');
        return content;
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('API Error (${response.statusCode}): $errorMessage');
      }
    } catch (e, stackTrace) {
      LoggerService.e('Failed to send message to AI', error: e, stackTrace: stackTrace);
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  /// Build message array for API request
  List<Map<String, dynamic>> _buildMessageArray(
    List<MessageModel> messages,
    String? systemPrompt,
  ) {
    final apiMessages = <Map<String, dynamic>>[];

    // Add system prompt if provided
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      apiMessages.add({
        'role': 'system',
        'content': systemPrompt,
      });
    }

    // Convert messages to API format
    for (final message in messages) {
      apiMessages.add({
        'role': message.role.toString().split('.').last, // user or assistant
        'content': message.content,
      });
    }

    return apiMessages;
  }

  /// Send message with streaming response
  /// Returns a stream of content chunks
  Stream<String> sendMessageStream({
    required String modelId,
    required List<MessageModel> messages,
    String? provider,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
  }) async* {
    // TODO: Implement streaming support
    // For now, just yield the full response
    final response = await sendMessage(
      modelId: modelId,
      messages: messages,
      provider: provider,
      systemPrompt: systemPrompt,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    yield response;
  }

  /// Get available models from the API
  Future<List<Map<String, dynamic>>> getAvailableModels({
    bool useTogetherAI = false,
  }) async {
    try {
      final apiKey = useTogetherAI ? _togetherApiKey : _aimlApiKey;
      final baseUrl = useTogetherAI
          ? AppConstants.togetherApiBaseUrl
          : AppConstants.aimlApiBaseUrl;

      if (apiKey.isEmpty) {
        throw Exception('API key not configured');
      }

      final response = await _client
          .get(
            Uri.parse('$baseUrl/models'),
            headers: {
              'Authorization': 'Bearer $apiKey',
            },
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final modelsData = data['data'] as List<dynamic>? ?? [];
        return List<Map<String, dynamic>>.from(
          modelsData.map((e) => e as Map<String, dynamic>)
        );
      } else {
        throw Exception('Failed to fetch models: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      LoggerService.e('Failed to get available models', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
