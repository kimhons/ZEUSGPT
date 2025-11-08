import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Empty conversation state widget
class EmptyConversationState extends StatelessWidget {
  const EmptyConversationState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zeus logo with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.zeusGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flash_on,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Welcome text
            Text(
              'Welcome to ZeusGPT',
              style: AppTextStyles.h2().copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              'Start a conversation with 500+ AI models',
              style: AppTextStyles.bodyLarge().copyWith(
                color: isDark
                    ? AppColors.textSecondary(isDark)
                    : AppColors.textSecondary(!isDark),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Feature highlights
            _buildFeatureCard(
              context,
              icon: Icons.psychology,
              title: 'Multiple AI Models',
              description: 'Access GPT-4, Claude, Gemini, and 500+ more',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFeatureCard(
              context,
              icon: Icons.image,
              title: 'Image Generation',
              description: 'Create stunning images with AI',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFeatureCard(
              context,
              icon: Icons.code,
              title: 'Code Assistant',
              description: 'Get help with coding and debugging',
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Start chat button
            ElevatedButton.icon(
              onPressed: () {
                context.push('/home/new-chat');
              },
              icon: const Icon(Icons.add),
              label: const Text('Start New Chat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Explore models button
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to models screen
              },
              icon: const Icon(Icons.explore),
              label: const Text('Explore AI Models'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surface(false)
            : AppColors.surface(true).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.zeusGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
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
      ),
    );
  }
}
