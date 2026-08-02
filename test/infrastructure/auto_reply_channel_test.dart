import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/infrastructure/platform/auto_reply_channel.dart';
import 'package:message_assistant/domain/entities/auto_reply.dart';

void main() {
  test('progressFromMap maps step/status/attempt/error', () {
    final p = AutoReplyGateway.progressFromMap({
      'step': 'openingSearch', 'status': 'retrying', 'attempt': 2, 'errorMessage': '节点未找到',
    });
    expect(p.step, AutoReplyStep.openingSearch);
    expect(p.status, AutoReplyStepStatus.retrying);
    expect(p.attempt, 2);
    expect(p.errorMessage, '节点未找到');
  });
  test('progressFromMap defaults attempt=1, error=null', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'launching', 'status': 'inProgress'});
    expect(p.attempt, 1);
    expect(p.errorMessage, isNull);
  });
  test('progressFromMap empty errorMessage string treated as null', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'launching', 'status': 'success', 'errorMessage': ''});
    expect(p.errorMessage, isNull);
  });
  test('progressFromMap unknown step throws ArgumentError', () {
    expect(() => AutoReplyGateway.progressFromMap({'step': 'nope', 'status': 'success'}),
        throwsA(isA<ArgumentError>()));
  });
  test('isTerminating: success-on-sending is terminating → success', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'sending', 'status': 'success'});
    expect(AutoReplyGateway.isTerminating(p), isTrue);
    expect(AutoReplyGateway.terminatingResult(p), AutoReplyResult.success);
  });
  test('isTerminating: failed attempt3 is terminating → failed', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'enteringGroup', 'status': 'failed', 'attempt': 3});
    expect(AutoReplyGateway.isTerminating(p), isTrue);
    expect(AutoReplyGateway.terminatingResult(p), AutoReplyResult.failed);
  });
  test('isTerminating: failed attempt1 NOT terminating (will retry)', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'enteringGroup', 'status': 'failed', 'attempt': 1});
    expect(AutoReplyGateway.isTerminating(p), isFalse);
  });
  test('isTerminating: success-non-sending NOT terminating', () {
    final p = AutoReplyGateway.progressFromMap({'step': 'openingSearch', 'status': 'success'});
    expect(AutoReplyGateway.isTerminating(p), isFalse);
  });
}
