import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';

/// Zeus-themed loading indicator
///
/// Usage:
/// ```dart
/// LoadingIndicator()
/// LoadingIndicator.overlay()
/// LoadingIndicator.page(message: 'Loading...')
/// ```
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 4,
  });

  /// Full-page loading overlay
  static Widget overlay({
    String? message,
    bool dismissible = false,
  }) =>
      _LoadingOverlay(message: message, dismissible: dismissible);

  /// Full-page loading with message
  static Widget page({
    String? message,
  }) =>
      _LoadingPage(message: message);

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Full-page loading overlay
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({
    this.message,
    this.dismissible = false,
  });

  final String? message;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: InkWell(
        onTap: dismissible ? () => Navigator.of(context).pop() : null,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LoadingIndicator(),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-page loading
class _LoadingPage extends StatelessWidget {
  const _LoadingPage({
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Zeus-branded loading with logo
class ZeusLoadingIndicator extends StatelessWidget {
  const ZeusLoadingIndicator({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Zeus logo with pulsing animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
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
                    Icons.flash_on,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart animation
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const LoadingIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
