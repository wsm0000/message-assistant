package com.example.message_assistant

import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log

/**
 * In-memory store of WeChat notification contentIntents, keyed by groupId.
 *
 * A PendingIntent is a system token — it can't cross the MethodChannel/DB
 * boundary or be serialized into SQLite. So we hold it here in native memory
 * and Flutter references it by the groupId string key.
 *
 * When a new WeChat notification for a group arrives, its contentIntent
 * overwrites the previous one for that groupId ("latest wins"). Tapping 回复 on
 * any message in group G fires G's most-recently-captured intent, jumping
 * straight into that chat. Old/expired intents naturally fall away: firing
 * throws → we return false → Flutter falls back to launching WeChat home.
 */
object JumpIntentStore {
    private const val TAG = "JumpIntentStore"
    private val store = mutableMapOf<String, PendingIntent>()

    fun put(groupId: String, intent: PendingIntent?) {
        if (intent == null) return
        store[groupId] = intent
        Log.i(TAG, "captured intent for groupId=$groupId (total=${store.size})")
    }

    /**
     * Fire the intent for [groupId]. Returns true if sent; false if missing or send failed.
     *
     * When [context] is an [Activity] (the normal case, since jumpToChat is
     * invoked from the foreground Flutter Activity via the MethodChannel), we
     * use [PendingIntent.send] with a fill-in [Intent] that adds
     * [Intent.FLAG_ACTIVITY_NEW_TASK]; firing from an Activity context bypasses
     * the Android 10+ background-Activity-launch restriction that otherwise
     * lets send() succeed silently while WeChat stays in the background.
     */
    fun fire(groupId: String, context: Context): Boolean {
        val intent = store[groupId] ?: return false
        return try {
            val fillIn = Intent().addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            intent.send(
                context,
                /* code = */ 0,
                /* intent = */ fillIn,
                /* onFinished = */ null,
                /* handler = */ null,
                /* requiredPermission = */ null,
                /* options = */ if (context is Activity) ActivityOptionsBundle else null,
            )
            Log.i(TAG, "fired intent for groupId=$groupId fromActivity=${context is Activity}")
            true
        } catch (e: PendingIntent.CanceledException) {
            Log.w(TAG, "intent canceled for groupId=$groupId: ${e.message}")
            store.remove(groupId)
            false
        } catch (e: Exception) {
            Log.w(TAG, "intent fire failed for groupId=$groupId: ${e.message}")
            false
        }
    }

    /** Placeholder options bundle used when firing from an Activity context. */
    private val ActivityOptionsBundle: Bundle = Bundle()
}
