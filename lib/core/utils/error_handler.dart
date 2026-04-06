import 'package:flutter/foundation.dart';

/// Returns a message safe to display in a [SnackBar].
///
/// In debug builds the raw error is shown for developer convenience.
/// In release builds a generic message is returned to avoid leaking internal
/// details (Supabase URLs, SQL errors, stack traces).
String userFriendlyMessage(Object error) {
  if (kDebugMode) return error.toString();
  return 'Something went wrong. Please try again.';
}
