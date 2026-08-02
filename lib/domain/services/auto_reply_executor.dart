import '../entities/auto_reply.dart';
import '../repositories/i_auto_reply_gateway.dart';
import '../repositories/i_message_repository.dart';

/// Orchestrates auto-reply: invoke gateway, on success mark the message replied.
/// Domain only orchestrates; the gateway is an injected abstract port (mockable).
class AutoReplyExecutor {
  final IAutoReplyGateway gateway;
  final IMessageRepository messageRepo;
  AutoReplyExecutor({required this.gateway, required this.messageRepo});

  Stream<AutoReplyProgress> get progress => gateway.progress;

  Future<AutoReplyOutcome> execute(AutoReplyRequest request) async {
    final outcome = (await gateway.execute(request)).fold(
      (failure) => const AutoReplyOutcome(
          result: AutoReplyResult.failed, steps: [], failedAtStep: 'gateway'),
      (o) => o,
    );
    if (outcome.result == AutoReplyResult.success) {
      await messageRepo.markReplied(request.messageId, request.replyText);
    }
    return outcome;
  }
}
