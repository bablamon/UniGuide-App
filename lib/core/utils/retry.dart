/// Retries an async operation with exponential back-off.
///
/// Only use for **read** operations — never retry mutations (inserts, upvotes)
/// to avoid duplicates.
Future<T> retryAsync<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 500),
}) async {
  var delay = initialDelay;
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await action();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(delay);
      delay *= 2;
    }
  }
  // Unreachable, but satisfies the type system.
  throw StateError('retryAsync exhausted all attempts');
}
