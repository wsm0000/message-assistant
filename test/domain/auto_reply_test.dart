import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/auto_reply.dart';

void main() {
  test('AutoReplyRequest holds fields', () {
    const r = AutoReplyRequest(messageId: 'm1', groupName: '货运群', senderName: '王', replyText: '接单');
    expect(r.groupName, '货运群');
    expect(r.replyText, '接单');
  });
  test('AutoReplyProgress defaults attempt=1', () {
    const p = AutoReplyProgress(step: AutoReplyStep.openingSearch, status: AutoReplyStepStatus.inProgress);
    expect(p.attempt, 1);
    expect(p.errorMessage, isNull);
  });
  test('AutoReplyOutcome success has no failedAtStep', () {
    const o = AutoReplyOutcome(result: AutoReplyResult.success, steps: []);
    expect(o.failedAtStep, isNull);
  });
  test('AutoReplyStep enum has 6 values in order', () {
    expect(AutoReplyStep.values.map((s) => s.name).toList(),
        ['launching', 'openingSearch', 'inputtingGroupName', 'enteringGroup', 'inputtingReply', 'sending']);
  });
}
