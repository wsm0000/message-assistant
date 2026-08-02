package com.example.message_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Task 5.3 — Auto-starts the [MonitorForegroundService] after device boot.
 *
 * Registered for `BOOT_COMPLETED` in the manifest. Requires the
 * `RECEIVE_BOOT_COMPLETED` permission. On API 26+ a service must be started
 * with `startForegroundService` (the service then has 5s to call
 * `startForeground`, which [MonitorForegroundService] does in `onCreate`).
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_BOOT_COMPLETED) return
        val service = Intent(context, MonitorForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(service)
        } else {
            context.startService(service)
        }
    }
}
