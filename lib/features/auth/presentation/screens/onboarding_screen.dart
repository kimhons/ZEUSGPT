import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/zeus_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';

/// Onboarding screen with feature highlights
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.flash_on,
      title: '500+ AI Models',
      description:
          'Access the most powerful AI models including GPT-4, Claude, Gemini, and more - all in one place.',
      gradient: AppColors.zeusGradient,
    ),
    OnboardingPage(
      icon: Icons.chat_bubble_outline,
      title: 'Smart Conversations',
      description:
          'Engage in natural, context-aware conversations with advanced memory and web search capabilities.',
      gradient: AppColors.lightningGradient,
    ),
    OnboardingPage(
      icon: Icons.image_outlined,
      title: 'Create & Analyze Images',
      description:
          'Generate stunning images and analyze visuals with state-of-the-art AI vision models.',
      gradient: AppColors.thunderGradient,
    ),
    OnboardingPage(
      icon: Icons.workspace_premium,
      title: 'Premium Features',
      description:
          'Unlock unlimited messages, priority access, team collaboration, and advanced model capabilities.',
      gradient: AppColors.auroraGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Onboarding. Page 1 of ${_pages.length}. ${_pages[0].title}');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Announce to screen readers
    SemanticsService.announce(
      '${_pages[page].title}. Page ${page + 1} of ${_pages.length}',
      TextDirection.ltr,
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // TODO: Mark onboarding as completed in user preferences
    // final prefsNotifier = ref.read(preferencesProvider.notifier);
    // prefsNotifier.setOnboardingCompleted(true);

    // Navigate to home
    context.go(AppRoutes.home);
  }

  Widget _buildDesktopLayout(bool isDark) {
    return ResponsiveCenter(
      maxWidth: 1200,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            'Welcome to ${AppConstants.appName}',
            style: AppTextStyles.headline1().copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 48,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Experience the power of multiple AI models in one platform',
            style: AppTextStyles.bodyLarge().copyWith(
              color: isDark
                  ? AppColors.textSecondary(isDark)
                  : AppColors.textSecondary(!isDark),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl * 2),

          // Feature Grid (2x2)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.xxl,
                mainAxisSpacing: AppSpacing.xxl,
                childAspectRatio: 1.2,
              ),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _OnboardingFeatureCard(page: _pages[index]);
              },
            ),
          ),

          // Get Started Button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ZeusButton.primary(
              text: 'Get Started',
              icon: Icons.rocket_launch,
              onPressed: _completeOnboarding,
              fullWidth: false,
              size: ZeusButtonSize.large,
            ),
          ),
        ],
      ),
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
              ? _buildDesktopLayout(isDark)
              : Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.body().copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPageWidget(page: _pages[index]);
                  },
                ),
              ),

              // Page Indicators
              Semantics(
                label: 'Page ${_currentPage + 1} of ${_pages.length}',
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => ExcludeSemantics(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primary
                                : (isDark
                                        ? AppColors.textSecondary(isDark)
                                        : AppColors.textSecondary(!isDark))
                                    .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Next/Get Started Button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ZeusButton.primary(
                  text: _currentPage == _pages.length - 1
                      ? 'Get Started'
                      : 'Next',
                  icon: _currentPage == _pages.length - 1
                      ? Icons.rocket_launch
                      : Icons.arrow_forward,
                  onPressed: _nextPage,
                  fullWidth: true,
                  size: ZeusButtonSize.large,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop feature card widget
class _OnboardingFeatureCard extends StatelessWidget {
  const _OnboardingFeatureCard({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surface(isDark).withValues(alpha: 0.3)
            : AppColors.surface(!isDark).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: page.gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 48,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            page.title,
            style: AppTextStyles.headline3().copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          // Description
          Text(
            page.description,
            style: AppTextStyles.body().copyWith(
              color: isDark
                  ? AppColors.textSecondary(isDark)
                  : AppColors.textSecondary(!isDark),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Onboarding page data model
class OnboardingPage {
  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;
}

/// Individual onboarding page widget
class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Semantics(
            label: '${page.title} feature',
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl * 1.5),
              decoration: BoxDecoration(
                gradient: page.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl * 2),

          // Title
          Text(
            page.title,
            style: AppTextStyles.headline1().copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Description
          Text(
            page.description,
            style: AppTextStyles.bodyLarge().copyWith(
              color: isDark
                  ? AppColors.textSecondary(isDark)
                  : AppColors.textSecondary(!isDark),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
