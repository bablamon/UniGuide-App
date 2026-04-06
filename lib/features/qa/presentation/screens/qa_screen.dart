import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/qa_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton.dart';

final _qaFilterProvider = StateProvider<String>((ref) => 'all');

class QAScreen extends ConsumerStatefulWidget {
  const QAScreen({super.key});

  @override
  ConsumerState<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends ConsumerState<QAScreen> {
  late PagingController<int, Question> _pagingController;
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _pagingController = _buildController();
    _pagingController.addListener(_rebuild);
  }

  PagingController<int, Question> _buildController() {
    return PagingController<int, Question>(
      getNextPageKey: (state) {
        final pages = state.pages;
        if (pages == null || pages.isEmpty) return 0;
        if (pages.last.length < QARepository.pageSize) return null;
        return pages.length;
      },
      fetchPage: (pageKey) => ref.read(qaRepoProvider).fetchQuestionsPage(
            page: pageKey,
            filter: _activeFilter,
          ),
    );
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pagingController.removeListener(_rebuild);
    _pagingController.dispose();
    super.dispose();
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(_qaFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    if (_activeFilter != filter) {
      _activeFilter = filter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pagingController.removeListener(_rebuild);
        _pagingController.dispose();
        _pagingController = _buildController();
        _pagingController.addListener(_rebuild);
        _pagingController.fetchNextPage();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_greeting(),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
                    const SizedBox(height: 4),
                    const Text('Ask anything.\nStay anonymous.',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                            color: Colors.white, height: 1.3)),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => context.push('/qa/ask'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.help_outline_rounded, size: 16, color: Color(0xFF555555)),
                          const SizedBox(width: 8),
                          const Expanded(child: Text("What's on your mind?",
                              style: TextStyle(fontSize: 13, color: Color(0xFF555555)))),
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Ask', style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(label: 'All', value: 'all', selected: filter == 'all', ref: ref, cs: cs, isDark: isDark),
                    ...qaTags.map((t) => _FilterChip(label: t, value: t, selected: filter == t, ref: ref, cs: cs, isDark: isDark)),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(children: [
                  _PulseDot(),
                  const SizedBox(width: 6),
                  Text(
                      filter == 'all' ? 'TRENDING NOW' : '${filter.toUpperCase()} QUESTIONS',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                          color: Color(0xFFBBBBBB), letterSpacing: 0.8)),
                ]),
              ),
            ),

            PagedSliverList<int, Question>(
              state: _pagingController.value,
              fetchNextPage: _pagingController.fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<Question>(
                itemBuilder: (ctx, question, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _QuestionCard(
                    question: question,
                    cs: cs,
                    isDark: isDark,
                    onUpvoted: _pagingController.refresh,
                  ),
                ),
                firstPageProgressIndicatorBuilder: (_) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(children: List.generate(5, (_) => const QuestionCardSkeleton())),
                    ),
                newPageProgressIndicatorBuilder: (_) =>
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    )),
                firstPageErrorIndicatorBuilder: (_) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Could not load',
                        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5))),
                  ),
                ),
                noItemsFoundIndicatorBuilder: (_) => _EmptyQA(cs: cs),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override State<_PulseDot> createState() => _PulseDotState();
}
class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: _anim,
      child: Container(width: 7, height: 7,
          decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)));
}

class _FilterChip extends StatelessWidget {
  final String label, value;
  final bool selected, isDark;
  final ColorScheme cs;
  final WidgetRef ref;
  const _FilterChip({required this.label, required this.value, required this.selected,
    required this.ref, required this.cs, required this.isDark});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => ref.read(_qaFilterProvider.notifier).state = value,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
          color: selected ? (isDark ? const Color(0xFF333333) : const Color(0xFF1A1A1A)) : cs.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? Colors.transparent : (isDark ? AppTheme.borderDark : AppTheme.border), width: 0.5)),
      child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : cs.onSurface.withValues(alpha:0.6))),
    ),
  );
}

class _QuestionCard extends ConsumerWidget {
  final Question question;
  final ColorScheme cs;
  final bool isDark;
  final VoidCallback? onUpvoted;
  const _QuestionCard({required this.question, required this.cs, required this.isDark, this.onUpvoted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = Supabase.instance.client.auth.currentUser?.id ?? '';
    final hasUpvoted = question.upvotedBy.contains(uid);
    final isHot = question.upvotes >= 20;
    final accentColor = isHot ? AppTheme.accent
        : question.isResolved ? AppTheme.green
        : null;

    return GestureDetector(
      onTap: () => context.push('/qa/${question.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Card body
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.border,
                    width: 0.5),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _TagPill(tag: question.tag),
                  const SizedBox(width: 6),
                  if (isHot) _badge('🔥 Hot', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
                  if (question.isResolved) _badge('✓ Resolved', AppTheme.greenLight, AppTheme.greenDark),
                ]),
                const SizedBox(height: 8),
                Text(question.body, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: cs.onSurface, height: 1.4)),
                const SizedBox(height: 10),
                Row(children: [
                  Text(question.authorTag, style: TextStyle(
                      fontSize: 11, color: cs.onSurface.withValues(alpha:0.55))),
                  Text(' · ', style: TextStyle(color: cs.onSurface.withValues(alpha:0.3))),
                  Text(timeago.format(question.createdAt), style: TextStyle(
                      fontSize: 11, color: cs.onSurface.withValues(alpha:0.4))),
                  const Spacer(),
                  Row(children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 13,
                        color: cs.onSurface.withValues(alpha:0.4)),
                    const SizedBox(width: 3),
                    Text('${question.answerCount}', style: TextStyle(
                        fontSize: 12, color: cs.onSurface.withValues(alpha:0.55))),
                  ]),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      await ref.read(qaRepoProvider).upvoteQuestion(question.id, uid);
                      onUpvoted?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: hasUpvoted ? AppTheme.accentLight
                              : isDark ? AppTheme.bgSurfaceDark : const Color(0xFFF0EDE8),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        Icon(Icons.keyboard_arrow_up_rounded, size: 16,
                            color: hasUpvoted ? AppTheme.accent : cs.onSurface.withValues(alpha:0.4)),
                        const SizedBox(width: 2),
                        Text('${question.upvotes}', style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: hasUpvoted ? AppTheme.accent : cs.onSurface)),
                      ]),
                    ),
                  ),
                ]),
              ]),
            ),
            // Left accent bar using Positioned inside Stack
            if (accentColor != null)
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 3, color: accentColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)));
}

class _TagPill extends StatelessWidget {
  final String tag;
  const _TagPill({required this.tag});
  @override
  Widget build(BuildContext context) {
    Color bg; Color fg;
    switch (tag.toLowerCase()) {
      case 'exams': bg = AppTheme.accentLight; fg = AppTheme.accentDark;
      case 'erp': bg = AppTheme.greenLight; fg = AppTheme.greenDark;
      case 'placements': bg = const Color(0xFFE0EEFF); fg = const Color(0xFF185FA5);
      case 'hostel': bg = const Color(0xFFFDF0D8); fg = const Color(0xFF854F0B);
      default: bg = const Color(0xFFF0EDE8); fg = const Color(0xFF888888);
    }
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)));
  }
}

class _EmptyQA extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyQA({required this.cs});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(width: 72, height: 72,
          decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.forum_rounded, size: 32, color: AppTheme.accent)),
      const SizedBox(height: 16),
      Text('No questions yet', style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: 6),
      Text('Be the first to ask!', style: TextStyle(
          fontSize: 13, color: cs.onSurface.withValues(alpha:0.5))),
      const SizedBox(height: 20),
      GestureDetector(
          onTap: () => context.push('/qa/ask'),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(12)),
              child: const Text('Ask a question', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)))),
    ],
  );
}