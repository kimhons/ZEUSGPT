import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert';

/// Mock HTTP Client for testing
class MockHttpClient extends Mock implements http.Client {}

/// Mock HTTP Response
class MockResponse extends Mock implements http.Response {
  final int _statusCode;
  final String _body;
  final Map<String, String> _headers;

  MockResponse({
    required int statusCode,
    required String body,
    Map<String, String>? headers,
  })  : _statusCode = statusCode,
        _body = body,
        _headers = headers ?? {};

  @override
  int get statusCode => _statusCode;

  @override
  String get body => _body;

  @override
  Map<String, String> get headers => _headers;
}

/// Helper to create success response
http.Response createSuccessResponse(Map<String, dynamic> data) {
  return MockResponse(
    statusCode: 200,
    body: json.encode(data),
    headers: {'content-type': 'application/json'},
  );
}

/// Helper to create error response
http.Response createErrorResponse(
  int statusCode,
  String message,
) {
  return MockResponse(
    statusCode: statusCode,
    body: json.encode({'error': message}),
    headers: {'content-type': 'application/json'},
  );
}

/// Mock API responses
class MockAPIResponses {
  /// Mock chat completion response
  static Map<String, dynamic> chatCompletion({
    String? id,
    String? content,
    String? role,
  }) {
    return {
      'id': id ?? 'chatcmpl-123',
      'object': 'chat.completion',
      'created': DateTime.now().millisecondsSinceEpoch,
      'model': 'gpt-4',
      'choices': [
        {
          'index': 0,
          'message': {
            'role': role ?? 'assistant',
            'content': content ?? 'This is a test response',
          },
          'finish_reason': 'stop',
        }
      ],
      'usage': {
        'prompt_tokens': 10,
        'completion_tokens': 20,
        'total_tokens': 30,
      },
    };
  }

  /// Mock streaming chat response
  static String chatCompletionStream(String content) {
    return 'data: ${json.encode({
          'id': 'chatcmpl-123',
          'object': 'chat.completion.chunk',
          'created': DateTime.now().millisecondsSinceEpoch,
          'model': 'gpt-4',
          'choices': [
            {
              'index': 0,
              'delta': {
                'content': content,
              },
              'finish_reason': null,
            }
          ],
        })}\n\n';
  }

  /// Mock models list response
  static Map<String, dynamic> modelsList() {
    return {
      'object': 'list',
      'data': [
        {
          'id': 'gpt-4',
          'object': 'model',
          'created': 1687882411,
          'owned_by': 'openai',
        },
        {
          'id': 'gpt-3.5-turbo',
          'object': 'model',
          'created': 1677649963,
          'owned_by': 'openai',
        },
      ],
    };
  }

  /// Mock user profile response
  static Map<String, dynamic> userProfile({
    String? uid,
    String? email,
    String? displayName,
  }) {
    return {
      'uid': uid ?? 'test-user-id',
      'email': email ?? 'test@example.com',
      'displayName': displayName ?? 'Test User',
      'photoURL': 'https://example.com/photo.jpg',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Mock conversation list response
  static Map<String, dynamic> conversationsList({
    int count = 3,
  }) {
    return {
      'conversations': List.generate(
        count,
        (index) => {
          'id': 'chat-$index',
          'title': 'Test Chat $index',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'messageCount': index + 1,
        },
      ),
    };
  }

  /// Mock error response
  static Map<String, dynamic> error({
    String? message,
    String? code,
  }) {
    return {
      'error': {
        'message': message ?? 'An error occurred',
        'type': 'error',
        'code': code ?? 'internal_error',
      },
    };
  }
}

/// Helper to simulate network delay
Future<void> simulateNetworkDelay([Duration? duration]) async {
  await Future.delayed(duration ?? const Duration(milliseconds: 100));
}

/// Helper to simulate API call
Future<T> simulateAPICall<T>(
  T Function() builder, {
  Duration? delay,
  bool shouldFail = false,
}) async {
  await simulateNetworkDelay(delay);

  if (shouldFail) {
    throw Exception('Simulated API error');
  }

  return builder();
}
