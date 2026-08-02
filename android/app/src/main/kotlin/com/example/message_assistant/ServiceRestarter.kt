package com.example.message_assistant

import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import java.util.concurrent.TimeUnit

/**
 * Task 5.3 — WorkManager heartbeat that restarts [MonitorForegroundService]
 * every ~15 minutes if it has been killed.
 *
 * WorkManager survives reboots and process death (it's backed by JobScheduler
 * /AlarmManager+broadcast), so this is the most reliable "kick the service
 * awake" hook available without a separate process. The minimum periodic
 * interval is 15 minutes (WorkManager enforces it).
 *
 * `KEEP` policy means the first [schedule] call wins; subsequent calls (e.g.
 * on every app start from [MainApplication.onCreate]) won't reset the window,
 * which is the desired behavior — we don't want to spam restarts.
 */
class ServiceRestarter(
    appContext: Context,
    params: WorkerParameters,
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        // Best-effort: start the foreground service. If the process is already
        // running, this is a no-op (same NOTIF_ID). If killed, this wakes it.
        return try {
            val intent = Intent(applicationContext, MonitorForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                applicationContext.startForegroundService(intent)
            } else {
                applicationContext.startService(intent)
            }
            Result.success()
        } catch (e: Exception) {
            // If we can't start (e.g. app is in background restrictions), retry
            // on the next 15-min window rather than failing hard.
            Result.retry()
        }
    }

    companion object {
        private const val WORK_NAME = "ma_restarter"

        /**
         * Enqueue a unique 15-minute periodic work. Idempotent under
         * [ExistingPeriodicWorkPolicy.KEEP] — safe to call on every app start.
         */
        fun schedule(context: Context) {
            val request = PeriodicWorkRequestBuilder<ServiceRestarter>(
                15, TimeUnit.MINUTES,
            ).build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                request,
            )
        }
    }
}
