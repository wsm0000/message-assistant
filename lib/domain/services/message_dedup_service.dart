import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Produces a stable dedup fingerprint for a chat message.
///
/// Two messages are considered duplicates if they share the same app, group,
/// sender, content AND fall in the same 1-minute bucket. The 1-minute window
/// exists because Android's NotificationListenerService can fire multiple
/// callbacks for the same physical message (e.g. on update/dismiss).
class MessageDedupService {
  String fingerprint(
    String appId,
    String groupId,
    String senderId,
    String content,
    DateTime timestamp,
  ) {
    final minuteBucket = timestamp.millisecondsSinceEpoch ~/ 60000;
    final raw = '$appId|$groupId|$senderId|$content|$minuteBucket';
    return sha1.convert(utf8.encode(raw)).toString();
  }
}
