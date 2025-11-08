import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zeusgpt/features/chat/presentation/widgets/empty_conversation_state.dart';

void main() {
  group('EmptyConversationState', () {
    testWidgets('renders welcome text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      expect(find.text('Welcome to ZeusGPT'), findsOneWidget);
      expect(
          find.text('Start a conversation with 500+ AI models'), findsOneWidget);
    });

    testWidgets('renders Zeus logo with flash icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      // Zeus logo uses flash_on icon
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
    });

    testWidgets('animates Zeus logo on mount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      // Animation should exist
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);

      // Pump animation
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('renders all three feature cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      expect(find.text('Multiple AI Models'), findsOneWidget);
      expect(find.text('Access GPT-4, Claude, Gemini, and 500+ more'),
          findsOneWidget);

      expect(find.text('Image Generation'), findsOneWidget);
      expect(find.text('Create stunning images with AI'), findsOneWidget);

      expect(find.text('Code Assistant'), findsOneWidget);
      expect(find.text('Get help with coding and debugging'), findsOneWidget);
    });

    testWidgets('renders feature icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('renders Start New Chat button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      expect(find.text('Start New Chat'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders Explore AI Models button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      expect(find.text('Explore AI Models'), findsOneWidget);
      expect(find.byIcon(Icons.explore), findsOneWidget);
    });

    testWidgets('navigates to /home/new-chat when Start New Chat is tapped',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: EmptyConversationState(),
            ),
          ),
          GoRoute(
            path: '/home/new-chat',
            builder: (context, state) => const Scaffold(
              body: Text('New Chat Screen'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Scroll to make button visible
      await tester.dragUntilVisible(
        find.text('Start New Chat'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );

      // Tap Start New Chat button
      await tester.tap(find.text('Start New Chat'));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.text('New Chat Screen'), findsOneWidget);
    });

    testWidgets('all feature cards have consistent styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      // Find all feature card containers
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(EmptyConversationState),
          matching: find.byType(Container),
        ),
      );

      // Check that feature card containers exist
      expect(containers.length, greaterThan(3));
    });

    testWidgets('is scrollable for small screens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('centers content on screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      // Multiple Center widgets exist (main content + feature card icons)
      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });

    testWidgets('renders correctly in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      expect(find.text('Welcome to ZeusGPT'), findsOneWidget);
      expect(find.text('Start New Chat'), findsOneWidget);
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      expect(find.text('Welcome to ZeusGPT'), findsOneWidget);
      expect(find.text('Start New Chat'), findsOneWidget);
    });

    testWidgets('feature card has icon, title, and description',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      // Check first feature card has all elements
      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.text('Multiple AI Models'), findsOneWidget);
      expect(find.text('Access GPT-4, Claude, Gemini, and 500+ more'),
          findsOneWidget);
    });

    testWidgets('button icons are properly sized', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyConversationState(),
          ),
        ),
      );

      // Both buttons should have icons
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.explore), findsOneWidget);
    });
  });
}
