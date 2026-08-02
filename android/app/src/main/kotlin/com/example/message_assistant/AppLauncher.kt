package com.example.message_assistant

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings

/**
 * Task 5.2/5.3 — Pure native helpers used by [NotificationPlugin] to fulfill
 * MethodChannel control requests. Kept separate so the plugin stays a thin
 * dispatcher and these helpers are independently testable/mockable.
 *
 * All methods take a [Context] (the plugin passes its applicationContext).
 */
object AppLauncher {

    private const val WECHAT_PACKAGE = "com.tencent.mm"

    /**
     * Launch WeChat via its launcher activity. Returns true if WeChat is
     * installed and an intent was fired; false if no launcher intent is found
     * (WeChat not installed).
     */
    fun launchWechat(context: Context): Boolean {
        val intent = context.packageManager.getLaunchIntentForPackage(WECHAT_PACKAGE)
            ?: return false
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            context.startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Copy [text] to the system clipboard (plain text clip, no label).
     */
    fun copyToClipboard(context: Context, text: String) {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboard.setPrimaryClip(ClipData.newPlainText("message_assistant", text))
    }

    /**
     * Whether the user has granted this app Notification Listener access.
     * Reads `Settings.Secure("enabled_notification_listeners")`, a space-/
     * newline-separated list of enabled listener component flat strings
     * ("pkg/cls"), and checks our package is present.
     */
    fun isNotificationListenerEnabled(context: Context): Boolean {
        val flat = Settings.Secure.getString(
            context.contentResolver,
            "enabled_notification_listeners",
        ) ?: return false
        return flat.split(' ', '\n', '\t').any { entry ->
            val component = entry.substringBefore('/', "")
            component == context.packageName
        }
    }

    /**
     * Open the system "Notification access" settings screen so the user can
     * toggle our listener. FLAG_ACTIVITY_NEW_TASK because we're launching from
     * a non-Activity context.
     */
    fun openNotificationListenerSettings(context: Context) {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }
}
