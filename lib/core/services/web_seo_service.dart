import 'package:flutter/foundation.dart';
import '../utils/platform_helper.dart';

/// Service for managing SEO meta tags on web
///
/// Provides utilities for setting meta tags, Open Graph tags,
/// Twitter Card tags, and structured data for better SEO.
///
/// Usage:
/// ```dart
/// final service = WebSEOService.instance;
///
/// service.setPageMetadata(
///   title: 'Zeus GPT - AI Assistant',
///   description: 'Your intelligent AI assistant',
///   keywords: ['AI', 'chatbot', 'assistant'],
/// );
/// ```
class WebSEOService {
  WebSEOService._();
  static final WebSEOService instance = WebSEOService._();

  /// Check if running on web
  bool get isWeb => kIsWeb && PlatformHelper.isWeb;

  /// Set basic page metadata
  void setPageMetadata({
    required String title,
    String? description,
    List<String>? keywords,
    String? author,
    String? robots,
  }) {
    if (!isWeb) return;

    // TODO: Implement web-specific SEO when dart:html is available
    // This service is currently disabled to avoid platform-specific import issues
    debugPrint('WebSEOService: setPageMetadata called but not implemented');
  }

  /// Set Open Graph metadata for social media
  void setOpenGraphMetadata({
    required String title,
    required String url,
    String? description,
    String? image,
    String? type,
    String? siteName,
    String? locale,
  }) {
    if (!isWeb) return;

    // TODO: Implement web-specific SEO when dart:html is available
    debugPrint('WebSEOService: setOpenGraphMetadata called but not implemented');
  }

  /// Set Twitter Card metadata
  void setTwitterCardMetadata({
    required String card,
    required String title,
    String? description,
    String? image,
    String? site,
    String? creator,
  }) {
    if (!isWeb) return;

    // TODO: Implement web-specific SEO when dart:html is available
    debugPrint('WebSEOService: setTwitterCardMetadata called but not implemented');
  }

  /// Set canonical URL
  void setCanonicalUrl(String url) {
    if (!isWeb) return;

    // TODO: Implement web-specific SEO when dart:html is available
    debugPrint('WebSEOService: setCanonicalUrl called but not implemented');
  }

  /// Add structured data (JSON-LD)
  void addStructuredData(Map<String, dynamic> data) {
    if (!isWeb) return;

    // TODO: Implement web-specific SEO when dart:html is available
    debugPrint('WebSEOService: addStructuredData called but not implemented');
  }

  /// Set meta tag by name
  void _setMetaTag(String name, String content) {
    // Stub implementation - requires dart:html
  }

  /// Set meta tag by property
  void _setMetaProperty(String property, String content) {
    // Stub implementation - requires dart:html
  }

  /// Simple JSON encoder for structured data
  String _jsonEncode(Map<String, dynamic> data) {
    // Simple implementation - replace with json.encode in production
    final buffer = StringBuffer('{');
    var first = true;

    data.forEach((key, value) {
      if (!first) buffer.write(',');
      first = false;

      buffer.write('"$key":');

      if (value is String) {
        buffer.write('"${value.replaceAll('"', '\\"')}"');
      } else if (value is num || value is bool) {
        buffer.write(value);
      } else if (value is List) {
        buffer.write('[');
        for (var i = 0; i < value.length; i++) {
          if (i > 0) buffer.write(',');
          if (value[i] is String) {
            buffer.write('"${value[i]}"');
          } else {
            buffer.write(value[i]);
          }
        }
        buffer.write(']');
      } else if (value is Map) {
        buffer.write(_jsonEncode(value as Map<String, dynamic>));
      }
    });

    buffer.write('}');
    return buffer.toString();
  }
}

/// Preset SEO configurations
class SEOPresets {
  /// Home page SEO
  static void homePage({
    String? siteName,
    String? siteUrl,
  }) {
    final service = WebSEOService.instance;

    service.setPageMetadata(
      title: siteName ?? 'Zeus GPT - Your AI Assistant',
      description: 'Zeus GPT is your intelligent AI assistant powered by advanced language models. Get help with writing, coding, analysis, and more.',
      keywords: ['AI', 'chatbot', 'assistant', 'GPT', 'Zeus GPT'],
      author: 'Zeus GPT Team',
      robots: 'index, follow',
    );

    if (siteUrl != null) {
      service.setOpenGraphMetadata(
        title: siteName ?? 'Zeus GPT',
        url: siteUrl,
        description: 'Your intelligent AI assistant',
        type: 'website',
        siteName: siteName,
      );

      service.setCanonicalUrl(siteUrl);
    }
  }

  /// Chat page SEO
  static void chatPage({
    String? conversationTitle,
    String? siteUrl,
  }) {
    final service = WebSEOService.instance;

    service.setPageMetadata(
      title: conversationTitle != null
          ? '$conversationTitle - Zeus GPT'
          : 'Chat - Zeus GPT',
      description: 'Have intelligent conversations with Zeus GPT AI assistant',
      keywords: ['AI chat', 'conversation', 'assistant'],
      robots: 'noindex, nofollow', // Chat pages usually shouldn't be indexed
    );

    if (siteUrl != null) {
      service.setCanonicalUrl('$siteUrl/chat');
    }
  }

  /// Settings page SEO
  static void settingsPage({String? siteUrl}) {
    final service = WebSEOService.instance;

    service.setPageMetadata(
      title: 'Settings - Zeus GPT',
      description: 'Configure your Zeus GPT preferences and settings',
      robots: 'noindex, nofollow',
    );

    if (siteUrl != null) {
      service.setCanonicalUrl('$siteUrl/settings');
    }
  }

  /// About page SEO
  static void aboutPage({String? siteUrl}) {
    final service = WebSEOService.instance;

    service.setPageMetadata(
      title: 'About - Zeus GPT',
      description: 'Learn about Zeus GPT, your intelligent AI assistant powered by advanced language models',
      keywords: ['about', 'Zeus GPT', 'AI assistant', 'team'],
      robots: 'index, follow',
    );

    if (siteUrl != null) {
      service.setOpenGraphMetadata(
        title: 'About Zeus GPT',
        url: '$siteUrl/about',
        description: 'Learn about Zeus GPT AI assistant',
        type: 'website',
      );

      service.setCanonicalUrl('$siteUrl/about');
    }
  }
}
