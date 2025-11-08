import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper class for integration tests
class IntegrationTestHelpers {
  /// Pumps the app with a specific initial location
  static Future<void> pumpApp(
    WidgetTester tester,
    Widget app, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: app,
      ),
    );
    await tester.pumpAndSettle(duration);
  }

  /// Enters text into a text field
  static Future<void> enterText(
    WidgetTester tester,
    String text, {
    String? label,
    Type? widgetType,
  }) async {
    final finder = label != null
        ? find.widgetWithText(TextField, label)
        : find.byType(widgetType ?? TextField);

    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Taps a button with specific text
  static Future<void> tapButton(
    WidgetTester tester,
    String text, {
    bool settle = true,
  }) async {
    await tester.tap(find.text(text));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  /// Taps a button with specific icon
  static Future<void> tapIconButton(
    WidgetTester tester,
    IconData icon, {
    bool settle = true,
  }) async {
    await tester.tap(find.byIcon(icon));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  /// Waits for a widget to appear
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      if (tester.any(finder)) {
        return;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    throw Exception('Timeout waiting for widget: $finder');
  }

  /// Scrolls until widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder item,
    Finder scrollable, {
    double delta = 100,
  }) async {
    await tester.dragUntilVisible(
      item,
      scrollable,
      Offset(0, -delta),
    );
  }

  /// Verifies a route by checking for expected widget
  static void verifyRoute(Finder expectedWidget) {
    expect(expectedWidget, findsOneWidget);
  }

  /// Verifies text is present
  static void verifyText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verifies widget is present
  static void verifyWidget(Type widgetType) {
    expect(find.byType(widgetType), findsOneWidget);
  }

  /// Verifies widget is not present
  static void verifyWidgetNotPresent(Type widgetType) {
    expect(find.byType(widgetType), findsNothing);
  }

  /// Waits for navigation to complete
  static Future<void> waitForNavigation(
    WidgetTester tester, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    await tester.pumpAndSettle(duration);
  }

  /// Verifies error message is displayed
  static void verifyErrorMessage(String message) {
    expect(find.text(message), findsOneWidget);
  }

  /// Verifies success message is displayed
  static void verifySuccessMessage(String message) {
    expect(find.text(message), findsOneWidget);
  }

  /// Simulates a delay (e.g., for animations)
  static Future<void> delay(
    WidgetTester tester, {
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    await tester.pump(duration);
  }

  /// Finds a TextField by hint text
  static Finder findTextFieldByHint(String hint) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == hint,
    );
  }

  /// Finds a TextField by label text
  static Finder findTextFieldByLabel(String label) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == label,
    );
  }

  /// Verifies that a specific number of widgets are present
  static void verifyWidgetCount(Type widgetType, int count) {
    expect(find.byType(widgetType), findsNWidgets(count));
  }

  /// Verifies loading indicator is shown
  static void verifyLoadingIndicator() {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verifies loading indicator is not shown
  static void verifyNoLoadingIndicator() {
    expect(find.byType(CircularProgressIndicator), findsNothing);
  }
}
