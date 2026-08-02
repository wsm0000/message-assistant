package com.example.message_assistant

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/**
 * Task 5.2 — Catches posted notifications, parses them via [NotificationParser]
 * (Task 5.1), and streams structured events to Flutter through
 * [MonitorForegroundService.eventSink].
 *
 * Requires the user to grant the Notification Listener permission (Settings →
 * Notification access). The permission + manifest `BIND_NOTIFICATION_LISTENER_SERVICE`
 * are what let the system bind this service; without the grant, no callbacks fire.
 *
 * MVP: no ranking/connection/summary filtering. We forward every WeChat
 * notification that [NotificationParser] can parse. Dedup/quiet-hours/keyword
 * matching all happen downstream (Dart pipeline), so this layer stays dumb and
 * fast.
 */
class MessageNotificationListenerService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val sbn = sbn ?: return
        val pkg = sbn.packageName ?: return

        val extras = sbn.notification.extras

        // "android.title" / "android.text" are the standard notification extras.
        // They can be CharSequence; coerce to String (trim handled in parser).
        val title = extras.getCharSequence("android.title")?.toString()
        val text = extras.getCharSequence("android.text")?.toString()

        val parsed = NotificationParser.parse(title, text, pkg) ?: return

        // Capture the contentIntent (jump-to-chat) for this group, keyed by
        // groupId. A PendingIntent can't cross the MethodChannel/DB boundary, so
        // we stash it in native memory (JumpIntentStore) and Flutter references
        // it via the groupId string ("jumpKey"). "Latest wins": a new WeChat
        // notification for the same group overwrites the previous intent.
        JumpIntentStore.put(parsed.groupId, sbn.notification?.contentIntent)

        val event: Map<String, Any?> = mapOf(
            "appId" to parsed.appId,
            "groupId" to parsed.groupId,
            // Dart's RawNotificationEvent expects a non-null String; emit "" for
            // single chats (parser uses null for groupName when isGroup == false).
            "groupName" to (parsed.groupName ?: ""),
            "senderName" to parsed.senderName,
            "content" to parsed.content,
            "occurredAt" to System.currentTimeMillis(),
            "packageName" to pkg,
            // The groupId as the jump key: Flutter stores this on the message
            // record and later passes it to the `jumpToChat` control method,
            // which looks up + fires the captured contentIntent.
            "jumpKey" to parsed.groupId,
        )

        // Push on the listener service thread. The EventSink is thread-safe to
        // call from any thread; Flutter marshals onto the platform thread.
        MonitorForegroundService.eventSink?.success(event)
    }
}
