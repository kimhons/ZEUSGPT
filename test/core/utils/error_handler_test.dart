import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zeusgpt/core/utils/error_handler.dart';

void main() {
  group('AppException Classes', () {
    group('NetworkException', () {
      test('creates with message and code', () {
        const exception = NetworkException('Network error', code: 'net_001');
        expect(exception.message, equals('Network error'));
        expect(exception.code, equals('net_001'));
      });

      test('toString returns message', () {
        const exception = NetworkException('Network error');
        expect(exception.toString(), equals('Network error'));
      });
    });

    group('AuthException', () {
      test('creates with message and code', () {
        const exception = AuthException('Auth error', code: 'auth_001');
        expect(exception.message, equals('Auth error'));
        expect(exception.code, equals('auth_001'));
      });
    });

    group('APIException', () {
      test('creates with message, code, and status code', () {
        const exception = APIException(
          'API error',
          code: 'api_001',
          statusCode: 404,
        );
        expect(exception.message, equals('API error'));
        expect(exception.code, equals('api_001'));
        expect(exception.statusCode, equals(404));
      });
    });

    group('RateLimitException', () {
      test('creates with message, code, and retry duration', () {
        const exception = RateLimitException(
          'Rate limit exceeded',
          code: 'rate_limit',
          retryAfter: Duration(minutes: 5),
        );
        expect(exception.message, equals('Rate limit exceeded'));
        expect(exception.code, equals('rate_limit'));
        expect(exception.retryAfter, equals(const Duration(minutes: 5)));
      });
    });

    group('InsufficientCreditsException', () {
      test('creates with message and code', () {
        const exception = InsufficientCreditsException(
          'Insufficient credits',
          code: 'no_credits',
        );
        expect(exception.message, equals('Insufficient credits'));
        expect(exception.code, equals('no_credits'));
      });
    });

    group('PermissionDeniedException', () {
      test('creates with message and code', () {
        const exception = PermissionDeniedException(
          'Permission denied',
          code: 'forbidden',
        );
        expect(exception.message, equals('Permission denied'));
        expect(exception.code, equals('forbidden'));
      });
    });

    group('ValidationException', () {
      test('creates with message and code', () {
        const exception = ValidationException(
          'Validation failed',
          code: 'validation_error',
        );
        expect(exception.message, equals('Validation failed'));
        expect(exception.code, equals('validation_error'));
      });
    });

    group('StorageException', () {
      test('creates with message and code', () {
        const exception = StorageException(
          'Storage error',
          code: 'storage_001',
        );
        expect(exception.message, equals('Storage error'));
        expect(exception.code, equals('storage_001'));
      });
    });

    group('UnknownException', () {
      test('creates with message and code', () {
        const exception = UnknownException(
          'Unknown error',
          code: 'unknown',
        );
        expect(exception.message, equals('Unknown error'));
        expect(exception.code, equals('unknown'));
      });
    });
  });

  group('ErrorHandler.handleError', () {
    group('DioException handling', () {
      test('handles connection timeout', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('connection_timeout'));
        expect(result.message, contains('Connection timeout'));
      });

      test('handles send timeout', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.sendTimeout,
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('connection_timeout'));
      });

      test('handles receive timeout', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('connection_timeout'));
      });

      test('handles connection error', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('no_connection'));
        expect(result.message, contains('No internet connection'));
      });

      test('handles request cancellation', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.cancel,
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('request_cancelled'));
      });

      test('handles unknown dio error', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.unknown,
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('unknown_network_error'));
      });
    });

    group('HTTP status code handling', () {
      test('handles 400 Bad Request', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'message': 'Invalid request'},
          ),
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<ValidationException>());
        expect(result.code, equals('bad_request'));
      });

      test('handles 401 Unauthorized', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<AuthException>());
        expect(result.code, equals('unauthorized'));
        expect(result.message, contains('not authorized'));
      });

      test('handles 403 Forbidden', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 403,
          ),
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<PermissionDeniedException>());
        expect(result.code, equals('forbidden'));
      });

      test('handles 404 Not Found', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 404,
          ),
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<APIException>());
        expect(result.code, equals('not_found'));
        expect((result as APIException).statusCode, equals(404));
      });

      test('handles 429 Rate Limit', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 429,
          ),
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<RateLimitException>());
        expect(result.code, equals('rate_limit_exceeded'));
        expect((result as RateLimitException).retryAfter,
            equals(const Duration(minutes: 1)));
      });

      test('handles 402 Payment Required', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 402,
          ),
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<InsufficientCreditsException>());
        expect(result.code, equals('insufficient_credits'));
      });

      test('handles 500 Server Error', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
          ),
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<APIException>());
        expect(result.code, equals('server_error'));
      });

      test('extracts error message from response data', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'message': 'Custom error message'},
          ),
        );

        final result = ErrorHandler.handleError(error);

        expect(result.message, equals('Custom error message'));
      });

      test('extracts error from response data', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'error': 'Error message'},
          ),
        );

        final result = ErrorHandler.handleError(error);

        expect(result.message, equals('Error message'));
      });
    });

    group('FirebaseAuthException handling', () {
      test('handles user-not-found', () {
        final error = FirebaseAuthException(code: 'user-not-found');

        final result = ErrorHandler.handleError(error);

        expect(result, isA<AuthException>());
        expect(result.code, equals('user_not_found'));
        expect(result.message, contains('No user found'));
      });

      test('handles wrong-password', () {
        final error = FirebaseAuthException(code: 'wrong-password');

        final result = ErrorHandler.handleError(error);

        expect(result, isA<AuthException>());
        expect(result.code, equals('wrong_password'));
        expect(result.message, contains('Incorrect password'));
      });

      test('handles email-already-in-use', () {
        final error = FirebaseAuthException(code: 'email-already-in-use');

        final result = ErrorHandler.handleError(error);

        expect(result, isA<AuthException>());
        expect(result.code, equals('email_already_in_use'));
      });

      test('handles invalid-email', () {
        final error = FirebaseAuthException(code: 'invalid-email');

        final result = ErrorHandler.handleError(error);

        expect(result, isA<AuthException>());
        expect(result.code, equals('invalid_email'));
      });

      test('handles weak-password', () {
        final error = FirebaseAuthException(code: 'weak-password');

        final result = ErrorHandler.handleError(error);

        expect(result, isA<AuthException>());
        expect(result.code, equals('weak_password'));
      });

      test('handles too-many-requests', () {
        final error = FirebaseAuthException(code: 'too-many-requests');

        final result = ErrorHandler.handleError(error);

        expect(result, isA<RateLimitException>());
        expect(result.code, equals('too_many_requests'));
      });

      test('handles network-request-failed', () {
        final error = FirebaseAuthException(code: 'network-request-failed');

        final result = ErrorHandler.handleError(error);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('network_request_failed'));
      });

      test('handles unknown auth error', () {
        final error = FirebaseAuthException(
          code: 'unknown-code',
          message: 'Unknown error occurred',
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<AuthException>());
        expect(result.code, equals('unknown-code'));
        expect(result.message, equals('Unknown error occurred'));
      });
    });

    group('FirebaseException handling', () {
      test('handles permission-denied', () {
        final error = FirebaseException(
          plugin: 'test',
          code: 'permission-denied',
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<PermissionDeniedException>());
        expect(result.code, equals('permission_denied'));
      });

      test('handles not-found', () {
        final error = FirebaseException(
          plugin: 'test',
          code: 'not-found',
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<StorageException>());
        expect(result.code, equals('not_found'));
      });

      test('handles unavailable', () {
        final error = FirebaseException(
          plugin: 'test',
          code: 'unavailable',
        );

        final result = ErrorHandler.handleError(error);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('unavailable'));
      });
    });

    group('AppException handling', () {
      test('returns AppException as-is', () {
        const exception = NetworkException('Network error', code: 'net_001');

        final result = ErrorHandler.handleError(exception);

        expect(result, same(exception));
      });
    });

    group('Unknown error handling', () {
      test('handles generic exception', () {
        final error = Exception('Something went wrong');

        final result = ErrorHandler.handleError(error);

        expect(result, isA<UnknownException>());
        expect(result.code, equals('unknown_error'));
        expect(result.message, contains('unexpected error'));
      });

      test('handles string error', () {
        const error = 'Error string';

        final result = ErrorHandler.handleError(error);

        expect(result, isA<UnknownException>());
      });
    });
  });

  group('ErrorHandler helper methods', () {
    group('getUserMessage', () {
      test('returns message from AppException', () {
        const exception = NetworkException('Network error');

        final message = ErrorHandler.getUserMessage(exception);

        expect(message, equals('Network error'));
      });

      test('converts non-AppException to user message', () {
        final error = Exception('Generic error');

        final message = ErrorHandler.getUserMessage(error);

        expect(message, contains('unexpected error'));
      });
    });

    group('isNetworkError', () {
      test('returns true for NetworkException', () {
        const exception = NetworkException('Network error');

        expect(ErrorHandler.isNetworkError(exception), isTrue);
      });

      test('returns true for connection timeout DioException', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );

        expect(ErrorHandler.isNetworkError(error), isTrue);
      });

      test('returns true for connection error DioException', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        );

        expect(ErrorHandler.isNetworkError(error), isTrue);
      });

      test('returns false for non-network errors', () {
        const exception = AuthException('Auth error');

        expect(ErrorHandler.isNetworkError(exception), isFalse);
      });
    });

    group('isAuthError', () {
      test('returns true for AuthException', () {
        const exception = AuthException('Auth error');

        expect(ErrorHandler.isAuthError(exception), isTrue);
      });

      test('returns true for FirebaseAuthException', () {
        final error = FirebaseAuthException(code: 'test');

        expect(ErrorHandler.isAuthError(error), isTrue);
      });

      test('returns false for non-auth errors', () {
        const exception = NetworkException('Network error');

        expect(ErrorHandler.isAuthError(exception), isFalse);
      });
    });

    group('isRateLimitError', () {
      test('returns true for RateLimitException', () {
        const exception = RateLimitException('Rate limit');

        expect(ErrorHandler.isRateLimitError(exception), isTrue);
      });

      test('returns false for non-rate-limit errors', () {
        const exception = NetworkException('Network error');

        expect(ErrorHandler.isRateLimitError(exception), isFalse);
      });
    });

    group('requiresUpgrade', () {
      test('returns true for InsufficientCreditsException', () {
        const exception = InsufficientCreditsException('No credits');

        expect(ErrorHandler.requiresUpgrade(exception), isTrue);
      });

      test('returns false for other errors', () {
        const exception = NetworkException('Network error');

        expect(ErrorHandler.requiresUpgrade(exception), isFalse);
      });
    });
  });
}
