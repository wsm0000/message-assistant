import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:message_assistant/domain/entities/auto_reply.dart';
import 'package:message_assistant/domain/entities/failure.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/repositories/i_auto_reply_gateway.dart';
import 'package:message_assistant/domain/repositories/i_message_repository.dart';
import 'package:message_assistant/domain/services/auto_reply_executor.dart';

class _FakeGateway implements IAutoReplyGateway {
  final AutoReplyOutcome outcome;
  _FakeGateway(this.outcome);
  @override
  Stream<AutoReplyProgress> get progress => const Stream.empty();
  @override
  Future<Either<Failure, AutoReplyOutcome>> execute(AutoReplyRequest r) async => right(outcome);
  @override
  Future<void> cancel() async {}
}

class _RecordingMsgRepo implements IMessageRepository {
  int repliedCount = 0;
  String? lastReply;
  @override
  Future<Either<Failure, void>> markReplied(String id, String reply) async { repliedCount++; lastReply = reply; return right(null); }
  @override
  Future<Either<Failure, MessageRecord>> save(MessageRecord r) async => right(r);
  @override
  Future<Either<Failure, bool>> existsByFingerprint(String f) async => right(false);
  @override
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({String? groupId, int limit=50, int offset=0}) async => right([]);
  @override
  Future<Either<Failure, MessageRecord?>> findById(String id) async => right(null);
  @override
  Future<Either<Failure, void>> markRead(String id) async => right(null);
}

void main() {
  const request = AutoReplyRequest(messageId: 'm1', groupName: '群', senderName: '王', replyText: '接单');

  test('success → markReplied called with replyText', () async {
    final repo = _RecordingMsgRepo();
    final gw = _FakeGateway(const AutoReplyOutcome(result: AutoReplyResult.success, steps: []));
    final exec = AutoReplyExecutor(gateway: gw, messageRepo: repo);
    final outcome = await exec.execute(request);
    expect(outcome.result, AutoReplyResult.success);
    expect(repo.repliedCount, 1);
    expect(repo.lastReply, '接单');
  });

  test('failed → NOT markReplied', () async {
    final repo = _RecordingMsgRepo();
    final gw = _FakeGateway(const AutoReplyOutcome(result: AutoReplyResult.failed, steps: [], failedAtStep: 'enteringGroup'));
    final exec = AutoReplyExecutor(gateway: gw, messageRepo: repo);
    final outcome = await exec.execute(request);
    expect(outcome.result, AutoReplyResult.failed);
    expect(repo.repliedCount, 0);
  });

  test('cancelled → NOT markReplied', () async {
    final repo = _RecordingMsgRepo();
    final gw = _FakeGateway(const AutoReplyOutcome(result: AutoReplyResult.cancelled, steps: []));
    final exec = AutoReplyExecutor(gateway: gw, messageRepo: repo);
    final outcome = await exec.execute(request);
    expect(outcome.result, AutoReplyResult.cancelled);
    expect(repo.repliedCount, 0);
  });

  test('gateway returns Left(failure) → outcome failed, not replied', () async {
    final repo = _RecordingMsgRepo();
    final gw = _LeftGateway();
    final exec = AutoReplyExecutor(gateway: gw, messageRepo: repo);
    final outcome = await exec.execute(request);
    expect(outcome.result, AutoReplyResult.failed);
    expect(repo.repliedCount, 0);
  });
}

class _LeftGateway implements IAutoReplyGateway {
  @override
  Stream<AutoReplyProgress> get progress => const Stream.empty();
  @override
  Future<Either<Failure, AutoReplyOutcome>> execute(AutoReplyRequest r) async => left(const DatabaseFailure('gw down'));
  @override
  Future<void> cancel() async {}
}
