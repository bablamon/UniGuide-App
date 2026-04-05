import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'core/config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router.dart';
import 'features/auth/data/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate build-time configuration before anything else.
  AppConfig.assertValid();

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

  runApp(ProviderScope(
    overrides: [
      // ThemeNotifier reads from this provider and initializes synchronously —
      // no async SharedPreferences load, no extra rebuild after first frame.
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const UniGuideApp(),
  ));
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
    } catch (e) {
      debugPrint('Initial link error: $e');
    }

    _appLinks.uriLinkStream.listen(
      (uri) async => await _processLink(uri),
      onError: (e) => debugPrint('Deep link stream error: $e'),
    );
  }

  Future<void> _processLink(Uri uri) async {
    final error = await ref.read(authServiceProvider).completeSignIn(uri);
    if (error != null) {
      debugPrint('Sign-in error: $error');
    }
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
