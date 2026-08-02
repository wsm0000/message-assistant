import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../domain/entities/auto_reply.dart';
import '../../domain/entities/failure.dart';
import '../../domain/entities/route_estimate.dart';
import '../../domain/entities/keyword_rule.dart';
import '../../domain/entities/message_record.dart';
import '../../domain/entities/message_stats.dart';
import '../../domain/entities/quick_reply.dart';
import '../../domain/repositories/i_auto_reply_gateway.dart';
import '../../domain/repositories/i_config_store.dart';
import '../../domain/repositories/i_quick_reply_repository.dart';
import '../../domain/repositories/i_keyword_repository.dart';
import '../../domain/repositories/i_message_repository.dart';
import '../../domain/repositories/i_stats_repository.dart';
import '../../domain/services/auto_reply_executor.dart';
import '../../domain/services/keyword_match_service.dart';
import '../../domain/services/message_dedup_service.dart';
import '../../domain/services/message_pipeline.dart';
import '../../domain/services/notify_policy_service.dart';
import '../../infrastructure/platform/auto_reply_channel.dart';
import '../../infrastructure/platform/notification_channel.dart';
import '../../infrastructure/services/local_notifier.dart';
import '../../infrastructure/storage/in_memory_quick_reply_repository.dart';
// `database.dart` (Drift) also exports generated data classes named
// `MessageRecord`/`KeywordRule` that collide with the domain entities above.
// Hide them so the unqualified names always refer to the domain entities;
// only `AppDatabase` is needed from this import.
import '../../infrastructure/database/database.dart'
    hide KeywordRule, MessageRecord;
import '../../infrastructure/database/drift_repositories.dart';
import '../../infrastructure/database/stats_repository.dart';
import '../../infrastructure/amap/amap_route_gateway.dart';
import '../../domain/repositories/i_route_gateway.dart';

/// Task 4.2 — Riverpod state-management layer.
///
/// This file is the bridge between the pure domain layer (services/repos) and
/// the Flutter UI pages (Task 4.3). It wires singletons (database, repos),
/// stateless domain services, the message-processing pipeline, read-model
/// [FutureProvider]s for the pages, and command wrappers that invalidate the
/// read providers after a mutation so the UI refreshes.
///
/// Uses the classic hand-written Riverpod API (no code-gen): the project's
/// `riverpod_generator`/`riverpod_lint` were disabled because
/// `analyzer_plugin 0.12.0` is incompatible with the rest of the toolchain.

// --- Infrastructure singletons ------------------------------------------------

/// Singleton [AppDatabase]. Registers [AppDatabase.close] for cleanup when the
/// [ProviderContainer] is disposed (app shutdown).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final messageRepoProvider = Provider<IMessageRepository>(
  (ref) => DriftMessageRepository(ref.read(databaseProvider)),
);

final keywordRepoProvider = Provider<IKeywordRepository>(
  (ref) => DriftKeywordRepository(ref.read(databaseProvider)),
);

// --- Config store (MVP in-memory; persistence deferred to a later task) -------

final configStoreProvider = Provider<IConfigStore>((ref) => _MemoryConfigStore());

// --- Domain services (stateless) ----------------------------------------------

final matcherProvider = Provider<KeywordMatchService>((ref) => KeywordMatchService());
final dedupProvider = Provider<MessageDedupService>((ref) => MessageDedupService());
final policyProvider = Provider<NotifyPolicyService>((ref) => NotifyPolicyService());

// --- Pipeline -----------------------------------------------------------------

final pipelineProvider = Provider<MessagePipeline>((ref) => MessagePipeline(
      messageRepo: ref.read(messageRepoProvider),
      keywordRepo: ref.read(keywordRepoProvider),
      dedup: ref.read(dedupProvider),
      matcher: ref.read(matcherProvider),
      policy: ref.read(policyProvider),
      configStore: ref.read(configStoreProvider),
    ));

// --- Read models --------------------------------------------------------------

/// Recent messages, optionally filtered by [groupId]. autoDispose so stale
/// screens don't hold data; family param supports per-group filtering.
final messageListProvider = FutureProvider.autoDispose
    .family<List<MessageRecord>, String?>((ref, groupId) async {
  final repo = ref.watch(messageRepoProvider);
  final either = await repo.findRecentPaged(groupId: groupId);
  return either.fold((_) => <MessageRecord>[], (r) => r);
});

/// Single message lookup by id. Returns null when not found or on error.
final messageDetailProvider =
    FutureProvider.autoDispose.family<MessageRecord?, String>((ref, id) async {
  final repo = ref.watch(messageRepoProvider);
  final either = await repo.findById(id);
  return either.fold((_) => null, (r) => r);
});

/// All keyword rules. autoDispose so the list is refetched when the page mounts.
final keywordListProvider =
    FutureProvider.autoDispose<List<KeywordRule>>((ref) async {
  final repo = ref.watch(keywordRepoProvider);
  final either = await repo.findAll();
  return either.fold((_) => <KeywordRule>[], (r) => r);
});

// --- Statistics dashboard -----------------------------------------------------

/// Singleton [IStatsRepository] backed by the Drift database.
final statsRepositoryProvider = Provider<IStatsRepository>(
  (ref) => DriftStatsRepository(ref.read(databaseProvider)),
);

/// Aggregate dashboard stats. Falls back to [MessageStats.empty] on error so the
/// dashboard never crashes. autoDispose so stats are recomputed on each visit.
final statsProvider = FutureProvider.autoDispose<MessageStats>((ref) async {
  final either = await ref.watch(statsRepositoryProvider).getStats();
  return either.fold((_) => MessageStats.empty, (s) => s);
});

// --- UI-driven mutations (invalidate the read providers above) ----------------

/// Wraps the keyword repository's save/delete and invalidates
/// [keywordListProvider] so the list refreshes after a mutation.
final keywordRepositoryCommandProvider = Provider<KeywordCommandRunner>(
  (ref) => KeywordCommandRunner(ref.read(keywordRepoProvider), ref),
);

class KeywordCommandRunner {
  final IKeywordRepository _repo;
  final Ref _ref;
  KeywordCommandRunner(this._repo, this._ref);

  Future<Either<Failure, KeywordRule>> save(KeywordRule rule) async {
    final res = await _repo.save(rule);
    _ref.invalidate(keywordListProvider);
    return res;
  }

  Future<Either<Failure, void>> delete(String id) async {
    final res = await _repo.delete(id);
    _ref.invalidate(keywordListProvider);
    return res;
  }
}

// --- Quick-reply phrases (preset replies in the detail page reply sheet) ------

/// MVP in-memory quick-reply repository. Persistence (Drift) deferred to a
/// later task; the default-reply-text machinery above is kept for backward
/// compat until the UI migrates fully to the phrase list.
final quickReplyRepoProvider = Provider<IQuickReplyRepository>(
  (ref) => InMemoryQuickReplyRepository(),
);

/// All quick-reply phrases, sorted ascending by [QuickReply.sortOrder].
/// autoDispose so the list is refetched when the page mounts.
final quickReplyListProvider =
    FutureProvider.autoDispose<List<QuickReply>>((ref) async {
  final either = await ref.watch(quickReplyRepoProvider).findAll();
  return either.fold((_) => <QuickReply>[], (list) => list);
});

/// Command wrapper for phrase mutations; invalidates [quickReplyListProvider]
/// so the list refreshes after a save/delete/reorder.
final quickReplyCommandProvider = Provider<QuickReplyCommandRunner>(
  (ref) => QuickReplyCommandRunner(ref.read(quickReplyRepoProvider), ref),
);

class QuickReplyCommandRunner {
  final IQuickReplyRepository _repo;
  final Ref _ref;
  QuickReplyCommandRunner(this._repo, this._ref);

  Future<Either<Failure, QuickReply>> save(QuickReply phrase) async {
    final res = await _repo.save(phrase);
    _ref.invalidate(quickReplyListProvider);
    return res;
  }

  Future<Either<Failure, void>> delete(String id) async {
    final res = await _repo.delete(id);
    _ref.invalidate(quickReplyListProvider);
    return res;
  }

  Future<Either<Failure, void>> reorder(List<String> orderedIds) async {
    final res = await _repo.reorder(orderedIds);
    _ref.invalidate(quickReplyListProvider);
    return res;
  }
}

// --- In-memory config store (MVP placeholder) ---------------------------------

/// MVP placeholder config store. Quiet-hours disabled by default; WeChat
/// (`com.tencent.mm`) is the only monitored target package. Persistence to
/// Drift (e.g. a `DriftConfigStore`) is deliberately deferred to a later task.
class _MemoryConfigStore implements IConfigStore {
  QuietHours _qh = const QuietHours.disabled();
  String _defaultReplyText = '接单';

  @override
  Future<Either<Failure, QuietHours>> getQuietHours() async => right(_qh);

  @override
  Future<Either<Failure, void>> setQuietHours(QuietHours qh) async {
    _qh = qh;
    return right(null);
  }

  @override
  Future<Either<Failure, List<String>>> getTargetAppPackages() async =>
      right(['com.tencent.mm']);

  @override
  Future<Either<Failure, String>> getDefaultReplyText() async =>
      right(_defaultReplyText);

  @override
  Future<Either<Failure, void>> setDefaultReplyText(String text) async {
    _defaultReplyText = text;
    return right(null);
  }
}

// --- Platform actions (native MethodChannel wired in Task 6.1) ---------------

/// Thin wrapper over the native `"message_assistant/control"` MethodChannel.
///
/// Every method is defensive: on any platform error (e.g. missing-handler on a
/// non-Android host) it returns a safe default so the UI never crashes. The
/// public signatures match the old stub so the presentation layer is unchanged.
final platformActionsProvider = Provider<PlatformActions>((ref) => PlatformActions());

class PlatformActions {
  static const _channel = MethodChannel('message_assistant/control');

  Future<bool> isNotificationListenerEnabled() async {
    try {
      return (await _channel.invokeMethod<bool>('isNotificationListenerEnabled')) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openNotificationListenerSettings() async {
    try {
      await _channel.invokeMethod<bool>('openNotificationListenerSettings');
    } catch (_) {}
  }

  Future<bool> launchWechat() async {
    try {
      return (await _channel.invokeMethod<bool>('launchWechat')) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Fires the WeChat contentIntent captured for this group's latest
  /// notification, jumping straight into that chat. Returns true if the intent
  /// was sent; false if the key is null/empty, the intent is gone/expired, or
  /// the platform call failed. On false the caller should fall back to
  /// [launchWechat].
  Future<bool> jumpToChat(String? jumpKey) async {
    if (jumpKey == null || jumpKey.isEmpty) return false;
    try {
      return (await _channel.invokeMethod<bool>('jumpToChat', {'jumpKey': jumpKey})) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> copyToClipboard(String text) async {
    try {
      await _channel.invokeMethod<bool>('copyToClipboard', {'text': text});
    } catch (_) {}
  }

  Future<bool> isMonitorServiceRunning() async {
    try {
      return (await _channel.invokeMethod<bool>('isMonitorServiceRunning')) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> restartMonitorService() async {
    try {
      await _channel.invokeMethod<bool>('restartMonitorService');
    } catch (_) {}
  }
}


/// The app's current [AppLifecycleState] (null until the first
/// [WidgetsBindingObserver.didChangeAppLifecycleState] callback). Updated by
/// [MessageAssistantApp]. Lets widgets avoid scheduling animations/frames
/// against an obscured Surface when the app is backgrounded.
final appLifecycleProvider =
    StateProvider<AppLifecycleState?>((ref) => null);

// --- Local notifications + startup wiring (Task 6.1) -------------------------

/// Owns the [LocalNotifier] singleton and closes its tap stream on dispose.
final localNotifierProvider = Provider<LocalNotifier>((ref) {
  final notifier = LocalNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// One-shot startup provider. When first read (by [MessageAssistantApp]), it:
///   1. Initializes the local-notification plugin + Android channel.
///   2. Subscribes to the native notification EventChannel.
///   3. Runs each incoming event through [MessagePipeline] (dedup → match →
///      persist), invalidates the message read-models, and fires a local
///      notification when the pipeline says `shouldNotify`.
///   4. Wires notification taps → `/message/:id` deep-link via [goRouter].
///
/// This is a [FutureProvider] purely so the app can `ref.watch` it once at
/// startup; it never returns a meaningful value. It is only read by
/// [MessageAssistantApp] (not by pages/tests), so the existing widget/provider
/// tests — which don't read it — stay green and never touch real channels.
final bootstrapProvider = FutureProvider<void>((ref) async {
  final notifier = ref.read(localNotifierProvider);
  await notifier.init();
  final pipeline = ref.read(pipelineProvider);

  // Notification taps → navigate to the message detail route.
  notifier.onNotificationTap.listen((messageId) {
    goRouter.push('/message/$messageId');
  });

  // Incoming notification events → pipeline → persist → maybe notify.
  NotificationEventChannel.stream.listen(
    (event) {
      pipeline.process(event).then((outcome) {
        if (outcome == null) return; // duplicate or no match — nothing saved
        // Refresh the recent-messages read-models so the UI updates.
        ref.invalidate(messageListProvider);
        if (outcome.shouldNotify) {
          notifier.notify(outcome.result, id: outcome.result.message.id);
        }
      }).catchError((Object e, StackTrace st) {
        // A throw inside the pipeline (DB error, parse error) used to be
        // silently swallowed by the stream and kill the subscription. Log it
        // so failures are observable instead of "nothing happens".
        developer.log('message pipeline error: $e', name: 'Bootstrap', error: e, stackTrace: st);
      });
    },
    onError: (Object e) {
      // EventChannel errors (e.g. native side threw) — log instead of dying
      // silently so the user/developer can tell the listener died.
      developer.log('notification event channel error: $e', name: 'Bootstrap', error: e);
    },
  );
});

// --- Auto-reply (Phase B) -----------------------------------------------------

/// Owns the [AutoReplyGateway] bridge to the native auto-reply channels and
/// disposes its stream controllers on container shutdown.
final autoReplyGatewayProvider = Provider<IAutoReplyGateway>((ref) {
  final gw = AutoReplyGateway();
  ref.onDispose(gw.dispose);
  return gw;
});

/// Wires the gateway + message repository into the domain orchestrator.
final autoReplyExecutorProvider = Provider((ref) => AutoReplyExecutor(
      gateway: ref.read(autoReplyGatewayProvider),
      messageRepo: ref.read(messageRepoProvider),
    ));

/// Holds the latest [AutoReplyProgress] emitted while an auto-reply run is in
/// flight; `null` when idle. Pages watch this to render step-by-step UI.
final autoReplyProgressProvider = StateProvider<AutoReplyProgress?>((ref) => null);

/// Loads the persisted default reply text, falling back to '接单' on any error.
final defaultReplyTextProvider = FutureProvider<String>((ref) async {
  final either = await ref.read(configStoreProvider).getDefaultReplyText();
  return either.getOrElse(() => '接单');
});

// --- Amap route distance / fare estimate ------------------------------------

/// The Amap REST route gateway singleton.
final routeGatewayProvider = Provider<IRouteGateway>(
  (ref) => amapRouteGatewayFactory(),
);

/// Arguments for [routeEstimateProvider].
class RouteEstimateArgs {
  const RouteEstimateArgs(this.origin, this.destination);
  final String origin;
  final String destination;
  @override
  bool operator ==(Object other) =>
      other is RouteEstimateArgs && other.origin == origin && other.destination == destination;
  @override
  int get hashCode => Object.hash(origin, destination);
}

/// Computes the route distance + fare estimate for the given origin/destination
/// addresses. autoDispose so it recomputes when the user changes inputs.
final routeEstimateProvider =
    FutureProvider.autoDispose<Either<Failure, RouteEstimate>>((ref) async {
  final args = ref.watch(routeEstimateArgsProvider);
  if (args == null) {
    // No args yet — return a synthetic "no input" failure so the UI can render
    // an idle state without firing the gateway.
    return const Left(GatewayFailure('请输入起点和终点'));
  }
  final gw = ref.read(routeGatewayProvider);
  return gw.calculateDistance(
    originAddress: args.origin,
    destinationAddress: args.destination,
  );
});

/// Holds the current origin/destination the user has entered (null = not yet
/// submitted). The route page sets this when the user taps 计算.
final routeEstimateArgsProvider = StateProvider<RouteEstimateArgs?>((ref) => null);

/// Re-export domain types used by the route UI so pages only need one import.
// (Already imported at the top of this file.)
