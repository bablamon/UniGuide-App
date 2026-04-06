import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../wiki/data/wiki_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger.dart';

final _bookmarksLog = AppLogger('BookmarksScreen');

final _bookmarksProvider = StreamProvider.autoDispose<List<WikiArticle>>((ref) {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return Stream.value([]);

  return Supabase.instance.client
      .from('bookmarks')
      .stream(primaryKey: ['id'])
      .eq('user_id', uid)
      .order('saved_at', ascending: false)
      .asyncMap((rows) async {
        if (rows.isEmpty) return <WikiArticle>[];
        final ids = rows.map((r) => r['ref_id'] as String).toList();
        final results = await Future.wait(
          ids.map((id) => Supabase.instance.client
              .from('wiki_articles')
              .select()
              .eq('id', id)
              .maybeSingle()),
        );
        return results
            .whereType<Map<String, dynamic>>()
            .map(WikiArticle.fromJson)
            .toList();
      })
      .handleError((e, s) => _bookmarksLog.error('bookmarks stream error', e, s));
});

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(_bookmarksProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved articles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: bookmarksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        error: (e, _) => Center(child: Text(userFriendlyMessage(e))),
        data: (articles) => articles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE0EEFF),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.bookmark_border_rounded,
                            size: 32, color: Color(0xFF185FA5))),
                    const SizedBox(height: 16),
                    Text('No saved articles yet',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface)),
                    const SizedBox(height: 6),
                    Text('Tap the bookmark icon on any wiki article',
                        style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: articles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final a = articles[i];
                  return GestureDetector(
                    onTap: () => context.push('/wiki/${a.id}'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark
                                  ? AppTheme.borderDark
                                  : AppTheme.border,
                              width: 0.5)),
                      child: Row(children: [
                        Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.bgSurfaceDark
                                    : AppTheme.accentLight,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.article_rounded,
                                size: 20, color: AppTheme.accentDark)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(a.title,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface)),
                              const SizedBox(height: 2),
                              Text(a.summary,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          cs.onSurface.withValues(alpha: 0.5)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              if (a.updatedAt != null)
                                Text(
                                    'Updated ${timeago.format(a.updatedAt!)}',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: cs.onSurface
                                            .withValues(alpha: 0.35))),
                            ])),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final uid = Supabase.instance.client.auth
                                .currentUser?.id;
                            if (uid == null) return;
                            await WikiRepository()
                                .toggleBookmark(a.id, uid, false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Bookmark removed')));
                            }
                          },
                          child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.bgSurfaceDark
                                      : const Color(0xFFF0EDE8),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(
                                  Icons.bookmark_remove_rounded,
                                  size: 18,
                                  color: AppTheme.accent)),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
