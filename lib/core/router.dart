import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/logger.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/check_email_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/wiki/presentation/screens/wiki_screen.dart';
import '../features/wiki/presentation/screens/wiki_article_screen.dart';
import '../features/qa/presentation/screens/qa_screen.dart';
import '../features/qa/presentation/screens/qa_detail_screen.dart';
import '../features/qa/presentation/screens/ask_question_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/my_questions_screen.dart';
import '../features/profile/presentation/screens/bookmarks_screen.dart';
import '../shell/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(
    Supabase.instance.client.auth.onAuthStateChange,
  );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) async {
      final user = Supabase.instance.client.auth.currentUser;
      final isAuth = user != null;
      final isLoginRoute =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/check-email');

      if (!isAuth && !isLoginRoute) return '/login';
      if (isAuth && isLoginRoute) {
        final done = await _isOnboardingComplete(user.id);
        return done ? '/wiki' : '/onboarding';
      }
      if (isAuth && state.matchedLocation == '/') {
        final done = await _isOnboardingComplete(user.id);
        return done ? '/wiki' : '/onboarding';
      }
      return null;
    },

    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/wiki'),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/check-email',
        builder: (_, state) => CheckEmailScreen(email: state.extra as String),
      ),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const WikiScreen()),
          GoRoute(
            path: '/wiki',
            builder: (_, __) => const WikiScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    WikiArticleScreen(articleId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/qa',
            builder: (_, __) => const QAScreen(),
            routes: [
              GoRoute(path: 'ask', builder: (_, __) => const AskQuestionScreen()),
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    QADetailScreen(questionId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'my-questions',
                builder: (_, __) => const MyQuestionsScreen(),
              ),
              GoRoute(
                path: 'bookmarks',
                builder: (_, __) => const BookmarksScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Future-based cache — if two callers ask simultaneously they share the same
// in-flight request rather than firing duplicate network calls.
// Cleared on sign-in / sign-out so a fresh check runs at the start of each session.
final _onboardingFutures = <String, Future<bool>>{};

Future<bool> _isOnboardingComplete(String uid) =>
    _onboardingFutures.putIfAbsent(uid, () async {
      try {
        final data = await Supabase.instance.client
            .from('users')
            .select('onboarding_complete')
            .eq('id', uid)
            .single();
        return data['onboarding_complete'] == true;
      } catch (e, stackTrace) {
        AppLogger('Router').warning('onboarding check failed for $uid', e, stackTrace);
        // Remove on failure so the next call retries rather than caching an error
        _onboardingFutures.remove(uid);
        return false;
      }
    });

// Called from main() to kick off the query concurrently with app init,
// so by the time the first router redirect runs the result is already cached.
Future<void> warmOnboardingCache(String uid) => _isOnboardingComplete(uid);

class _RouterRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  _RouterRefreshNotifier(Stream<AuthState> stream) {
    _subscription = stream.listen((authState) {
      // Only trigger a redirect re-evaluation on meaningful session changes.
      // Ignoring TOKEN_REFRESHED prevents a network call every time Supabase
      // silently refreshes the JWT in the background.
      switch (authState.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userUpdated:
        case AuthChangeEvent.initialSession:
          _onboardingFutures.clear();
          notifyListeners();
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
