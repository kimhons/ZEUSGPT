import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logger_service.dart';

/// Custom app exceptions
abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// API exceptions
class APIException extends AppException {
  const APIException(super.message, {super.code, this.statusCode});

  final int? statusCode;
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Rate limit exceptions
class RateLimitException extends AppException {
  const RateLimitException(super.message, {super.code, this.retryAfter});

  final Duration? retryAfter;
}

/// Insufficient credits exceptions
class InsufficientCreditsException extends AppException {
  const InsufficientCreditsException(super.message, {super.code});
}

/// Permission denied exceptions
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message, {super.code});
}

/// Unknown exceptions
class UnknownException extends AppException {
  const UnknownException(super.message, {super.code});
}

/// Centralized error handler
class ErrorHandler {
  /// Handle and convert errors to user-friendly messages
  static AppException handleError(dynamic error, {StackTrace? stackTrace}) {
    LoggerService.e(
      'Error occurred',
      error: error,
      stackTrace: stackTrace,
    );

    // Dio HTTP errors
    if (error is DioException) {
      return _handleDioError(error);
    }

    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error);
    }

    // Firebase exceptions
    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }

    // Custom app exceptions
    if (error is AppException) {
      return error;
    }

    // Unknown errors
    return UnknownException(
      'An unexpected error occurred. Please try again.',
      code: 'unknown_error',
    );
  }

  /// Handle Dio errors
  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Connection timeout. Please check your internet connection.',
          code: 'connection_timeout',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return const NetworkException(
          'Request was cancelled',
          code: 'request_cancelled',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network settings.',
          code: 'no_connection',
        );

      case DioExceptionType.unknown:
        return const NetworkException(
          'An unknown network error occurred',
          code: 'unknown_network_error',
        );

      default:
        return const NetworkException(
          'A network error occurred. Please try again.',
          code: 'network_error',
        );
    }
  }

  /// Handle bad HTTP responses
  static AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Try to extract error message from response
    String message = 'An error occurred. Please try again.';
    if (data is Map<String, dynamic>) {
      message = (data['message'] as String?) ?? (data['error'] as String?) ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message,
          code: 'bad_request',
        );

      case 401:
        return const AuthException(
          'You are not authorized. Please sign in again.',
          code: 'unauthorized',
        );

      case 403:
        return const PermissionDeniedException(
          'You do not have permission to perform this action.',
          code: 'forbidden',
        );

      case 404:
        return APIException(
          'The requested resource was not found.',
          code: 'not_found',
          statusCode: statusCode,
        );

      case 429:
        return RateLimitException(
          'Too many requests. Please try again later.',
          code: 'rate_limit_exceeded',
          retryAfter: const Duration(minutes: 1),
        );

      case 402:
        return const InsufficientCreditsException(
          'Insufficient credits. Please upgrade your plan.',
          code: 'insufficient_credits',
        );

      case 500:
      case 502:
      case 503:
        return APIException(
          'Server error. Please try again later.',
          code: 'server_error',
          statusCode: statusCode,
        );

      default:
        return APIException(
          message,
          code: 'api_error',
          statusCode: statusCode,
        );
    }
  }

  /// Handle Firebase Auth errors
  static AppException _handleFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return const AuthException(
          'No user found with this email.',
          code: 'user_not_found',
        );

      case 'wrong-password':
        return const AuthException(
          'Incorrect password. Please try again.',
          code: 'wrong_password',
        );

      case 'email-already-in-use':
        return const AuthException(
          'An account already exists with this email.',
          code: 'email_already_in_use',
        );

      case 'invalid-email':
        return const AuthException(
          'Invalid email address.',
          code: 'invalid_email',
        );

      case 'weak-password':
        return const AuthException(
          'Password is too weak. Please use a stronger password.',
          code: 'weak_password',
        );

      case 'user-disabled':
        return const AuthException(
          'This account has been disabled.',
          code: 'user_disabled',
        );

      case 'too-many-requests':
        return const RateLimitException(
          'Too many attempts. Please try again later.',
          code: 'too_many_requests',
        );

      case 'operation-not-allowed':
        return const AuthException(
          'This sign-in method is not enabled.',
          code: 'operation_not_allowed',
        );

      case 'account-exists-with-different-credential':
        return const AuthException(
          'An account already exists with this email using a different sign-in method.',
          code: 'account_exists_with_different_credential',
        );

      case 'invalid-credential':
        return const AuthException(
          'Invalid credentials. Please try again.',
          code: 'invalid_credential',
        );

      case 'invalid-verification-code':
        return const AuthException(
          'Invalid verification code.',
          code: 'invalid_verification_code',
        );

      case 'invalid-verification-id':
        return const AuthException(
          'Invalid verification ID.',
          code: 'invalid_verification_id',
        );

      case 'network-request-failed':
        return const NetworkException(
          'Network error. Please check your connection.',
          code: 'network_request_failed',
        );

      default:
        return AuthException(
          error.message ?? 'Authentication error occurred.',
          code: error.code,
        );
    }
  }

  /// Handle Firebase errors
  static AppException _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return const PermissionDeniedException(
          'You do not have permission to access this resource.',
          code: 'permission_denied',
        );

      case 'not-found':
        return const StorageException(
          'The requested resource was not found.',
          code: 'not_found',
        );

      case 'already-exists':
        return const StorageException(
          'This resource already exists.',
          code: 'already_exists',
        );

      case 'unauthenticated':
        return const AuthException(
          'You must be signed in to perform this action.',
          code: 'unauthenticated',
        );

      case 'unavailable':
        return const NetworkException(
          'Service is temporarily unavailable. Please try again later.',
          code: 'unavailable',
        );

      case 'deadline-exceeded':
        return const NetworkException(
          'Request timeout. Please try again.',
          code: 'deadline_exceeded',
        );

      case 'cancelled':
        return const NetworkException(
          'Request was cancelled.',
          code: 'cancelled',
        );

      default:
        return StorageException(
          error.message ?? 'A storage error occurred.',
          code: error.code,
        );
    }
  }

  /// Get user-friendly error message
  static String getUserMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return handleError(error).message;
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    if (error is NetworkException) return true;
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError;
    }
    return false;
  }

  /// Check if error is authentication-related
  static bool isAuthError(dynamic error) {
    return error is AuthException || error is FirebaseAuthException;
  }

  /// Check if error is rate limit-related
  static bool isRateLimitError(dynamic error) {
    return error is RateLimitException;
  }

  /// Check if error requires subscription upgrade
  static bool requiresUpgrade(dynamic error) {
    return error is InsufficientCreditsException;
  }
}
