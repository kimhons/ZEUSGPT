import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_spacing.dart';

/// Zeus-themed button with multiple variants
///
/// Usage:
/// ```dart
/// ZeusButton.primary(
///   text: 'Submit',
///   onPressed: () {},
/// )
///
/// ZeusButton.secondary(
///   text: 'Cancel',
///   onPressed: () {},
/// )
/// ```
class ZeusButton extends StatelessWidget {
  const ZeusButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.variant = ZeusButtonVariant.primary,
    this.size = ZeusButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.fullWidth = false,
    this.loadingText,
  });

  /// Primary button (Zeus Blue)
  factory ZeusButton.primary({
    required String text,
    required VoidCallback? onPressed,
    Key? key,
    ZeusButtonSize size = ZeusButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool fullWidth = false,
    String? loadingText,
  }) =>
      ZeusButton(
        text: text,
        onPressed: onPressed,
        key: key,
        variant: ZeusButtonVariant.primary,
        size: size,
        isLoading: isLoading,
        isDisabled: isDisabled,
        icon: icon,
        fullWidth: fullWidth,
        loadingText: loadingText,
      );

  /// Secondary button (Thunder Purple)
  factory ZeusButton.secondary({
    required String text,
    required VoidCallback? onPressed,
    Key? key,
    ZeusButtonSize size = ZeusButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool fullWidth = false,
    String? loadingText,
  }) =>
      ZeusButton(
        text: text,
        onPressed: onPressed,
        key: key,
        variant: ZeusButtonVariant.secondary,
        size: size,
        isLoading: isLoading,
        isDisabled: isDisabled,
        icon: icon,
        fullWidth: fullWidth,
        loadingText: loadingText,
      );

  /// Outlined button
  factory ZeusButton.outlined({
    required String text,
    required VoidCallback? onPressed,
    Key? key,
    ZeusButtonSize size = ZeusButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool fullWidth = false,
    String? loadingText,
  }) =>
      ZeusButton(
        text: text,
        onPressed: onPressed,
        key: key,
        variant: ZeusButtonVariant.outlined,
        size: size,
        isLoading: isLoading,
        isDisabled: isDisabled,
        icon: icon,
        fullWidth: fullWidth,
        loadingText: loadingText,
      );

  /// Text button (no background)
  factory ZeusButton.text({
    required String text,
    required VoidCallback? onPressed,
    Key? key,
    ZeusButtonSize size = ZeusButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool fullWidth = false,
    String? loadingText,
  }) =>
      ZeusButton(
        text: text,
        onPressed: onPressed,
        key: key,
        variant: ZeusButtonVariant.text,
        size: size,
        isLoading: isLoading,
        isDisabled: isDisabled,
        icon: icon,
        fullWidth: fullWidth,
        loadingText: loadingText,
      );

  /// Danger/destructive button (red)
  factory ZeusButton.danger({
    required String text,
    required VoidCallback? onPressed,
    Key? key,
    ZeusButtonSize size = ZeusButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool fullWidth = false,
    String? loadingText,
  }) =>
      ZeusButton(
        text: text,
        onPressed: onPressed,
        key: key,
        variant: ZeusButtonVariant.danger,
        size: size,
        isLoading: isLoading,
        isDisabled: isDisabled,
        icon: icon,
        fullWidth: fullWidth,
        loadingText: loadingText,
      );

  /// Success button (green)
  factory ZeusButton.success({
    required String text,
    required VoidCallback? onPressed,
    Key? key,
    ZeusButtonSize size = ZeusButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    IconData? icon,
    bool fullWidth = false,
    String? loadingText,
  }) =>
      ZeusButton(
        text: text,
        onPressed: onPressed,
        key: key,
        variant: ZeusButtonVariant.success,
        size: size,
        isLoading: isLoading,
        isDisabled: isDisabled,
        icon: icon,
        fullWidth: fullWidth,
        loadingText: loadingText,
      );

  final String text;
  final VoidCallback? onPressed;
  final ZeusButtonVariant variant;
  final ZeusButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool fullWidth;
  final String? loadingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isEffectivelyDisabled = isDisabled || isLoading || onPressed == null;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isDark, isEffectivelyDisabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isDark, bool disabled) {
    final buttonStyle = _getButtonStyle(context, isDark, disabled);

    final content = _buildContent(context, isDark);

    switch (variant) {
      case ZeusButtonVariant.primary:
      case ZeusButtonVariant.secondary:
      case ZeusButtonVariant.danger:
      case ZeusButtonVariant.success:
        return ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: buttonStyle,
          child: content,
        );

      case ZeusButtonVariant.outlined:
        return OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: buttonStyle,
          child: content,
        );

      case ZeusButtonVariant.text:
        return TextButton(
          onPressed: disabled ? null : onPressed,
          style: buttonStyle,
          child: content,
        );
    }
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    final displayText = isLoading ? (loadingText ?? text) : text;

    if (isLoading && icon == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getContentColor(context, isDark),
              ),
            ),
          ),
          if (loadingText != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(displayText),
          ],
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: _getIconSize(),
              height: _getIconSize(),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getContentColor(context, isDark),
                ),
              ),
            )
          else
            Icon(icon, size: _getIconSize()),
          const SizedBox(width: AppSpacing.sm),
          Text(displayText),
        ],
      );
    }

    return Text(displayText);
  }

  ButtonStyle _getButtonStyle(
    BuildContext context,
    bool isDark,
    bool disabled,
  ) {
    final backgroundColor = _getBackgroundColor(context, isDark, disabled);
    final foregroundColor = _getContentColor(context, isDark);
    final borderColor = _getBorderColor(context, isDark, disabled);

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (variant == ZeusButtonVariant.text) return Colors.transparent;
        if (variant == ZeusButtonVariant.outlined) return Colors.transparent;
        if (disabled) return backgroundColor?.withOpacity(0.5);
        if (states.contains(WidgetState.pressed)) {
          return backgroundColor?.withOpacity(0.8);
        }
        return backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      side: variant == ZeusButtonVariant.outlined
          ? WidgetStateProperty.all(
              BorderSide(color: borderColor, width: 2),
            )
          : null,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      padding: WidgetStateProperty.all(_getPadding()),
      elevation: variant == ZeusButtonVariant.text ||
              variant == ZeusButtonVariant.outlined
          ? WidgetStateProperty.all(0)
          : WidgetStateProperty.resolveWith<double>((states) {
              if (states.contains(WidgetState.pressed)) return 0;
              return 2;
            }),
    );
  }

  Color? _getBackgroundColor(
    BuildContext context,
    bool isDark,
    bool disabled,
  ) {
    if (disabled) {
      return isDark ? Colors.grey[800] : Colors.grey[300];
    }

    switch (variant) {
      case ZeusButtonVariant.primary:
        return AppColors.primary;
      case ZeusButtonVariant.secondary:
        return AppColors.secondary;
      case ZeusButtonVariant.danger:
        return AppColors.error;
      case ZeusButtonVariant.success:
        return AppColors.success;
      case ZeusButtonVariant.outlined:
      case ZeusButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getContentColor(BuildContext context, bool isDark) {
    switch (variant) {
      case ZeusButtonVariant.primary:
      case ZeusButtonVariant.secondary:
      case ZeusButtonVariant.danger:
      case ZeusButtonVariant.success:
        return Colors.white;
      case ZeusButtonVariant.outlined:
        return AppColors.primary;
      case ZeusButtonVariant.text:
        return AppColors.primary;
    }
  }

  Color _getBorderColor(BuildContext context, bool isDark, bool disabled) {
    if (disabled) {
      return isDark ? Colors.grey[700]! : Colors.grey[400]!;
    }
    return AppColors.primary;
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ZeusButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case ZeusButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
      case ZeusButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        );
    }
  }

  double _getHeight() {
    switch (size) {
      case ZeusButtonSize.small:
        return AppSpacing.buttonHeightSmall;
      case ZeusButtonSize.medium:
        return AppSpacing.buttonHeightMedium;
      case ZeusButtonSize.large:
        return AppSpacing.buttonHeightLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ZeusButtonSize.small:
        return AppSpacing.iconSizeSmall;
      case ZeusButtonSize.medium:
        return AppSpacing.iconSizeMedium;
      case ZeusButtonSize.large:
        return AppSpacing.iconSizeLarge;
    }
  }
}

/// Button variant enum
enum ZeusButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  danger,
  success,
}

/// Button size enum
enum ZeusButtonSize {
  small,
  medium,
  large,
}
