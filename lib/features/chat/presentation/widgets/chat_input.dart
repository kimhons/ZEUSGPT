import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Chat input widget
class ChatInput extends StatefulWidget {
  const ChatInput({
    required this.controller,
    required this.onSend,
    this.isLoading = false,
    this.onAttachment,
    this.onVoice,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final VoidCallback? onAttachment;
  final VoidCallback? onVoice;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface(false) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            if (widget.onAttachment != null)
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: widget.isLoading ? null : widget.onAttachment,
                tooltip: 'Attach file',
              ),

            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  enabled: !widget.isLoading,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.bodyMedium().copyWith(
                      color: Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium(),
                  onSubmitted: (_) {
                    if (_hasText && !widget.isLoading) {
                      widget.onSend();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Voice/Send button
            if (widget.isLoading)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              )
            else if (_hasText)
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: widget.onSend,
                  tooltip: 'Send message',
                  padding: EdgeInsets.zero,
                ),
              )
            else if (widget.onVoice != null)
              IconButton(
                icon: const Icon(Icons.mic),
                onPressed: widget.onVoice,
                tooltip: 'Voice input',
              ),
          ],
        ),
      ),
    );
  }
}
