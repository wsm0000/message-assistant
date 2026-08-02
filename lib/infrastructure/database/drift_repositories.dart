import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' show Value;

import '../../domain/entities/failure.dart';
import '../../domain/entities/keyword_rule.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/entities/message_record.dart';
import '../../domain/repositories/i_keyword_repository.dart';
import '../../domain/repositories/i_message_repository.dart';
// NOTE on the naming collision: Drift's generated data classes are named
// `MessageRecord` and `KeywordRule` (defined in `database.g.dart`, which is a
// `part of` this library) — they COLLIDE with the domain entities of the same
// name. The Drift row types live in `database.dart`'s namespace, NOT in
// `tables/messages.dart`/`tables/keywords.dart` (those only declare the
// `Table` subclasses). So we alias the whole `database.dart` import as `drift`
// and prefix every Drift type (`drift.AppDatabase`, `drift.MessageRecord`,
// `drift.MessageRecordsCompanion`, `drift.KeywordRule`,
// `drift.KeywordRulesCompanion`) with it. The unqualified `MessageRecord` /
// `KeywordRule` always refer to the domain entities.
import 'database.dart' as drift;

/// Drift-backed adapter for [IMessageRepository].
///
/// Maps between domain [MessageRecord] entities and the flat Drift row
/// [drift.MessageRecord]. The structured `hits` field is serialized to JSON in
/// the `matched_keywords_json` text column.
class DriftMessageRepository implements IMessageRepository {
  final drift.AppDatabase db;
  DriftMessageRepository(this.db);

  @override
  Future<Either<Failure, MessageRecord>> save(MessageRecord r) async {
    try {
      final hitsJson = jsonEncode(r.hits
          .map((h) => <String, dynamic>{
                'ruleId': h.ruleId,
                'keyword': h.keyword,
                'type': h.type.index,
                'priority': h.priority,
                'highlightPositions': h.highlightPositions,
              })
          .toList());
      await db.messageDao.insertMessage(drift.MessageRecordsCompanion.insert(
        id: r.id,
        appId: r.appId,
        groupId: r.groupId,
        groupName: Value(r.groupName),
        senderName: r.senderName,
        senderId: Value(r.senderId),
        content: r.content,
        matchedKeywordsJson: Value(hitsJson),
        score: Value(r.score),
        occurredAt: r.occurredAt,
        receivedAt: r.receivedAt,
        isRead: Value(r.isRead),
        isReplied: Value(r.isReplied),
        replyContent: Value(r.replyContent),
        fingerprint: r.fingerprint,
        createdAt: r.createdAt,
        jumpKey: Value(r.jumpKey),
      ));
      return right(r);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  MessageRecord _toEntity(drift.MessageRecord row) {
    final decoded =
        (jsonDecode(row.matchedKeywordsJson) as List).cast<Map<String, dynamic>>();
    final hits = decoded
        .map((m) => KeywordHit(
              ruleId: m['ruleId'] as String,
              keyword: m['keyword'] as String,
              type: MatchType.values[(m['type'] as num).toInt()],
              priority: (m['priority'] as num).toInt(),
              highlightPositions:
                  (m['highlightPositions'] as List).cast<int>(),
            ))
        .toList();
    return MessageRecord(
      id: row.id,
      appId: row.appId,
      groupId: row.groupId,
      groupName: row.groupName,
      senderName: row.senderName,
      senderId: row.senderId,
      content: row.content,
      hits: hits,
      score: row.score,
      occurredAt: row.occurredAt,
      receivedAt: row.receivedAt,
      isRead: row.isRead,
      isReplied: row.isReplied,
      replyContent: row.replyContent,
      fingerprint: row.fingerprint,
      createdAt: row.createdAt,
      jumpKey: row.jumpKey,
    );
  }

  @override
  Future<Either<Failure, bool>> existsByFingerprint(String fp) async {
    try {
      return right(await db.messageDao.existsByFingerprint(fp));
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({
    String? groupId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final rows = await db.messageDao
          .recentMessages(groupId: groupId, limit: limit, offset: offset);
      return right(rows.map(_toEntity).toList());
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageRecord?>> findById(String id) async {
    try {
      final row = await db.messageDao.findById(id);
      return right(row == null ? null : _toEntity(row));
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markRead(String id) async {
    try {
      await db.messageDao.markRead(id);
      return right(null);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markReplied(String id, String replyContent) async {
    try {
      await db.messageDao.markReplied(id, replyContent);
      return right(null);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}

/// Drift-backed adapter for [IKeywordRepository].
///
/// Maps between domain [KeywordRule] entities and the flat Drift row
/// [drift.KeywordRule]. The structured `scopeGroupIds`/`excludeWords` lists are
/// serialized to JSON in the `scope_group_ids_json`/`exclude_words_json` text
/// columns; `type` is stored as int (0=exact, 1=contains).
///
/// `findByScope` returns all ENABLED rules here — scope-group filtering is
/// performed by the matcher (KeywordMatchService), not by this repository.
class DriftKeywordRepository implements IKeywordRepository {
  final drift.AppDatabase db;
  DriftKeywordRepository(this.db);

  @override
  Future<Either<Failure, List<KeywordRule>>> findAll() async {
    try {
      final rows = await db.keywordDao.all();
      return right(rows.map(_toEntity).toList());
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KeywordRule>>> findByScope(String groupId) async {
    // MVP: scope-group filtering is performed by KeywordMatchService, so
    // findByScope returns all ENABLED rules here. `groupId` is accepted to
    // satisfy the port but not used for filtering at this layer.
    final all = await findAll();
    return all.map((rules) => rules.where((r) => r.enabled).toList());
  }

  KeywordRule _toEntity(drift.KeywordRule row) => KeywordRule(
        id: row.id,
        keyword: row.keyword,
        type: MatchType.values[row.type],
        priority: row.priority,
        scopeGroupIds:
            (jsonDecode(row.scopeGroupIdsJson) as List).cast<String>(),
        excludeWords:
            (jsonDecode(row.excludeWordsJson) as List).cast<String>(),
        enabled: row.enabled,
        groupName: row.groupName,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  @override
  Future<Either<Failure, KeywordRule>> save(KeywordRule r) async {
    try {
      await db.keywordDao.upsert(drift.KeywordRulesCompanion.insert(
        id: r.id,
        keyword: r.keyword,
        type: r.type.index,
        priority: Value(r.priority),
        scopeGroupIdsJson: Value(jsonEncode(r.scopeGroupIds)),
        excludeWordsJson: Value(jsonEncode(r.excludeWords)),
        enabled: Value(r.enabled),
        groupName: Value(r.groupName),
        createdAt: r.createdAt,
        updatedAt: Value(r.updatedAt),
      ));
      return right(r);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await db.keywordDao.deleteById(id);
      return right(null);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
