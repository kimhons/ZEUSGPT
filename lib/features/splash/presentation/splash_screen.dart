import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/logger_service.dart';
import '../../../core/responsive.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// Animated splash screen with Zeus branding
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Scale animation for logo
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    // Fade animation for text
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
    ));

    // Glow animation for logo
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _controller.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Firebase is already initialized in main.dart
      LoggerService.i('Starting app initialization...');

      // Initialize logger service
      LoggerService.init();

      // Note: Hive initialization is handled in main.dart if needed
      // For now, we'll use Firebase Firestore for all data storage

      // Check auth state
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;

      LoggerService.i('Auth state checked: ${isAuthenticated ? "authenticated" : "not authenticated"}');

      // Wait minimum 3 seconds for splash animation
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Navigate based on auth state
      if (isAuthenticated) {
        LoggerService.i('Navigating to home screen');
        context.go(AppRoutes.home);
      } else {
        LoggerService.i('Navigating to login screen');
        context.go(AppRoutes.login);
      }
    } catch (e, stackTrace) {
      LoggerService.e('Failed to initialize app', error: e, stackTrace: stackTrace);

      // Handle initialization errors
      if (mounted) {
        // For now, navigate to login as fallback
        // In production, you might want a dedicated error screen
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    // Responsive sizing
    final logoSize = isDesktop ? 120.0 : (isTablet ? 110.0 : 100.0);
    final titleSize = isDesktop ? 56.0 : (isTablet ? 52.0 : 48.0);
    final taglineSize = isDesktop ? 18.0 : (isTablet ? 17.0 : 16.0);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: AppColors.zeusGradient,
          ),
          child: Stack(
          children: [
            // Background lightning effect
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LightningPainter(
                      animationValue: _glowAnimation.value,
                    ),
                  );
                },
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Zeus logo
                  Semantics(
                    label: 'Zeus GPT Logo',
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(
                                    0.3 * _glowAnimation.value,
                                  ),
                                  blurRadius: 40 * _glowAnimation.value,
                                  spreadRadius: 10 * _glowAnimation.value,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.flash_on,
                              size: logoSize,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // App name with fade animation
                  Semantics(
                    label: 'Zeus GPT - Multi-AI Chat Platform',
                    header: true,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Tagline with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        fontSize: taglineSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl * 2),

                  // Loading indicator
                  Semantics(
                    label: 'Loading application',
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Version number at bottom
            Positioned(
              bottom: AppSpacing.xl,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'v${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Custom painter for lightning effect
class LightningPainter extends CustomPainter {
  LightningPainter({required this.animationValue});

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1 * animationValue)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw multiple lightning bolts
    _drawLightning(canvas, size, paint, 0.3, 0.2);
    _drawLightning(canvas, size, paint, 0.7, 0.3);
    _drawLightning(canvas, size, paint, 0.5, 0.1);
  }

  void _drawLightning(
    Canvas canvas,
    Size size,
    Paint paint,
    double xOffset,
    double yOffset,
  ) {
    final path = Path();
    final startX = size.width * xOffset;
    final startY = size.height * yOffset;

    path.moveTo(startX, startY);
    path.lineTo(startX - 20, startY + 50);
    path.lineTo(startX + 10, startY + 50);
    path.lineTo(startX - 15, startY + 100);
    path.lineTo(startX + 15, startY + 100);
    path.lineTo(startX - 10, startY + 150);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LightningPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
