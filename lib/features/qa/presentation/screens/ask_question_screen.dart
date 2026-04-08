import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/qa_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sanitizer.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/schema_validator.dart';

class AskQuestionScreen extends ConsumerStatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  ConsumerState<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends ConsumerState<AskQuestionScreen> {
  final _ctrl = TextEditingController();
  String _tag = 'General';
  bool _posting = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    // Pre-flight: validate body locally before fetching authorTag
    final bodyErr = validateRequiredString(
      _ctrl.text,
      maxLength: 5000,
      label: 'Question body',
    );
    if (bodyErr != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(bodyErr)));
      return;
    }
    if (_ctrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question must be at least 10 characters.'),
        ),
      );
      return;
    }

    setState(() => _posting = true);
    try {
      final authorTag = await ref.read(qaRepoProvider).getDisplayTag();

      // Full validation now that authorTag is available
      final validationError = validateQuestionInput(
        body: _ctrl.text,
        tag: _tag,
        authorTag: authorTag,
        authorUid: uid,
      );
      if (validationError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(validationError.message)));
        }
        setState(() => _posting = false);
        return;
      }

      await ref
          .read(qaRepoProvider)
          .postQuestion(
            body: sanitizePlainText(_ctrl.text, maxLength: 5000),
            tag: _tag,
            authorTag: authorTag,
            authorUid: uid,
          );
      ref.invalidate(questionsProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post question: ${userFriendlyMessage(e)}'),
        ),
      );
      setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ask a question'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _posting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accent,
                    ),
                  )
                : TextButton(
                    onPressed: _post,
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anonymous note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your name is never shown. You appear as your year & branch only.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tag selector
            Text('Category', style: AppText.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: qaTags.map((t) {
                final sel = _tag == t;
                return GestureDetector(
                  onTap: () => setState(() => _tag = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.accent : AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppTheme.accent : AppTheme.border,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Question field
            Text('Your question', style: AppText.label),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                maxLength: 5000,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintText:
                      'What do you want to know? Be specific — better questions get better answers.',
                  hintMaxLines: 3,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.border,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.border,
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.accent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
