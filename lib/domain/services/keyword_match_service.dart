import '../entities/keyword_rule.dart';
import '../entities/message_record.dart';
import '../entities/match_result.dart';

/// The core keyword-matching engine of the message assistant.
///
/// Given a [MessageRecord] and a list of [KeywordRule]s, [match] scans the
/// message content and returns a [MatchResult] describing which rules hit and
/// where (as 0-based character indices into the content, for UI highlighting),
/// or `null` when nothing matched.
///
/// Design notes:
/// * Pure Dart, no dependencies, no Flutter. Fully unit-testable.
/// * The constructor takes no dependencies so future index structures
///   (Trie / Aho-Corasick) can be dropped in without changing the call site.
/// * Matching is case-insensitive (via [String.toLowerCase]); this does not
///   affect CJK text. Highlight positions are character indices into the
///   *original* content — lowercasing never changes index alignment.
class KeywordMatchService {
  MatchResult? match(MessageRecord message, List<KeywordRule> rules) {
    final contentLower = message.content.toLowerCase();
    final hits = <KeywordHit>[];

    for (final rule in rules) {
      if (!rule.enabled) continue;

      // Group scope filter: a non-empty scope that does not include this
      // message's group id means the rule does not apply here.
      if (rule.scopeGroupIds.isNotEmpty &&
          !rule.scopeGroupIds.contains(message.groupId)) {
        continue;
      }

      // Exclude words: if the content contains any of them
      // (case-insensitive), the whole rule is skipped.
      if (rule.excludeWords
          .any((w) => contentLower.contains(w.toLowerCase()))) {
        continue;
      }

      final kwLower = rule.keyword.toLowerCase();

      switch (rule.type) {
        case MatchType.exact:
          // Whole content (trimmed) must equal the keyword (trimmed),
          // case-insensitive. No specific highlight position — the match is
          // the entire string, so positions is the empty list.
          if (contentLower.trim() == kwLower.trim()) {
            hits.add(KeywordHit(
              ruleId: rule.id,
              keyword: rule.keyword,
              type: rule.type,
              priority: rule.priority,
              highlightPositions: const <int>[],
            ));
          }
          break;
        case MatchType.contains:
          final positions = _findAll(contentLower, kwLower);
          // An empty positions list means the keyword did not occur (or is an
          // empty keyword) — in either case there is no hit for this rule.
          if (positions.isNotEmpty) {
            hits.add(KeywordHit(
              ruleId: rule.id,
              keyword: rule.keyword,
              type: rule.type,
              priority: rule.priority,
              highlightPositions: positions,
            ));
          }
          break;
      }
    }

    if (hits.isEmpty) return null;

    // Highest priority first; ties keep insertion (rule list) order since
    // List.sort is stable.
    hits.sort((a, b) => b.priority.compareTo(a.priority));

    final score = hits.fold<int>(0, (s, h) => s + h.priority);

    return MatchResult(
      message: message.copyWith(hits: hits, score: score),
      hits: hits,
      score: score,
    );
  }

  /// Finds every start index of [needle] within [haystack] (both already
  /// lower-cased). Non-overlapping: each match advances by the needle length.
  /// Returns an empty list for an empty needle (nothing to find).
  List<int> _findAll(String haystack, String needle) {
    if (needle.isEmpty) return const <int>[];
    final positions = <int>[];
    var start = 0;
    while (true) {
      final idx = haystack.indexOf(needle, start);
      if (idx == -1) break;
      positions.add(idx);
      start = idx + needle.length;
    }
    return positions;
  }
}
