// Shared validation helpers.

/// Permissive email regex — allows TLDs longer than 4 chars
/// (e.g. .museum, .technology, .college).
final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');

/// Returns `true` when [email] looks like a valid email address.
bool isValidEmail(String email) => emailRegex.hasMatch(email.trim().toLowerCase());
