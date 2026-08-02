package com.example.message_assistant

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import io.flutter.plugin.common.EventChannel

/**
 * Task 5.2 — The keep-alive foreground service.
 *
 * Android aggressively kills background processes. To keep the
 * [MessageNotificationListenerService] (and thus the EventChannel bridge to
 * Flutter) alive, we run this as a *foreground* service with a persistent
 * low-importance notification ("消息监听运行中").
 *
 * The service itself does little work — it just exists so the process has a
 * foreground priority. The [MessageNotificationListenerService] does the
 * actual notification parsing and pushes events through the static
 * [eventSink], which the [NotificationPlugin] attaches on `onListen`.
 *
 * Foreground-service type is `specialUse` on Android 14+ (API 34+): we are
 * not a media/location/data-sync/camera/health/call/etc. service, so the
 * catch-all special-use category + the `PROPERTY_SPECIAL_USE_FGS_SUBTYPE`
 * property ("notification_monitoring") is the correct declaration. The
 * matching permission `FOREGROUND_SERVICE_SPECIAL_USE` is in the manifest.
 */
class MonitorForegroundService : Service() {

    override fun onCreate() {
        super.onCreate()
        ensureChannel()
        startForegroundCompat()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Re-assert foreground in case the system is rebinding us (e.g. after
        // a WorkManager restart). startForeground is idempotent for the same id.
        startForegroundCompat()
        isRunning = true
        // START_STICKY: if killed, restart with a null intent so we come back.
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
    }

    private fun ensureChannel() {
        // Channels are required from API 26+. Low importance so it doesn't
        // make a sound — it's an ongoing "service is running" marker.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "监听服务",
                    NotificationManager.IMPORTANCE_LOW,
                ).apply {
                    description = "消息监听服务运行中"
                    setShowBadge(false)
                }
                nm.createNotificationChannel(channel)
            }
        }
    }

    private fun startForegroundCompat() {
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("消息监听运行中")
            .setContentText("正在监听微信通知")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()

        // ServiceCompat.startForeground handles the per-version foreground type
        // flag. On API 34+ we must declare FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        // because the manifest declares specialUse.
        val type = if (Build.VERSION.SDK_INT >= 34) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        } else {
            0
        }
        ServiceCompat.startForeground(this, NOTIF_ID, notification, type)
    }

    companion object {
        private const val NOTIF_ID = 1001
        private const val CHANNEL_ID = "ma_foreground"

        /**
         * The EventChannel sink the [NotificationPlugin] attaches on `onListen`.
         * The [MessageNotificationListenerService] pushes parsed notification
         * maps through this. Volatile because it's read/written across threads
         * (listener service thread vs. plugin's platform thread).
         */
        @Volatile
        var eventSink: EventChannel.EventSink? = null

        /**
         * Liveness flag set in [onStartCommand]/[onDestroy]. Coarse — used by
         * the plugin's `isMonitorServiceRunning` method. The authoritative
         * signal is the visible foreground notification; this is a best-effort
         * mirror for the UI.
         */
        @Volatile
        var isRunning: Boolean = false
    }
}
