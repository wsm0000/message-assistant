import 'package:freezed_annotation/freezed_annotation.dart';
part 'keyword_rule.freezed.dart';
part 'keyword_rule.g.dart';

enum MatchType { exact, contains }

@freezed
class KeywordRule with _$KeywordRule {
  const factory KeywordRule({
    required String id,
    required String keyword,
    @Default(MatchType.contains) MatchType type,
    @Default(50) int priority,
    @Default([]) List<String> scopeGroupIds,
    @Default([]) List<String> excludeWords,
    @Default(true) bool enabled,
    String? groupName,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _KeywordRule;

  factory KeywordRule.fromJson(Map<String, dynamic> json) =>
      _$KeywordRuleFromJson(json);
}
