import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zeusgpt/features/auth/data/repositories/auth_repository.dart';
import 'package:zeusgpt/data/models/user_model.dart';
import 'package:zeusgpt/features/auth/presentation/providers/auth_provider.dart';

// Mock classes
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  // Test user data
  final testUser = UserModel(
    userId: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
    photoURL: 'https://example.com/photo.jpg',
    emailVerified: true,
    onboardingCompleted: true,
    subscription: const UserSubscription(),
    preferences: const UserPreferences(),
    usage: const UserUsage(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockAuthRepository();

    // Default mock behavior - no auth state changes
    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthState', () {
    test('has correct default values', () {
      const state = AuthState();

      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('isAuthenticated returns true when user is not null', () {
      final state = AuthState(user: testUser);

      expect(state.isAuthenticated, isTrue);
    });

    test('isAuthenticated returns false when user is null', () {
      const state = AuthState();

      expect(state.isAuthenticated, isFalse);
    });

    test('isEmailVerified returns true when user email is verified', () {
      final state = AuthState(user: testUser);

      expect(state.isEmailVerified, isTrue);
    });

    test('isEmailVerified returns false when user email is not verified', () {
      final unverifiedUser = testUser.copyWith(emailVerified: false);
      final state = AuthState(user: unverifiedUser);

      expect(state.isEmailVerified, isFalse);
    });

    test('isEmailVerified returns false when user is null', () {
      const state = AuthState();

      expect(state.isEmailVerified, isFalse);
    });

    test('hasCompletedOnboarding returns true when user completed onboarding', () {
      final state = AuthState(user: testUser);

      expect(state.hasCompletedOnboarding, isTrue);
    });

    test('hasCompletedOnboarding returns false when user has not completed onboarding', () {
      final userWithoutOnboarding = testUser.copyWith(onboardingCompleted: false);
      final state = AuthState(user: userWithoutOnboarding);

      expect(state.hasCompletedOnboarding, isFalse);
    });

    test('hasCompletedOnboarding returns false when user is null', () {
      const state = AuthState();

      expect(state.hasCompletedOnboarding, isFalse);
    });
  });

  group('AuthNotifier', () {
    group('initialization', () {
      test('initializes with empty state when no current user', () {
        final state = container.read(authProvider);

        expect(state.user, isNull);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, isNull);
      });

      test('initializes with user when current user exists', () async {
        when(() => mockRepository.currentUser).thenReturn(testUser);

        final newContainer = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final state = newContainer.read(authProvider);

        expect(state.user, equals(testUser));
        expect(state.isLoading, isFalse);

        await Future.delayed(Duration.zero);
        newContainer.dispose();
      });

      test('updates state when authStateChanges emits new user', () async {
        final streamController = StreamController<UserModel?>();
        when(() => mockRepository.authStateChanges)
            .thenAnswer((_) => streamController.stream);

        final newContainer = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        // Initialize the provider to start listening to stream
        newContainer.read(authProvider);

        streamController.add(testUser);
        await Future.delayed(const Duration(milliseconds: 100));

        final state = newContainer.read(authProvider);

        expect(state.user, equals(testUser));

        await streamController.close();
        await Future.delayed(Duration.zero);
        newContainer.dispose();
      });
    });

    group('signInWithEmailAndPassword', () {
      test('sets loading to true, then updates user on success', () async {
        when(() => mockRepository.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);

        final notifier = container.read(authProvider.notifier);
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(states[0].isLoading, isTrue);
        expect(states.last.isLoading, isFalse);
        expect(states.last.user, equals(testUser));
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Login failed');
        when(() => mockRepository.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          );
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Login failed'));
      });

      test('verifies repository method is called with correct parameters', () async {
        when(() => mockRepository.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);

        final notifier = container.read(authProvider.notifier);

        await notifier.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        verify(() => mockRepository.signInWithEmailAndPassword(
              email: 'test@example.com',
              password: 'password123',
            )).called(1);
      });
    });

    group('signUpWithEmailAndPassword', () {
      test('sets loading to true, then updates user on success', () async {
        when(() => mockRepository.signUpWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenAnswer((_) async => testUser);

        final notifier = container.read(authProvider.notifier);
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        expect(states[0].isLoading, isTrue);
        expect(states.last.isLoading, isFalse);
        expect(states.last.user, equals(testUser));
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Sign up failed');
        when(() => mockRepository.signUpWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
            displayName: 'Test User',
          );
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Sign up failed'));
      });
    });

    group('signInWithGoogle', () {
      test('sets loading to true, then updates user on success', () async {
        when(() => mockRepository.signInWithGoogle())
            .thenAnswer((_) async => testUser);

        final notifier = container.read(authProvider.notifier);
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.signInWithGoogle();

        expect(states[0].isLoading, isTrue);
        expect(states.last.isLoading, isFalse);
        expect(states.last.user, equals(testUser));
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Google sign in failed');
        when(() => mockRepository.signInWithGoogle()).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.signInWithGoogle();
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Google sign in failed'));
      });
    });

    group('signInWithApple', () {
      test('sets loading to true, then updates user on success', () async {
        when(() => mockRepository.signInWithApple())
            .thenAnswer((_) async => testUser);

        final notifier = container.read(authProvider.notifier);
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.signInWithApple();

        expect(states[0].isLoading, isTrue);
        expect(states.last.isLoading, isFalse);
        expect(states.last.user, equals(testUser));
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Apple sign in failed');
        when(() => mockRepository.signInWithApple()).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.signInWithApple();
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Apple sign in failed'));
      });
    });

    group('signOut', () {
      test('sets loading to true, then clears user on success', () async {
        when(() => mockRepository.signOut()).thenAnswer((_) async {});

        final notifier = container.read(authProvider.notifier);
        
        // Set a user first
        notifier.state = notifier.state.copyWith(user: testUser);
        
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.signOut();

        expect(states[0].isLoading, isTrue);
        expect(states.last.isLoading, isFalse);
        expect(states.last.user, isNull);
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Sign out failed');
        when(() => mockRepository.signOut()).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.signOut();
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Sign out failed'));
      });
    });

    group('sendPasswordResetEmail', () {
      test('sets loading to true, then completes successfully', () async {
        when(() => mockRepository.sendPasswordResetEmail(
              email: any(named: 'email'),
            )).thenAnswer((_) async {});

        final notifier = container.read(authProvider.notifier);
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.sendPasswordResetEmail(email: 'test@example.com');

        expect(states[0].isLoading, isTrue);
        expect(states.last.isLoading, isFalse);
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Reset password failed');
        when(() => mockRepository.sendPasswordResetEmail(
              email: any(named: 'email'),
            )).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.sendPasswordResetEmail(email: 'test@example.com');
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Reset password failed'));
      });
    });

    group('sendEmailVerification', () {
      test('sets loading to true, then completes successfully', () async {
        when(() => mockRepository.sendEmailVerification())
            .thenAnswer((_) async {});

        final notifier = container.read(authProvider.notifier);
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.sendEmailVerification();

        expect(states[0].isLoading, isTrue);
        expect(states.last.isLoading, isFalse);
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Email verification failed');
        when(() => mockRepository.sendEmailVerification()).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.sendEmailVerification();
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Email verification failed'));
      });
    });

    group('reloadUser', () {
      test('sets loading to true, then updates user on success', () async {
        when(() => mockRepository.reloadUser()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
        });
        when(() => mockRepository.currentUser).thenReturn(testUser);

        final notifier = container.read(authProvider.notifier);
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.reloadUser();

        expect(states.length, greaterThanOrEqualTo(1));
        expect(states.last.user, equals(testUser));
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Reload user failed');
        when(() => mockRepository.reloadUser()).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.reloadUser();
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Reload user failed'));
      });
    });

    group('updateProfile', () {
      test('sets loading to true, then updates user on success', () async {
        final updatedUser = testUser.copyWith(displayName: 'New Name');
        when(() => mockRepository.updateProfile(
              displayName: any(named: 'displayName'),
              photoURL: any(named: 'photoURL'),
            )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
        });
        when(() => mockRepository.currentUser).thenReturn(updatedUser);

        final notifier = container.read(authProvider.notifier);
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.updateProfile(
          displayName: 'New Name',
          photoURL: 'https://example.com/new-photo.jpg',
        );

        expect(states.length, greaterThanOrEqualTo(2));
        expect(states[0].isLoading, isTrue);
        expect(states.last.isLoading, isFalse);
        expect(states.last.user, equals(updatedUser));
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Update profile failed');
        when(() => mockRepository.updateProfile(
              displayName: any(named: 'displayName'),
              photoURL: any(named: 'photoURL'),
            )).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.updateProfile(displayName: 'New Name');
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Update profile failed'));
      });
    });

    group('deleteAccount', () {
      test('sets loading to true, then clears user on success', () async {
        when(() => mockRepository.deleteAccount()).thenAnswer((_) async {});

        final notifier = container.read(authProvider.notifier);
        
        // Set a user first
        notifier.state = notifier.state.copyWith(user: testUser);
        
        final states = <AuthState>[];

        container.listen(authProvider, (previous, next) {
          states.add(next);
        });

        await notifier.deleteAccount();

        expect(states[0].isLoading, isTrue);
        expect(states.last.isLoading, isFalse);
        expect(states.last.user, isNull);
        expect(states.last.errorMessage, isNull);
      });

      test('sets errorMessage and rethrows on failure', () async {
        final exception = Exception('Delete account failed');
        when(() => mockRepository.deleteAccount()).thenThrow(exception);

        final notifier = container.read(authProvider.notifier);

        try {
          await notifier.deleteAccount();
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, equals(exception));
        }

        final state = container.read(authProvider);

        expect(state.isLoading, isFalse);
        expect(state.errorMessage, contains('Delete account failed'));
      });
    });

    group('clearError', () {
      test('clears error message from state', () {
        final notifier = container.read(authProvider.notifier);

        // Set an error first
        notifier.state = notifier.state.copyWith(errorMessage: 'Test error');

        expect(container.read(authProvider).errorMessage, equals('Test error'));

        notifier.clearError();

        final state = container.read(authProvider);

        expect(state.errorMessage, isNull);
      });
    });

    group('completeOnboarding', () {
      test('marks onboarding as completed when user exists', () {
        final notifier = container.read(authProvider.notifier);

        // Set a user with onboarding not completed
        final userWithoutOnboarding = testUser.copyWith(onboardingCompleted: false);
        notifier.state = notifier.state.copyWith(user: userWithoutOnboarding);

        notifier.completeOnboarding();

        final state = container.read(authProvider);

        expect(state.user, isNotNull);
        expect(state.user!.onboardingCompleted, isTrue);
      });

      test('does nothing when user is null', () {
        final notifier = container.read(authProvider.notifier);

        // Ensure no user
        expect(container.read(authProvider).user, isNull);

        notifier.completeOnboarding();

        final state = container.read(authProvider);

        expect(state.user, isNull);
      });
    });
  });
}
