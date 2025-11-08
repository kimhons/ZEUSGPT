import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/chat/presentation/screens/home_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/new_chat_screen.dart';

/// App router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state for navigation guards
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRouteNames.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        name: AppRouteNames.verifyEmail,
        builder: (context, state) => const VerifyEmailScreen(),
      ),

      // Main app routes (after auth)
      GoRoute(
        path: AppRoutes.home,
        name: AppRouteNames.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Chat routes
          GoRoute(
            path: 'chat/:conversationId',
            name: AppRouteNames.chat,
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              return ChatScreen(conversationId: conversationId);
            },
          ),
          GoRoute(
            path: 'new-chat',
            name: AppRouteNames.newChat,
            builder: (context, state) => const NewChatScreen(),
          ),

          // Settings routes
          GoRoute(
            path: 'settings',
            name: AppRouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                name: AppRouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'subscription',
                name: AppRouteNames.subscription,
                builder: (context, state) => const SubscriptionScreen(),
              ),
              GoRoute(
                path: 'api-keys',
                name: AppRouteNames.apiKeys,
                builder: (context, state) => const APIKeysScreen(),
              ),
              GoRoute(
                path: 'preferences',
                name: AppRouteNames.preferences,
                builder: (context, state) => const PreferencesScreen(),
              ),
              GoRoute(
                path: 'security',
                name: AppRouteNames.security,
                builder: (context, state) => const SecurityScreen(),
              ),
            ],
          ),

          // Model selection
          GoRoute(
            path: 'models',
            name: AppRouteNames.models,
            builder: (context, state) => const ModelsScreen(),
          ),

          // History
          GoRoute(
            path: 'history',
            name: AppRouteNames.history,
            builder: (context, state) => const HistoryScreen(),
          ),

          // Team routes (for team subscriptions)
          GoRoute(
            path: 'team',
            name: AppRouteNames.team,
            builder: (context, state) => const TeamScreen(),
            routes: [
              GoRoute(
                path: 'members',
                name: AppRouteNames.teamMembers,
                builder: (context, state) => const TeamMembersScreen(),
              ),
              GoRoute(
                path: 'invite',
                name: AppRouteNames.teamInvite,
                builder: (context, state) => const TeamInviteScreen(),
              ),
            ],
          ),
        ],
      ),

      // Error/404
      GoRoute(
        path: '/error',
        name: AppRouteNames.error,
        builder: (context, state) {
          final error = state.extra as String?;
          return ErrorScreen(error: error);
        },
      ),
    ],

    // Redirect logic for auth
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isEmailVerified = authState.isEmailVerified;
      final hasCompletedOnboarding = authState.hasCompletedOnboarding;

      final location = state.matchedLocation;
      final isGoingToAuth = location.startsWith('/login') ||
          location.startsWith('/signup') ||
          location.startsWith('/forgot-password');
      final isGoingToVerifyEmail = location == AppRoutes.verifyEmail;
      final isGoingToOnboarding = location == AppRoutes.onboarding;
      final isGoingToSplash = location == AppRoutes.splash;

      // Allow splash screen always
      if (isGoingToSplash) {
        return null;
      }

      // If not authenticated and not going to auth screens, redirect to login
      if (!isAuthenticated && !isGoingToAuth) {
        return AppRoutes.login;
      }

      // If authenticated but email not verified, redirect to verify email
      if (isAuthenticated &&
          !isEmailVerified &&
          !isGoingToVerifyEmail &&
          !isGoingToAuth) {
        return AppRoutes.verifyEmail;
      }

      // If authenticated and email verified but not onboarded, go to onboarding
      if (isAuthenticated &&
          isEmailVerified &&
          !hasCompletedOnboarding &&
          !isGoingToOnboarding) {
        return AppRoutes.onboarding;
      }

      // If authenticated and going to auth screens, redirect to home
      if (isAuthenticated &&
          isEmailVerified &&
          hasCompletedOnboarding &&
          (isGoingToAuth || isGoingToVerifyEmail || isGoingToOnboarding)) {
        return AppRoutes.home;
      }

      return null; // No redirect
    },

    // Error handler
    errorBuilder: (context, state) {
      return ErrorScreen(error: state.error?.toString());
    },
  );
});

/// App route paths
class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';

  // Main
  static const String home = '/home';
  static const String chat = '/home/chat/:conversationId';
  static const String newChat = '/home/new-chat';

  // Settings
  static const String settings = '/home/settings';
  static const String profile = '/home/settings/profile';
  static const String subscription = '/home/settings/subscription';
  static const String apiKeys = '/home/settings/api-keys';
  static const String preferences = '/home/settings/preferences';
  static const String security = '/home/settings/security';

  // Other
  static const String models = '/home/models';
  static const String history = '/home/history';
  static const String team = '/home/team';
  static const String teamMembers = '/home/team/members';
  static const String teamInvite = '/home/team/invite';
  static const String error = '/error';
}

/// App route names (for named navigation)
class AppRouteNames {
  // Auth
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgotPassword';
  static const String verifyEmail = 'verifyEmail';

  // Main
  static const String home = 'home';
  static const String chat = 'chat';
  static const String newChat = 'newChat';

  // Settings
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String subscription = 'subscription';
  static const String apiKeys = 'apiKeys';
  static const String preferences = 'preferences';
  static const String security = 'security';

  // Other
  static const String models = 'models';
  static const String history = 'history';
  static const String team = 'team';
  static const String teamMembers = 'teamMembers';
  static const String teamInvite = 'teamInvite';
  static const String error = 'error';
}

// Placeholder screens (to be implemented)

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Settings')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile')),
    );
  }
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Subscription')),
    );
  }
}

class APIKeysScreen extends StatelessWidget {
  const APIKeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('API Keys')),
    );
  }
}

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Preferences')),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Security')),
    );
  }
}

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Models')),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('History')),
    );
  }
}

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Team')),
    );
  }
}

class TeamMembersScreen extends StatelessWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Team Members')),
    );
  }
}

class TeamInviteScreen extends StatelessWidget {
  const TeamInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Team Invite')),
    );
  }
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
