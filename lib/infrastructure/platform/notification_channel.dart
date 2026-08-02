import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/raw_notification_event.dart';

/// Subscribes to the native notification-listener EventChannel and exposes a
/// stream of structured [RawNotificationEvent]s for the pipeline to consume.
///
/// The native side (`NotificationParser.kt` + `MessageNotificationListenerService`,
/// built in Phase 5) already parsed WeChat notifications into structured fields,
/// so here we only MAP the platform map into the domain type — no re-parsing.
///
/// Channel contract (must match `NotificationPlugin.kt`):
///   EventChannel name: "message_assistant/notification"
///   Each event is a map with keys:
///     appId, groupId, groupName?, senderName, content,
///     occurredAt (Long epoch millis), packageName
///   NOTE: the native side does NOT send `senderId` (it sends `senderName`
///   only). `senderId` is therefore always null here, which is fine — the
///   pipeline falls back to `senderName` for the fingerprint.
class NotificationEventChannel {
  static const _channel = EventChannel('message_assistant/notification');
  static Stream<RawNotificationEvent>? _stream;

  /// A broadcast stream of incoming notification events.
  ///
  /// Lazy-initialized and cached as a broadcast stream so it is safe to listen
  /// to multiple times without re-subscribing to the native side.
  static Stream<RawNotificationEvent> get stream {
    _stream ??= _channel
        .receiveBroadcastStream()
        .map(_toEvent)
        .asBroadcastStream();
    return _stream!;
  }

  /// Converts the raw platform map into a [RawNotificationEvent].
  ///
  /// Marked [visibleForTesting] so the map→entity transform can be unit-tested
  /// in isolation without standing up a fake [EventChannel].
  @visibleForTesting
  static RawNotificationEvent toEventForTesting(Map<Object?, Object?> raw) =>
      _toEvent(raw);

  static RawNotificationEvent _toEvent(dynamic raw) {
    final m = Map<String, dynamic>.from(raw as Map);
    final millis =
        (m['occurredAt'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    final groupName = m['groupName'] as String?;
    return RawNotificationEvent(
      appId: m['appId'] as String? ?? '',
      groupId: m['groupId'] as String? ?? '',
      groupName: (groupName == null || groupName.isEmpty) ? null : groupName,
      senderName: m['senderName'] as String? ?? '未知',
      senderId: m['senderId'] as String?,
      content: m['content'] as String? ?? '',
      occurredAt: DateTime.fromMillisecondsSinceEpoch(millis),
      jumpKey: m['jumpKey'] as String?,
    );
  }
}
