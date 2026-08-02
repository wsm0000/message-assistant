import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:message_assistant/domain/entities/message_record.dart' as dom;
import 'package:message_assistant/domain/entities/keyword_rule.dart'
    as dom
    show KeywordRule, MatchType;
import 'package:message_assistant/domain/entities/match_result.dart'
    show KeywordHit;
import 'package:message_assistant/infrastructure/database/database.dart';
import 'package:message_assistant/infrastructure/database/drift_repositories.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('DriftMessageRepository save + findById roundtrip preserves hits/score',
      () async {
    final repo = DriftMessageRepository(db);
    final msg = dom.MessageRecord(
      id: 'm1',
      appId: 'a',
      groupId: 'g',
      groupName: '群',
      senderName: '王',
      content: '南京到上海',
      hits: const [
        KeywordHit(
            ruleId: 'k',
            keyword: '到',
            type: dom.MatchType.contains,
            priority: 50,
            highlightPositions: [2])
      ],
      score: 50,
      occurredAt: DateTime(2026),
      receivedAt: DateTime(2026),
      fingerprint: 'fp1',
      createdAt: DateTime(2026),
    );
    final saved = await repo.save(msg);
    expect(saved.isRight(), isTrue);
    final found = await repo.findById('m1');
    final m = found.fold((l) => null, (r) => r);
    expect(m, isNotNull);
    expect(m!.content, '南京到上海');
    expect(m.hits.single.keyword, '到');
    expect(m.hits.single.highlightPositions, [2]);
    expect(m.score, 50);
    expect(m.groupName, '群');
  });

  test('DriftMessageRepository existsByFingerprint', () async {
    final repo = DriftMessageRepository(db);
    final msg = dom.MessageRecord(
      id: 'm1',
      appId: 'a',
      groupId: 'g',
      senderName: '王',
      content: 'x',
      occurredAt: DateTime(2026),
      receivedAt: DateTime(2026),
      fingerprint: 'fp1',
      createdAt: DateTime(2026),
    );
    expect((await repo.existsByFingerprint('fp1')).getOrElse(() => true),
        isFalse);
    await repo.save(msg);
    expect((await repo.existsByFingerprint('fp1')).getOrElse(() => false),
        isTrue);
  });

  test('DriftMessageRepository findRecentPaged returns list', () async {
    final repo = DriftMessageRepository(db);
    await repo.save(dom.MessageRecord(
      id: 'm1',
      appId: 'a',
      groupId: 'gA',
      senderName: '王',
      content: 'x',
      occurredAt: DateTime(2026),
      receivedAt: DateTime(2026),
      fingerprint: 'fp1',
      createdAt: DateTime(2026),
    ));
    final all = await repo.findRecentPaged();
    final list = all.getOrElse(() => <dom.MessageRecord>[]);
    expect(list.length, 1);
    final filtered =
        (await repo.findRecentPaged(groupId: 'gA')).getOrElse(() => <dom.MessageRecord>[]);
    expect(filtered.length, 1);
    final none =
        (await repo.findRecentPaged(groupId: 'gZ')).getOrElse(() => <dom.MessageRecord>[]);
    expect(none.length, 0);
  });

  test('DriftMessageRepository markRead / markReplied', () async {
    final repo = DriftMessageRepository(db);
    await repo.save(dom.MessageRecord(
      id: 'm1',
      appId: 'a',
      groupId: 'g',
      senderName: '王',
      content: 'x',
      occurredAt: DateTime(2026),
      receivedAt: DateTime(2026),
      fingerprint: 'fp1',
      createdAt: DateTime(2026),
    ));
    await repo.markRead('m1');
    final r1 = (await repo.findById('m1')).fold((_) => null, (r) => r);
    expect(r1!.isRead, isTrue);
    await repo.markReplied('m1', '接单');
    final r2 = (await repo.findById('m1')).fold((_) => null, (r) => r);
    expect(r2!.isReplied, isTrue);
    expect(r2.replyContent, '接单');
  });

  test('DriftMessageRepository preserves jumpKey through save/read roundtrip',
      () async {
    final repo = DriftMessageRepository(db);
    await repo.save(dom.MessageRecord(
      id: 'mj',
      appId: 'a',
      groupId: 'g',
      senderName: '王',
      content: 'x',
      occurredAt: DateTime(2026),
      receivedAt: DateTime(2026),
      fingerprint: 'fpj',
      createdAt: DateTime(2026),
      jumpKey: 'group-jump-key',
    ));
    final got =
        (await repo.findById('mj')).fold((_) => null, (r) => r);
    expect(got, isNotNull);
    expect(got!.jumpKey, 'group-jump-key');

    // A record saved without a jumpKey reads back as null (old-row behavior).
    await repo.save(dom.MessageRecord(
      id: 'mn',
      appId: 'a',
      groupId: 'g2',
      senderName: '王',
      content: 'y',
      occurredAt: DateTime(2026),
      receivedAt: DateTime(2026),
      fingerprint: 'fpn',
      createdAt: DateTime(2026),
    ));
    final noJump =
        (await repo.findById('mn')).fold((_) => null, (r) => r);
    expect(noJump!.jumpKey, isNull);
  });

  test(
      'DriftKeywordRepository save + findAll roundtrip preserves scope/exclude/type',
      () async {
    final repo = DriftKeywordRepository(db);
    final k = dom.KeywordRule(
      id: 'k1',
      keyword: '南京',
      type: dom.MatchType.exact,
      priority: 80,
      scopeGroupIds: const ['gA', 'gB'],
      excludeWords: const ['测试'],
      enabled: true,
      groupName: '货运',
      createdAt: DateTime(2026),
    );
    final saved = await repo.save(k);
    expect(saved.isRight(), isTrue);
    final all = (await repo.findAll()).getOrElse(() => <dom.KeywordRule>[]);
    expect(all.length, 1);
    final got = all.first;
    expect(got.keyword, '南京');
    expect(got.type, dom.MatchType.exact);
    expect(got.priority, 80);
    expect(got.scopeGroupIds, ['gA', 'gB']);
    expect(got.excludeWords, ['测试']);
    expect(got.groupName, '货运');
  });

  test('DriftKeywordRepository findByScope returns only enabled rules',
      () async {
    final repo = DriftKeywordRepository(db);
    await repo.save(dom.KeywordRule(
        id: 'k1', keyword: '南京', enabled: true, createdAt: DateTime(2026)));
    await repo.save(dom.KeywordRule(
        id: 'k2', keyword: '上海', enabled: false, createdAt: DateTime(2026)));
    final scoped =
        (await repo.findByScope('anyGroup')).getOrElse(() => <dom.KeywordRule>[]);
    expect(scoped.length, 1);
    expect(scoped.first.id, 'k1');
  });

  test('DriftKeywordRepository delete removes rule', () async {
    final repo = DriftKeywordRepository(db);
    await repo.save(
        dom.KeywordRule(id: 'k1', keyword: '南京', createdAt: DateTime(2026)));
    await repo.delete('k1');
    expect(
        ((await repo.findAll()).getOrElse(() => <dom.KeywordRule>[])).length, 0);
  });
}
