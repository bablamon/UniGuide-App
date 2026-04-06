import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/qa_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sanitizer.dart';
import '../../../../core/utils/error_handler.dart';

class QADetailScreen extends ConsumerStatefulWidget {
  final String questionId;
  const QADetailScreen({super.key, required this.questionId});

  @override
  ConsumerState<QADetailScreen> createState() => _QADetailScreenState();
}

class _QADetailScreenState extends ConsumerState<QADetailScreen> {
  final _ctrl = TextEditingController();
  bool _posting = false;

  Future<void> _postAnswer() async {
    if (_ctrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a more detailed answer (at least 10 characters).')),
      );
      return;
    }
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _posting = true);
    try {
      final tag = await ref.read(qaRepoProvider).getDisplayTag();
      await ref.read(qaRepoProvider).postAnswer(
        questionId: widget.questionId,
        body: sanitizePlainText(_ctrl.text, maxLength: 10000),
        authorTag: tag,
        authorUid: uid,
      );
      if (!mounted) return;
      _ctrl.clear();
      FocusScope.of(context).unfocus();
      ref.invalidate(answersProvider(widget.questionId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post answer: ${userFriendlyMessage(e)}')),
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final questionAsync = ref.watch(questionProvider(widget.questionId));
    final answersAsync = ref.watch(answersProvider(widget.questionId));
    final uid = Supabase.instance.client.auth.currentUser?.id ?? '';

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Question'),
      ),
      body: Column(
        children: [
          Expanded(
            child: questionAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
              error: (e, _) => Center(child: Text(userFriendlyMessage(e))),
              data: (question) {
                if (question == null) return const Center(child: Text('Not found'));
                return CustomScrollView(
                  slivers: [
                    // Question card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.border, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: isDark ? AppTheme.bgSurfaceDark : AppTheme.bgSurface, borderRadius: BorderRadius.circular(8)),
                                child: Text(question.tag, style: AppText.label.copyWith(color: cs.onSurface)),
                              ),
                              const SizedBox(height: 10),
                              Text(question.body, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface, height: 1.4)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(question.authorTag, style: AppText.bodySmall.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                                  const SizedBox(width: 4),
                                  Text('·', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.3))),
                                  const SizedBox(width: 4),
                                  Text(timeago.format(question.createdAt), style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => ref.read(qaRepoProvider).upvoteQuestion(question.id, uid),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28, height: 28,
                                          decoration: BoxDecoration(
                                            color: question.upvotedBy.contains(uid) ? AppTheme.accentLight : (isDark ? AppTheme.bgSurfaceDark : AppTheme.bgSurface),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.keyboard_arrow_up_rounded, size: 18, color: question.upvotedBy.contains(uid) ? AppTheme.accent : AppTheme.textSecondary),
                                        ),
                                        const SizedBox(width: 5),
                                        Text('${question.upvotes}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Answers header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: answersAsync.when(
                          data: (a) => Text('${a.length} answer${a.length == 1 ? '' : 's'}', style: AppText.h3),
                          loading: () => const Text('Answers', style: AppText.h3),
                          error: (_, __) => const Text('Answers', style: AppText.h3),
                        ),
                      ),
                    ),

                    // Answers list
                    answersAsync.when(
                      loading: () => const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppTheme.accent)))),
                      error: (e, _) => SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Could not load answers', style: AppText.bodySmall),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () => ref.invalidate(answersProvider(widget.questionId)),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      data: (answers) => answers.isEmpty
                          ? const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(child: Text('No answers yet — be the first!', style: AppText.bodySmall)),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                  child: _AnswerCard(answer: answers[i], questionId: widget.questionId, uid: uid),
                                ),
                                childCount: answers.length,
                              ),
                            ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                );
              },
            ),
          ),

          // Answer input
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.border, width: 0.5)),
            ),
            padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    maxLength: 10000,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Write your answer...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border, width: 0.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border, width: 0.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _posting ? null : _postAnswer,
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(12)),
                    child: _posting
                        ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends ConsumerWidget {
  final Answer answer;
  final String questionId;
  final String uid;
  const _AnswerCard({required this.answer, required this.questionId, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUpvoted = answer.upvotedBy.contains(uid);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: answer.isVerified
            ? AppTheme.greenLight.withValues(alpha: isDark ? 0.15 : 0.4)
            : cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: answer.isVerified
              ? AppTheme.green.withValues(alpha: 0.3)
              : (isDark ? AppTheme.borderDark : AppTheme.border),
          width: answer.isVerified ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (answer.isVerified)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 14, color: AppTheme.greenDark),
                  const SizedBox(width: 5),
                  const Text('Verified answer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.greenDark)),
                ],
              ),
            ),

          Text(answer.body, style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.5)),
          const SizedBox(height: 10),

          Row(
            children: [
              Text(answer.authorTag, style: AppText.bodySmall.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
              const SizedBox(width: 4),
              Text('·', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.3))),
              const SizedBox(width: 4),
              Text(timeago.format(answer.createdAt), style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(qaRepoProvider).upvoteAnswer(questionId, answer.id, uid),
                child: Row(
                  children: [
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: hasUpvoted ? AppTheme.accentLight : (isDark ? AppTheme.bgSurfaceDark : AppTheme.bgSurface),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: hasUpvoted ? AppTheme.accent : cs.onSurface.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(width: 4),
                    Text('${answer.upvotes}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: hasUpvoted ? AppTheme.accent : cs.onSurface)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
