import 'package:flutter_test/flutter_test.dart';
import 'package:message_assistant/domain/entities/raw_notification_event.dart';
import 'package:message_assistant/infrastructure/platform/notification_channel.dart';

/// Unit-tests [NotificationEventChannel.toEventForTesting], the pure map→entity
/// transform that the EventChannel applies to each native event. This avoids
/// standing up a fake [EventChannel]; the transform is the only non-trivial
/// logic on this side of the bridge.
void main() {
  group('NotificationEventChannel.toEventForTesting', () {
    test('maps a complete WeChat group event to a RawNotificationEvent', () {
      // Millis for 2026-07-30 09:05:00 local.
      const occurredAt = 1795779900000; // arbitrary stable epoch millis
      final raw = <Object?, Object?>{
        'appId': 'com.tencent.mm',
        'groupId': 'g1',
        'groupName': '南京货运群',
        'senderName': '张师傅',
        'content': '南京到上海有一车货',
        'occurredAt': occurredAt,
        'packageName': 'com.tencent.mm',
        'jumpKey': 'g1',
      };

      final event = NotificationEventChannel.toEventForTesting(raw);

      expect(event, isA<RawNotificationEvent>());
      expect(event.appId, 'com.tencent.mm');
      expect(event.groupId, 'g1');
      expect(event.groupName, '南京货运群');
      expect(event.senderName, '张师傅');
      // Native side never sends senderId → stays null (pipeline falls back to
      // senderName for the fingerprint).
      expect(event.senderId, isNull);
      expect(event.content, '南京到上海有一车货');
      // The native event carries the groupId as the jump key.
      expect(event.jumpKey, 'g1');
      expect(
        event.occurredAt,
        DateTime.fromMillisecondsSinceEpoch(occurredAt),
      );
    });

    test('converts empty groupName to null', () {
      final event = NotificationEventChannel.toEventForTesting({
        'appId': 'com.tencent.mm',
        'groupId': 'g1',
        'groupName': '',
        'senderName': '张师傅',
        'content': 'hi',
        'occurredAt': 1000,
      });
      expect(event.groupName, isNull);
    });

    test('uses defaults for missing fields', () {
      final event = NotificationEventChannel.toEventForTesting(<Object?, Object?>{
        // occurredAt intentionally absent
      });
      expect(event.appId, '');
      expect(event.groupId, '');
      expect(event.groupName, isNull);
      expect(event.senderName, '未知');
      expect(event.senderId, isNull);
      expect(event.jumpKey, isNull);
      expect(event.content, '');
      // occurredAt falls back to now — just assert it is recent and valid.
      expect(
        DateTime.now().difference(event.occurredAt).inSeconds.abs(),
        lessThan(5),
      );
    });

    test('accepts occurredAt as int', () {
      final event = NotificationEventChannel.toEventForTesting({
        'occurredAt': 1234567890000,
      });
      expect(
        event.occurredAt,
        DateTime.fromMillisecondsSinceEpoch(1234567890000),
      );
    });
  });
}
