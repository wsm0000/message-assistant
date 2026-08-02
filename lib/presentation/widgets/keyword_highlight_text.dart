import 'package:flutter/material.dart';
import '../../domain/entities/match_result.dart';

/// Renders [text] with matched keyword substrings highlighted (background color).
///
/// Highlight ranges are derived from each [KeywordHit]'s
/// [KeywordHit.highlightPositions] (start indices) extended by the keyword's
/// length. Characters inside any range get a background color; others stay
/// plain. Consecutive same-state characters are grouped into a single span.
class KeywordHighlightText extends StatelessWidget {
  final String text;
  final List<KeywordHit> hits;
  final TextStyle? baseStyle;
  final Color highlightColor;

  const KeywordHighlightText({
    super.key,
    required this.text,
    required this.hits,
    this.baseStyle,
    this.highlightColor = const Color(0xFFFFD54F), // amber
  });

  @override
  Widget build(BuildContext context) {
    final base = baseStyle ?? DefaultTextStyle.of(context).style;

    if (hits.isEmpty) {
      return RichText(
        text: TextSpan(style: base, children: [TextSpan(text: text)]),
      );
    }

    // Build the set of character indices that should be highlighted.
    final highlighted = <int>{};
    for (final h in hits) {
      final kwLen = h.keyword.length;
      for (final start in h.highlightPositions) {
        for (var i = 0; i < kwLen; i++) {
          final idx = start + i;
          if (idx >= 0 && idx < text.length) highlighted.add(idx);
        }
      }
    }

    // Walk the string char-by-char, grouping consecutive same-highlight runs
    // into spans. This keeps multi-char keywords (e.g. '南京') as ONE span.
    final spans = <TextSpan>[];
    var buf = StringBuffer();
    bool? currentHi; // null = not yet started
    void flush() {
      if (buf.isNotEmpty) {
        if (currentHi == true) {
          spans.add(TextSpan(
              text: buf.toString(), style: TextStyle(backgroundColor: highlightColor)));
        } else {
          spans.add(TextSpan(text: buf.toString()));
        }
        buf = StringBuffer();
      }
    }

    for (var i = 0; i < text.length; i++) {
      final isHi = highlighted.contains(i);
      if (currentHi == null) {
        currentHi = isHi;
        buf.write(text[i]);
      } else if (isHi == currentHi) {
        buf.write(text[i]);
      } else {
        flush();
        currentHi = isHi;
        buf.write(text[i]);
      }
    }
    flush();

    return RichText(
      text: TextSpan(style: base, children: spans),
    );
  }
}
