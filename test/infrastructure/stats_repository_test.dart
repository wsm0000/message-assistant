import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:message_assistant/domain/entities/failure.dart';
import 'package:message_assistant/domain/entities/message_stats.dart';
import 'package:message_assistant/infrastructure/database/database.dart';
import 'package:message_assistant/infrastructure/database/stats_repository.dart';

void main() {
  late AppDatabase db;
  late DriftStatsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftStatsRepository(db);
  });
  tearDown(() => db.close());

  /// Insert a row with the given fields, using fixed ids to avoid fingerprint
  /// collisions. Occurred-at defaults to "now" if not supplied.
  Future<void> add({
    required String id,
    required String fingerprint,
    DateTime? occurredAt,
    String? groupName,
    bool isRead = false,
    bool isReplied = false,
    String matchedKeywordsJson = '[]',
    String groupId = 'g',
  }) async {
    final now = DateTime.now();
    await db.messageDao.insertMessage(MessageRecordsCompanion.insert(
      id: id,
      appId: 'a',
      groupId: groupId,
      groupName: groupName != null ? Value(groupName) : const Value.absent(),
      senderName: 's',
      content: 'c-$id',
      matchedKeywordsJson: Value(matchedKeywordsJson),
      score: const Value(0),
      occurredAt: occurredAt ?? now,
      receivedAt: now,
      isRead: Value(isRead),
      isReplied: Value(isReplied),
      fingerprint: fingerprint,
      createdAt: now,
    ));
  }

  // Keyword payloads ----------------------------------------------------------
  const kwNanjing = '[{"ruleId":"r1","keyword":"南京","type":1,"priority":1}]';
  const kwBeijing = '[{"ruleId":"r2","keyword":"北京","type":1,"priority":1}]';
  // Two-keyword row, to confirm multiple hits in one message both count.
  const kwTwo =
      '[{"ruleId":"r1","keyword":"南京","type":1,"priority":1},'
      '{"ruleId":"r2","keyword":"北京","type":1,"priority":1}]';

  group('DriftStatsRepository.getStats', () {
    test('returns zeroed stats on empty database', () async {
      final res = await repo.getStats();
      expect(res.isRight(), isTrue);
      final s = res.getOrElse(() => throw StateError('expected right'));
      expect(s.totalCount, 0);
      expect(s.todayCount, 0);
      expect(s.unreadCount, 0);
      expect(s.repliedCount, 0);
      expect(s.replyRate, 0.0);
      expect(s.last7Days.length, 7);
      // every day is zero
      expect(s.last7Days.every((d) => d.count == 0), isTrue);
      expect(s.topGroups, isEmpty);
      expect(s.topKeywords, isEmpty);
    });

    test('totalCount, todayCount, unreadCount, repliedCount are correct',
        () async {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      final yesterday = todayMidnight.subtract(const Duration(days: 1));

      // today, unread, replied
      await add(
        id: 't1', fingerprint: 'fp1', occurredAt: now,
        isRead: false, isReplied: true, groupName: 'G1',
      );
      // today, read, not replied
      await add(
        id: 't2', fingerprint: 'fp2', occurredAt: now,
        isRead: true, isReplied: false, groupName: 'G1',
      );
      // yesterday
      await add(
        id: 'y1', fingerprint: 'fp3', occurredAt: yesterday,
        isRead: true, isReplied: true, groupName: 'G2',
      );

      final s = await repo.getStats().then((r) => r.getOrElse(() => throw StateError('')));
      expect(s.totalCount, 3);
      expect(s.todayCount, 2);
      expect(s.unreadCount, 1, reason: 'only t1 is unread');
      expect(s.repliedCount, 2, reason: 't1 and y1 are replied');
      expect(s.replyRate, closeTo(2 / 3, 1e-9));
    });

    test('last7Days has 7 entries ordered oldest->newest, fills zeros, today correct',
        () async {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      // 3 days ago: 1 hit
      await add(
        id: 'd3', fingerprint: 'fp_a',
        occurredAt: todayMidnight.subtract(const Duration(days: 3)).add(const Duration(hours: 5)),
      );
      // today: 2 hits
      await add(id: 'td1', fingerprint: 'fp_b', occurredAt: now);
      await add(id: 'td2', fingerprint: 'fp_c', occurredAt: now);

      final s = await repo.getStats().then((r) => r.getOrElse(() => throw StateError('')));

      expect(s.last7Days.length, 7);
      // ordering: first entry is 6 days ago, last is today
      final firstDay = s.last7Days.first.day;
      final lastDay = s.last7Days.last.day;
      expect(firstDay, todayMidnight.subtract(const Duration(days: 6)));
      expect(lastDay, todayMidnight);
      // consecutive days, ascending
      for (var i = 0; i < s.last7Days.length - 1; i++) {
        final diff = s.last7Days[i + 1].day.difference(s.last7Days[i].day).inHours;
        expect(diff, 24, reason: 'entries must be consecutive days');
      }
      // today count = 2
      expect(s.last7Days.last.count, 2);
      // 3-days-ago count = 1
      final d3 = s.last7Days[s.last7Days.length - 4];
      expect(d3.day, todayMidnight.subtract(const Duration(days: 3)));
      expect(d3.count, 1);
      // all the "no hit" days are zero
      expect(s.last7Days.every((d) => d.count >= 0), isTrue);
      // every day is midnight-normalized
      expect(s.last7Days.every((d) =>
          d.day.hour == 0 && d.day.minute == 0 && d.day.second == 0 && d.day.millisecond == 0),
          isTrue);
    });

    test('last7Days excludes anything older than 7 days', () async {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      // 10 days ago — should NOT appear in last7Days even though total counts it
      await add(
        id: 'old', fingerprint: 'fp_old',
        occurredAt: todayMidnight.subtract(const Duration(days: 10)).add(const Duration(hours: 3)),
      );
      final s = await repo.getStats().then((r) => r.getOrElse(() => throw StateError('')));
      expect(s.totalCount, 1);
      expect(s.last7Days.every((d) => d.count == 0), isTrue,
          reason: 'the lone hit is 10 days old, outside the 7-day window');
    });

    test('topGroups ranks by count, excludes null/empty names, capped at 5', () async {
      // G1 x3, G2 x2, G3 x1, one null name (excluded), one empty name (excluded)
      for (final id in ['a1', 'a2', 'a3']) {
        await add(id: id, fingerprint: 'fp_$id', groupName: 'G1');
      }
      for (final id in ['b1', 'b2']) {
        await add(id: id, fingerprint: 'fp_$id', groupName: 'G2');
      }
      await add(id: 'c1', fingerprint: 'fp_c1', groupName: 'G3');
      await add(id: 'n1', fingerprint: 'fp_n1', groupName: null);
      await add(id: 'e1', fingerprint: 'fp_e1', groupName: '');

      final s = await repo.getStats().then((r) => r.getOrElse(() => throw StateError('')));
      expect(s.topGroups.length, 3);
      expect(s.topGroups[0], const NamedCount('G1', 3));
      expect(s.topGroups[1], const NamedCount('G2', 2));
      expect(s.topGroups[2], const NamedCount('G3', 1));
    });

    test('topGroups respects the limit of 5', () async {
      for (var i = 0; i < 8; i++) {
        await add(id: 'g$i', fingerprint: 'fp_g$i', groupName: 'G$i');
      }
      final s = await repo.getStats().then((r) => r.getOrElse(() => throw StateError('')));
      expect(s.topGroups.length, 5);
    });

    test('topKeywords parses matchedKeywordsJson and ranks correctly', () async {
      // 南京 appears in 3 rows (rows 1, 2, 3) -> should be #1
      await add(id: 'k1', fingerprint: 'fp_k1', matchedKeywordsJson: kwNanjing);
      await add(id: 'k2', fingerprint: 'fp_k2', matchedKeywordsJson: kwNanjing);
      await add(id: 'k3', fingerprint: 'fp_k3', matchedKeywordsJson: kwTwo);
      // 北京 appears in 2 rows (row 3 has it + row 4) -> #2
      await add(id: 'k4', fingerprint: 'fp_k4', matchedKeywordsJson: kwBeijing);
      // empty / malformed payloads must be tolerated
      await add(id: 'k5', fingerprint: 'fp_k5', matchedKeywordsJson: '[]');
      await add(id: 'k6', fingerprint: 'fp_k6', matchedKeywordsJson: 'not-json');

      final s = await repo.getStats().then((r) => r.getOrElse(() => throw StateError('')));
      expect(s.topKeywords.length, 2);
      expect(s.topKeywords[0], const NamedCount('南京', 3));
      expect(s.topKeywords[1], const NamedCount('北京', 2));
    });

    test('topKeywords is capped at 5', () async {
      for (var i = 0; i < 8; i++) {
        await add(
          id: 'kk$i', fingerprint: 'fp_kk$i',
          matchedKeywordsJson:
              '[{"ruleId":"r","keyword":"kw$i","type":1,"priority":1}]',
        );
      }
      final s = await repo.getStats().then((r) => r.getOrElse(() => throw StateError('')));
      expect(s.topKeywords.length, 5);
      // each distinct keyword appears exactly once
      expect(s.topKeywords.every((k) => k.count == 1), isTrue);
    });

    test('returns Left(DatabaseFailure) when the database throws', () async {
      // A broken executor that fails on `ensureOpen` reliably triggers the
      // repository's catch path regardless of how drift handles closed
      // in-memory databases.
      final brokenDb = AppDatabase.forTesting(_ThrowingExecutor());
      final brokenRepo = DriftStatsRepository(brokenDb);
      addTearDown(brokenDb.close);
      final res = await brokenRepo.getStats();
      expect(res.isLeft(), isTrue);
      res.fold(
        (f) => expect(f, isA<DatabaseFailure>()),
        (_) => fail('expected a Failure'),
      );
    });
  });

  group('DAO aggregate methods', () {
    // Direct DAO-level coverage of each method to lock in the SQL behaviour.

    test('totalCount / countToday / unreadCount / repliedCount', () async {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      await add(id: 'd1', fingerprint: 'f1', occurredAt: now,
          isRead: false, isReplied: true);
      await add(id: 'd2', fingerprint: 'f2', occurredAt: now,
          isRead: true, isReplied: false);
      await add(
        id: 'd3', fingerprint: 'f3',
        occurredAt: todayMidnight.subtract(const Duration(days: 2)),
        isRead: false, isReplied: false,
      );

      expect(await db.messageDao.totalCount(), 3);
      expect(await db.messageDao.countToday(), 2);
      expect(await db.messageDao.unreadCount(), 2);
      expect(await db.messageDao.repliedCount(), 1);
    });

    test('last7DaysCounts length 7 oldest->newest with zeros filled', () async {
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      await add(
        id: 'x', fingerprint: 'fx',
        occurredAt: todayMidnight.subtract(const Duration(days: 1)),
      );
      final days = await db.messageDao.last7DaysCounts();
      expect(days.length, 7);
      expect(days.last.day, todayMidnight);
      expect(days.last.count, 0, reason: 'today has no hits, only yesterday does');
      expect(days[days.length - 2].count, 1);
    });

    test('topGroups(2) limits results', () async {
      await add(id: 'p1', fingerprint: 'p1', groupName: 'A');
      await add(id: 'p2', fingerprint: 'p2', groupName: 'A');
      await add(id: 'p3', fingerprint: 'p3', groupName: 'B');
      await add(id: 'p4', fingerprint: 'p4', groupName: 'C');
      final r = await db.messageDao.topGroups(2);
      expect(r.length, 2);
      expect(r[0], const NamedCount('A', 2));
      expect(r[1], const NamedCount('B', 1));
    });

    test('topKeywords(2) limits results', () async {
      await add(id: 'q1', fingerprint: 'q1', matchedKeywordsJson: kwNanjing);
      await add(id: 'q2', fingerprint: 'q2', matchedKeywordsJson: kwNanjing);
      await add(id: 'q3', fingerprint: 'q3', matchedKeywordsJson: kwBeijing);
      final r = await db.messageDao.topKeywords(2);
      expect(r.length, 2);
      expect(r[0], const NamedCount('南京', 2));
      expect(r[1], const NamedCount('北京', 1));
    });
  });
}

/// A [QueryExecutor] that always throws on `ensureOpen`, used to verify the
/// repository wraps database errors in a [DatabaseFailure]. `ensureOpen`
/// throws before any query method is ever called, so we only need concrete
/// implementations of it plus the `dialect` getter and `close` (which runs
/// during teardown).
class _ThrowingExecutor implements QueryExecutor {
  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async {
    throw StateError('boom: database unavailable');
  }

  @override
  SqlDialect get dialect => SqlDialect.sqlite;

  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('ThrowingExecutor.${invocation.memberName}');
}
