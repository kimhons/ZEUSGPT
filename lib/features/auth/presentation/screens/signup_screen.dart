import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/zeus_button.dart';
import '../../../../core/widgets/zeus_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/responsive.dart';
import '../../../../core/utils/keyboard_navigation.dart';
import '../providers/auth_provider.dart';

/// Sign up screen with email/password registration
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _acceptedTerms = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Sign Up');
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
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

    // Check terms acceptance
    if (!_acceptedTerms) {
      setState(() {
        _errorMessage = 'Please accept the Terms of Service and Privacy Policy';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.signUpWithEmailAndPassword(
        displayName: _displayNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Navigate to verify email screen
        context.go(AppRoutes.verifyEmail);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to create account. Please check your information and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.signInWithGoogle();

      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google Sign-Up failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.signInWithApple();

      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Apple Sign-Up failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildInfoPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.flash_on,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Join Zeus GPT',
            style: AppTextStyles.headline1().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFeatureItem(
            Icons.chat_bubble_outline,
            'Multi-AI Chat',
            'Access GPT-4, Claude, Gemini, and more in one place',
            isDark,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFeatureItem(
            Icons.security_outlined,
            'Secure & Private',
            'Your data is encrypted and never shared',
            isDark,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFeatureItem(
            Icons.speed_outlined,
            'Lightning Fast',
            'Optimized for speed and performance',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.bodySmall().copyWith(
                  color: isDark
                      ? AppColors.textSecondary(isDark)
                      : AppColors.textSecondary(!isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = context.isDesktop;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
        ),
        child: SafeArea(
          child: isDesktop
              ? Row(
                  children: [
                    // Left: Form
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: ResponsiveCenter(
                          maxWidth: 500,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _buildFormContent(isDark),
                          ),
                        ),
                      ),
                    ),
                    // Right: Info Panel
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.zeusGradient,
                        ),
                        child: _buildInfoPanel(isDark),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildFormContent(isDark),
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildFormContent(bool isDark) {
    return [
                const SizedBox(height: AppSpacing.lg),

                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: SemanticIconButton(
                    icon: Icons.arrow_back,
                    label: 'Go back',
                    color: isDark
                        ? AppColors.textPrimary(isDark)
                        : AppColors.textPrimary(!isDark),
                    onPressed: _isLoading
                        ? null
                        : () {
                            context.pop();
                          },
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Zeus Logo
                Center(
                  child: Semantics(
                    label: 'Zeus GPT Logo',
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: AppColors.zeusGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Welcome Text
                Text(
                  'Create Account',
                  style: AppTextStyles.headline2().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Join thousands of users experiencing the power of AI',
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

                // Sign Up Form
                KeyboardNavigableForm(
                  onSubmit: _handleSignUp,
                  padding: EdgeInsets.zero,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      // Display Name Field
                      ZeusTextField(
                        controller: _displayNameController,
                        label: 'Display Name',
                        hint: 'Enter your name',
                        prefixIcon: Icons.person_outline,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.next,
                        validator: Validators.displayName,
                      ),

                      const SizedBox(height: AppSpacing.lg),

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
                        hint: 'Must be at least 8 characters with uppercase, lowercase, and number',
                        enabled: !_isLoading,
                        validator: (value) =>
                            Validators.password(value, requireStrong: true),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Confirm Password Field
                      ZeusPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        enabled: !_isLoading,
                        validator: (value) => Validators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        textInputAction: TextInputAction.done,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Terms and Conditions Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _acceptedTerms = value ?? false;
                                    });
                                  },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.sm,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodySmall(),
                                  children: [
                                    const TextSpan(
                                      text: 'I agree to the ',
                                    ),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // TODO: Navigate to Terms of Service
                                        },
                                    ),
                                    const TextSpan(
                                      text: ' and ',
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // TODO: Navigate to Privacy Policy
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Sign Up Button
                      ZeusButton.primary(
                        text: 'Create Account',
                        onPressed: _isLoading ? null : _handleSignUp,
                        isLoading: _isLoading,
                        fullWidth: true,
                        size: ZeusButtonSize.large,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: (isDark
                                      ? AppColors.textSecondary(isDark)
                                      : AppColors.textSecondary(!isDark))
                                  .withValues(alpha: 0.3),
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
                            child: Divider(
                              color: (isDark
                                      ? AppColors.textSecondary(isDark)
                                      : AppColors.textSecondary(!isDark))
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Social Sign Up Buttons
                      ZeusButton.outlined(
                        text: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        onPressed: _isLoading ? null : _handleGoogleSignUp,
                        fullWidth: true,
                        size: ZeusButtonSize.large,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      ZeusButton.outlined(
                        text: 'Continue with Apple',
                        icon: Icons.apple,
                        onPressed: _isLoading ? null : _handleAppleSignUp,
                        fullWidth: true,
                        size: ZeusButtonSize.large,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
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
                                    context.pop();
                                  },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign In',
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
    ];
  }
}
