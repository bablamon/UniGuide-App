import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/retry.dart';

// ── Model ────────────────────────────────────────────────────────────────────

class WikiArticle {
  final String id;
  final String title;
  final String summary;
  final String body;
  final String category;
  final List<int> targetYears;
  final List<String> targetBranches;
  final bool isPinned;
  final String status;
  final DateTime? lastVerifiedAt;
  final DateTime? updatedAt;
  final int viewCount;
  final int bookmarkCount;

  const WikiArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    this.targetYears = const [],
    this.targetBranches = const ['all'],
    this.isPinned = false,
    this.status = 'published',
    this.lastVerifiedAt,
    this.updatedAt,
    this.viewCount = 0,
    this.bookmarkCount = 0,
  });

  factory WikiArticle.fromJson(Map<String, dynamic> d) {
    if (d['id'] == null) {
      throw const FormatException('WikiArticle.fromJson: missing required field "id"');
    }
    return WikiArticle(
      id: d['id'] as String,
      title: d['title'] ?? '',
      summary: d['summary'] ?? '',
      body: d['body'] ?? '',
      category: d['category'] ?? 'general',
      targetYears: List<int>.from(d['target_years'] ?? []),
      targetBranches: List<String>.from(d['target_branches'] ?? ['all']),
      isPinned: d['is_pinned'] ?? false,
      status: d['status'] ?? 'published',
      lastVerifiedAt: d['last_verified_at'] != null
          ? DateTime.tryParse(d['last_verified_at'].toString())
          : null,
      updatedAt: d['updated_at'] != null
          ? DateTime.tryParse(d['updated_at'].toString())
          : null,
      viewCount: d['view_count'] ?? 0,
      bookmarkCount: d['bookmark_count'] ?? 0,
    );
  }
}

// ── Categories ───────────────────────────────────────────────────────────────

const wikiCategories = [
  WikiCategory(id: 'all', label: 'All'),
  WikiCategory(id: 'exams', label: 'Exams'),
  WikiCategory(id: 'erp', label: 'ERP'),
  WikiCategory(id: 'placements', label: 'Placements'),
  WikiCategory(id: 'facilities', label: 'Facilities'),
  WikiCategory(id: 'hostel', label: 'Hostel'),
];

class WikiCategory {
  final String id;
  final String label;
  const WikiCategory({required this.id, required this.label});
}

// ── Providers ─────────────────────────────────────────────────────────────────

final wikiRepoProvider = Provider<WikiRepository>((ref) => WikiRepository());

final wikiArticlesProvider =
    FutureProvider.family<List<WikiArticle>, String>((ref, category) {
  return ref.read(wikiRepoProvider).getArticles(category: category);
});

final wikiArticleProvider =
    FutureProvider.family<WikiArticle?, String>((ref, id) {
  return ref.read(wikiRepoProvider).getArticle(id);
});

final pinnedArticleProvider = FutureProvider<WikiArticle?>((ref) {
  return ref.read(wikiRepoProvider).getPinnedArticle();
});

// ── Repository ───────────────────────────────────────────────────────────────

class WikiRepository {
  final _db = Supabase.instance.client;
  final _log = AppLogger('WikiRepository');

  // Only fetch columns the list UI actually uses — body can be very large HTML
  // and loading it for every article in the list caused severe main-thread jank.
  static const _listColumns =
      'id, title, summary, category, is_pinned, status, '
      'last_verified_at, updated_at, view_count, bookmark_count, '
      'target_years, target_branches';

  Future<List<WikiArticle>> getArticles({String category = 'all'}) async {
    return retryAsync(() async {
      List<Map<String, dynamic>> data;
      if (category == 'all') {
        data = await _db
            .from('wiki_articles')
            .select(_listColumns)
            .eq('status', 'published')
            .order('updated_at', ascending: false);
      } else {
        data = await _db
            .from('wiki_articles')
            .select(_listColumns)
            .eq('status', 'published')
            .eq('category', category)
            .order('updated_at', ascending: false);
      }
      return data.map(WikiArticle.fromJson).toList();
    });
  }

  Future<WikiArticle?> getArticle(String id) async {
    try {
      final data = await retryAsync(() => _db
          .from('wiki_articles')
          .select()
          .eq('id', id)
          .single());
      // Fire-and-forget view count increment — log errors instead of losing them.
      _db.rpc('increment_view_count', params: {'article_id': id}).catchError(
        (e) => _log.warning('view count increment failed', e),
      );
      return WikiArticle.fromJson(data);
    } catch (e, stackTrace) {
      _log.error('getArticle($id) failed', e, stackTrace);
      return null;
    }
  }

  Future<WikiArticle?> getPinnedArticle() async {
    final data = await retryAsync(() => _db
        .from('wiki_articles')
        .select()
        .eq('is_pinned', true)
        .eq('status', 'published')
        .limit(1)
        .maybeSingle());
    if (data == null) return null;
    return WikiArticle.fromJson(data);
  }

  Future<void> toggleBookmark(
      String articleId, String uid, bool bookmarked) async {
    await _db.rpc('toggle_bookmark', params: {
      'p_article_id': articleId,
      'p_user_id': uid,
      'p_add': bookmarked,
    });
  }

  Future<bool> isBookmarked(String articleId, String uid) async {
    final data = await _db
        .from('bookmarks')
        .select()
        .eq('user_id', uid)
        .eq('ref_id', articleId)
        .maybeSingle();
    return data != null;
  }
}
