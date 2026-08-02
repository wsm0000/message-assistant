import 'package:freezed_annotation/freezed_annotation.dart';
part 'auto_reply.freezed.dart';

@freezed
class AutoReplyRequest with _$AutoReplyRequest {
  const factory AutoReplyRequest({
    required String messageId,
    required String groupName,
    required String senderName,
    required String replyText,
  }) = _AutoReplyRequest;
}

enum AutoReplyStep {
  launching, openingSearch, inputtingGroupName,
  enteringGroup, inputtingReply, sending,
}

enum AutoReplyStepStatus { inProgress, success, retrying, failed }

@freezed
class AutoReplyProgress with _$AutoReplyProgress {
  const factory AutoReplyProgress({
    required AutoReplyStep step,
    required AutoReplyStepStatus status,
    @Default(1) int attempt,
    String? errorMessage,
  }) = _AutoReplyProgress;
}

enum AutoReplyResult { success, failed, cancelled }

@freezed
class AutoReplyOutcome with _$AutoReplyOutcome {
  const factory AutoReplyOutcome({
    required AutoReplyResult result,
    required List<AutoReplyProgress> steps,
    String? failedAtStep,
  }) = _AutoReplyOutcome;
}
