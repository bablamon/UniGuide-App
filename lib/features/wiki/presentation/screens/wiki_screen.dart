import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/wiki_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';

final _selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final _searchQueryProvider = StateProvider<String>((ref) => '');

// ── Main screen ───────────────────────────────────────────────────────────────
// Only watches _selectedCategoryProvider — category changes don't cascade
// rebuilds to the hero, search bar, or pinned section.

class WikiScreen extends ConsumerWidget {
  const WikiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(_selectedCategoryProvider);
    final query = ref.watch(_searchQueryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          onRefresh: () async {
            ref.invalidate(wikiArticlesProvider(category));
            ref.invalidate(pinnedArticleProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HeroBanner(isDark: isDark, category: category)),
              const SliverToBoxAdapter(child: _SearchBar()),
              SliverToBoxAdapter(child: _CategoryChips(selected: category)),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              if (category == 'all' && query.isEmpty) const _PinnedSliver(),
              _ArticlesSliver(category: category),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────
// StatelessWidget — never rebuilds due to article loading state changes.
// Article count uses an inline Consumer scoped only to that one stat.

class _HeroBanner extends StatelessWidget {
  final bool isDark;
  final String category;
  const _HeroBanner({required this.isDark, required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: AppTheme.accent, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('PCCOE NIGDI WIKI', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: Color(0xFF666666), letterSpacing: 0.8)),
              const Spacer(),
              Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.bookmark_border_rounded,
                      size: 16, color: Color(0xFF888888))),
            ]),
            const SizedBox(height: 12),
            const Text('Everything\nyou need\nto know.', style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w800,
                color: Colors.white, height: 1.15)),
            const SizedBox(height: 6),
            const Text('Verified by seniors & faculty',
                style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
            const SizedBox(height: 16),
            Row(children: [
              const _HeroStat(label: 'GUIDES', value: '24'),
              const SizedBox(width: 20),
              const _HeroStat(label: 'CATEGORIES', value: '6'),
              const SizedBox(width: 20),
              // Scoped Consumer — only this widget rebuilds when articles load
              Consumer(builder: (context, ref, _) {
                final articles = ref.watch(wikiArticlesProvider(category));
                return articles.maybeWhen(
                  data: (l) => _HeroStat(label: 'ARTICLES', value: '${l.length}'),
                  orElse: () => const _HeroStat(label: 'ARTICLES', value: '—'),
                );
              }),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: TextField(
        controller: _ctrl,
        onChanged: (v) => ref.read(_searchQueryProvider.notifier).state = v,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          hintText: 'Search guides, topics...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFFBBBBBB)),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFBBBBBB)),
                  onPressed: () {
                    _ctrl.clear();
                    ref.read(_searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.border, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.border, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

class _CategoryChips extends ConsumerWidget {
  final String selected;
  const _CategoryChips({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.border;
    final selectedBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        itemCount: wikiCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = wikiCategories[i];
          final isSelected = selected == cat.id;
          return GestureDetector(
            onTap: () =>
                ref.read(_selectedCategoryProvider.notifier).state = cat.id,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? Colors.transparent : borderColor,
                    width: 0.5),
              ),
              child: Text(cat.label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF888888))),
            ),
          );
        },
      ),
    );
  }
}

// ── Pinned article sliver ─────────────────────────────────────────────────────
// Isolated ConsumerWidget — only rebuilds when pinnedArticleProvider changes,
// NOT when the article list loads or the category switches.

class _PinnedSliver extends ConsumerWidget {
  const _PinnedSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned = ref.watch(pinnedArticleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return pinned.maybeWhen(
      data: (article) => article != null
          ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: GestureDetector(
                  onTap: () => context.push('/wiki/${article.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1C)
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PINNED',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF666666),
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          Text(article.title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(article.summary,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF888888),
                                  height: 1.5)),
                          const SizedBox(height: 14),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Text('Read guide',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white))),
                        ]),
                  ),
                ),
              ))
          : const SliverToBoxAdapter(child: SizedBox.shrink()),
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

// ── Articles sliver ───────────────────────────────────────────────────────────
// Isolated ConsumerWidget — only rebuilds when its own provider changes.

class _ArticlesSliver extends ConsumerWidget {
  final String category;
  const _ArticlesSliver({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(wikiArticlesProvider(category));
    final query = ref.watch(_searchQueryProvider).trim().toLowerCase();
    return articles.when(
      loading: () => SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: WikiCardSkeleton(),
            ),
            childCount: 5,
          )),
      error: (e, _) => const SliverFillRemaining(
          child: Center(
              child: Text('Could not load articles',
                  style: TextStyle(color: Color(0xFF888888))))),
      data: (list) {
        final filtered = query.isEmpty
            ? list
            : list
                .where((a) =>
                    a.title.toLowerCase().contains(query) ||
                    a.summary.toLowerCase().contains(query) ||
                    a.category.toLowerCase().contains(query))
                .toList();
        if (filtered.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                query.isEmpty ? 'No articles yet' : 'No results for "$query"',
                style: const TextStyle(color: Color(0xFF888888)),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _WikiCard(article: filtered[i]),
            ),
            childCount: filtered.length,
          ),
        );
      },
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _HeroStat extends StatelessWidget {
  final String label, value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                  letterSpacing: 0.5)),
        ],
      );
}

class _WikiCard extends StatelessWidget {
  final WikiArticle article;
  const _WikiCard({required this.article});

  static const _catBgMap = {
    'exams': AppTheme.accentLight,
    'erp': AppTheme.greenLight,
    'placements': Color(0xFFFDF0D8),
    'facilities': Color(0xFFE0EEFF),
  };
  static const _catFgMap = {
    'exams': AppTheme.accentDark,
    'erp': AppTheme.greenDark,
    'placements': Color(0xFF854F0B),
    'facilities': Color(0xFF185FA5),
  };
  static const _catIconMap = {
    'exams': Icons.article_rounded,
    'erp': Icons.computer_rounded,
    'placements': Icons.work_rounded,
    'facilities': Icons.map_rounded,
    'hostel': Icons.hotel_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = article.updatedAt != null
        ? now.difference(article.updatedAt!).inDays
        : 999;
    final isNew = diff < 3;
    final isUpdated = !isNew && diff < 7;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.border;

    return GestureDetector(
      onTap: () => context.push('/wiki/${article.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: _catBgMap[article.category] ??
                      const Color(0xFFF0EDE8),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(
                  _catIconMap[article.category] ?? Icons.book_rounded,
                  size: 20,
                  color: _catFgMap[article.category] ??
                      AppTheme.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(article.title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
                const SizedBox(height: 2),
                Text(article.summary,
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.55)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  if (article.updatedAt != null)
                    Text('Updated ${timeago.format(article.updatedAt!)}',
                        style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurface.withValues(alpha: 0.35))),
                  const SizedBox(width: 5),
                  if (isNew)
                    _badge('New', AppTheme.accentLight, AppTheme.accentDark)
                  else if (isUpdated)
                    _badge('Updated', AppTheme.greenLight, AppTheme.greenDark),
                  const SizedBox(width: 4),
                  if (article.viewCount > 0)
                    _badge('${article.viewCount} views',
                        const Color(0xFFF0EDE8), const Color(0xFF888888)),
                ]),
              ])),
          Icon(Icons.chevron_right_rounded,
              size: 18, color: cs.onSurface.withValues(alpha: 0.3)),
        ]),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: fg)));
}
