import 'dart:developer' as dev;

/// Lightweight structured logger wrapping [dart:developer]'s [log].
///
/// Levels mirror common conventions:
///   debug = 500, info = 800, warning = 900, error = 1000.
class AppLogger {
  AppLogger(this.name);

  final String name;

  void debug(String message) =>
      dev.log(message, name: name, level: 500);

  void info(String message) =>
      dev.log(message, name: name, level: 800);

  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      dev.log(message, name: name, level: 900, error: error, stackTrace: stackTrace);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      dev.log(message, name: name, level: 1000, error: error, stackTrace: stackTrace);
}
