import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/zeus_button.dart';
import '../../../../core/widgets/zeus_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/responsive.dart';
import '../../../../core/utils/keyboard_navigation.dart';

/// Forgot password screen for password reset
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
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
      // TODO: Implement actual password reset logic
      // final authNotifier = ref.read(authProvider.notifier);
      // await authNotifier.sendPasswordResetEmail(
      //   email: _emailController.text.trim(),
      // );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _emailSent = true;
      });
    } catch (e) {
      const errorMsg = 'Unable to send reset email. Please check the email address and try again.';
      setState(() {
        _errorMessage = errorMsg;
      });

      // Announce error to screen readers
      SemanticsService.announce(
        errorMsg,
        TextDirection.ltr,
      );
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
                const SizedBox(height: AppSpacing.lg),

                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color:
                          isDark ? AppColors.textPrimary(isDark) : AppColors.textPrimary(!isDark),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            context.pop();
                          },
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Icon
                Center(
                  child: Semantics(
                    label: _emailSent ? 'Email sent successfully' : 'Reset your password',
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Title
                Text(
                  _emailSent ? 'Check Your Email' : 'Forgot Password?',
                  style: AppTextStyles.headline2().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  _emailSent
                      ? "We've sent a password reset link to ${_emailController.text}. Check your inbox and follow the instructions."
                      : "No worries! Enter your email address and we'll send you a link to reset your password.",
                  style: AppTextStyles.body().copyWith(
                    color: isDark
                        ? AppColors.textSecondary(isDark)
                        : AppColors.textSecondary(!isDark),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xxl),

                if (!_emailSent) ...[
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

                  // Reset Password Form
                  KeyboardNavigableForm(
                    onSubmit: _handleResetPassword,
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
                          hint: 'Enter your email address',
                          enabled: !_isLoading,
                          validator: Validators.email,
                          autofocus: true,
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Reset Password Button
                        ZeusButton.primary(
                          text: 'Send Reset Link',
                          onPressed: _isLoading ? null : _handleResetPassword,
                          isLoading: _isLoading,
                          fullWidth: true,
                          size: ZeusButtonSize.large,
                          icon: Icons.send,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Back to Login
                        ZeusButton.text(
                          text: 'Back to Login',
                          onPressed: _isLoading
                              ? null
                              : () {
                                  context.pop();
                                },
                          fullWidth: true,
                        ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Email Sent Success
                  Column(
                    children: [
                      SuccessMessage(
                        message: 'Password reset email sent successfully!',
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Resend Email Button
                      ZeusButton.outlined(
                        text: 'Resend Email',
                        icon: Icons.refresh,
                        onPressed: () {
                          setState(() {
                            _emailSent = false;
                            _errorMessage = null;
                          });
                        },
                        fullWidth: true,
                        size: ZeusButtonSize.large,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Back to Login
                      ZeusButton.text(
                        text: 'Back to Login',
                        onPressed: () {
                          context.pop();
                        },
                        fullWidth: true,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                // Help Text
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        label: 'Help information',
                        child: Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          "Didn't receive the email? Check your spam folder or contact support.",
                          style: AppTextStyles.bodySmall().copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
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
