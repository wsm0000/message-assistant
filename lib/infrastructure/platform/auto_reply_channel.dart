import 'dart:async';
import 'package:flutter/services.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/auto_reply.dart';
import '../../domain/entities/failure.dart';
import '../../domain/repositories/i_auto_reply_gateway.dart';

/// Bridges to native auto-reply channels. Implements [IAutoReplyGateway].
///
/// Channel contract (aligns with AutoReplyPlugin.kt):
///   MethodChannel "message_assistant/autoreply": startAutoReply {groupName,senderName,replyText} / cancelAutoReply
///   EventChannel "message_assistant/autoreply_progress": emits {step,status,attempt,errorMessage?}
///
/// Termination: sending+success = overall success; any step failed+attempt>=3 = overall failed.
class AutoReplyGateway implements IAutoReplyGateway {
  static const _method = MethodChannel('message_assistant/autoreply');
  static const _event = EventChannel('message_assistant/autoreply_progress');

  final _progressController = StreamController<AutoReplyProgress>.broadcast();
  StreamSubscription<dynamic>? _nativeSub;
  bool _listening = false;

  @override
  Stream<AutoReplyProgress> get progress => _progressController.stream;

  /// Pure mapping: native map → AutoReplyProgress.
  static AutoReplyProgress progressFromMap(Map<Object?, Object?> m) {
    final stepName = m['step'] as String?;
    final statusName = m['status'] as String?;
    final step = AutoReplyStep.values.firstWhere(
      (s) => s.name == stepName,
      orElse: () => throw ArgumentError('unknown step: $stepName'),
    );
    final status = AutoReplyStepStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => throw ArgumentError('unknown status: $statusName'),
    );
    final errMsgRaw = m['errorMessage'] as String?;
    return AutoReplyProgress(
      step: step,
      status: status,
      attempt: (m['attempt'] as num?)?.toInt() ?? 1,
      errorMessage: (errMsgRaw == null || errMsgRaw.isEmpty) ? null : errMsgRaw,
    );
  }

  static bool isTerminating(AutoReplyProgress p) {
    if (p.status == AutoReplyStepStatus.success && p.step == AutoReplyStep.sending) return true;
    if (p.status == AutoReplyStepStatus.failed && p.attempt >= 3) return true;
    return false;
  }

  static AutoReplyResult terminatingResult(AutoReplyProgress p) {
    return p.status == AutoReplyStepStatus.success ? AutoReplyResult.success : AutoReplyResult.failed;
  }

  void _ensureListening() {
    if (_listening) return;
    _listening = true;
    _nativeSub = _event.receiveBroadcastStream().listen(
      (raw) => _progressController.add(progressFromMap(Map<Object?, Object?>.from(raw as Map))),
      onError: (Object e) => _progressController.addError(e),
    );
  }

  @override
  Future<Either<Failure, AutoReplyOutcome>> execute(AutoReplyRequest request) async {
    _ensureListening();
    final completer = Completer<Either<Failure, AutoReplyOutcome>>();
    final steps = <AutoReplyProgress>[];
    late StreamSubscription<AutoReplyProgress> sub;
    sub = progress.listen(
      (p) {
        steps.add(p);
        if (isTerminating(p)) {
          final result = terminatingResult(p);
          final failedAt = result == AutoReplyResult.failed ? p.step.name : null;
          if (!completer.isCompleted) {
            completer.complete(right(AutoReplyOutcome(result: result, steps: steps, failedAtStep: failedAt)));
          }
        }
      },
      onError: (e) {
        if (!completer.isCompleted) {
          completer.complete(left(GatewayFailure(e.toString())));
        }
      },
    );
    try {
      await _method.invokeMethod<bool>('startAutoReply', {
        'groupName': request.groupName,
        'senderName': request.senderName,
        'replyText': request.replyText,
      });
    } catch (e) {
      await sub.cancel();
      return left(GatewayFailure(e.toString()));
    }
    final outcome = await completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => right(const AutoReplyOutcome(result: AutoReplyResult.failed, steps: [], failedAtStep: 'timeout')),
    );
    await sub.cancel();
    return outcome;
  }

  @override
  Future<void> cancel() async {
    try { await _method.invokeMethod<bool>('cancelAutoReply'); } catch (_) {}
  }

  void dispose() {
    _nativeSub?.cancel();
    _progressController.close();
  }
}
