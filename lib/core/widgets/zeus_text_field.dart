import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../constants/app_spacing.dart';

/// Zeus-themed text input field with validation
///
/// Usage:
/// ```dart
/// ZeusTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   validator: Validators.email,
///   onChanged: (value) {},
/// )
/// ```
class ZeusTextField extends StatefulWidget {
  const ZeusTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.focusNode,
    this.filled = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool filled;

  @override
  State<ZeusTextField> createState() => _ZeusTextFieldState();
}

class _ZeusTextFieldState extends State<ZeusTextField> {
  bool _obscureText = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _errorText = widget.errorText;
  }

  @override
  void didUpdateWidget(covariant ZeusTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
    }
  }

  void _validate(String? value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText && _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          autofocus: widget.autofocus,
          autocorrect: widget.autocorrect,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: _errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _errorText != null
                        ? AppColors.error
                        : (isDark
                            ? AppColors.textSecondary(isDark)
                            : AppColors.textSecondary(!isDark)),
                  )
                : null,
            suffixIcon: _buildSuffixIcon(isDark),
            filled: widget.filled,
            fillColor: isDark
                ? AppColors.surface(true).withValues(alpha: 0.5)
                : AppColors.surface(false),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.border(true)
                    : AppColors.border(false),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.border(true)
                    : AppColors.border(false),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.border(true).withValues(alpha: 0.5)
                    : AppColors.border(false).withValues(alpha: 0.5),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          onChanged: (value) {
            if (widget.validator != null) {
              _validate(value);
            }
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(bool isDark) {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: isDark
              ? AppColors.textSecondary(isDark)
              : AppColors.textSecondary(!isDark),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return null;
  }
}

/// Search text field with search icon
class ZeusSearchField extends StatelessWidget {
  const ZeusSearchField({
    required this.onChanged,
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final void Function(String) onChanged;
  final void Function(String)? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ZeusTextField(
      controller: controller,
      hint: hint,
      prefixIcon: Icons.search,
      suffixIcon: controller != null && controller!.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller!.clear();
                onChanged('');
              },
            )
          : null,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      autofocus: autofocus,
    );
  }
}

/// Email text field with email validation
class ZeusEmailField extends StatelessWidget {
  const ZeusEmailField({
    super.key,
    this.controller,
    this.label = 'Email',
    this.hint = 'Enter your email',
    this.validator,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final String? errorText;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ZeusTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      validator: validator,
      errorText: errorText,
      onChanged: onChanged,
      enabled: enabled,
      autofocus: autofocus,
    );
  }
}

/// Password text field with visibility toggle
class ZeusPasswordField extends StatelessWidget {
  const ZeusPasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.validator,
    this.errorText,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final String? errorText;
  final void Function(String)? onChanged;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ZeusTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.lock_outlined,
      obscureText: true,
      textInputAction: textInputAction,
      autocorrect: false,
      validator: validator,
      errorText: errorText,
      onChanged: onChanged,
      enabled: enabled,
      autofocus: autofocus,
    );
  }
}
