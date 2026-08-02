import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';

void main() {
  test('defaults: contains type, priority 50, enabled true, empty lists', () {
    final k = KeywordRule(id: 'k1', keyword: '南京', createdAt: DateTime(2026));
    expect(k.type, MatchType.contains);
    expect(k.priority, 50);
    expect(k.enabled, isTrue);
    expect(k.scopeGroupIds, isEmpty);
    expect(k.excludeWords, isEmpty);
  });
  test('MatchType enum has exact and contains', () {
    expect(MatchType.values, containsAll([MatchType.exact, MatchType.contains]));
  });
}
