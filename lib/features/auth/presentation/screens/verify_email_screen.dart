import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/zeus_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/responsive.dart';

/// Verify email screen shown after signup
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isCheckingVerification = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  Timer? _autoCheckTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 5 seconds
    _startAutoCheck();
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startAutoCheck() {
    _autoCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkEmailVerification(showLoading: false),
    );
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60;
    });

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _resendCooldown--;
        });

        if (_resendCooldown == 0) {
          timer.cancel();
        }
      },
    );
  }

  Future<void> _checkEmailVerification({bool showLoading = true}) async {
    if (_isCheckingVerification) return;

    if (showLoading) {
      setState(() {
        _isCheckingVerification = true;
        _errorMessage = null;
      });
    }

    try {
      // TODO: Implement actual email verification check
      // final authNotifier = ref.read(authProvider.notifier);
      // await authNotifier.reloadUser();
      // final user = ref.read(authProvider).user;
      //
      // if (user != null && user.emailVerified) {
      //   _autoCheckTimer?.cancel();
      //   if (mounted) {
      //     context.go(AppRoutes.onboarding);
      //   }
      // }

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      if (showLoading) {
        setState(() {
          _errorMessage = 'Unable to check verification status. Please check your internet connection.';
        });
      }
    } finally {
      if (showLoading && mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // TODO: Implement actual resend verification email
      // final authNotifier = ref.read(authProvider.notifier);
      // await authNotifier.sendEmailVerification();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _successMessage = 'Verification email sent successfully!';
      });

      // Add announcement for screen readers
      if (mounted) {
        SemanticsService.announce(
          'Verification email sent successfully',
          TextDirection.ltr,
        );
      }

      _startResendCooldown();

      // Clear success message after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to send verification email. Please check your internet connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _handleLogout() {
    // TODO: Implement logout
    // final authNotifier = ref.read(authProvider.notifier);
    // authNotifier.signOut();

    context.go(AppRoutes.login);
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
                const SizedBox(height: AppSpacing.xxl * 2),

                // Email Icon
                Center(
                  child: Semantics(
                    label: 'Email verification pending',
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
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
                        Icons.mark_email_unread,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Title
                Text(
                  'Verify Your Email',
                  style: AppTextStyles.headline1().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  "We've sent a verification link to your email address. Please check your inbox and click the link to verify your account.",
                  style: AppTextStyles.body().copyWith(
                    color: isDark
                        ? AppColors.textSecondary(isDark)
                        : AppColors.textSecondary(!isDark),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Success message
                if (_successMessage != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: SuccessMessage(
                      message: _successMessage!,
                      onDismiss: () {
                        setState(() {
                          _successMessage = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

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

                // Check Verification Button
                ZeusButton.primary(
                  text: 'I\'ve Verified My Email',
                  icon: Icons.check_circle_outline,
                  onPressed: _isCheckingVerification
                      ? null
                      : () => _checkEmailVerification(),
                  isLoading: _isCheckingVerification,
                  fullWidth: true,
                  size: ZeusButtonSize.large,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Resend Email Button
                Semantics(
                  label: _resendCooldown > 0
                      ? 'Resend verification email. Available in $_resendCooldown seconds'
                      : 'Resend verification email',
                  button: true,
                  child: ZeusButton.outlined(
                    text: _resendCooldown > 0
                        ? 'Resend in ${_resendCooldown}s'
                        : 'Resend Verification Email',
                    icon: Icons.refresh,
                    onPressed: _resendCooldown > 0 || _isResending
                        ? null
                        : _resendVerificationEmail,
                    isLoading: _isResending,
                    fullWidth: true,
                    size: ZeusButtonSize.large,
                  ),
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

                // Sign Out Button
                ZeusButton.text(
                  text: 'Sign Out',
                  onPressed: _handleLogout,
                  fullWidth: true,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Help Text
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Semantics(
                            label: 'Help tips',
                            child: Icon(
                              Icons.info_outline,
                              color: AppColors.info,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Tips',
                            style: AppTextStyles.bodySmall().copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '• Check your spam or junk folder\n'
                        '• Verification link expires in 24 hours\n'
                        '• Contact support if you need help',
                        style: AppTextStyles.bodySmall().copyWith(
                          color: AppColors.info,
                          height: 1.5,
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
