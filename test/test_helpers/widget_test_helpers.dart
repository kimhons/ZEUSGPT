import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pump a widget with MaterialApp wrapper
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
  ThemeData? theme,
  Locale? locale,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme,
        locale: locale,
        home: Scaffold(body: widget),
      ),
    ),
  );
}

/// Pump a widget with full app setup (routes, theme, etc.)
Future<void> pumpTestApp(
  WidgetTester tester,
  Widget home, {
  List<Override> overrides = const [],
  ThemeData? theme,
  Map<String, WidgetBuilder>? routes,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme,
        home: home,
        routes: routes ?? {},
      ),
    ),
  );
}

/// Find a widget by type
Finder findWidgetByType<T>() => find.byType(T);

/// Find a widget by key
Finder findWidgetByKey(Key key) => find.byKey(key);

/// Find text widget
Finder findTextWidget(String text) => find.text(text);

/// Find icon widget
Finder findIconWidget(IconData icon) => find.byIcon(icon);

/// Tap a widget
Future<void> tapWidget(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Enter text in a text field
Future<void> enterText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Scroll until visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double scrollDelta = 100.0,
  int maxScrolls = 50,
}) async {
  for (int i = 0; i < maxScrolls; i++) {
    if (tester.any(finder)) {
      break;
    }

    await tester.drag(scrollable, Offset(0, -scrollDelta));
    await tester.pumpAndSettle();
  }

  expect(tester.any(finder), isTrue,
      reason: 'Widget not found after scrolling');
}

/// Verify widget exists
void expectWidgetExists(Finder finder, {int count = 1}) {
  expect(finder, findsNWidgets(count));
}

/// Verify widget doesn't exist
void expectWidgetNotExists(Finder finder) {
  expect(finder, findsNothing);
}

/// Verify text exists
void expectTextExists(String text, {int count = 1}) {
  expect(find.text(text), findsNWidgets(count));
}

/// Verify text doesn't exist
void expectTextNotExists(String text) {
  expect(find.text(text), findsNothing);
}

/// Get widget from finder
T getWidget<T>(WidgetTester tester, Finder finder) {
  return tester.widget<T>(finder);
}

/// Get state from finder
T getState<T extends State>(WidgetTester tester, Finder finder) {
  return tester.state<T>(finder);
}

/// Create a mock BuildContext
BuildContext createMockContext() {
  return _MockBuildContext();
}

class _MockBuildContext implements BuildContext {
  @override
  bool get debugDoingBuild => false;

  @override
  InheritedWidget dependOnInheritedElement(
    InheritedElement ancestor, {
    Object? aspect,
  }) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({
    Object? aspect,
  }) {
    return null;
  }

  @override
  InheritedElement?
      getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return null;
  }

  @override
  Widget get widget => Container();

  @override
  BuildOwner? get owner => null;

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildElements(ElementVisitor visitor) {}

  @override
  DiagnosticsNode describeElement(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor(
      {required Type expectedAncestorType}) {
    return [];
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    return null;
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    return null;
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    return null;
  }

  @override
  T? findRenderObject<T extends RenderObject>() {
    return null;
  }

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    return null;
  }

  @override
  RenderObject? get renderObject => null;

  @override
  Size? get size => null;

  @override
  bool get mounted => true;

  @override
  bool get debugIsDefunct => false;
}

/// Test utilities for responsive widgets
class ResponsiveTestHelpers {
  /// Create a mobile size for testing
  static Size get mobileSize => const Size(375, 667);

  /// Create a tablet size for testing
  static Size get tabletSize => const Size(768, 1024);

  /// Create a desktop size for testing
  static Size get desktopSize => const Size(1920, 1080);

  /// Set screen size for testing
  static void setScreenSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
}

/// Test utilities for theme testing
class ThemeTestHelpers {
  /// Create a light theme
  static ThemeData get lightTheme => ThemeData.light();

  /// Create a dark theme
  static ThemeData get darkTheme => ThemeData.dark();

  /// Get current theme from widget
  static ThemeData getTheme(WidgetTester tester) {
    return Theme.of(tester.element(find.byType(MaterialApp)));
  }
}

/// Test utilities for navigation
class NavigationTestHelpers {
  /// Push a new route
  static Future<void> pushRoute(
    WidgetTester tester,
    String routeName,
  ) async {
    final context = tester.element(find.byType(MaterialApp));
    Navigator.of(context).pushNamed(routeName);
    await tester.pumpAndSettle();
  }

  /// Pop current route
  static Future<void> popRoute(WidgetTester tester) async {
    final context = tester.element(find.byType(MaterialApp));
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
  }

  /// Verify current route
  static void expectCurrentRoute(WidgetTester tester, String routeName) {
    final context = tester.element(find.byType(MaterialApp));
    final currentRoute = ModalRoute.of(context)?.settings.name;
    expect(currentRoute, equals(routeName));
  }
}

/// Test utilities for gestures
class GestureTestHelpers {
  /// Long press on a widget
  static Future<void> longPress(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.longPress(finder);
    await tester.pumpAndSettle();
  }

  /// Drag a widget
  static Future<void> drag(
    WidgetTester tester,
    Finder finder,
    Offset offset,
  ) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle();
  }

  /// Fling a widget
  static Future<void> fling(
    WidgetTester tester,
    Finder finder,
    Offset offset,
    double velocity,
  ) async {
    await tester.fling(finder, offset, velocity);
    await tester.pumpAndSettle();
  }
}

/// Common test data
class TestData {
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testUserId = 'test-user-id';
  static const String testUserName = 'Test User';
  static const String testChatId = 'test-chat-id';
  static const String testMessageId = 'test-message-id';
  static const String testModelId = 'test-model-id';
}
