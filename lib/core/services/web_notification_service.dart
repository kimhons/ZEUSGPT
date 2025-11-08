import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/platform_helper.dart';
import 'dart:html' as html;

/// Service for Web Notifications API
///
/// Provides access to the Notifications API for displaying
/// system notifications on web platforms.
///
/// Usage:
/// ```dart
/// final service = WebNotificationService.instance;
///
/// // Request permission
/// final granted = await service.requestPermission();
///
/// if (granted) {
///   // Show notification
///   await service.showNotification(
///     title: 'New Message',
///     body: 'You have a new message from Zeus GPT',
///     icon: '/icons/notification-icon.png',
///   );
/// }
/// ```
class WebNotificationService {
  WebNotificationService._();
  static final WebNotificationService instance = WebNotificationService._();

  /// Check if Notifications API is supported
  bool get isSupported {
    if (!kIsWeb) return false;
    if (!PlatformHelper.isWeb) return false;

    try {
      return html.Notification.supported;
    } catch (e) {
      return false;
    }
  }

  /// Get current permission status
  ///
  /// Returns 'granted', 'denied', or 'default'
  String get permissionStatus {
    if (!isSupported) return 'denied';

    try {
      return html.Notification.permission;
    } catch (e) {
      debugPrint('Failed to get notification permission: $e');
      return 'denied';
    }
  }

  /// Check if permission is granted
  bool get hasPermission {
    return permissionStatus == 'granted';
  }

  /// Request notification permission
  ///
  /// Returns true if permission is granted
  Future<bool> requestPermission() async {
    if (!isSupported) {
      debugPrint('Notifications not supported on this browser');
      return false;
    }

    if (hasPermission) {
      return true;
    }

    try {
      final permission = await html.Notification.requestPermission();
      return permission == 'granted';
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }

  /// Show a notification
  ///
  /// Returns the notification object or null if failed
  Future<html.Notification?> showNotification({
    required String title,
    String? body,
    String? icon,
    String? badge,
    String? tag,
    String? image,
    List<Map<String, dynamic>>? actions,
    bool? requireInteraction,
    bool? silent,
    Duration? autoClose,
    VoidCallback? onClick,
    VoidCallback? onClose,
    VoidCallback? onError,
  }) async {
    if (!isSupported) {
      debugPrint('Notifications not supported on this browser');
      return null;
    }

    if (!hasPermission) {
      final granted = await requestPermission();
      if (!granted) {
        debugPrint('Notification permission not granted');
        return null;
      }
    }

    try {
      final options = <String, dynamic>{};

      if (body != null) options['body'] = body;
      if (icon != null) options['icon'] = icon;
      if (badge != null) options['badge'] = badge;
      if (tag != null) options['tag'] = tag;
      if (image != null) options['image'] = image;
      if (requireInteraction != null) {
        options['requireInteraction'] = requireInteraction;
      }
      if (silent != null) options['silent'] = silent;
      if (actions != null && actions.isNotEmpty) {
        options['actions'] = actions;
      }

      final notification = html.Notification(title, options);

      // Set up event listeners
      if (onClick != null) {
        notification.onClick.listen((_) => onClick());
      }

      if (onClose != null) {
        notification.onClose.listen((_) => onClose());
      }

      if (onError != null) {
        notification.onError.listen((_) => onError());
      }

      // Auto-close if specified
      if (autoClose != null) {
        Future.delayed(autoClose, () {
          notification.close();
        });
      }

      return notification;
    } catch (e) {
      debugPrint('Failed to show notification: $e');
      return null;
    }
  }

  /// Show a simple notification with just title and body
  Future<html.Notification?> showSimpleNotification({
    required String title,
    String? body,
    String? icon,
    Duration? autoClose,
  }) async {
    return showNotification(
      title: title,
      body: body,
      icon: icon,
      autoClose: autoClose,
    );
  }

  /// Show a notification with actions (requires service worker)
  Future<html.Notification?> showActionableNotification({
    required String title,
    String? body,
    String? icon,
    required List<NotificationAction> actions,
    VoidCallback? onClick,
  }) async {
    return showNotification(
      title: title,
      body: body,
      icon: icon,
      actions: actions.map((a) => a.toMap()).toList(),
      onClick: onClick,
    );
  }

  /// Show a notification that requires user interaction to dismiss
  Future<html.Notification?> showPersistentNotification({
    required String title,
    String? body,
    String? icon,
    VoidCallback? onClick,
  }) async {
    return showNotification(
      title: title,
      body: body,
      icon: icon,
      requireInteraction: true,
      onClick: onClick,
    );
  }

  /// Show a silent notification (no sound)
  Future<html.Notification?> showSilentNotification({
    required String title,
    String? body,
    String? icon,
    Duration? autoClose,
  }) async {
    return showNotification(
      title: title,
      body: body,
      icon: icon,
      silent: true,
      autoClose: autoClose,
    );
  }

  /// Close all notifications with a specific tag
  void closeNotificationsWithTag(String tag) {
    // Note: This requires service worker support
    // For now, we can only close individual notifications
    debugPrint('Close by tag requires service worker support');
  }
}

/// Notification action data
class NotificationAction {
  final String action;
  final String title;
  final String? icon;

  const NotificationAction({
    required this.action,
    required this.title,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'action': action,
      'title': title,
    };

    if (icon != null) {
      map['icon'] = icon;
    }

    return map;
  }
}

/// Preset notification configurations
class NotificationPresets {
  /// New message notification
  static Future<html.Notification?> newMessage({
    required String sender,
    required String message,
    String? icon,
    VoidCallback? onClick,
  }) {
    return WebNotificationService.instance.showNotification(
      title: 'New message from $sender',
      body: message,
      icon: icon ?? '/icons/message-icon.png',
      tag: 'new-message',
      autoClose: const Duration(seconds: 10),
      onClick: onClick,
    );
  }

  /// Error notification
  static Future<html.Notification?> error({
    required String title,
    String? message,
    VoidCallback? onClick,
  }) {
    return WebNotificationService.instance.showNotification(
      title: title,
      body: message ?? 'An error occurred',
      icon: '/icons/error-icon.png',
      tag: 'error',
      requireInteraction: true,
      onClick: onClick,
    );
  }

  /// Success notification
  static Future<html.Notification?> success({
    required String title,
    String? message,
  }) {
    return WebNotificationService.instance.showNotification(
      title: title,
      body: message ?? 'Operation completed successfully',
      icon: '/icons/success-icon.png',
      tag: 'success',
      autoClose: const Duration(seconds: 5),
    );
  }

  /// Info notification
  static Future<html.Notification?> info({
    required String title,
    String? message,
    Duration? autoClose,
  }) {
    return WebNotificationService.instance.showNotification(
      title: title,
      body: message,
      icon: '/icons/info-icon.png',
      tag: 'info',
      autoClose: autoClose ?? const Duration(seconds: 8),
    );
  }

  /// Task completed notification
  static Future<html.Notification?> taskCompleted({
    required String taskName,
    VoidCallback? onClick,
  }) {
    return WebNotificationService.instance.showNotification(
      title: 'Task Completed',
      body: taskName,
      icon: '/icons/task-complete-icon.png',
      tag: 'task-completed',
      autoClose: const Duration(seconds: 7),
      onClick: onClick,
    );
  }
}
