import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zeusgpt/features/auth/data/repositories/auth_repository.dart';
import 'package:zeusgpt/data/models/user_model.dart';
import 'package:zeusgpt/core/utils/error_handler.dart';

/// Mock classes
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockUser extends Mock implements firebase_auth.User {}

class MockUserMetadata extends Mock implements firebase_auth.UserMetadata {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class FakeAuthCredential extends Fake implements firebase_auth.AuthCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthRepository authRepository;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    authRepository = AuthRepository(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('AuthRepository', () {
    group('currentUser', () {
      test('returns null when no user is signed in', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        final result = authRepository.currentUser;

        expect(result, isNull);
      });

      test('returns UserModel when user is signed in', () {
        final mockUser = MockUser();
        final mockMetadata = MockUserMetadata();

        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
        when(() => mockUser.phoneNumber).thenReturn(null);
        when(() => mockUser.emailVerified).thenReturn(true);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(DateTime(2024, 1, 1));
        when(() => mockMetadata.lastSignInTime).thenReturn(DateTime(2024, 1, 15));
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final result = authRepository.currentUser;

        expect(result, isA<UserModel>());
        expect(result?.userId, equals('test-uid'));
        expect(result?.email, equals('test@example.com'));
        expect(result?.displayName, equals('Test User'));
      });
    });

    group('isAuthenticated', () {
      test('returns false when no user is signed in', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(authRepository.isAuthenticated, isFalse);
      });

      test('returns true when user is signed in', () {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        expect(authRepository.isAuthenticated, isTrue);
      });
    });

    group('authStateChanges', () {
      test('emits null when user signs out', () async {
        final controller = StreamController<firebase_auth.User?>();
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => controller.stream);

        final stream = authRepository.authStateChanges;

        controller.add(null);

        expect(await stream.first, isNull);
        controller.close();
      });

      test('emits UserModel when user signs in', () async {
        final mockUser = MockUser();
        final mockMetadata = MockUserMetadata();
        final controller = StreamController<firebase_auth.User?>();

        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.phoneNumber).thenReturn(null);
        when(() => mockUser.emailVerified).thenReturn(false);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(DateTime(2024, 1, 1));
        when(() => mockMetadata.lastSignInTime).thenReturn(DateTime(2024, 1, 1));
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => controller.stream);

        final stream = authRepository.authStateChanges;

        controller.add(mockUser);

        final user = await stream.first;
        expect(user, isA<UserModel>());
        expect(user?.userId, equals('test-uid'));
        controller.close();
      });
    });

    group('signInWithEmailAndPassword', () {
      test('returns UserModel on successful sign in', () async {
        final mockUser = MockUser();
        final mockMetadata = MockUserMetadata();
        final mockCredential = MockUserCredential();

        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.phoneNumber).thenReturn(null);
        when(() => mockUser.emailVerified).thenReturn(true);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(DateTime(2024, 1, 1));
        when(() => mockMetadata.lastSignInTime).thenReturn(DateTime(2024, 1, 15));
        when(() => mockCredential.user).thenReturn(mockUser);

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenAnswer((_) async => mockCredential);

        final result = await authRepository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isA<UserModel>());
        expect(result.userId, equals('test-uid'));
        expect(result.email, equals('test@example.com'));
      });

      test('throws AuthException when sign in fails with no user', () async {
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(null);

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenAnswer((_) async => mockCredential);

        expect(
          () => authRepository.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws AuthException on FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'user-not-found'),
        );

        expect(
          () => authRepository.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signUpWithEmailAndPassword', () {
      test('returns UserModel on successful sign up', () async {
        final mockUser = MockUser();
        final mockMetadata = MockUserMetadata();
        final mockCredential = MockUserCredential();

        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.phoneNumber).thenReturn(null);
        when(() => mockUser.emailVerified).thenReturn(false);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(DateTime(2024, 1, 1));
        when(() => mockMetadata.lastSignInTime).thenReturn(DateTime(2024, 1, 1));
        when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async => {});
        when(() => mockUser.sendEmailVerification()).thenAnswer((_) async => {});
        when(() => mockCredential.user).thenReturn(mockUser);

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenAnswer((_) async => mockCredential);

        final result = await authRepository.signUpWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        expect(result, isA<UserModel>());
        expect(result.userId, equals('test-uid'));
        verify(() => mockUser.updateDisplayName('Test User')).called(1);
        verify(() => mockUser.sendEmailVerification()).called(1);
      });

      test('throws AuthException when sign up fails with no user', () async {
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(null);

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenAnswer((_) async => mockCredential);

        expect(
          () => authRepository.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
            displayName: 'Test User',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws AuthException on FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'email-already-in-use'),
        );

        expect(
          () => authRepository.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
            displayName: 'Test User',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signInWithGoogle', () {
      test('returns UserModel on successful Google sign in', () async {
        final mockGoogleAccount = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final mockUser = MockUser();
        final mockMetadata = MockUserMetadata();
        final mockCredential = MockUserCredential();

        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleAccount);
        when(() => mockGoogleAccount.authentication)
            .thenAnswer((_) async => mockGoogleAuth);
        when(() => mockGoogleAuth.accessToken).thenReturn('access-token');
        when(() => mockGoogleAuth.idToken).thenReturn('id-token');

        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.phoneNumber).thenReturn(null);
        when(() => mockUser.emailVerified).thenReturn(true);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(DateTime(2024, 1, 1));
        when(() => mockMetadata.lastSignInTime).thenReturn(DateTime(2024, 1, 15));
        when(() => mockCredential.user).thenReturn(mockUser);

        when(() => mockFirebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockCredential);

        final result = await authRepository.signInWithGoogle();

        expect(result, isA<UserModel>());
        expect(result.userId, equals('test-uid'));
        expect(result.email, equals('test@example.com'));
      });

      test('throws AuthException when Google sign in is cancelled', () async {
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        expect(
          () => authRepository.signInWithGoogle(),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws AuthException when no user returned', () async {
        final mockGoogleAccount = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final mockCredential = MockUserCredential();

        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleAccount);
        when(() => mockGoogleAccount.authentication)
            .thenAnswer((_) async => mockGoogleAuth);
        when(() => mockGoogleAuth.accessToken).thenReturn('access-token');
        when(() => mockGoogleAuth.idToken).thenReturn('id-token');
        when(() => mockCredential.user).thenReturn(null);

        when(() => mockFirebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockCredential);

        expect(
          () => authRepository.signInWithGoogle(),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws AuthException on FirebaseAuthException', () async {
        final mockGoogleAccount = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();

        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleAccount);
        when(() => mockGoogleAccount.authentication)
            .thenAnswer((_) async => mockGoogleAuth);
        when(() => mockGoogleAuth.accessToken).thenReturn('access-token');
        when(() => mockGoogleAuth.idToken).thenReturn('id-token');

        when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'account-exists-with-different-credential'),
        );

        expect(
          () => authRepository.signInWithGoogle(),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signOut', () {
      test('signs out successfully', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        await authRepository.signOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      });

      test('throws exception on sign out failure', () async {
        when(() => mockFirebaseAuth.signOut())
            .thenThrow(Exception('Sign out failed'));
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        expect(
          () => authRepository.signOut(),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('sendPasswordResetEmail', () {
      test('sends password reset email successfully', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: 'test@example.com',
        )).thenAnswer((_) async => {});

        await authRepository.sendPasswordResetEmail(
          email: 'test@example.com',
        );

        verify(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: 'test@example.com',
        )).called(1);
      });

      test('throws AuthException on FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: 'test@example.com',
        )).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'user-not-found'),
        );

        expect(
          () => authRepository.sendPasswordResetEmail(
            email: 'test@example.com',
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('sendEmailVerification', () {
      test('sends email verification successfully', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.sendEmailVerification()).thenAnswer((_) async => {});

        await authRepository.sendEmailVerification();

        verify(() => mockUser.sendEmailVerification()).called(1);
      });

      test('throws AuthException when no user is signed in', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(
          () => authRepository.sendEmailVerification(),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws AuthException on FirebaseAuthException', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.sendEmailVerification()).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'too-many-requests'),
        );

        expect(
          () => authRepository.sendEmailVerification(),
          throwsA(isA<RateLimitException>()),
        );
      });
    });

    group('reloadUser', () {
      test('reloads user successfully', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.reload()).thenAnswer((_) async => {});

        await authRepository.reloadUser();

        verify(() => mockUser.reload()).called(1);
      });

      test('throws AuthException when no user is signed in', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(
          () => authRepository.reloadUser(),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws exception on reload failure', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.reload()).thenThrow(Exception('Reload failed'));

        expect(
          () => authRepository.reloadUser(),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('updateProfile', () {
      test('updates display name successfully', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async => {});
        when(() => mockUser.reload()).thenAnswer((_) async => {});

        await authRepository.updateProfile(displayName: 'New Name');

        verify(() => mockUser.updateDisplayName('New Name')).called(1);
        verify(() => mockUser.reload()).called(1);
      });

      test('updates photo URL successfully', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.updatePhotoURL(any())).thenAnswer((_) async => {});
        when(() => mockUser.reload()).thenAnswer((_) async => {});

        await authRepository.updateProfile(
          photoURL: 'https://example.com/photo.jpg',
        );

        verify(() => mockUser.updatePhotoURL('https://example.com/photo.jpg'))
            .called(1);
        verify(() => mockUser.reload()).called(1);
      });

      test('updates both display name and photo URL', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async => {});
        when(() => mockUser.updatePhotoURL(any())).thenAnswer((_) async => {});
        when(() => mockUser.reload()).thenAnswer((_) async => {});

        await authRepository.updateProfile(
          displayName: 'New Name',
          photoURL: 'https://example.com/photo.jpg',
        );

        verify(() => mockUser.updateDisplayName('New Name')).called(1);
        verify(() => mockUser.updatePhotoURL('https://example.com/photo.jpg'))
            .called(1);
        verify(() => mockUser.reload()).called(1);
      });

      test('throws AuthException when no user is signed in', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(
          () => authRepository.updateProfile(displayName: 'New Name'),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws AuthException on FirebaseAuthException', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.updateDisplayName(any())).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'invalid-display-name'),
        );

        expect(
          () => authRepository.updateProfile(displayName: 'New Name'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('deleteAccount', () {
      test('deletes account successfully', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.delete()).thenAnswer((_) async => {});

        await authRepository.deleteAccount();

        verify(() => mockUser.delete()).called(1);
      });

      test('throws AuthException when no user is signed in', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(
          () => authRepository.deleteAccount(),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws AuthException on FirebaseAuthException', () async {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('test-uid');
        when(() => mockUser.delete()).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'requires-recent-login'),
        );

        expect(
          () => authRepository.deleteAccount(),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });
}
