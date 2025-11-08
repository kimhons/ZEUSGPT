import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility helper functions for the ZeusGPT application.
///
/// These utilities ensure the app is accessible to users with disabilities,
/// particularly those using screen readers and other assistive technologies.

/// Shows a [SnackBar] with a message and announces it to screen readers.
///
/// This ensures users with visual impairments receive feedback about
/// actions and state changes through their assistive technology.
///
/// Example usage:
/// ```dart
/// showAccessibleSnackBar(
///   context,
///   'Message deleted successfully',
/// );
/// ```
///
/// With custom action:
/// ```dart
/// showAccessibleSnackBar(
///   context,
///   'Conversation archived',
///   action: SnackBarAction(
///     label: 'Undo',
///     onPressed: _undoArchive,
///   ),
/// );
/// ```
void showAccessibleSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 4),
  Color? backgroundColor,
}) {
  // Show the SnackBar visually
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: action,
      duration: duration,
      backgroundColor: backgroundColor,
    ),
  );

  // Announce the message to screen readers
  SemanticsService.announce(
    message,
    TextDirection.ltr,
  );
}

/// Announces a message to screen readers without showing a [SnackBar].
///
/// Use this for announcements that don't need visual confirmation,
/// such as page changes, filter updates, or background operations.
///
/// Example usage:
/// ```dart
/// announceToScreenReader('Showing 5 messages');
/// announceToScreenReader('Filters applied');
/// announceToScreenReader('Loading complete');
/// ```
Future<void> announceToScreenReader(String message) async {
  await SemanticsService.announce(
    message,
    TextDirection.ltr,
  );
}

/// Shows an error [SnackBar] with a red background and announces it.
///
/// This provides consistent error messaging throughout the app
/// with proper accessibility support.
///
/// Example usage:
/// ```dart
/// showAccessibleErrorSnackBar(
///   context,
///   'Failed to send message. Please check your connection.',
/// );
/// ```
void showAccessibleErrorSnackBar(
  BuildContext context,
  String errorMessage, {
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 5),
}) {
  showAccessibleSnackBar(
    context,
    errorMessage,
    action: action,
    duration: duration,
    backgroundColor: Theme.of(context).colorScheme.error,
  );
}

/// Shows a success [SnackBar] with a green background and announces it.
///
/// This provides consistent success messaging throughout the app
/// with proper accessibility support.
///
/// Example usage:
/// ```dart
/// showAccessibleSuccessSnackBar(
///   context,
///   'Message sent successfully',
/// );
/// ```
void showAccessibleSuccessSnackBar(
  BuildContext context,
  String successMessage, {
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 3),
}) {
  showAccessibleSnackBar(
    context,
    successMessage,
    action: action,
    duration: duration,
    backgroundColor: Colors.green.shade700,
  );
}

/// Announces page changes to screen readers.
///
/// Call this when navigating to a new screen to help users understand
/// where they are in the app.
///
/// Example usage:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   WidgetsBinding.instance.addPostFrameCallback((_) {
///     announcePageChange('Chat screen');
///   });
/// }
/// ```
Future<void> announcePageChange(String pageName) async {
  await announceToScreenReader('Navigated to $pageName');
}

/// Wraps any interactive widget with semantic labels.
///
/// Use this for custom interactive widgets that don't have built-in
/// semantic support (e.g., custom gesture detectors, inkwell cards).
///
/// Example usage:
/// ```dart
/// semanticTapTarget(
///   label: 'Open conversation details',
///   child: InkWell(
///     onTap: _openDetails,
///     child: ConversationCard(...),
///   ),
/// )
/// ```
Widget semanticTapTarget({
  required String label,
  required Widget child,
  bool enabled = true,
  VoidCallback? onTap,
  String? hint,
}) {
  return Semantics(
    label: label,
    button: true,
    enabled: enabled,
    onTap: onTap,
    hint: hint,
    child: child,
  );
}

/// Marks a widget as decorative (hidden from screen readers).
///
/// Use this for purely visual elements that don't convey
/// meaningful information (e.g., decorative icons, dividers).
///
/// Example usage:
/// ```dart
/// decorative(
///   child: Icon(Icons.star, color: Colors.amber),
/// )
/// ```
Widget decorative({required Widget child}) {
  return ExcludeSemantics(
    child: child,
  );
}

/// Groups related semantic elements together.
///
/// This helps screen reader users understand that multiple
/// elements belong together as a single unit.
///
/// Example usage:
/// ```dart
/// semanticGroup(
///   label: 'Message from John Doe, sent at 2:30 PM',
///   children: [
///     Text('John Doe'),
///     Text('2:30 PM'),
///     Text('Hello, how are you?'),
///   ],
/// )
/// ```
Widget semanticGroup({
  required String label,
  required List<Widget> children,
}) {
  return Semantics(
    label: label,
    container: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}
