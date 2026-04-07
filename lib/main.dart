import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'core/config.dart';
import 'core/utils/logger.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router.dart';
import 'features/auth/data/auth_service.dart';

final _log = AppLogger('Main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment configuration before initializing any services.
  // Fails fast with a clear error if SUPABASE_URL or SUPABASE_ANON_KEY are missing.
  AppConfig.validate();

  // Global error boundary — catches all unhandled exceptions.
  FlutterError.onError = (details) {
    _log.error('FlutterError', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    _log.error('PlatformError', error, stack);
    return true;
  };

  // Run both I/O operations concurrently — they're independent.
  final prefsF = SharedPreferences.getInstance();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  final prefs = await prefsF;

  // Kick off the onboarding query as a background side-effect.
  // By the time the first router redirect fires this will already be in-flight
  // (or resolved), so the redirect returns instantly rather than blocking a frame.
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    warmOnboardingCache(user.id); // intentionally not awaited
  }

  runZonedGuarded(
    () => runApp(
      ProviderScope(
        overrides: [
          // ThemeNotifier reads from this provider and initializes synchronously —
          // no async SharedPreferences load, no extra rebuild after first frame.
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const UniGuideApp(),
      ),
    ),
    (error, stack) => _log.error('Uncaught zone error', error, stack),
  );
}

class UniGuideApp extends ConsumerStatefulWidget {
  const UniGuideApp({super.key});

  @override
  ConsumerState<UniGuideApp> createState() => _UniGuideAppState();
}

class _UniGuideAppState extends ConsumerState<UniGuideApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleDeepLinks();
  }

  Future<void> _handleDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _processLink(initialUri);
      }
    } catch (e, stackTrace) {
      _log.warning('Initial link error', e, stackTrace);
    }

    _appLinks.uriLinkStream.listen(
      (uri) async => await _processLink(uri),
      onError: (e) => _log.warning('Deep link stream error', e),
    );
  }

  Future<void> _processLink(Uri uri) async {
    // Validate deep link URL before processing.
    // Only allow our custom scheme and the expected host.
    // This prevents SSRF and malicious redirects.
    if (!_isValidDeepLink(uri)) {
      _log.warning('Rejected invalid deep link: $uri');
      return;
    }

    final error = await ref.read(authServiceProvider).completeSignIn(uri);
    if (error != null) {
      _log.warning('Sign-in error: $error');
    }
  }

  bool _isValidDeepLink(Uri uri) {
    // Allow only our custom scheme for auth redirects
    if (uri.scheme == 'uniguide') {
      return uri.host == 'login' || uri.host.isEmpty;
    }
    // Allow https for any future deep link expansion (with strict host validation)
    if (uri.scheme == 'https') {
      // Currently no https deep links expected - reject unless explicitly added
      return false;
    }
    // Reject any other schemes (file, http, ftp, etc.)
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'UniGuide',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
