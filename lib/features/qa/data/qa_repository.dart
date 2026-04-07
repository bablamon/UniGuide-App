import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/retry.dart';
import '../../../core/utils/schema_validator.dart';
import '../../../core/utils/rate_limiter.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class Question {
  final String id;
  final String body;
  final String tag;
  final String authorTag;
  final String authorUid;
  final int upvotes;
  final int answerCount;
  final bool isResolved;
  final DateTime createdAt;
  final List<String> upvotedBy;

  const Question({
    required this.id,
    required this.body,
    required this.tag,
    required this.authorTag,
    required this.authorUid,
    this.upvotes = 0,
    this.answerCount = 0,
    this.isResolved = false,
    required this.createdAt,
    this.upvotedBy = const [],
  });

  factory Question.fromJson(Map<String, dynamic> d) {
    if (d['id'] == null) {
      throw const FormatException(
        'Question.fromJson: missing required field "id"',
      );
    }
    return Question(
      id: d['id'] as String,
      body: d['body'] ?? '',
      tag: d['tag'] ?? 'General',
      authorTag: d['author_tag'] ?? 'Anonymous',
      authorUid: d['author_uid'] ?? '',
      upvotes: d['upvotes'] ?? 0,
      answerCount: d['answer_count'] ?? 0,
      isResolved: d['is_resolved'] ?? false,
      createdAt:
          DateTime.tryParse(d['created_at']?.toString() ?? '') ??
          DateTime.now(),
      upvotedBy: List<String>.from(d['upvoted_by'] ?? []),
    );
  }
}

class Answer {
  final String id;
  final String body;
  final String authorTag;
  final String authorUid;
  final int upvotes;
  final bool isVerified;
  final String? verifiedBy;
  final DateTime createdAt;
  final List<String> upvotedBy;

  const Answer({
    required this.id,
    required this.body,
    required this.authorTag,
    required this.authorUid,
    this.upvotes = 0,
    this.isVerified = false,
    this.verifiedBy,
    required this.createdAt,
    this.upvotedBy = const [],
  });

  factory Answer.fromJson(Map<String, dynamic> d) {
    if (d['id'] == null) {
      throw const FormatException(
        'Answer.fromJson: missing required field "id"',
      );
    }
    return Answer(
      id: d['id'] as String,
      body: d['body'] ?? '',
      authorTag: d['author_tag'] ?? 'Anonymous',
      authorUid: d['author_uid'] ?? '',
      upvotes: d['upvotes'] ?? 0,
      isVerified: d['is_verified'] ?? false,
      verifiedBy: d['verified_by'],
      createdAt:
          DateTime.tryParse(d['created_at']?.toString() ?? '') ??
          DateTime.now(),
      upvotedBy: List<String>.from(d['upvoted_by'] ?? []),
    );
  }
}

// ── Tags ─────────────────────────────────────────────────────────────────────

const qaTags = [
  'General',
  'Exams',
  'ERP',
  'Placements',
  'Hostel',
  'Facilities',
  'Fees',
  'Other',
];

// ── Providers ─────────────────────────────────────────────────────────────────

final qaRepoProvider = Provider<QARepository>((ref) => QARepository());

final questionsProvider = StreamProvider.family<List<Question>, String>((
  ref,
  filter,
) {
  return ref.read(qaRepoProvider).streamQuestions(filter: filter);
});

final answersProvider = FutureProvider.family<List<Answer>, String>((
  ref,
  questionId,
) {
  return ref.read(qaRepoProvider).fetchAnswers(questionId);
});

final questionProvider = FutureProvider.family<Question?, String>((ref, id) {
  return ref.read(qaRepoProvider).getQuestion(id);
});

// ── Repository ───────────────────────────────────────────────────────────────

class QARepository {
  final _db = Supabase.instance.client;
  final _log = AppLogger('QARepository');

  static const pageSize = 15;

  Future<List<Question>> fetchQuestionsPage({
    required int page,
    String filter = 'all',
  }) async {
    return retryAsync(() async {
      final from = page * pageSize;
      final to = from + pageSize - 1;
      var query = _db.from('questions').select();
      if (filter != 'all') query = query.eq('tag', filter);
      final data = await query
          .order('created_at', ascending: false)
          .range(from, to);
      return data.map(Question.fromJson).toList();
    });
  }

  Stream<List<Question>> streamMyQuestions(String uid) {
    return _db
        .from('questions')
        .stream(primaryKey: ['id'])
        .eq('author_uid', uid)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(Question.fromJson).toList());
  }

  Stream<List<Question>> streamQuestions({String filter = 'all'}) {
    if (filter == 'all') {
      return _db
          .from('questions')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((rows) => rows.map(Question.fromJson).toList());
    }
    return _db
        .from('questions')
        .stream(primaryKey: ['id'])
        .eq('tag', filter)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(Question.fromJson).toList());
  }

  Future<List<Answer>> fetchAnswers(String questionId) async {
    return retryAsync(() async {
      final rows = await _db
          .from('answers')
          .select()
          .eq('question_id', questionId)
          .order('created_at', ascending: false);
      final answers = rows.map(Answer.fromJson).toList();
      answers.sort((a, b) {
        if (a.isVerified != b.isVerified) return a.isVerified ? -1 : 1;
        return b.upvotes.compareTo(a.upvotes);
      });
      return answers;
    });
  }

  Stream<List<Answer>> streamAnswers(String questionId) {
    return _db
        .from('answers')
        .stream(primaryKey: ['id'])
        .eq('question_id', questionId)
        .order('created_at', ascending: false)
        .map((rows) {
          final answers = rows.map(Answer.fromJson).toList();
          // verified first, then by upvotes
          answers.sort((a, b) {
            if (a.isVerified != b.isVerified) return a.isVerified ? -1 : 1;
            return b.upvotes.compareTo(a.upvotes);
          });
          return answers;
        });
  }

  Future<Question?> getQuestion(String id) async {
    try {
      final data = await _db.from('questions').select().eq('id', id).single();
      return Question.fromJson(data);
    } catch (e, stackTrace) {
      _log.error('getQuestion($id) failed', e, stackTrace);
      return null;
    }
  }

  Future<String> getDisplayTag() async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) return 'Student';
      final data = await _db
          .from('users')
          .select('display_tag')
          .eq('id', user.id)
          .maybeSingle();
      return data?['display_tag'] ?? 'Student';
    } catch (e, stackTrace) {
      _log.warning(
        'getDisplayTag failed, falling back to "Student"',
        e,
        stackTrace,
      );
      return 'Student';
    }
  }

  Future<void> postQuestion({
    required String body,
    required String tag,
    required String authorTag,
    required String authorUid,
  }) async {
    // Check rate limit before processing.
    final rateLimitResult = checkQuestionRateLimit(authorUid);
    if (!rateLimitResult.allowed) {
      throw ValidationError(formatRetryMessage(rateLimitResult.retryAfter));
    }

    final validation = validateQuestionInput(
      body: body,
      tag: tag,
      authorTag: authorTag,
      authorUid: authorUid,
    );
    if (validation != null) {
      throw validation;
    }
    await _db.from('questions').insert({
      'body': body,
      'tag': tag,
      'author_tag': authorTag,
      'author_uid': authorUid,
    });
  }

  Future<void> postAnswer({
    required String questionId,
    required String body,
    required String authorTag,
    required String authorUid,
  }) async {
    // Check rate limit before processing.
    final rateLimitResult = checkAnswerRateLimit(authorUid);
    if (!rateLimitResult.allowed) {
      throw ValidationError(formatRetryMessage(rateLimitResult.retryAfter));
    }

    final validation = validateAnswerInput(
      questionId: questionId,
      body: body,
      authorTag: authorTag,
      authorUid: authorUid,
    );
    if (validation != null) {
      throw validation;
    }
    await _db.rpc(
      'post_answer',
      params: {
        'p_question_id': questionId,
        'p_body': body,
        'p_author_tag': authorTag,
        'p_author_uid': authorUid,
      },
    );
  }

  Future<void> upvoteQuestion(String questionId, String uid) async {
    final rateLimitResult = checkUpvoteRateLimit(uid);
    if (!rateLimitResult.allowed) {
      throw ValidationError(formatRetryMessage(rateLimitResult.retryAfter));
    }

    final qidErr = validateUuid(questionId, label: 'Question ID');
    if (qidErr != null) {
      throw ValidationError(qidErr);
    }
    final uidErr = validateUuid(uid, label: 'User ID');
    if (uidErr != null) {
      throw ValidationError(uidErr);
    }
    await _db.rpc(
      'upvote_question',
      params: {'p_question_id': questionId, 'p_uid': uid},
    );
  }

  Future<void> upvoteAnswer(
    String questionId,
    String answerId,
    String uid,
  ) async {
    final rateLimitResult = checkUpvoteRateLimit(uid);
    if (!rateLimitResult.allowed) {
      throw ValidationError(formatRetryMessage(rateLimitResult.retryAfter));
    }

    final aidErr = validateUuid(answerId, label: 'Answer ID');
    if (aidErr != null) {
      throw ValidationError(aidErr);
    }
    final uidErr = validateUuid(uid, label: 'User ID');
    if (uidErr != null) {
      throw ValidationError(uidErr);
    }
    await _db.rpc(
      'upvote_answer',
      params: {'p_answer_id': answerId, 'p_uid': uid},
    );
  }
}
