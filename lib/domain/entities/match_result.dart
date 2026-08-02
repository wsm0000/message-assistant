import 'package:freezed_annotation/freezed_annotation.dart';
import 'keyword_rule.dart'; // for MatchType
import 'message_record.dart';
part 'match_result.freezed.dart';

@freezed
class KeywordHit with _$KeywordHit {
  const factory KeywordHit({
    required String ruleId,
    required String keyword,
    required MatchType type,
    required int priority,
    required List<int> highlightPositions,
  }) = _KeywordHit;
}

@freezed
class MatchResult with _$MatchResult {
  const factory MatchResult({
    required MessageRecord message,
    required List<KeywordHit> hits,
    required int score,
  }) = _MatchResult;
}
