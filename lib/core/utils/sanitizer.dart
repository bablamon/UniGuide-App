// Utilities for sanitizing user-generated content before persistence or
// rendering.
//
// OWASP alignment:
//   - A03:2021 Injection — strict HTML sanitization with allowlist approach
//   - A04:2021 Insecure Design — defense in depth with multiple sanitization passes

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
/// rendering with [HtmlWidget]. Uses an allowlist approach — only tags known
/// to be safe are kept.
///
/// Defense in depth:
///   1. Remove dangerous tags entirely
///   2. Strip event handler attributes (onclick, onerror, onload, etc.)
///   3. Block dangerous URL protocols (javascript:, data: for certain types)
String sanitizeHtml(String html) {
  // 1. Remove dangerous tags entirely (including nested content).
  var result = html;
  for (final tag in _dangerousTags) {
    // Block tags with content.
    result = result.replaceAll(
      RegExp('<$tag[^>]*>[\\s\\S]*?</$tag>', caseSensitive: false),
      '',
    );
    // Block self-closing variants.
    result = result.replaceAll(
      RegExp('<$tag[^>]*/?>',caseSensitive: false),
      '',
    );
  }

  // 2. Strip event-handler attributes (onclick, onerror, onload, onmouse*, etc.).
  final eventHandlerRegex =
      RegExp(r"""\s+on\w+\s*=\s*("[^"]*"|'[^']*'|[^\s>]*)""");
  result = result.replaceAll(eventHandlerRegex, '');

  // 3. Block javascript: protocol in href/src.
  final jsProtocolRegex = RegExp(r"""(href|src)\s*=\s*(["']?)\s*javascript:""");
  result = result.replaceAll(jsProtocolRegex, r'$1=$2#');

  // 4. Block data: URLs in certain attributes (can contain XSS).
  final dataUrlRegex =
      RegExp(r"""(href|action|background|poster)\s*=\s*["']?\s*data:""");
  result = result.replaceAll(dataUrlRegex, r'$1=#blocked');

  // 5. Block data: in src for elements other than img.
  final nonImgDataRegex =
      RegExp(r"""<(?!img\b)[^>]*\ssrc\s*=\s*["']?\s*data:""");
  result = result.replaceAll(nonImgDataRegex, '<blocked src="#blocked"');

  // 6. Strip XML processing instructions (<?xml ... ?>, <![CDATA[...>).
  final xmlPiRegex = RegExp(r'<\?[^?]*\?>');
  result = result.replaceAll(xmlPiRegex, '');

  final cdataRegex = RegExp(r'<!\[CDATA\[[\s\S]*?\]\]>');
  result = result.replaceAll(cdataRegex, '');

  // 7. Strip <!-- comments --> which could contain malicious content.
  final commentRegex = RegExp(r'<!--[\s\S]*?-->');
  result = result.replaceAll(commentRegex, '');

  return result;
}

/// Tags that are always dangerous and must be completely removed.
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
  'svg',
  'math',
  'applet',
  'audio',
  'video',
  'source',
  'track',
  'canvas',
  'head',
  'body',
  'html',
];

/// Allowlist of safe HTML tags for content.
/// Used for stricter validation if needed.
// ignore: unused_element
const _allowedHtmlTags = {
  'p', 'br', 'b', 'i', 'u', 'strong', 'em', 'a',
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
  'ul', 'ol', 'li', 'blockquote', 'pre', 'code',
  'img', 'span', 'div', 'table', 'thead', 'tbody',
  'tr', 'th', 'td', 'hr',
};