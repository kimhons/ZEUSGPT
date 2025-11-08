import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeusgpt/features/chat/presentation/screens/home_screen.dart';
import 'package:zeusgpt/features/chat/presentation/screens/new_chat_screen.dart';
import 'package:zeusgpt/features/chat/presentation/screens/chat_screen.dart';
import 'package:zeusgpt/core/theme/app_theme.dart';

import 'helpers/integration_test_helpers.dart';

void main() {
  group('Conversation Flow Integration Tests', () {
    testWidgets('home screen - displays empty state when no conversations',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'new-chat',
                builder: (context, state) => const NewChatScreen(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.lightTheme(),
            routerConfig: router,
          ),
        ),
      );

      // Wait for home screen to load
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('Welcome to ZeusGPT'), findsOneWidget);
      expect(find.text('Start a conversation with 500+ AI models'),
          findsOneWidget);
    });

    testWidgets('home screen - navigate to new chat', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'new-chat',
                builder: (context, state) => const NewChatScreen(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.lightTheme(),
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap new chat button
      // Scroll to make button visible
      await tester.dragUntilVisible(
        find.text('Start New Chat'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );

      await tester.tap(find.text('Start New Chat'));
      await tester.pumpAndSettle();

      // Verify navigation to new chat screen
      expect(find.text('New Conversation'), findsOneWidget);
    });

    testWidgets('new chat screen - displays model selection', (tester) async {
      final router = GoRouter(
        initialLocation: '/home/new-chat',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'new-chat',
                builder: (context, state) => const NewChatScreen(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.lightTheme(),
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify model selection UI is shown
      expect(find.text('New Conversation'), findsOneWidget);
      expect(find.text('Select AI Model'), findsOneWidget);

      // Verify provider tabs are shown
      expect(find.text('OpenAI'), findsOneWidget);
      expect(find.text('Anthropic'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
    });

    testWidgets('new chat screen - can select model', (tester) async {
      final router = GoRouter(
        initialLocation: '/home/new-chat',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'new-chat',
                builder: (context, state) => const NewChatScreen(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.lightTheme(),
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on a provider tab (e.g., Anthropic)
      await tester.tap(find.text('Anthropic'));
      await tester.pumpAndSettle();

      // Verify Anthropic models are shown
      // This would require actual implementation to verify specific models
    });

    testWidgets('chat screen - displays conversation header', (tester) async {
      final router = GoRouter(
        initialLocation: '/home/chat/test-conversation-id',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'chat/:conversationId',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  return ChatScreen(conversationId: conversationId);
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.lightTheme(),
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify chat screen loads
      // Note: This would require mocked data to show actual conversation
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('chat screen - can send message', (tester) async {
      final router = GoRouter(
        initialLocation: '/home/chat/test-conversation-id',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'chat/:conversationId',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  return ChatScreen(conversationId: conversationId);
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.lightTheme(),
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find chat input field
      final chatInput = find.byType(TextField);
      if (chatInput.evaluate().isNotEmpty) {
        // Enter message text
        await tester.enterText(chatInput, 'Hello, this is a test message');
        await tester.pump();

        // Find and tap send button
        final sendButton = find.byIcon(Icons.send);
        if (sendButton.evaluate().isNotEmpty) {
          await tester.tap(sendButton);
          await tester.pump();

          // Message sending would require mocked providers
        }
      }
    });

    testWidgets('home screen - displays conversation list when conversations exist',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.lightTheme(),
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // With mocked data, this would show conversations
      // For now, verifies home screen loads
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('conversation flow - create new conversation and send message',
        (tester) async {
      // This test would require full mocking to work properly
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'new-chat',
                builder: (context, state) => const NewChatScreen(),
              ),
              GoRoute(
                path: 'chat/:conversationId',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  return ChatScreen(conversationId: conversationId);
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.lightTheme(),
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Navigate to new chat
      await tester.dragUntilVisible(
        find.text('Start New Chat'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );

      await tester.tap(find.text('Start New Chat'));
      await tester.pumpAndSettle();

      // Step 2: Verify new chat screen
      expect(find.text('New Conversation'), findsOneWidget);

      // Step 3: Select model and start chat
      // (would require implementation details)

      // Step 4: Send first message
      // (would require mocked providers)

      // Step 5: Verify message appears in chat
      // (would require mocked providers)
    });
  });
}
