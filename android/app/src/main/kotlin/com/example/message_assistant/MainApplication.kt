package com.example.message_assistant

import android.app.Application

/**
 * Task 5.3 — The app's [Application] subclass.
 *
 * Single responsibility here: schedule the WorkManager heartbeat
 * ([ServiceRestarter]) in [onCreate] so the [MonitorForegroundService] is
 * restarted every ~15 min even if the app process is killed.
 *
 * Plugin registration (adding [NotificationPlugin] to the engine) is NOT done
 * here: `FlutterApplication` (which exposed a `configureFlutterEngine` hook)
 * is deprecated/removed, and plain [Application] has no such hook. Instead,
 * [MainActivity] overrides `FlutterActivity.configureFlutterEngine` — that is
 * the engine Flutter actually runs — and adds the plugin there.
 *
 * Referenced from the manifest via `android:name=".MainApplication"`.
 */
class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        ServiceRestarter.schedule(this)
    }
}
