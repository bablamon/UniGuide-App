import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);
});

class AuthService {
  final _auth = Supabase.instance.client.auth;

  Future<String?> sendMagicLink(String email) async {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) return 'Please enter your email address.';

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
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
      debugPrint('completeSignIn (non-auth link): $e');
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
