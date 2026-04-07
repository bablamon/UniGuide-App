// Schema-based input validation for all user-supplied data.
//
// Every validator follows the same contract:
//   - Returns null on success.
//   - Returns a human-readable error string on failure.
//
// OWASP alignment:
//   - A03:2021 Injection — strict type checks, length limits, allowlists
//   - A04:2021 Insecure Design — reject unexpected fields, fail closed
//   - A10:2021 SSRF — UUID format validation for resource IDs

import 'validators.dart';

// ── Validation error ────────────────────────────────────────────────────────

/// Thrown when input fails schema validation.
/// Carry a user-safe message (no internal details).
class ValidationError implements Exception {
  final String message;
  const ValidationError(this.message);
  @override
  String toString() => 'ValidationError: $message';
}

// ── Allowed value sets (allowlists) ─────────────────────────────────────────

const _allowedQaTags = {
  'General',
  'Exams',
  'ERP',
  'Placements',
  'Hostel',
  'Facilities',
  'Fees',
  'Other',
};

const _allowedWikiCategories = {
  'all',
  'exams',
  'erp',
  'placements',
  'facilities',
  'hostel',
};

const _allowedBranches = {
  'CS',
  'IT',
  'Mech',
  'Civil',
  'ENTC',
  'EE',
  'Chem',
  'Other',
};

// Strict UUID v4 regex — 8-4-4-4-12 hex with version nibble = 4.
final _uuidRegex = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

// RFC 5321: max 254 octets for an email address.
const _maxEmailLength = 254;

// ── Primitive validators ────────────────────────────────────────────────────

/// Validates that [value] is a non-null, non-empty string within [maxLength].
String? validateRequiredString(
  String? value, {
  int maxLength = 255,
  String label = 'Field',
}) {
  if (value == null) return '$label is required.';
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '$label cannot be empty.';
  if (trimmed.length > maxLength) {
    return '$label must be at most $maxLength characters.';
  }
  return null;
}

/// Validates a UUID string (strict v4 format).
String? validateUuid(String? value, {String label = 'ID'}) {
  if (value == null || value.isEmpty) return '$label is required.';
  if (!_uuidRegex.hasMatch(value)) return '$label has an invalid format.';
  return null;
}

/// Validates an email address: type, length, format.
String? validateEmail(String? value) {
  if (value == null) return 'Email is required.';
  final trimmed = value.trim().toLowerCase();
  if (trimmed.isEmpty) return 'Email cannot be empty.';
  if (trimmed.length > _maxEmailLength) return 'Email is too long.';
  if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address.';
  return null;
}

/// Validates that an integer is within [min]..[max] (inclusive).
String? validateIntRange(int? value, int min, int max, String label) {
  if (value == null) return '$label is required.';
  if (value < min || value > max) {
    return '$label must be between $min and $max.';
  }
  return null;
}

/// Validates that [value] is one of the allowed strings (case-sensitive).
String? validateAllowlist(String? value, Set<String> allowed, String label) {
  if (value == null) return '$label is required.';
  if (!allowed.contains(value)) return '$label has an invalid value.';
  return null;
}

// ── Domain validators (schema-based) ────────────────────────────────────────

/// Validates a question submission payload.
///
/// Rejects unexpected fields by only accepting known keys.
/// Returns null on success, or a ValidationError on failure.
ValidationError? validateQuestionInput({
  required String? body,
  required String? tag,
  required String? authorTag,
  required String? authorUid,
}) {
  // Reject unexpected extra fields at the call-site by validating each known
  // field individually. The repository layer should never receive a raw Map
  // with arbitrary keys.

  final bodyErr = validateRequiredString(
    body,
    maxLength: 5000,
    label: 'Question body',
  );
  if (bodyErr != null) return ValidationError(bodyErr);

  // Minimum meaningful length to prevent spam / empty-ish posts.
  if (body!.trim().length < 10) {
    return const ValidationError('Question must be at least 10 characters.');
  }

  final tagErr = validateAllowlist(tag, _allowedQaTags, 'Tag');
  if (tagErr != null) return ValidationError(tagErr);

  final authorTagErr = validateRequiredString(
    authorTag,
    maxLength: 50,
    label: 'Author tag',
  );
  if (authorTagErr != null) return ValidationError(authorTagErr);

  final uidErr = validateUuid(authorUid, label: 'Author UID');
  if (uidErr != null) return ValidationError(uidErr);

  return null;
}

/// Validates an answer submission payload.
ValidationError? validateAnswerInput({
  required String? body,
  required String? questionId,
  required String? authorTag,
  required String? authorUid,
}) {
  final bodyErr = validateRequiredString(
    body,
    maxLength: 5000,
    label: 'Answer body',
  );
  if (bodyErr != null) return ValidationError(bodyErr);

  if (body!.trim().length < 5) {
    return const ValidationError('Answer must be at least 5 characters.');
  }

  final qidErr = validateUuid(questionId, label: 'Question ID');
  if (qidErr != null) return ValidationError(qidErr);

  final authorTagErr = validateRequiredString(
    authorTag,
    maxLength: 50,
    label: 'Author tag',
  );
  if (authorTagErr != null) return ValidationError(authorTagErr);

  final uidErr = validateUuid(authorUid, label: 'Author UID');
  if (uidErr != null) return ValidationError(uidErr);

  return null;
}

/// Validates onboarding data (year + branch selection).
ValidationError? validateOnboardingInput({
  required int? year,
  required String? branch,
}) {
  final yearErr = validateIntRange(year, 1, 4, 'Year');
  if (yearErr != null) return ValidationError(yearErr);

  final branchErr = validateAllowlist(branch, _allowedBranches, 'Branch');
  if (branchErr != null) return ValidationError(branchErr);

  return null;
}

/// Validates a wiki article category filter.
String? validateWikiCategory(String? value) {
  return validateAllowlist(value, _allowedWikiCategories, 'Category');
}

/// Validates a resource ID used in URL path parameters.
/// Accepts any non-empty string up to 100 chars (Supabase UUIDs are 36 chars).
String? validateResourceId(String? value, {String label = 'ID'}) {
  if (value == null || value.trim().isEmpty) return '$label is required.';
  if (value.length > 100) return '$label is too long.';
  // Reject anything that looks like path traversal.
  if (value.contains('..') || value.contains('/') || value.contains('\\')) {
    return '$label contains invalid characters.';
  }
  return null;
}

/// Validates a bookmark toggle request.
ValidationError? validateBookmarkInput({
  required String? articleId,
  required String? uid,
}) {
  final articleErr = validateUuid(articleId, label: 'Article ID');
  if (articleErr != null) return ValidationError(articleErr);

  final uidErr = validateUuid(uid, label: 'User ID');
  if (uidErr != null) return ValidationError(uidErr);

  return null;
}

/// Validates a user profile display name / tag.
String? validateDisplayName(String? value) {
  return validateRequiredString(value, maxLength: 100, label: 'Display name');
}
