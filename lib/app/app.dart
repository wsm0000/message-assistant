import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/providers/providers.dart';
import 'router.dart';

/// Root widget of the 消息助手 app. Material 3 with a blue seed; routing
/// delegated to [goRouter]. Wrapped in a [ProviderScope] at [main].
///
/// It is a [ConsumerStatefulWidget] so its build can `ref.watch(bootstrapProvider)`
/// once — that kicks off the one-shot startup wiring (local-notification init,
/// notification EventChannel subscription → pipeline → notify, and tap
/// deep-linking). See [bootstrapProvider] for the full flow.
///
/// It also tracks [AppLifecycleState] via [WidgetsBindingObserver]. A Flutter
/// indeterminate progress animation that keeps redraw-requesting while the
/// Activity's Surface is obscured can drive the Impeller/Vulkan raster thread
/// into a stall on some Mali GPUs, leaving a black screen on resume. Exposing
/// the current lifecycle (resumed/paused) lets descendants avoid scheduling
/// frames/animations in the background, and forces a fresh frame on return.
class MessageAssistantApp extends ConsumerStatefulWidget {
  const MessageAssistantApp({super.key});

  @override
  ConsumerState<MessageAssistantApp> createState() => _MessageAssistantAppState();
}

class _MessageAssistantAppState extends ConsumerState<MessageAssistantApp>
    with WidgetsBindingObserver {
  AppLifecycleState? _lifecycle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _lifecycle = state);
    // Refresh the lifecycle provider so widgets that gated work on "is the app
    // in the foreground" react immediately.
    ref.read(appLifecycleProvider.notifier).state = state;
    if (state == AppLifecycleState.resumed) {
      // Force fresh frames after returning from the background. When the
      // Activity was obscured (e.g. the RPA chain ran while the user was in
      // WeChat) the GPU surface can be torn down and the raster thread idles
      // on resume, leaving a black screen. Scheduling two rebuilds across
      // successive frames nudges the renderer back into compositing. (The
      // primary fix is FlutterFragmentActivity in MainActivity.kt; this is a
      // belt-and-suspenders nudge.)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start the bootstrap wiring (no-op if already started). Watching means
    // this rebuild won't tear it down; the FutureProvider is app-scoped.
    ref.watch(bootstrapProvider);
    return MaterialApp.router(
      title: '消息助手',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      // Suppress the default MaterialApp ticker while the app is in the
      // background: this is the root cause of the raster-thread stall on some
      // Mali/Vulkan devices when an indeterminate animation keeps requesting
      // frames against an obscured Surface (seen during the RPA chain, which
      // runs while the user is in WeChat).
      builder: (context, child) {
        final bg = _lifecycle == AppLifecycleState.paused ||
            _lifecycle == AppLifecycleState.inactive ||
            _lifecycle == AppLifecycleState.detached;
        return TickerMode(
          enabled: !bg,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
