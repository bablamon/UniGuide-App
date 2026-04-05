import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeKey = 'isDarkMode';

// Injected as an override in ProviderScope — value is pre-loaded in main()
// before runApp so ThemeNotifier initializes synchronously with the correct mode.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in ProviderScope'),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._prefs)
      : super((_prefs.getBool(_themeKey) ?? false) ? ThemeMode.dark : ThemeMode.light);

  final SharedPreferences _prefs;

  Future<void> toggle() async {
    final nowDark = state != ThemeMode.dark;
    state = nowDark ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setBool(_themeKey, nowDark);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref.watch(sharedPreferencesProvider));
});
