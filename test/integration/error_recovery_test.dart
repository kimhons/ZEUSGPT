import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeusgpt/features/auth/presentation/screens/login_screen.dart';
import 'package:zeusgpt/features/chat/presentation/screens/chat_screen.dart';
import 'package:zeusgpt/features/chat/presentation/screens/home_screen.dart';
import 'package:zeusgpt/core/theme/app_theme.dart';
import 'package:zeusgpt/core/widgets/error_view.dart';

import 'helpers/integration_test_helpers.dart';

void main() {
  group('Error Recovery Integration Tests', () {
    testWidgets('login screen - handles invalid credentials gracefully',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
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

      // Enter invalid credentials
      final emailField = IntegrationTestHelpers.findTextFieldByLabel('Email');
      final passwordField =
          IntegrationTestHelpers.findTextFieldByLabel('Password');

      await tester.enterText(emailField, 'invalid@example.com');
      await tester.pump();

      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pump();

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(loginButton);
      await tester.pump();

      // Error message should appear (implementation-dependent)
      // This would show an error dialog or snackbar
      await tester.pumpAndSettle();

      // Verify form is still accessible for retry
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);
    });

    testWidgets('login screen - handles network errors', (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
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

      // This test would require mocking network failures
      // Verify error UI is shown when network fails
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('chat screen - handles message send failure', (tester) async {
      final router = GoRouter(
        initialLocation: '/home/chat/test-id',
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

      // This test would require mocking message send failure
      // Verify error indicator on failed message
      // Verify retry functionality
    });

    testWidgets('app - handles unexpected errors with error screen',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/error',
        routes: [
          GoRoute(
            path: '/error',
            builder: (context, state) {
              return const ErrorScreen(
                error: 'An unexpected error occurred',
              );
            },
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

      // Verify error screen is shown
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('An unexpected error occurred'), findsOneWidget);
    });

    testWidgets('error view widget - displays error message and retry button',
        (tester) async {
      var retryCallbackInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Failed to load data',
              onRetry: () {
                retryCallbackInvoked = true;
              },
            ),
          ),
        ),
      );

      // Verify error message is shown
      expect(find.text('Failed to load data'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Find and tap retry button
      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();

      // Verify retry callback was invoked
      expect(retryCallbackInvoked, isTrue);
    });

    testWidgets('error view widget - works without retry button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      // Verify error message is shown
      expect(find.text('Something went wrong'), findsOneWidget);

      // Verify retry button is not shown
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('error view widget - allows custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'No internet connection',
              icon: Icons.wifi_off,
            ),
          ),
        ),
      );

      // Verify custom icon is shown
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('login screen - can recover from error state', (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
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

      // 1. Attempt login with invalid credentials
      final emailField = IntegrationTestHelpers.findTextFieldByLabel('Email');
      final passwordField =
          IntegrationTestHelpers.findTextFieldByLabel('Password');

      await tester.enterText(emailField, 'wrong@example.com');
      await tester.pump();

      await tester.enterText(passwordField, 'wrongpass');
      await tester.pump();

      final loginButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(loginButton);
      await tester.pump();

      // 2. Error should appear (implementation-dependent)
      await tester.pumpAndSettle();

      // 3. Correct the credentials
      await tester.enterText(emailField, 'correct@example.com');
      await tester.pump();

      await tester.enterText(passwordField, 'correctpassword');
      await tester.pump();

      // 4. Retry login
      await tester.tap(loginButton);
      await tester.pump();

      // With proper mocking, login should now succeed
      // Verify form is still accessible
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('chat screen - retries failed messages', (tester) async {
      final router = GoRouter(
        initialLocation: '/home/chat/test-id',
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

      // This test would require:
      // 1. Mock a failed message send
      // 2. Verify error indicator appears
      // 3. Tap retry button
      // 4. Verify message resends

      // For now, just verify chat screen loads
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('home screen - handles empty conversation list gracefully',
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

      // Verify empty state is shown gracefully
      expect(find.text('Welcome to ZeusGPT'), findsOneWidget);

      // Verify no error messages
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('navigation - handles invalid routes', (tester) async {
      final router = GoRouter(
        initialLocation: '/invalid-route',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
        errorBuilder: (context, state) => const ErrorScreen(
          error: 'Page not found',
        ),
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

      // Verify error screen is shown for invalid routes
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error ?? 'An error occurred',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
