/// App configuration sourced from compile-time `--dart-define` flags.
///
/// Build with:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Call once at startup before [Supabase.initialize].
  static void assertValid() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing Supabase config. '
        'Pass --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... '
        'when building.',
      );
    }
  }
}
