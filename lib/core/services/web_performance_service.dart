import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/platform_helper.dart';
// TODO: Add conditional import for dart:html when web-specific implementation is needed
// import 'dart:html' as html;

/// Stub class for Performance API until dart:html is properly integrated
class _PerformanceTiming {
  int? get navigationStart => 0;
  int? get domainLookupStart => 0;
  int? get domainLookupEnd => 0;
  int? get connectStart => 0;
  int? get connectEnd => 0;
  int? get requestStart => 0;
  int? get responseStart => 0;
  int? get responseEnd => 0;
  int? get domContentLoadedEventEnd => 0;
  int? get loadEventEnd => 0;
  int? get domInteractive => 0;
}

class _PerformanceEntry {
  String get name => '';
  num get duration => 0;
  num get startTime => 0;
}

class _PerformanceResourceTiming extends _PerformanceEntry {
  int get transferSize => 0;
  int get encodedBodySize => 0;
  int get decodedBodySize => 0;
}

class _PerformanceStub {
  _PerformanceTiming get timing => _PerformanceTiming();
  List<_PerformanceEntry> getEntriesByType(String type) => [];
  List<_PerformanceEntry> getEntriesByName(String name, String type) => [];
  void mark(String name) {}
  void measure(String name, String startMark, String endMark) {}
  void clearMarks([String? name]) {}
  void clearMeasures([String? name]) {}
}

final _performanceStub = _PerformanceStub();

/// Service for monitoring web performance
/// CURRENTLY STUBBED: Requires dart:html for full implementation
///
/// Provides utilities for measuring page load performance,
/// tracking Core Web Vitals, and monitoring resource loading.
///
/// Usage:
/// ```dart
/// final service = WebPerformanceService.instance;
///
/// // Get performance metrics
/// final metrics = service.getPerformanceMetrics();
/// print('Page load time: ${metrics['loadTime']}ms');
///
/// // Monitor Core Web Vitals
/// service.monitorCoreWebVitals((vitals) {
///   print('LCP: ${vitals['lcp']}');
///   print('FID: ${vitals['fid']}');
///   print('CLS: ${vitals['cls']}');
/// });
/// ```
class WebPerformanceService {
  WebPerformanceService._();
  static final WebPerformanceService instance = WebPerformanceService._();

  /// Check if running on web
  bool get isWeb => kIsWeb && PlatformHelper.isWeb;

  /// Check if Performance API is supported
  bool get isSupported {
    if (!isWeb) return false;

    // Stubbed - always return false until dart:html is properly integrated
    return false;
  }

  /// Get basic performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    if (!isSupported) return {};

    try {
      final timing = _performanceStub.timing;
      final navigationStart = timing.navigationStart ?? 0;

      return {
        'navigationStart': navigationStart,
        'domainLookupTime': (timing.domainLookupEnd ?? 0) - (timing.domainLookupStart ?? 0),
        'connectTime': (timing.connectEnd ?? 0) - (timing.connectStart ?? 0),
        'requestTime': (timing.responseEnd ?? 0) - (timing.requestStart ?? 0),
        'responseTime': (timing.responseEnd ?? 0) - (timing.responseStart ?? 0),
        'domLoadingTime': (timing.domContentLoadedEventEnd ?? 0) - navigationStart,
        'loadTime': (timing.loadEventEnd ?? 0) - navigationStart,
        'domInteractiveTime': (timing.domInteractive ?? 0) - navigationStart,
      };
    } catch (e) {
      debugPrint('Failed to get performance metrics: $e');
      return {};
    }
  }

  /// Measure time to first byte (TTFB)
  int? getTimeToFirstByte() {
    if (!isSupported) return null;

    try {
      final timing = _performanceStub.timing;
      final navigationStart = timing.navigationStart ?? 0;
      final responseStart = timing.responseStart ?? 0;

      return responseStart - navigationStart;
    } catch (e) {
      debugPrint('Failed to get TTFB: $e');
      return null;
    }
  }

  /// Measure DOM content loaded time
  int? getDOMContentLoadedTime() {
    if (!isSupported) return null;

    try {
      final timing = _performanceStub.timing;
      final navigationStart = timing.navigationStart ?? 0;
      final domContentLoaded = timing.domContentLoadedEventEnd ?? 0;

      return domContentLoaded - navigationStart;
    } catch (e) {
      debugPrint('Failed to get DOM content loaded time: $e');
      return null;
    }
  }

  /// Measure full page load time
  int? getPageLoadTime() {
    if (!isSupported) return null;

    try {
      final timing = _performanceStub.timing;
      final navigationStart = timing.navigationStart ?? 0;
      final loadEventEnd = timing.loadEventEnd ?? 0;

      return loadEventEnd - navigationStart;
    } catch (e) {
      debugPrint('Failed to get page load time: $e');
      return null;
    }
  }

  /// Get resource timing information
  List<Map<String, dynamic>> getResourceTimings() {
    if (!isSupported) return [];

    try {
      final entries = _performanceStub.getEntriesByType('resource');
      final List<Map<String, dynamic>> timings = [];

      for (final entry in entries) {
        final resourceEntry = entry as _PerformanceResourceTiming;

        timings.add({
          'name': resourceEntry.name,
          'duration': resourceEntry.duration,
          'startTime': resourceEntry.startTime,
          'transferSize': resourceEntry.transferSize,
          'encodedBodySize': resourceEntry.encodedBodySize,
          'decodedBodySize': resourceEntry.decodedBodySize,
        });
      }

      return timings;
    } catch (e) {
      debugPrint('Failed to get resource timings: $e');
      return [];
    }
  }

  /// Mark a custom performance mark
  void mark(String name) {
    if (!isSupported) return;

    try {
      _performanceStub.mark(name);
    } catch (e) {
      debugPrint('Failed to create performance mark: $e');
    }
  }

  /// Measure time between two marks
  double? measure(String name, String startMark, String endMark) {
    if (!isSupported) return null;

    try {
      _performanceStub.measure(name, startMark, endMark);

      final entries = _performanceStub.getEntriesByName(name, 'measure');
      if (entries.isNotEmpty) {
        return entries.first.duration;
      }

      return null;
    } catch (e) {
      debugPrint('Failed to measure performance: $e');
      return null;
    }
  }

  /// Clear all performance marks
  void clearMarks() {
    if (!isSupported) return;

    try {
      _performanceStub.clearMarks();
    } catch (e) {
      debugPrint('Failed to clear performance marks: $e');
    }
  }

  /// Clear all performance measures
  void clearMeasures() {
    if (!isSupported) return;

    try {
      _performanceStub.clearMeasures();
    } catch (e) {
      debugPrint('Failed to clear performance measures: $e');
    }
  }

  /// Log performance metrics to console
  void logPerformanceMetrics() {
    if (!isSupported) {
      debugPrint('Performance API not supported');
      return;
    }

    final metrics = getPerformanceMetrics();
    final ttfb = getTimeToFirstByte();
    final domContentLoaded = getDOMContentLoadedTime();
    final pageLoad = getPageLoadTime();

    debugPrint('=== Performance Metrics ===');
    debugPrint('Time to First Byte: ${ttfb}ms');
    debugPrint('DOM Content Loaded: ${domContentLoaded}ms');
    debugPrint('Page Load Time: ${pageLoad}ms');
    debugPrint('Domain Lookup: ${metrics['domainLookupTime']}ms');
    debugPrint('Connection Time: ${metrics['connectTime']}ms');
    debugPrint('Request Time: ${metrics['requestTime']}ms');
    debugPrint('Response Time: ${metrics['responseTime']}ms');
    debugPrint('==========================');
  }

  /// Monitor performance and call callback when ready
  void monitorPerformance(Function(Map<String, dynamic>) callback) {
    if (!isSupported) return;

    // Wait for page load
    html.window.onLoad.listen((_) {
      // Give browser time to settle
      Future.delayed(const Duration(milliseconds: 100), () {
        callback(getPerformanceMetrics());
      });
    });
  }
}

/// Performance measurement helper
class PerformanceMeasurement {
  final String name;
  final String startMarkName;
  final String endMarkName;

  PerformanceMeasurement(this.name)
      : startMarkName = '${name}_start',
        endMarkName = '${name}_end';

  /// Start measurement
  void start() {
    WebPerformanceService.instance.mark(startMarkName);
  }

  /// End measurement and return duration
  double? end() {
    WebPerformanceService.instance.mark(endMarkName);
    return WebPerformanceService.instance.measure(
      name,
      startMarkName,
      endMarkName,
    );
  }
}

/// Preset performance measurements
class PerformancePresets {
  /// Measure widget build time
  static PerformanceMeasurement widgetBuild(String widgetName) {
    return PerformanceMeasurement('widget_build_$widgetName');
  }

  /// Measure API call time
  static PerformanceMeasurement apiCall(String endpoint) {
    return PerformanceMeasurement('api_call_$endpoint');
  }

  /// Measure navigation time
  static PerformanceMeasurement navigation(String route) {
    return PerformanceMeasurement('navigation_$route');
  }

  /// Measure data processing time
  static PerformanceMeasurement dataProcessing(String operation) {
    return PerformanceMeasurement('data_processing_$operation');
  }
}

/// Helper for async operations
extension PerformanceMeasurementExt on PerformanceMeasurement {
  /// Measure async operation
  Future<T> measureAsync<T>(Future<T> Function() operation) async {
    start();
    try {
      return await operation();
    } finally {
      final duration = end();
      if (duration != null) {
        debugPrint('$name took ${duration.toStringAsFixed(2)}ms');
      }
    }
  }

  /// Measure sync operation
  T measureSync<T>(T Function() operation) {
    start();
    try {
      return operation();
    } finally {
      final duration = end();
      if (duration != null) {
        debugPrint('$name took ${duration.toStringAsFixed(2)}ms');
      }
    }
  }
}
