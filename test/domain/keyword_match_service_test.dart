import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/services/keyword_match_service.dart';

KeywordRule _kw(String id, String word,
        {MatchType type = MatchType.contains,
        int priority = 50,
        List<String> scope = const [],
        List<String> exclude = const [],
        bool enabled = true}) =>
    KeywordRule(
      id: id,
      keyword: word,
      type: type,
      priority: priority,
      scopeGroupIds: scope,
      excludeWords: exclude,
      enabled: enabled,
      createdAt: DateTime(2026),
    );

MessageRecord _msg(String content, {String groupId = 'g'}) => MessageRecord(
    id: 'm',
    appId: 'a',
    groupId: groupId,
    senderName: 's',
    content: content,
    occurredAt: DateTime(2026),
    receivedAt: DateTime(2026),
    fingerprint: 'f',
    createdAt: DateTime(2026));

void main() {
  final svc = KeywordMatchService();

  test('contains hit records position', () {
    final r = svc.match(_msg('南京到上海'), [_kw('k1', '到')]);
    expect(r, isNotNull);
    expect(r!.hits.single.keyword, '到');
    expect(r.hits.single.highlightPositions, [2]); // 南[京][到]上[海] — 到 is at index 2
    expect(r.score, 50);
  });

  test('exact does NOT match substring', () {
    final r = svc.match(_msg('上海港'), [_kw('k1', '上海', type: MatchType.exact)]);
    expect(r, isNull);
  });

  test('exact matches whole string', () {
    final r = svc.match(
        _msg('上海'), [_kw('k1', '上海', type: MatchType.exact, priority: 80)]);
    expect(r, isNotNull);
    expect(r!.score, 80);
  });

  test('multiple hits sorted by priority desc, score summed', () {
    final r = svc.match(_msg('台州到南通'), [
      _kw('low', '到', priority: 30),
      _kw('hi', '南通', priority: 80),
      _kw('mid', '台州', priority: 50)
    ]);
    expect(r!.hits.map((h) => h.keyword).toList(), ['南通', '台州', '到']);
    expect(r.score, 30 + 80 + 50);
  });

  test('excludeWord skips rule', () {
    final r = svc.match(
        _msg('南京到上海测试'), [_kw('k1', '南京', exclude: ['测试'])]);
    expect(r, isNull);
  });

  test('scopeGroupIds non-empty and not containing groupId skips rule', () {
    final r = svc.match(_msg('南京', groupId: 'gA'),
        [_kw('k1', '南京', scope: ['gB'])]);
    expect(r, isNull);
  });

  test('scopeGroupIds containing groupId matches', () {
    final r = svc.match(
        _msg('南京', groupId: 'gA'), [_kw('k1', '南京', scope: ['gA'])]);
    expect(r, isNotNull);
  });

  test('disabled rule skipped', () {
    final r = svc.match(_msg('南京'), [_kw('k1', '南京', enabled: false)]);
    expect(r, isNull);
  });

  test('english case-insensitive', () {
    final r = svc.match(_msg('SHANGHAI'), [_kw('k1', 'shanghai')]);
    expect(r, isNotNull);
  });

  test('no hit returns null', () {
    expect(svc.match(_msg('无关内容'), [_kw('k1', '南京')]), isNull);
  });

  test('all-occurrences positions for repeated keyword', () {
    final r = svc.match(_msg('到这到那'), [_kw('k1', '到')]);
    expect(r!.hits.single.highlightPositions, [0, 2]); // [到]这[到]那
  });

  test('empty rules list returns null', () {
    expect(svc.match(_msg('南京'), []), isNull);
  });

  test('exact match is case-insensitive too', () {
    final r = svc.match(
        _msg('Shanghai'), [_kw('k1', 'SHANGHAI', type: MatchType.exact)]);
    expect(r, isNotNull);
  });

  test('exact match trims surrounding whitespace in content', () {
    final r = svc.match(
        _msg('  上海  '), [_kw('k1', '上海', type: MatchType.exact)]);
    expect(r, isNotNull);
  });
}
