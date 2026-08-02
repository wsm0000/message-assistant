import 'dart:convert';

import 'package:drift/drift.dart';
import '../../../domain/entities/message_stats.dart';
import '../database.dart';
import '../tables/messages.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [MessageRecords])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Future<void> insertMessage(MessageRecordsCompanion entry) {
    return into(messageRecords).insert(entry);
  }

  Future<List<MessageRecord>> recentMessages({
    String? groupId,
    int limit = 50,
    int offset = 0,
  }) {
    final q = (select(messageRecords)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
      ..limit(limit, offset: offset));
    if (groupId != null) {
      q.where((t) => t.groupId.equals(groupId));
    }
    return q.get();
  }

  Future<bool> existsByFingerprint(String fp) async {
    final q = select(messageRecords)
      ..where((t) => t.fingerprint.equals(fp))
      ..limit(1);
    final r = await q.get();
    return r.isNotEmpty;
  }

  Future<MessageRecord?> findById(String id) {
    return (select(messageRecords)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> markRead(String id) =>
      (update(messageRecords)..where((t) => t.id.equals(id)))
          .write(const MessageRecordsCompanion(isRead: Value(true)));

  Future<void> markReplied(String id, String replyContent) =>
      (update(messageRecords)..where((t) => t.id.equals(id))).write(
        MessageRecordsCompanion(
          isReplied: const Value(true),
          replyContent: Value(replyContent),
        ),
      );

  // ---------------------------------------------------------------------------
  // Aggregate stats queries (dashboard F13).
  //
  // Drift stores `DateTimeColumn` values as epoch *seconds* (not millis) in this
  // project, so all `occurred_at` comparisons and `date()` conversions below
  // work directly in seconds — no `/1000` needed. This was confirmed empirically
  // against the generated schema (date(occurred_at,'unixepoch','localtime')
  // yields the expected YYYY-MM-DD for a known timestamp).
  // ---------------------------------------------------------------------------

  /// Total number of stored messages.
  Future<int> totalCount() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM message_records',
    ).getSingle();
    return row.read<int>('c');
  }

  /// Messages whose `occurred_at` is on or after local midnight today.
  Future<int> countToday() async {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM message_records WHERE occurred_at >= ?',
      variables: [Variable<int>(todayMidnight.millisecondsSinceEpoch ~/ 1000)],
    ).getSingle();
    return row.read<int>('c');
  }

  /// Messages with `is_read = 0`.
  Future<int> unreadCount() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM message_records WHERE is_read = 0',
    ).getSingle();
    return row.read<int>('c');
  }

  /// Messages with `is_replied = 1`.
  Future<int> repliedCount() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM message_records WHERE is_replied = 1',
    ).getSingle();
    return row.read<int>('c');
  }

  /// Hit counts for the last 7 days (oldest -> newest), with `day` normalized
  /// to local midnight and zero counts filled in for days without any hits.
  ///
  /// We group by date string in SQL (efficient), then materialize the full
  /// 7-entry window in Dart so missing days appear as explicit zeros.
  Future<List<DailyCount>> last7DaysCounts() async {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    // The 7-day window covers [6 days ago midnight .. today midnight], i.e. the
    // 7 days ending today. Bound is in seconds.
    final startSeconds =
        todayMidnight.subtract(const Duration(days: 6)).millisecondsSinceEpoch ~/
            1000;

    final rows = await customSelect(
      "SELECT date(occurred_at, 'unixepoch', 'localtime') AS d, COUNT(*) AS c "
      'FROM message_records '
      'WHERE occurred_at >= ? '
      'GROUP BY d',
      variables: [Variable<int>(startSeconds)],
    ).get();

    // Map of 'YYYY-MM-DD' -> count.
    final byDay = <String, int>{
      for (final r in rows) r.read<String>('d'): r.read<int>('c'),
    };

    final result = <DailyCount>[];
    for (var i = 6; i >= 0; i--) {
      final day = todayMidnight.subtract(Duration(days: i));
      final key =
          '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      result.add(DailyCount(day, byDay[key] ?? 0));
    }
    return result;
  }

  /// The top [limit] group names by hit count. Rows with a NULL or empty
  /// `group_name` are excluded.
  Future<List<NamedCount>> topGroups(int limit) async {
    final rows = await customSelect(
      'SELECT group_name AS g, COUNT(*) AS c '
      'FROM message_records '
      "WHERE group_name IS NOT NULL AND group_name != '' "
      'GROUP BY group_name '
      'ORDER BY c DESC, group_name ASC '
      'LIMIT ?',
      variables: [Variable<int>(limit)],
    ).get();
    return [for (final r in rows) NamedCount(r.read<String>('g'), r.read<int>('c'))];
  }

  /// The top [limit] keywords by hit count. Keywords live inside each row's
  /// `matched_keywords_json` (a JSON array of objects with a `keyword` field),
  /// so we load the raw payloads and tally them in Dart — simple and robust
  /// regardless of whether SQLite's JSON1 extension is compiled in. Each
  /// keyword in a row's payload contributes one count (per row that mentions
  /// it, not per duplicate within the same row).
  Future<List<NamedCount>> topKeywords(int limit) async {
    final rows = await customSelect(
      'SELECT matched_keywords_json AS j FROM message_records',
    ).get();
    return _tallyKeywords(
      [for (final r in rows) r.read<String>('j')],
      limit,
    );
  }
}

/// Tally keyword frequencies across a list of `matched_keywords_json` payloads
/// and return the top [limit] by count. Malformed or empty payloads are
/// silently skipped. Within a single payload, each distinct keyword is counted
/// once.
List<NamedCount> _tallyKeywords(Iterable<String> payloads, int limit) {
  final counts = <String, int>{};
  for (final payload in payloads) {
    if (payload.isEmpty) continue;
    final dynamic decoded;
    try {
      decoded = jsonDecode(payload);
    } catch (_) {
      // Malformed JSON — skip this row rather than poisoning the whole tally.
      continue;
    }
    if (decoded is! List) continue;
    final seenInRow = <String>{};
    for (final item in decoded) {
      if (item is Map) {
        final kw = item['keyword'];
        if (kw is String && kw.isNotEmpty) seenInRow.add(kw);
      }
    }
    for (final kw in seenInRow) {
      counts[kw] = (counts[kw] ?? 0) + 1;
    }
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) {
      final cmp = b.value.compareTo(a.value);
      if (cmp != 0) return cmp;
      return a.key.compareTo(b.key); // stable, deterministic tie-break
    });
  return sorted.take(limit).map((e) => NamedCount(e.key, e.value)).toList();
}
