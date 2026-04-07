// App configuration for Supabase.
//
// SECURITY: Credentials are loaded from Flutter --dart-define flags at build time.
// This prevents hard-coded secrets in source control.
//
// Usage:
//   flutter run --dart-define-from-file=.env
//   flutter build apk --dart-define-from-file=.env
//   flutter build ios --dart-define-from-file=.env
//
// The anon key is a public client-side key - security is enforced by
// Row Level Security (RLS) policies on the database, not by hiding this key.
// The service_role key must NEVER be embedded in client code.
//
// Key rotation procedure:
//   1. Generate new keys in Supabase Dashboard -> Settings -> API
//   2. Update your .env file with the new values
//   3. Rebuild and redeploy the app
//   4. Revoke the old keys in the Supabase Dashboard
class AppConfig {
  // Read from --dart-define at build time, with fallback for development.
  // If you see this fallback URL in production, your build is misconfigured.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    // Production should provide this via --dart-define-from-file=.env
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    // Development fallback - replace with your actual key in .env
    defaultValue: '',
  );

  /// Validate that configuration values are set and non-empty.
  /// Call this during app initialization to fail fast if env vars are missing.
  static void validate() {
    if (supabaseUrl.isEmpty || supabaseUrl.contains('YOUR_PROJECT_ID')) {
      throw StateError(
        'SUPABASE_URL is not configured. '
        'Build with --dart-define-from-file=.env or set SUPABASE_URL.',
      );
    }
    if (supabaseAnonKey.isEmpty || supabaseAnonKey.contains('your_anon_key')) {
      throw StateError(
        'SUPABASE_ANON_KEY is not configured. '
        'Build with --dart-define-from-file=.env or set SUPABASE_ANON_KEY.',
      );
    }
  }
}
