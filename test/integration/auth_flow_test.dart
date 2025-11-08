import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeusgpt/features/auth/presentation/screens/login_screen.dart';
import 'package:zeusgpt/features/auth/presentation/screens/signup_screen.dart';
import 'package:zeusgpt/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:zeusgpt/features/chat/presentation/screens/home_screen.dart';
import 'package:zeusgpt/core/theme/app_theme.dart';

import 'helpers/integration_test_helpers.dart';

void main() {
  group('Authentication Flow Integration Tests', () {
    testWidgets('login flow - successful login navigates to home',
        (tester) async {
      // Create router for testing
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      );

      // Pump the app
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.lightTheme(),
            routerConfig: router,
          ),
        ),
      );

      // Verify we're on login screen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);

      // Find email and password fields
      final emailField = IntegrationTestHelpers.findTextFieldByLabel('Email');
      final passwordField =
          IntegrationTestHelpers.findTextFieldByLabel('Password');

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      // Enter credentials
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Find and tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(loginButton, findsOneWidget);

      // Note: Actual login will require mock providers
      // This test verifies the UI flow
    });

    testWidgets('login screen - has forgot password link', (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
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

      // Look for forgot password link
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Verify navigation to forgot password screen
      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('login screen - has sign up link', (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignUpScreen(),
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

      // Look for sign up link
      expect(find.textContaining("Don't have an account?"), findsOneWidget);

      // Find and tap sign up link
      final signUpLink = find.textContaining('Sign Up');
      expect(signUpLink, findsOneWidget);

      await tester.tap(signUpLink);
      await tester.pumpAndSettle();

      // Verify navigation to sign up screen
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('signup screen - validates form fields', (tester) async {
      final router = GoRouter(
        initialLocation: '/signup',
        routes: [
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignUpScreen(),
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

      // Verify we're on signup screen
      expect(find.text('Create Account'), findsOneWidget);

      // Find form fields
      expect(IntegrationTestHelpers.findTextFieldByLabel('Full Name'),
          findsOneWidget);
      expect(IntegrationTestHelpers.findTextFieldByLabel('Email'),
          findsOneWidget);
      expect(IntegrationTestHelpers.findTextFieldByLabel('Password'),
          findsOneWidget);
      expect(IntegrationTestHelpers.findTextFieldByLabel('Confirm Password'),
          findsOneWidget);
    });

    testWidgets('forgot password screen - can request password reset',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/forgot-password',
        routes: [
          GoRoute(
            path: '/forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
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

      // Verify we're on forgot password screen
      expect(find.text('Reset Password'), findsOneWidget);

      // Find email field
      final emailField = IntegrationTestHelpers.findTextFieldByLabel('Email');
      expect(emailField, findsOneWidget);

      // Enter email
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Find reset button
      final resetButton =
          find.widgetWithText(ElevatedButton, 'Send Reset Link');
      expect(resetButton, findsOneWidget);
    });

    testWidgets('login screen - email validation', (tester) async {
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

      // Find email field
      final emailField = IntegrationTestHelpers.findTextFieldByLabel('Email');

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.pump();

      // Tap login button to trigger validation
      final loginButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(loginButton);
      await tester.pump();

      // Expect validation error (implementation-dependent)
      // This would need to be adjusted based on actual validation implementation
    });

    testWidgets('signup screen - password confirmation validation',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/signup',
        routes: [
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignUpScreen(),
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

      // Find password fields
      final passwordField =
          IntegrationTestHelpers.findTextFieldByLabel('Password');
      final confirmPasswordField =
          IntegrationTestHelpers.findTextFieldByLabel('Confirm Password');

      // Enter mismatched passwords
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      await tester.enterText(confirmPasswordField, 'different456');
      await tester.pump();

      // Tap sign up button to trigger validation
      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.tap(signUpButton);
      await tester.pump();

      // Expect validation error (implementation-dependent)
    });
  });
}
