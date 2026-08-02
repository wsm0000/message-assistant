package com.example.message_assistant

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Task 5.2 — The Flutter bridge plugin.
 *
 * Two channels, matching exactly what Task 6.1 (the Dart side) will call:
 *
 * - **EventChannel** `"message_assistant/notification"`: streams parsed
 *   notification events (the map produced by
 *   [MessageNotificationListenerService]) to Dart. Implements
 *   [EventChannel.StreamHandler]; on `onListen` we attach the sink to the
 *   static [MonitorForegroundService.eventSink] and start the foreground
 *   service so the listener service keeps firing.
 *
 * - **MethodChannel** `"message_assistant/control"`: request/response control
 *   methods — launch WeChat, copy text, check/open the notification-listener
 *   permission, query monitor-service liveness, restart the monitor service.
 *
 * Registered by [MainApplication.configureFlutterEngine].
 */
class NotificationPlugin : FlutterPlugin, EventChannel.StreamHandler, MethodChannel.MethodCallHandler, ActivityAware {

    private var appContext: Context? = null
    private var eventChannel: EventChannel? = null
    private var methodChannel: MethodChannel? = null
    // The current foreground Activity, when attached. Used by jumpToChat so the
    // WeChat PendingIntent is fired from an Activity context (bypasses Android
    // 10+ background-Activity-launch restrictions that otherwise let the send
    // succeed silently while WeChat stays in the background).
    private var activity: Activity? = null

    // --- FlutterPlugin --------------------------------------------------------

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL).also {
            it.setStreamHandler(this)
        }
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL).also {
            it.setMethodCallHandler(this)
        }
    }

    // --- ActivityAware --------------------------------------------------------

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        MonitorForegroundService.eventSink = null
        eventChannel?.setStreamHandler(null)
        methodChannel?.setMethodCallHandler(null)
        eventChannel = null
        methodChannel = null
        appContext = null
    }

    // --- EventChannel.StreamHandler ------------------------------------------

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        MonitorForegroundService.eventSink = events
        appContext?.let { ctx ->
            // Start the foreground service so the process stays alive and the
            // NotificationListenerService keeps posting. startForegroundService
            // requires O+; on older versions plain startService is fine.
            val intent = Intent(ctx, MonitorForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ctx.startForegroundService(intent)
            } else {
                ctx.startService(intent)
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        MonitorForegroundService.eventSink = null
    }

    // --- MethodChannel.MethodCallHandler -------------------------------------

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val ctx = appContext ?: run {
            result.error("no_context", "Application context is null", null)
            return
        }
        when (call.method) {
            "launchWechat" -> result.success(AppLauncher.launchWechat(ctx))

            "copyToClipboard" -> {
                val text = call.argument<String>("text") ?: ""
                AppLauncher.copyToClipboard(ctx, text)
                result.success(true)
            }

            "isNotificationListenerEnabled" ->
                result.success(AppLauncher.isNotificationListenerEnabled(ctx))

            "openNotificationListenerSettings" -> {
                AppLauncher.openNotificationListenerSettings(ctx)
                result.success(true)
            }

            "isMonitorServiceRunning" ->
                // Coarse liveness flag set by the foreground service. The
                // authoritative signal is the visible foreground notification;
                // this mirror is best-effort for the UI's status indicator.
                result.success(MonitorForegroundService.isRunning)

            "restartMonitorService" -> {
                val intent = Intent(ctx, MonitorForegroundService::class.java)
                // Stop then start to force a clean restart.
                ctx.stopService(intent)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    ctx.startForegroundService(intent)
                } else {
                    ctx.startService(intent)
                }
                result.success(true)
            }

            // Fire the WeChat contentIntent captured for this group to jump
            // straight into the chat. Returns true if sent, false if the key is
            // missing or the intent expired (Flutter falls back to launchWechat).
            // Prefers the foreground Activity context so the PendingIntent is
            // fired from an Activity (bypasses background-Activity-launch limits).
            "jumpToChat" -> {
                val key = call.argument<String>("jumpKey")
                if (key != null) {
                    result.success(JumpIntentStore.fire(key, activity ?: ctx))
                } else {
                    result.success(false)
                }
            }

            else -> result.notImplemented()
        }
    }

    companion object {
        private const val EVENT_CHANNEL = "message_assistant/notification"
        private const val METHOD_CHANNEL = "message_assistant/control"
    }
}
