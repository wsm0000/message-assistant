import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:message_assistant/domain/entities/failure.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/entities/raw_notification_event.dart';
import 'package:message_assistant/domain/repositories/i_message_repository.dart';
import 'package:message_assistant/domain/repositories/i_keyword_repository.dart';
import 'package:message_assistant/domain/repositories/i_config_store.dart';
import 'package:message_assistant/domain/services/message_pipeline.dart';
import 'package:message_assistant/domain/services/keyword_match_service.dart';
import 'package:message_assistant/domain/services/message_dedup_service.dart';
import 'package:message_assistant/domain/services/notify_policy_service.dart';

class _FakeMsgRepo implements IMessageRepository {
  int saveCalls = 0;
  final bool dupExists;
  _FakeMsgRepo({this.dupExists = false});
  @override
  Future<Either<Failure, MessageRecord>> save(MessageRecord r) async { saveCalls++; return right(r); }
  @override
  Future<Either<Failure, bool>> existsByFingerprint(String f) async => right(dupExists);
  @override
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({String? groupId, int limit=50, int offset=0}) async => right(<MessageRecord>[]);
  @override
  Future<Either<Failure, MessageRecord?>> findById(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markRead(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markReplied(String id, String reply) async => right(null);
}

/// Captures the last persisted record so tests can assert field propagation.
class _RecordingMsgRepo implements IMessageRepository {
  MessageRecord? lastSaved;
  @override
  Future<Either<Failure, MessageRecord>> save(MessageRecord r) async { lastSaved = r; return right(r); }
  @override
  Future<Either<Failure, bool>> existsByFingerprint(String f) async => right(false);
  @override
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({String? groupId, int limit=50, int offset=0}) async => right(<MessageRecord>[]);
  @override
  Future<Either<Failure, MessageRecord?>> findById(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markRead(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markReplied(String id, String reply) async => right(null);
}

class _FakeKwRepo implements IKeywordRepository {
  final List<KeywordRule> rules;
  _FakeKwRepo(this.rules);
  @override
  Future<Either<Failure, List<KeywordRule>>> findAll() async => right(rules);
  @override
  Future<Either<Failure, List<KeywordRule>>> findByScope(String groupId) async => right(rules);
  @override
  Future<Either<Failure, KeywordRule>> save(KeywordRule r) async => right(r);
  @override
  Future<Either<Failure, void>> delete(String id) async => right(null);
}

class _FakeConfigStore implements IConfigStore {
  QuietHours qh;
  _FakeConfigStore([this.qh = const QuietHours.disabled()]);
  @override
  Future<Either<Failure, QuietHours>> getQuietHours() async => right(qh);
  @override
  Future<Either<Failure, void>> setQuietHours(QuietHours q) async { qh = q; return right(null); }
  @override
  Future<Either<Failure, List<String>>> getTargetAppPackages() async => right(['com.tencent.mm']);
  @override
  Future<Either<Failure, String>> getDefaultReplyText() async => right('接单');
  @override
  Future<Either<Failure, void>> setDefaultReplyText(String text) async => right(null);
}

void main() {
  final base = DateTime(2026, 7, 30, 14, 32);

  RawNotificationEvent makeEvent(String content) => RawNotificationEvent(
    appId: 'com.tencent.mm', groupId: 'g1', groupName: '群',
    senderName: '王', content: content, occurredAt: base,
  );

  MessagePipeline makePipe(IMessageRepository repo, {List<KeywordRule> rules = const [], IConfigStore? configStore, DateTime Function()? now}) =>
    MessagePipeline(
      messageRepo: repo,
      keywordRepo: _FakeKwRepo(rules),
      dedup: MessageDedupService(),
      matcher: KeywordMatchService(),
      policy: NotifyPolicyService(),
      configStore: configStore ?? _FakeConfigStore(),
      now: now ?? (() => base),
    );

  test('hit -> save 1x + returns PipelineOutcome with shouldNotify=true', () async {
    final repo = _FakeMsgRepo();
    final pipe = makePipe(repo, rules: [KeywordRule(id:'k',keyword:'南京',createdAt:base)]);
    final r = await pipe.process(makeEvent('南京到上海'));
    expect(r, isNotNull);
    expect(repo.saveCalls, 1);
    expect(r!.shouldNotify, isTrue);
    expect(r.result.hits.single.keyword, '南京');
  });

  test('carries jumpKey from the event onto the persisted record', () async {
    final repo = _RecordingMsgRepo();
    final pipe = makePipe(repo, rules: [KeywordRule(id:'k',keyword:'南京',createdAt:base)]);
    final event = RawNotificationEvent(
      appId: 'com.tencent.mm', groupId: 'g1', groupName: '群',
      senderName: '王', content: '南京到上海', occurredAt: base, jumpKey: 'g1',
    );
    final r = await pipe.process(event);
    expect(r, isNotNull);
    // The saved record carries the jumpKey through (NOT part of the fingerprint).
    expect(repo.lastSaved!.jumpKey, 'g1');
  });

  test('no hit -> NOT saved (saveCalls 0) + returns null', () async {
    final repo = _FakeMsgRepo();
    final pipe = makePipe(repo, rules: [KeywordRule(id:'k',keyword:'不存在',createdAt:base)]);
    final r = await pipe.process(makeEvent('南京到上海'));
    expect(r, isNull);
    expect(repo.saveCalls, 0); // KEY ASSERTION: unmatched not persisted
  });

  test('duplicate (fingerprint exists) -> NOT saved + returns null', () async {
    final repo = _FakeMsgRepo(dupExists: true);
    final pipe = makePipe(repo, rules: [KeywordRule(id:'k',keyword:'南京',createdAt:base)]);
    final r = await pipe.process(makeEvent('南京到上海'));
    expect(r, isNull);
    expect(repo.saveCalls, 0);
  });

  test('quiet hours -> still saved (saveCalls 1) but shouldNotify=false', () async {
    final repo = _FakeMsgRepo();
    final pipe = makePipe(repo,
      rules: [KeywordRule(id:'k',keyword:'南京',createdAt:base)],
      configStore: _FakeConfigStore(const QuietHours(startHour: 22, endHour: 7, enabled: true)),
      now: () => DateTime(2026,7,30,3,0), // 03:00 in quiet
    );
    final r = await pipe.process(makeEvent('南京到上海'));
    expect(r, isNotNull);
    expect(repo.saveCalls, 1); // still persisted
    expect(r!.shouldNotify, isFalse); // but no notification
  });

  test('empty rules -> returns null, not saved', () async {
    final repo = _FakeMsgRepo();
    final pipe = makePipe(repo, rules: []);
    final r = await pipe.process(makeEvent('南京到上海'));
    expect(r, isNull);
    expect(repo.saveCalls, 0);
  });

  test('repo failure on existsByFingerprint -> treated as not-duplicate, proceeds', () async {
    // If the dedup check errors, pipeline should not crash; treat as not-dup and continue matching.
    final repo = _FailingExistsRepo();
    final pipe = makePipe(repo, rules: [KeywordRule(id:'k',keyword:'南京',createdAt:base)]);
    final r = await pipe.process(makeEvent('南京到上海'));
    expect(r, isNotNull);
    expect(repo.saveCalls, 1);
  });
}

class _FailingExistsRepo implements IMessageRepository {
  int saveCalls = 0;
  @override
  Future<Either<Failure, MessageRecord>> save(MessageRecord r) async { saveCalls++; return right(r); }
  @override
  Future<Either<Failure, bool>> existsByFingerprint(String f) async => left(const DatabaseFailure('check failed'));
  @override
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({String? groupId, int limit=50, int offset=0}) async => right(<MessageRecord>[]);
  @override
  Future<Either<Failure, MessageRecord?>> findById(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markRead(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markReplied(String id, String reply) async => right(null);
}
