// Rate limiting for all mutation endpoints.
//
// Implements token-bucket algorithm with per-user and per-action limits.
// Provides graceful 429-style feedback with cooldown messages.
//
// OWASP alignment:
//   - A04:2021 Insecure Design — prevent abuse of mutation endpoints
//   - A07:2021 Identification and Authentication Failures — rate limit auth attempts

import 'dart:async';

/// Configuration for a single rate limit bucket.
class RateLimitConfig {
  final int maxTokens;
  final Duration windowSize;

  const RateLimitConfig({required this.maxTokens, required this.windowSize});
}

/// Default rate limits (sensible for a mobile app).
class RateLimits {
  // Auth: 5 magic links per 60 seconds (prevents spam abuse).
  static const authMagicLink = RateLimitConfig(
    maxTokens: 5,
    windowSize: Duration(seconds: 60),
  );

  // Questions: 10 per 60 seconds (prevent flood attacks).
  static const questionPost = RateLimitConfig(
    maxTokens: 10,
    windowSize: Duration(seconds: 60),
  );

  // Answers: 20 per 60 seconds (allow active discussion).
  static const answerPost = RateLimitConfig(
    maxTokens: 20,
    windowSize: Duration(seconds: 60),
  );

  // Upvotes: 30 per 60 seconds (prevent vote manipulation).
  static const upvote = RateLimitConfig(
    maxTokens: 30,
    windowSize: Duration(seconds: 60),
  );

  // Bookmarks: 30 per 60 seconds.
  static const bookmark = RateLimitConfig(
    maxTokens: 30,
    windowSize: Duration(seconds: 60),
  );
}

/// Result of a rate limit check.
class RateLimitResult {
  final bool allowed;
  final Duration? retryAfter;

  const RateLimitResult.allowed() : allowed = true, retryAfter = null;
  const RateLimitResult.denied(this.retryAfter) : allowed = false;
}

/// Rate limiter using token-bucket algorithm.
/// Each bucket is keyed by (userId, actionName).
class RateLimiter {
  final Map<String, _TokenBucket> _buckets = {};
  final Duration _cleanupInterval;

  RateLimiter({Duration cleanupInterval = const Duration(minutes: 5)})
    : _cleanupInterval = cleanupInterval {
    // Periodically clean up stale buckets to prevent memory leaks.
    Timer.periodic(_cleanupInterval, (_) => _cleanup());
  }

  /// Check if an action is allowed for the given user.
  /// Returns a RateLimitResult indicating whether the action is permitted.
  RateLimitResult check(String? userId, String action, RateLimitConfig config) {
    if (userId == null || userId.isEmpty) {
      // No user = apply a default limit based on IP (not tracked here).
      // Return allowed but log warning in production.
      return const RateLimitResult.allowed();
    }

    final key = '$userId:$action';
    final bucket = _buckets.putIfAbsent(
      key,
      () => _TokenBucket(config.maxTokens, config.windowSize),
    );

    return bucket.consume();
  }

  /// Returns the time until the user can perform the action again.
  Duration? getRetryAfter(
    String? userId,
    String action,
    RateLimitConfig config,
  ) {
    if (userId == null || userId.isEmpty) return null;

    final key = '$userId:$action';
    final bucket = _buckets[key];
    if (bucket == null) return null;

    return bucket.timeUntilAvailable();
  }

  void _cleanup() {
    final now = DateTime.now();
    _buckets.removeWhere((_, bucket) => bucket.isExpired(now));
  }
}

/// Internal token bucket implementation.
class _TokenBucket {
  int _tokens;
  final int _capacity;
  final Duration _windowSize;
  DateTime _windowStart;

  _TokenBucket(this._capacity, this._windowSize)
    : _tokens = _capacity,
      _windowStart = DateTime.now();

  /// Consume one token if available. Returns whether the action is allowed.
  RateLimitResult consume() {
    _refill();

    if (_tokens > 0) {
      _tokens--;
      return const RateLimitResult.allowed();
    }

    // Return time until next token is available.
    final retryAfter = _windowStart.add(_windowSize).difference(DateTime.now());
    return RateLimitResult.denied(
      retryAfter.isNegative ? Duration.zero : retryAfter,
    );
  }

  /// Refill tokens based on elapsed time since window start.
  void _refill() {
    final now = DateTime.now();
    final elapsed = now.difference(_windowStart);

    if (elapsed >= _windowSize) {
      // Window expired — reset tokens and window.
      _tokens = _capacity;
      _windowStart = now;
    }
    // Otherwise, tokens remain at current level (no partial refill in this simple implementation).
  }

  /// Returns time until a token is available, or null if tokens available now.
  Duration? timeUntilAvailable() {
    _refill();
    if (_tokens > 0) return null;
    return _windowStart.add(_windowSize).difference(DateTime.now());
  }

  /// Check if this bucket has been inactive and should be cleaned up.
  bool isExpired(DateTime now) {
    return now.difference(_windowStart) > _windowSize * 2;
  }
}

/// Global rate limiter instance — shared across all services.
final rateLimiter = RateLimiter();

/// Convenience function to check rate limits for auth operations.
RateLimitResult checkAuthRateLimit(String? userId) {
  return rateLimiter.check(userId, 'auth_magic_link', RateLimits.authMagicLink);
}

/// Convenience function to check rate limits for question posting.
RateLimitResult checkQuestionRateLimit(String? userId) {
  return rateLimiter.check(userId, 'post_question', RateLimits.questionPost);
}

/// Convenience function to check rate limits for answer posting.
RateLimitResult checkAnswerRateLimit(String? userId) {
  return rateLimiter.check(userId, 'post_answer', RateLimits.answerPost);
}

/// Convenience function to check rate limits for upvotes.
RateLimitResult checkUpvoteRateLimit(String? userId) {
  return rateLimiter.check(userId, 'upvote', RateLimits.upvote);
}

/// Convenience function to check rate limits for bookmarks.
RateLimitResult checkBookmarkRateLimit(String? userId) {
  return rateLimiter.check(userId, 'bookmark', RateLimits.bookmark);
}

/// Format a Duration into a human-readable retry message.
String formatRetryMessage(Duration? retryAfter) {
  if (retryAfter == null || retryAfter <= Duration.zero) {
    return 'Please try again.';
  }

  final seconds = retryAfter.inSeconds;
  if (seconds < 60) {
    return 'Please wait $seconds seconds.';
  }

  final minutes = (seconds / 60).ceil();
  return 'Please wait $minutes minute${minutes > 1 ? 's' : ''}.';
}
