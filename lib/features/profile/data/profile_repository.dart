import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/retry.dart';

final profileRepoProvider = Provider<ProfileRepository>((ref) => ProfileRepository());

/// Aggregated profile stats — replaces the three separate COUNT queries.
class UserStats {
  final int questionCount;
  final int answerCount;
  final int bookmarkCount;

  const UserStats({
    this.questionCount = 0,
    this.answerCount = 0,
    this.bookmarkCount = 0,
  });
}

final userStatsProvider = FutureProvider<UserStats>((ref) {
  return ref.read(profileRepoProvider).getUserStats();
});

class ProfileRepository {
  final _db = Supabase.instance.client;
  final _log = AppLogger('ProfileRepository');

  /// Fetches question, answer, and bookmark counts in a single RPC call.
  /// Falls back to three separate queries if the RPC doesn't exist yet.
  Future<UserStats> getUserStats() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return const UserStats();

    try {
      final result = await retryAsync(
        () => _db.rpc('get_user_stats', params: {'p_uid': uid}),
      );
      if (result is Map) {
        return UserStats(
          questionCount: result['question_count'] ?? 0,
          answerCount: result['answer_count'] ?? 0,
          bookmarkCount: result['bookmark_count'] ?? 0,
        );
      }
    } catch (e, stackTrace) {
      _log.warning('get_user_stats RPC failed, falling back to individual queries', e, stackTrace);
    }

    // Fallback: three parallel COUNT queries.
    try {
      final results = await Future.wait([
        _db.from('questions').select('id').eq('author_uid', uid),
        _db.from('answers').select('id').eq('author_uid', uid),
        _db.from('bookmarks').select('id').eq('user_id', uid),
      ]);
      return UserStats(
        questionCount: (results[0] as List).length,
        answerCount: (results[1] as List).length,
        bookmarkCount: (results[2] as List).length,
      );
    } catch (e, stackTrace) {
      _log.error('getUserStats fallback failed', e, stackTrace);
      return const UserStats();
    }
  }
}
