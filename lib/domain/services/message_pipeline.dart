import 'package:uuid/uuid.dart';
import '../entities/keyword_rule.dart';
import '../entities/match_result.dart';
import '../entities/message_record.dart';
import '../entities/raw_notification_event.dart';
import '../repositories/i_config_store.dart';
import '../repositories/i_keyword_repository.dart';
import '../repositories/i_message_repository.dart';
import 'keyword_match_service.dart';
import 'message_dedup_service.dart';
import 'notify_policy_service.dart';

/// Outcome of processing one notification event.
///
/// [result] is the matched+persisted message; [shouldNotify] tells the
/// infrastructure layer whether to fire a local notification (false during
/// quiet hours — the message is still saved, just not announced).
class PipelineOutcome {
  final MatchResult result;
  final bool shouldNotify;
  PipelineOutcome(this.result, this.shouldNotify);
}

/// Orchestrates the message processing flow:
///   normalize -> dedup -> load rules -> match -> persist (only on hit) -> notify decision
///
/// CRITICAL INVARIANT: unmatched messages are NEVER persisted. Only matched
/// messages reach the repository. Duplicates are dropped before matching.
class MessagePipeline {
  final IMessageRepository messageRepo;
  final IKeywordRepository keywordRepo;
  final MessageDedupService dedup;
  final KeywordMatchService matcher;
  final NotifyPolicyService policy;
  final IConfigStore configStore;
  final DateTime Function() now;
  final Uuid _uuid;

  MessagePipeline({
    required this.messageRepo,
    required this.keywordRepo,
    required this.dedup,
    required this.matcher,
    required this.policy,
    required this.configStore,
    DateTime Function()? now,
    Uuid? uuid,
  })  : now = now ?? (() => DateTime.now()),
        _uuid = uuid ?? const Uuid();

  /// Processes one notification event end-to-end.
  ///
  /// Returns null when the message is a duplicate OR when nothing matched
  /// (in both cases nothing is persisted and no notification fires).
  /// Returns a [PipelineOutcome] when a keyword hit and the message was
  /// successfully persisted; [PipelineOutcome.shouldNotify] reflects the
  /// quiet-hours decision.
  Future<PipelineOutcome?> process(RawNotificationEvent event) async {
    final senderId = event.senderId ?? event.senderName;
    final fingerprint = dedup.fingerprint(
      event.appId, event.groupId, senderId, event.content, event.occurredAt,
    );

    // 1. Dedup: if the fingerprint already exists, drop. On repo error, treat
    //    as "not a duplicate" so we don't silently lose messages.
    final dupEither = await messageRepo.existsByFingerprint(fingerprint);
    final isDup = dupEither.fold((_) => false, (exists) => exists);
    if (isDup) return null;

    // 2. Load candidate rules for this group. On repo error, fall back to an
    //    empty rule list (so nothing matches, but the pipeline doesn't crash).
    final rulesEither = await keywordRepo.findByScope(event.groupId);
    final rules = rulesEither.fold((_) => <KeywordRule>[], (r) => r);

    // 3. Build the message record for matching.
    final receivedAt = now();
    final record = _toRecord(event, fingerprint, receivedAt);

    // 4. Match. No hit -> drop (NOT persisted).
    final matchResult = matcher.match(record, rules);
    if (matchResult == null) return null;

    // 5. Persist (only matched messages).
    await messageRepo.save(matchResult.message);

    // 6. Notify decision based on quiet hours. On config error, fall back to
    //    disabled (i.e. notify) so matched messages aren't silently swallowed.
    final qhEither = await configStore.getQuietHours();
    final qh = qhEither.fold((_) => const QuietHours.disabled(), (qh) => qh);
    final shouldNotify = policy.shouldNotify(receivedAt, qh);

    return PipelineOutcome(matchResult, shouldNotify);
  }

  /// Maps a [RawNotificationEvent] into a fresh [MessageRecord] ready for
  /// matching and persistence. The id is generated via uuid v4; receivedAt /
  /// createdAt share the same timestamp (injected via [now] for testability).
  MessageRecord _toRecord(
    RawNotificationEvent event,
    String fingerprint,
    DateTime receivedAt,
  ) {
    return MessageRecord(
      id: _uuid.v4(),
      appId: event.appId,
      groupId: event.groupId,
      groupName: event.groupName,
      senderName: event.senderName,
      senderId: event.senderId,
      content: event.content,
      occurredAt: event.occurredAt,
      receivedAt: receivedAt,
      fingerprint: fingerprint,
      createdAt: receivedAt,
      jumpKey: event.jumpKey,
    );
  }
}
