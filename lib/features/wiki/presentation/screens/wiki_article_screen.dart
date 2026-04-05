import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/wiki_repository.dart';
import '../../../../core/theme/app_theme.dart';

class WikiArticleScreen extends ConsumerWidget {
  final String articleId;
  const WikiArticleScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(wikiArticleProvider(articleId));

    return Scaffold(
      body: articleAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.accent)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (article) {
          if (article == null) {
            return const Center(child: Text('Article not found'));
          }

          final cs = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final htmlTextColor = isDark ? '#F0EDE8' : '#1A1A1A';

          // ✅ PERFORMANCE FIX: limit HTML size
          final safeBody = article.body.length > 4000
              ? article.body.substring(0, 4000)
              : article.body;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  _BookmarkButton(articleId: articleId),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.bgSurfaceDark
                              : AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article.category.toUpperCase(),
                          style:
                              AppText.label.copyWith(color: cs.onSurface),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(article.title, style: AppText.h1),
                      const SizedBox(height: 8),
                      Text(article.summary, style: AppText.bodySmall),
                      const SizedBox(height: 12),

                      Row(children: [
                        if (article.lastVerifiedAt != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.greenLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(children: [
                              Icon(Icons.verified_rounded,
                                  size: 12, color: AppTheme.greenDark),
                              SizedBox(width: 4),
                              Text('Verified',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.greenDark)),
                            ]),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (article.updatedAt != null)
                          Text(
                            'Updated ${timeago.format(article.updatedAt!)}',
                            style: AppText.caption,
                          ),
                      ]),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),

                      // ✅ FIXED HTML RENDERING (NO LAG / NO STUCK LOADER)
                      if (safeBody.isEmpty)
                        const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.accent),
                        )
                      else
                        RepaintBoundary(
                          child: HtmlWidget(
                            safeBody,
                            key: ValueKey(article.id),
                            textStyle: AppText.body
                                .copyWith(color: cs.onSurface),
                            customStylesBuilder: (element) {
                              switch (element.localName) {
                                case 'h2':
                                  return {
                                    'font-size': '18px',
                                    'font-weight': '600',
                                    'margin-top': '20px',
                                    'color': htmlTextColor,
                                  };
                                case 'h3':
                                  return {
                                    'font-size': '15px',
                                    'font-weight': '600',
                                    'margin-top': '14px',
                                    'color': htmlTextColor,
                                  };
                                case 'p':
                                case 'li':
                                  return {'color': htmlTextColor};
                                default:
                                  return null;
                              }
                            },
                          ),
                        ),

                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.bgSurfaceDark
                              : AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(children: [
                          Icon(Icons.info_outline_rounded,
                              size: 16, color: AppTheme.textSecondary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'See something outdated? Flag it using the button below.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.flag_outlined, size: 16),
                          label: const Text('Flag as outdated'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            side: const BorderSide(color: AppTheme.border),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 🔖 Bookmark button (unchanged)
class _BookmarkButton extends StatefulWidget {
  final String articleId;
  const _BookmarkButton({required this.articleId});

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton> {
  bool _bookmarked = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final result =
        await WikiRepository().isBookmarked(widget.articleId, uid);
    if (mounted) setState(() => _bookmarked = result);
  }

  Future<void> _toggle() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    setState(() {
      _loading = true;
      _bookmarked = !_bookmarked;
    });
    await WikiRepository()
        .toggleBookmark(widget.articleId, uid, _bookmarked);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(_bookmarked
              ? 'Article bookmarked'
              : 'Bookmark removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppTheme.accent),
        ),
      );
    }
    return IconButton(
      icon: Icon(
        _bookmarked
            ? Icons.bookmark_rounded
            : Icons.bookmark_border_rounded,
        color: _bookmarked
            ? AppTheme.accent
            : AppTheme.textSecondary,
      ),
      onPressed: _toggle,
    );
  }
}