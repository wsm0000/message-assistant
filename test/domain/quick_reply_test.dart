import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/quick_reply.dart';

void main() {
  test('QuickReply defaults: enabled true, sortOrder 0', () {
    final q = QuickReply(id: 'q1', text: '接单', createdAt: DateTime(2026));
    expect(q.text, '接单');
    expect(q.enabled, isTrue);
    expect(q.sortOrder, 0);
    expect(q.isDefault, isFalse);
  });
  test('QuickReply factory newPhrase sets id non-empty and provided text', () {
    final q = QuickReply.newPhrase(text: '已发车', sortOrder: 2, isDefault: false);
    expect(q.text, '已发车');
    expect(q.id, isNotEmpty);
    expect(q.sortOrder, 2);
    expect(q.createdAt, isNotNull);
  });
}
