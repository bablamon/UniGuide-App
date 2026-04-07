import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/rate_limiter.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});

class AuthService {
  final _auth = Supabase.instance.client.auth;
  final _log = AppLogger('AuthService');

  Future<String?> sendMagicLink(String email) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) return 'Please enter your email address.';

    if (!isValidEmail(trimmed)) {
      return 'Please enter a valid email address.';
    }

    // Check rate limit before attempting to send.
    // Use email as the key since user isn't authenticated yet.
    final rateLimitResult = rateLimiter.check(
      trimmed,
      'auth_magic_link',
      RateLimits.authMagicLink,
    );
    if (!rateLimitResult.allowed) {
      return formatRetryMessage(rateLimitResult.retryAfter);
    }

    try {
      await _auth.signInWithOtp(
        email: trimmed,
        emailRedirectTo: 'uniguide://login',
      );
      return null;
    } on AuthException catch (e) {
      return _mapError(e.message);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> completeSignIn(Uri uri) async {
    try {
      await _auth.getSessionFromUrl(uri);
      return null;
    } on AuthException catch (e) {
      return _mapError(e.message);
    } catch (e) {
      // Not all deep links are auth links — ignore silently
      _log.debug('completeSignIn (non-auth link): $e');
      return null;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'uniguide://login',
      );
      return null;
    } on AuthException catch (e) {
      return _mapError(e.message);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<void> signOut() async => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  String _mapError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('too many') || lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment.';
    }
    if (lower.contains('expired')) {
      return 'This link has expired. Please request a new one.';
    }
    if (lower.contains('invalid action') || lower.contains('already used')) {
      return 'This link is invalid or already used.';
    }
    if (kDebugMode) return message;
    return 'Something went wrong. Please try again.';
  }
}
