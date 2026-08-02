import 'package:freezed_annotation/freezed_annotation.dart';
part 'raw_notification_event.freezed.dart';

@freezed
class RawNotificationEvent with _$RawNotificationEvent {
  const factory RawNotificationEvent({
    required String appId,
    required String groupId,
    String? groupName,
    required String senderName,
    String? senderId,
    required String content,
    required DateTime occurredAt,
    // The jump key (groupId) carried from native so the pipeline can stash it
    // on the MessageRecord. Null when the native side didn't supply one.
    String? jumpKey,
  }) = _RawNotificationEvent;
}
