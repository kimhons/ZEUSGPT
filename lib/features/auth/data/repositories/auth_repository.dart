import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger_service.dart';

/// Auth repository interface
abstract class IAuthRepository {
  /// Get current user
  UserModel? get currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Auth state changes stream
  Stream<UserModel?> get authStateChanges;

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign in with Apple
  Future<UserModel> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email});

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Reload user
  Future<void> reloadUser();

  /// Update profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  });

  /// Delete account
  Future<void> deleteAccount();
}

/// Firebase Auth repository implementation
class AuthRepository implements IAuthRepository {
  AuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  UserModel? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return _mapFirebaseUserToUserModel(firebaseUser);
  }

  @override
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return _mapFirebaseUserToUserModel(firebaseUser);
    });
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.i('Signing in with email: $email');

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Sign in failed. No user returned.');
      }

      LoggerService.i('Sign in successful: ${credential.user!.uid}');
      return _mapFirebaseUserToUserModel(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      LoggerService.e(
        'Sign in failed',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      LoggerService.e(
        'Unexpected error during sign in',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      LoggerService.i('Creating account for email: $email');

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Sign up failed. No user returned.');
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Send email verification
      await credential.user!.sendEmailVerification();

      LoggerService.i('Account created successfully: ${credential.user!.uid}');
      return _mapFirebaseUserToUserModel(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      LoggerService.e(
        'Sign up failed',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      LoggerService.e(
        'Unexpected error during sign up',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      LoggerService.i('Starting Google Sign-In');

      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google Sign-In was cancelled');
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw const AuthException('Google Sign-In failed. No user returned.');
      }

      LoggerService.i('Google Sign-In successful: ${userCredential.user!.uid}');
      return _mapFirebaseUserToUserModel(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      LoggerService.e(
        'Google Sign-In failed',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      LoggerService.e(
        'Unexpected error during Google Sign-In',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      LoggerService.i('Starting Apple Sign-In');

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth provider credential
      final oAuthProvider = firebase_auth.OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw const AuthException('Apple Sign-In failed. No user returned.');
      }

      // Update display name if available
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      LoggerService.i('Apple Sign-In successful: ${userCredential.user!.uid}');
      return _mapFirebaseUserToUserModel(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      LoggerService.e(
        'Apple Sign-In failed',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      LoggerService.e(
        'Unexpected error during Apple Sign-In',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      LoggerService.i('Signing out');

      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

      LoggerService.i('Sign out successful');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Sign out failed',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      LoggerService.i('Sending password reset email to: $email');

      await _firebaseAuth.sendPasswordResetEmail(email: email);

      LoggerService.i('Password reset email sent successfully');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      LoggerService.e(
        'Failed to send password reset email',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      LoggerService.e(
        'Unexpected error sending password reset email',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      LoggerService.i('Sending email verification to: ${user.email}');

      await user.sendEmailVerification();

      LoggerService.i('Email verification sent successfully');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      LoggerService.e(
        'Failed to send email verification',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      LoggerService.e(
        'Unexpected error sending email verification',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      await user.reload();
      LoggerService.d('User reloaded successfully');
    } catch (e, stackTrace) {
      LoggerService.e(
        'Failed to reload user',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      LoggerService.i('Updating user profile');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();
      LoggerService.i('Profile updated successfully');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      LoggerService.e(
        'Failed to update profile',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      LoggerService.e(
        'Unexpected error updating profile',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      LoggerService.w('Deleting user account: ${user.uid}');

      await user.delete();

      LoggerService.w('Account deleted successfully');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      LoggerService.e(
        'Failed to delete account',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      LoggerService.e(
        'Unexpected error deleting account',
        error: e,
        stackTrace: stackTrace,
      );
      throw ErrorHandler.handleError(e, stackTrace: stackTrace);
    }
  }

  /// Map Firebase User to UserModel
  UserModel _mapFirebaseUserToUserModel(firebase_auth.User firebaseUser) {
    return UserModel(
      userId: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
      // Default values for other fields - will be populated from Firestore
      subscription: UserSubscription(
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
      ),
      preferences: UserPreferences(
        theme: ThemeMode.system,
        defaultModelId: 'gpt-3.5-turbo',
        defaultProvider: ModelProvider.openai,
        language: 'en',
      ),
      usage: UserUsage(
        messagesThisMonth: 0,
        tokensThisMonth: 0,
        imagesThisMonth: 0,
        lastResetDate: DateTime.now(),
      ),
      devices: [],
      onboardingCompleted: false,
    );
  }
}
