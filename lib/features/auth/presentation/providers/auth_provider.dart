import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_provider.freezed.dart';

/// Auth state
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    UserModel? user,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => user != null;
  bool get isEmailVerified => user?.emailVerified ?? false;
  bool get hasCompletedOnboarding => user?.onboardingCompleted ?? false;
}

/// Auth repository provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository();
});

/// Auth state notifier provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState()) {
    // Listen to auth state changes from Firebase
    _repository.authStateChanges.listen((user) {
      state = state.copyWith(user: user, errorMessage: null);
    });

    // Initialize with current user if available
    final currentUser = _repository.currentUser;
    if (currentUser != null) {
      state = state.copyWith(user: currentUser);
    }
  }

  final IAuthRepository _repository;

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final user = await _repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final user = await _repository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final user = await _repository.signInWithGoogle();

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final user = await _repository.signInWithApple();

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _repository.signOut();

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _repository.sendPasswordResetEmail(email: email);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _repository.sendEmailVerification();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Reload user
  Future<void> reloadUser() async {
    try {
      await _repository.reloadUser();

      // Get updated user data
      final currentUser = _repository.currentUser;
      if (currentUser != null) {
        state = state.copyWith(user: currentUser);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  /// Update profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _repository.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Get updated user data
      final currentUser = _repository.currentUser;
      if (currentUser != null) {
        state = state.copyWith(user: currentUser, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _repository.deleteAccount();

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Mark onboarding as completed
  void completeOnboarding() {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(onboardingCompleted: true),
      );
    }
  }
}
