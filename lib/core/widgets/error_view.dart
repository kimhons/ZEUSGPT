import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../utils/error_handler.dart';
import 'zeus_button.dart';

/// Zeus-themed error view
///
/// Usage:
/// ```dart
/// ErrorView(
///   error: error,
///   onRetry: () {},
/// )
/// ```
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.error,
    super.key,
    this.onRetry,
    this.message,
    this.showDetails = false,
  });

  final dynamic error;
  final VoidCallback? onRetry;
  final String? message;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final errorMessage = message ?? ErrorHandler.getUserMessage(error);
    final isNetworkError = ErrorHandler.isNetworkError(error);
    final isAuthError = ErrorHandler.isAuthError(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Icon(
              _getErrorIcon(isNetworkError, isAuthError),
              size: 80,
              color: AppColors.error.withValues(alpha: 0.8),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Error title
            Text(
              _getErrorTitle(isNetworkError, isAuthError),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // Error message
            Text(
              errorMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
              textAlign: TextAlign.center,
            ),

            // Show error details if requested
            if (showDetails && error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.grey[800] : Colors.grey[200])
                      ?.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ZeusButton.primary(
                text: isNetworkError ? 'Check Connection' : 'Try Again',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(bool isNetworkError, bool isAuthError) {
    if (isNetworkError) return Icons.wifi_off;
    if (isAuthError) return Icons.lock_outline;
    return Icons.error_outline;
  }

  String _getErrorTitle(bool isNetworkError, bool isAuthError) {
    if (isNetworkError) return 'Connection Error';
    if (isAuthError) return 'Authentication Error';
    return 'Something Went Wrong';
  }
}

/// Inline error message widget
class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    required this.message,
    super.key,
    this.icon = Icons.error_outline,
    this.onDismiss,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.error,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Success message widget
class SuccessMessage extends StatelessWidget {
  const SuccessMessage({
    required this.message,
    super.key,
    this.icon = Icons.check_circle_outline,
    this.onDismiss,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.success,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.success,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Warning message widget
class WarningMessage extends StatelessWidget {
  const WarningMessage({
    required this.message,
    super.key,
    this.icon = Icons.warning_amber_outlined,
    this.onDismiss,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.warning,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Info message widget
class InfoMessage extends StatelessWidget {
  const InfoMessage({
    required this.message,
    super.key,
    this.icon = Icons.info_outline,
    this.onDismiss,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.info,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.info,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.info,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
