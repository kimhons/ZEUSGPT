import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/utils/platform_helper.dart';
import 'core/responsive.dart';

// Platform-specific imports
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-specific initialization
  await _initializePlatform();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // TODO: Initialize Hive for local storage
  // await Hive.initFlutter();

  // TODO: Initialize secure storage
  // final secureStorage = FlutterSecureStorage();

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: ZeusGPTApp(),
    ),
  );
}

/// Initialize platform-specific settings
Future<void> _initializePlatform() async {
  // Mobile-specific initialization
  if (PlatformHelper.isMobile) {
    // Set preferred orientations (portrait only for mobile)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style for mobile
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // Web-specific initialization
  if (PlatformHelper.isWeb) {
    // Use path-based URLs instead of hash-based URLs
    setPathUrlStrategy();
  }

  // Desktop-specific initialization
  if (PlatformHelper.isDesktop) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: AppConstants.appName,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Initialize system tray
    await SystemTrayManager.instance.initialize();
  }
}

/// Root application widget
class ZeusGPTApp extends ConsumerStatefulWidget {
  const ZeusGPTApp({super.key});

  @override
  ConsumerState<ZeusGPTApp> createState() => _ZeusGPTAppState();
}

class _ZeusGPTAppState extends ConsumerState<ZeusGPTApp> {
  @override
  void initState() {
    super.initState();
    _registerTrayCallbacks();
  }

  void _registerTrayCallbacks() {
    if (PlatformHelper.isDesktop) {
      final trayManager = SystemTrayManager.instance;

      trayManager.registerCallback('show_window', () async {
        await windowManager.show();
        await windowManager.focus();
      });

      trayManager.registerCallback('about', () {
        // Will show about dialog when context is available
      });

      trayManager.registerCallback('quit', () async {
        await windowManager.close();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Watch theme mode provider
    // final themeMode = ref.watch(themeModeProvider);

    final router = ref.watch(appRouterProvider);

    return DesktopMenuWrapper(
      // Basic menu callbacks - more can be added as features are implemented
      onShowAbout: () => _showAboutDialog(context),

      child: MaterialApp.router(
        // App Info
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system, // TODO: Replace with provider

        // Router
        routerConfig: router,

        // Localization (TODO: Add l10n)
        // localizationsDelegates: AppLocalizations.localizationsDelegates,
        // supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '0.1.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: const [
        Text('The most powerful multi-LLM AI assistant.'),
        SizedBox(height: 8),
        Text('Access 500+ models in one beautiful app.'),
      ],
    );
  }
}

