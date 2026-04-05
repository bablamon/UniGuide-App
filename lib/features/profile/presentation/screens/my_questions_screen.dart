import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../qa/data/qa_repository.dart';
import '../../../../core/theme/app_theme.dart';

final _myQuestionsProvider = StreamProvider<List<Question>>((ref) {
  final uid = Supabase.instance.client.auth.currentUser?.id ?? '';
  return QARepository().streamMyQuestions(uid);
});

class MyQuestionsScreen extends ConsumerWidget {
  const MyQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(_myQuestionsProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My questions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (questions) => questions.isEmpty
            ? Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 72, height: 72,
                decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.help_outline_rounded, size: 32, color: AppTheme.accent)),
            const SizedBox(height: 16),
            Text("You haven't asked anything yet", style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 6),
            Text('Ask your first question in the Q&A tab', style: TextStyle(
                fontSize: 13, color: cs.onSurface.withValues(alpha:0.5))),
          ]),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final q = questions[i];
            return GestureDetector(
              onTap: () => context.push('/qa/${q.id}'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDark ? AppTheme.borderDark : AppTheme.border, width: 0.5)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppTheme.accentLight,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(q.tag, style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentDark))),
                    const Spacer(),
                    if (q.isResolved)
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppTheme.greenLight, borderRadius: BorderRadius.circular(6)),
                          child: const Text('✓ Resolved', style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.greenDark))),
                  ]),
                  const SizedBox(height: 8),
                  Text(q.body, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: cs.onSurface, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 13,
                        color: cs.onSurface.withValues(alpha:0.4)),
                    const SizedBox(width: 4),
                    Text('${q.answerCount} answers', style: TextStyle(
                        fontSize: 11, color: cs.onSurface.withValues(alpha:0.5))),
                    const SizedBox(width: 12),
                    Icon(Icons.keyboard_arrow_up_rounded, size: 15,
                        color: cs.onSurface.withValues(alpha:0.4)),
                    Text('${q.upvotes}', style: TextStyle(
                        fontSize: 11, color: cs.onSurface.withValues(alpha:0.5))),
                    const Spacer(),
                    Text(timeago.format(q.createdAt), style: TextStyle(
                        fontSize: 11, color: cs.onSurface.withValues(alpha:0.4))),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}