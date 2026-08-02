import 'package:freezed_annotation/freezed_annotation.dart';
import 'match_result.dart'; // for KeywordHit
part 'message_record.freezed.dart';

@freezed
class MessageRecord with _$MessageRecord {
  const factory MessageRecord({
    required String id,
    required String appId,
    required String groupId,
    String? groupName,
    required String senderName,
    String? senderId,
    required String content,
    @Default([]) List<KeywordHit> hits,
    @Default(0) int score,
    required DateTime occurredAt,
    required DateTime receivedAt,
    @Default(false) bool isRead,
    @Default(false) bool isReplied,
    String? replyContent,
    required String fingerprint,
    required DateTime createdAt,
    // The native contentIntent captured for this group's latest WeChat
    // notification, referenced by the groupId (jump key). Held only in native
    // memory (JumpIntentStore); null on old DB records → reply flow falls back
    // to launching WeChat home. NOT part of the dedup fingerprint.
    String? jumpKey,
  }) = _MessageRecord;
}
