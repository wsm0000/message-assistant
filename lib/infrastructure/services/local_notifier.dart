import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/entities/match_result.dart';

/// Sends local notifications for matched messages and surfaces notification
/// taps as a stream for deep-linking.
///
/// On Android it owns a high-importance notification channel (`message_matched`
/// / 命中消息提醒). Notification taps emit the tapped message id on
/// [onNotificationTap]; the bootstrap layer subscribes and navigates to the
/// message detail route.
///
/// Highlighting: system notifications don't support rich text, so matched
/// keywords are surfaced by appending a "（命中：keyword1、keyword2）" line. The
/// detail page already shows inline highlights, so this is the MVP approach.
class LocalNotifier {
  static const _channelId = 'message_matched';
  static const _channelName = '命中消息提醒';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Stream of tapped notification payloads (message ids) for deep-linking.
  final StreamController<String> _tapController = StreamController<String>.broadcast();
  Stream<String> get onNotificationTap => _tapController.stream;

  /// Idempotent. Creates the Android notification channel on first call.
  Future<void> init() async {
    if (_initialized) return;
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (resp) {
        // payload = message id
        final payload = resp.payload;
        if (payload != null && payload.isNotEmpty) {
          _tapController.add(payload);
        }
      },
    );
    // Create the high-importance channel (Android). No-op on other platforms.
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
          ),
        );
    _initialized = true;
  }

  /// Show a notification for a matched message. [id] is the message id; it is
  /// hashed into a stable non-negative int (the platform notification id).
  Future<void> notify(MatchResult result, {required String id}) async {
    await init();
    final msg = result.message;
    final title =
        (msg.groupName?.isNotEmpty == true ? msg.groupName : msg.senderName) ??
        msg.senderName;
    final body = _formatBody(msg.content, result.hits);
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      id: id.hashCode & 0x7fffffff, // stable non-negative int id
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: id, // message id for tap deep-link
    );
  }

  /// Releases the tap stream. Safe to call multiple times.
  Future<void> dispose() async {
    await _tapController.close();
  }

  /// Builds the notification body: the original content followed by a summary
  /// of matched keywords (joined with '、'). Returns the content unchanged when
  /// there are no hits (defensive; in practice notify() is only called on hits).
  String _formatBody(String content, List<KeywordHit> hits) {
    if (hits.isEmpty) return content;
    final matched = hits.map((h) => h.keyword).toSet().join('、');
    return '$content\n（命中：$matched）';
  }
}
