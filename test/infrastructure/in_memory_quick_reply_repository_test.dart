import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/quick_reply.dart';
import 'package:message_assistant/infrastructure/storage/in_memory_quick_reply_repository.dart';

void main() {
  test('findAll returns defaults sorted by sortOrder', () async {
    final repo = InMemoryQuickReplyRepository();
    final list = (await repo.findAll()).getOrElse(() => []);
    expect(list.map((p) => p.text).toList(), ['接单', '已发车', '稍后联系', '已满']);
  });
  test('save new adds; findAll includes it', () async {
    final repo = InMemoryQuickReplyRepository(seed: const []);
    await repo.save(QuickReply(id: 'q1', text: 'X', sortOrder: 0, createdAt: DateTime(2026)));
    final list = (await repo.findAll()).getOrElse(() => []);
    expect(list.length, 1);
    expect(list.first.text, 'X');
  });
  test('save existing updates text', () async {
    final repo = InMemoryQuickReplyRepository();
    await repo.save(QuickReply(id: 'default_jiedan', text: '接单啦', sortOrder: 0, isDefault: true, createdAt: DateTime(2026)));
    final list = (await repo.findAll()).getOrElse(() => []);
    expect(list.firstWhere((p) => p.id == 'default_jiedan').text, '接单啦');
    expect(list.length, 4); // not duplicated
  });
  test('delete removes', () async {
    final repo = InMemoryQuickReplyRepository();
    await repo.delete('default_jiedan');
    final list = (await repo.findAll()).getOrElse(() => []);
    expect(list.any((p) => p.id == 'default_jiedan'), isFalse);
    expect(list.length, 3);
  });
  test('reorder updates sortOrder', () async {
    final repo = InMemoryQuickReplyRepository();
    await repo.reorder(['default_yiman', 'default_jiedan', 'default_facar', 'default_shaohou']);
    final list = (await repo.findAll()).getOrElse(() => []);
    expect(list.map((p) => p.id).toList(),
        ['default_yiman', 'default_jiedan', 'default_facar', 'default_shaohou']);
  });
}
