import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/zeus_button.dart';
import '../../../../core/widgets/zeus_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';
import '../../../../core/utils/keyboard_navigation.dart';
import '../providers/auth_provider.dart';

/// Login screen with email/password and social auth
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Login');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(dynamic error) {
    // Map technical errors to user-friendly messages
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('email') && errorString.contains('invalid')) {
      return 'Please enter a valid email address.';
    } else if (errorString.contains('password') && errorString.contains('weak')) {
      return 'Your password is too weak. Please use a stronger password.';
    } else if (errorString.contains('user') && errorString.contains('not found')) {
      return 'No account found with this email. Please sign up first.';
    } else if (errorString.contains('wrong password') || errorString.contains('invalid credentials')) {
      return 'Incorrect email or password. Please try again.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('too many requests')) {
      return 'Too many login attempts. Please try again later.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> _handleLogin() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Clear previous errors
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use existing auth provider
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Navigate to home on success
        context.go(AppRoutes.home);
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use existing auth provider
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.signInWithGoogle();

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-In failed. ${_getErrorMessage(e)}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use existing auth provider
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.signInWithApple();

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Apple Sign-In failed. ${_getErrorMessage(e)}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ResponsiveCenter(
              maxWidth: context.isDesktop ? 500 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const SizedBox(height: AppSpacing.xxl),

                // Zeus Logo
                Center(
                  child: Semantics(
                    label: 'Zeus GPT Logo',
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: AppColors.zeusGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // App Name
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.headline1().copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Tagline
                Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.body().copyWith(
                    color: isDark
                        ? AppColors.textSecondary(isDark)
                        : AppColors.textSecondary(!isDark),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xxl * 2),

                // Welcome Text
                Text(
                  'Welcome Back',
                  style: AppTextStyles.headline2().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Sign in to continue your AI journey',
                  style: AppTextStyles.bodySmall().copyWith(
                    color: isDark
                        ? AppColors.textSecondary(isDark)
                        : AppColors.textSecondary(!isDark),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Error message
                if (_errorMessage != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: ErrorMessage(
                      message: _errorMessage!,
                      onDismiss: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Login Form
                KeyboardNavigableForm(
                  onSubmit: _handleLogin,
                  padding: EdgeInsets.zero,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      // Email Field
                      ZeusEmailField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        enabled: !_isLoading,
                        validator: Validators.email,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Password Field
                      ZeusPasswordField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        enabled: !_isLoading,
                        validator: (value) =>
                            Validators.password(value, requireStrong: false),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  context.push(AppRoutes.forgotPassword);
                                },
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.bodySmall().copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Login Button
                      ZeusButton.primary(
                        text: 'Sign In',
                        onPressed: _isLoading ? null : _handleLogin,
                        isLoading: _isLoading,
                        fullWidth: true,
                        size: ZeusButtonSize.large,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Divider
                      Semantics(
                        label: 'Or sign in with social account',
                        child: Row(
                          children: [
                            Expanded(
                              child: ExcludeSemantics(
                                child: Divider(
                                  color: (isDark
                                          ? AppColors.textSecondary(isDark)
                                          : AppColors.textSecondary(!isDark))
                                      .withOpacity(0.3),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Text(
                                'OR',
                                style: AppTextStyles.caption().copyWith(
                                  color: isDark
                                      ? AppColors.textSecondary(isDark)
                                      : AppColors.textSecondary(!isDark),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ExcludeSemantics(
                                child: Divider(
                                  color: (isDark
                                          ? AppColors.textSecondary(isDark)
                                          : AppColors.textSecondary(!isDark))
                                      .withOpacity(0.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Social Login Buttons
                      ZeusButton.outlined(
                        text: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        fullWidth: true,
                        size: ZeusButtonSize.large,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      ZeusButton.outlined(
                        text: 'Continue with Apple',
                        icon: Icons.apple,
                        onPressed: _isLoading ? null : _handleAppleSignIn,
                        fullWidth: true,
                        size: ZeusButtonSize.large,
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.body().copyWith(
                              color: isDark
                                  ? AppColors.textSecondary(isDark)
                                  : AppColors.textSecondary(!isDark),
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    context.push(AppRoutes.signup);
                                  },
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.body().copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
