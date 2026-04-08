class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xpceyjlalortjluwxzpg.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    // Development fallback - replace with your actual key in .env
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhwY2V5amxhbG9ydGpsdXd4enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNDUyMjEsImV4cCI6MjA5MDcyMTIyMX0.'
        'dnjir28UhUD8O0FsvR5j_gAo5ELkzHPdiG13PEZStyQ',
  );

  static void validate() {
    // Hardcoded for development — values are always set.
  }
}
