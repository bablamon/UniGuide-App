// Utilities for sanitizing user-generated content before persistence or
// rendering.

/// Strips control characters, trims whitespace, and enforces a maximum length
/// on plain-text input (questions, answers, etc.).
String sanitizePlainText(String input, {int maxLength = 5000}) {
  // Remove ASCII control chars (except newline/tab) and trim.
  final cleaned = input
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
      .trim();
  if (cleaned.length <= maxLength) return cleaned;
  return cleaned.substring(0, maxLength);
}

/// Strips dangerous HTML tags and attributes from wiki article HTML before
/// rendering with [HtmlWidget].  Uses an allowlist approach — only tags known
/// to be safe are kept.
String sanitizeHtml(String html) {
  // Remove <script>, <iframe>, <object>, <embed>, <style>, <form> blocks.
  var result = html;
  for (final tag in _dangerousTags) {
    result = result.replaceAll(
      RegExp('<$tag[^>]*>[\\s\\S]*?</$tag>', caseSensitive: false),
      '',
    );
    // Self-closing variants.
    result = result.replaceAll(
      RegExp('<$tag[^>]*/?>',  caseSensitive: false),
      '',
    );
  }

  // Strip event-handler attributes (onclick, onerror, onload, …).
  result = result.replaceAll(
    RegExp(r'''\s+on\w+\s*=\s*("[^"]*"|'[^']*'|[^\s>]*)''', caseSensitive: false),
    '',
  );

  // Strip javascript: protocol in href/src.
  result = result.replaceAll(
    RegExp(r'''(href|src)\s*=\s*(['"]?)\s*javascript:''', caseSensitive: false),
    r'$1=$2#',
  );

  return result;
}

const _dangerousTags = [
  'script',
  'iframe',
  'object',
  'embed',
  'style',
  'form',
  'base',
  'link',
  'meta',
];
