import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:message_assistant/infrastructure/database/database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('insert and query message', () async {
    await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: 'm1', appId: 'a', groupId: 'g', senderName: 's', content: 'c',
      matchedKeywordsJson: const Value('[]'), occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp1', createdAt: DateTime(2026),
    ));
    final all = await db.messageDao.recentMessages();
    expect(all.length, 1);
    expect(all.first.id, 'm1');
  });

  test('fingerprint unique constraint rejects duplicate', () async {
    Future<void> insert(String id, String fp) => db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: id, appId: 'a', groupId: 'g', senderName: 's', content: 'c',
      matchedKeywordsJson: const Value('[]'), occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: fp, createdAt: DateTime(2026),
    ));
    await insert('m1', 'fp1');
    expect(() => insert('m2', 'fp1'), throwsA(isA<Object>()));
  });

  test('existsByFingerprint true/false', () async {
    await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: 'm1', appId: 'a', groupId: 'g', senderName: 's', content: 'c',
      matchedKeywordsJson: const Value('[]'), occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp1', createdAt: DateTime(2026),
    ));
    expect(await db.messageDao.existsByFingerprint('fp1'), isTrue);
    expect(await db.messageDao.existsByFingerprint('nope'), isFalse);
  });

  test('recentMessages ordered by occurredAt desc', () async {
    for (var i = 0; i < 3; i++) {
      await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
        id: 'm$i', appId: 'a', groupId: 'g', senderName: 's', content: 'c$i',
        matchedKeywordsJson: const Value('[]'),
        occurredAt: DateTime(2026, 1, i + 1), receivedAt: DateTime(2026),
        fingerprint: 'fp$i', createdAt: DateTime(2026),
      ));
    }
    final rows = await db.messageDao.recentMessages();
    expect(rows.map((r) => r.id).toList(), ['m2', 'm1', 'm0']);
  });

  test('recentMessages filter by groupId', () async {
    await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: 'm1', appId: 'a', groupId: 'gA', senderName: 's', content: 'c',
      matchedKeywordsJson: const Value('[]'), occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp1', createdAt: DateTime(2026),
    ));
    await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: 'm2', appId: 'a', groupId: 'gB', senderName: 's', content: 'c',
      matchedKeywordsJson: const Value('[]'), occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp2', createdAt: DateTime(2026),
    ));
    final a = await db.messageDao.recentMessages(groupId: 'gA');
    expect(a.length, 1);
    expect(a.first.id, 'm1');
  });

  test('markRead and markReplied update flags', () async {
    await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: 'm1', appId: 'a', groupId: 'g', senderName: 's', content: 'c',
      matchedKeywordsJson: const Value('[]'), occurredAt: DateTime(2026), receivedAt: DateTime(2026),
      fingerprint: 'fp1', createdAt: DateTime(2026),
    ));
    await db.messageDao.markRead('m1');
    expect((await db.messageDao.findById('m1'))!.isRead, isTrue);
    await db.messageDao.markReplied('m1', 'ok');
    final r = await db.messageDao.findById('m1');
    expect(r!.isReplied, isTrue);
    expect(r.replyContent, 'ok');
  });

  test('keyword upsert + all + delete', () async {
    await db.keywordDao.upsert(KeywordRulesCompanion.insert(
      id: 'k1', keyword: '南京', type: 1, createdAt: DateTime(2026),
    ));
    final all = await db.keywordDao.all();
    expect(all.length, 1);
    expect(all.first.keyword, '南京');
    await db.keywordDao.deleteById('k1');
    expect((await db.keywordDao.all()).length, 0);
  });

  test('fresh schema (onCreate) includes the jump_key column', () async {
    // A fresh in-memory DB runs onCreate → the table should have jump_key.
    final cols = await db.customSelect(
      "PRAGMA table_info(message_records)",
    ).get();
    final names = cols.map((r) => r.read<String>('name')).toSet();
    expect(names, contains('jump_key'));
    // And a roundtrip through the DAO with jumpKey works.
    await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: 'mj', appId: 'a', groupId: 'g', senderName: 's', content: 'c',
      matchedKeywordsJson: const Value('[]'), occurredAt: DateTime(2026),
      receivedAt: DateTime(2026), fingerprint: 'fpj', createdAt: DateTime(2026),
      jumpKey: const Value('g1'),
    ));
    final row = await db.messageDao.findById('mj');
    expect(row!.jumpKey, 'g1');
  });
}
