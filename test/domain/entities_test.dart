import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/entities/match_result.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/raw_notification_event.dart';

void main() {
  test('RawNotificationEvent holds structured fields', () {
    final e = RawNotificationEvent(
      appId: 'com.tencent.mm', groupId: 'g1', groupName: '群',
      senderName: '王', senderId: null, content: '南京到上海',
      occurredAt: DateTime(2026, 7, 30, 14, 32),
    );
    expect(e.appId, 'com.tencent.mm');
    expect(e.content, '南京到上海');
  });
  test('MessageRecord defaults: score 0, isRead false', () {
    final r = MessageRecord(
      id: 'm1', appId: 'a', groupId: 'g', senderName: 's',
      content: 'c', occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp', createdAt: DateTime(2026),
    );
    expect(r.score, 0);
    expect(r.isRead, isFalse);
    expect(r.hits, isEmpty);
  });
  test('KeywordHit stores highlightPositions', () {
    const h = KeywordHit(ruleId: 'k', keyword: '到', type: MatchType.contains, priority: 50, highlightPositions: [2]);
    expect(h.highlightPositions, [2]);
  });
}
