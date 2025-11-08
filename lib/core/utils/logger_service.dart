import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Centralized logging service with Sentry integration
///
/// Usage:
/// ```dart
/// LoggerService.d('Debug message');
/// LoggerService.i('Info message');
/// LoggerService.w('Warning message');
/// LoggerService.e('Error message', error: e, stackTrace: st);
/// ```
class LoggerService {
  static late Logger _logger;
  static bool _initialized = false;

  /// Initialize the logger service
  static void init({bool enableSentry = true}) {
    if (_initialized) return;

    _logger = Logger(
      filter: _LogFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: _LogOutput(),
    );

    _initialized = true;

    if (enableSentry && !kDebugMode) {
      i('Logger service initialized with Sentry');
    } else {
      i('Logger service initialized (Debug mode)');
    }
  }

  /// Log debug message
  static void d(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _ensureInitialized();
    _logger.d(message, error: error, stackTrace: stackTrace);
    _logToSentry(Level.debug, message, error, stackTrace, data);
  }

  /// Log info message
  static void i(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _ensureInitialized();
    _logger.i(message, error: error, stackTrace: stackTrace);
    _logToSentry(Level.info, message, error, stackTrace, data);
  }

  /// Log warning message
  static void w(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _ensureInitialized();
    _logger.w(message, error: error, stackTrace: stackTrace);
    _logToSentry(Level.warning, message, error, stackTrace, data);
  }

  /// Log error message
  static void e(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _ensureInitialized();
    _logger.e(message, error: error, stackTrace: stackTrace);
    _logToSentry(Level.error, message, error, stackTrace, data);
  }

  /// Log fatal error message
  static void f(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _ensureInitialized();
    _logger.f(message, error: error, stackTrace: stackTrace);
    _logToSentry(Level.fatal, message, error, stackTrace, data);
  }

  /// Log API request
  static void logApiRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    d('API Request: $method $url', data: {
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
    });
  }

  /// Log API response
  static void logApiResponse(
    String method,
    String url,
    int statusCode, {
    dynamic response,
    Duration? duration,
  }) {
    if (statusCode >= 200 && statusCode < 300) {
      d('API Response: $method $url [$statusCode] ${duration != null ? "(${duration.inMilliseconds}ms)" : ""}');
    } else {
      w('API Response Error: $method $url [$statusCode]', data: {
        'method': method,
        'url': url,
        'statusCode': statusCode,
        'response': response,
      });
    }
  }

  /// Log user action
  static void logUserAction(
    String action, {
    Map<String, dynamic>? data,
  }) {
    i('User Action: $action', data: data);
  }

  /// Log performance metric
  static void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? data,
  }) {
    final enrichedData = {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      ...?data,
    };

    if (duration.inMilliseconds > 1000) {
      w('Slow Operation: $operation (${duration.inMilliseconds}ms)',
        data: enrichedData,
      );
    } else {
      d('Performance: $operation (${duration.inMilliseconds}ms)',
        data: enrichedData,
      );
    }
  }

  /// Ensure logger is initialized
  static void _ensureInitialized() {
    if (!_initialized) {
      init();
    }
  }

  /// Send logs to Sentry (only in production and for warnings/errors)
  static void _logToSentry(
    Level level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  ) {
    if (kDebugMode) return;

    // Only log warnings and errors to Sentry
    if (level.index < Level.warning.index) return;

    final sentryLevel = _mapToSentryLevel(level);

    Sentry.captureMessage(
      message,
      level: sentryLevel,
      withScope: (scope) {
        if (error != null) {
          scope.setExtra('error', error.toString());
        }
        if (data != null) {
          scope.setContexts('data', data);
        }
      },
    );

    // If there's an error object, also capture it as an exception
    if (error != null) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setExtra('message', message);
          if (data != null) {
            scope.setContexts('data', data);
          }
        },
      );
    }
  }

  /// Map Logger level to Sentry level
  static SentryLevel _mapToSentryLevel(Level level) {
    switch (level) {
      case Level.debug:
        return SentryLevel.debug;
      case Level.info:
        return SentryLevel.info;
      case Level.warning:
        return SentryLevel.warning;
      case Level.error:
        return SentryLevel.error;
      case Level.fatal:
        return SentryLevel.fatal;
      default:
        return SentryLevel.info;
    }
  }
}

/// Custom log filter
class _LogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kDebugMode) {
      return true; // Log everything in debug mode
    }

    // In production, only log warnings and errors
    return event.level.index >= Level.warning.index;
  }
}

/// Custom log output
class _LogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      // In debug mode, print to console
      if (kDebugMode) {
        // ignore: avoid_print
        print(line);
      }
    }
  }
}
