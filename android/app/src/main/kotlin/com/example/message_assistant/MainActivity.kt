package com.example.message_assistant

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * The single Flutter activity. Also the registration site for the native
 * [NotificationPlugin] (the EventChannel/MethodChannel bridge to the
 * notification listener + control methods).
 *
 * Extends [FlutterFragmentActivity] (not [io.flutter.embedding.android.FlutterActivity]).
 * This is deliberate and fixes a black-screen bug seen on Huawei Android 12:
 * when the app is backgrounded (e.g. jumping to WeChat) with a dialog/overlay
 * open, plain `FlutterActivity`'s `FlutterSurfaceView` can have its Surface
 * torn down while obscured; on resume the raster thread idles and the screen
 * stays permanently black until a cold restart. `FlutterFragmentActivity`
 * drives the Flutter view through the Fragment lifecycle whose Surface is
 * managed and correctly recreated on resume — the documented remedy for this
 * class of bug (flutter/flutter#94516 and similar). It is otherwise a drop-in
 * superclass.
 *
 * `FlutterApplication` (which had its own `configureFlutterEngine` hook) is
 * deprecated and doesn't reliably expose that method on an [Application]
 * subclass, so we register the plugin here instead — [FlutterFragmentActivity]
 * does call [configureFlutterEngine] right after building the engine, and this
 * is the engine the Flutter UI actually uses.
 */
class MainActivity : FlutterFragmentActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        flutterEngine.plugins.add(NotificationPlugin())
    }
}
