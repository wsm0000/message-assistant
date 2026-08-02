import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/entities/quick_reply.dart';
import 'package:message_assistant/domain/entities/failure.dart';
import 'package:message_assistant/domain/repositories/i_message_repository.dart';
import 'package:message_assistant/presentation/pages/message_detail/message_detail_page.dart';
import 'package:message_assistant/presentation/providers/providers.dart';

/// Records the args passed to PlatformActions so tests can assert the composed
/// reply text was copied and WeChat was launched / jumped to.
class _FakePlatformActions extends PlatformActions {
  String? lastCopied;
  String? lastJumpKey;
  int copyCalls = 0;
  int launchCalls = 0;
  int jumpCalls = 0;
  bool launchResult = true;
  bool jumpResult = false;

  @override
  Future<void> copyToClipboard(String text) async {
    lastCopied = text;
    copyCalls++;
  }

  @override
  Future<bool> launchWechat() async {
    launchCalls++;
    return launchResult;
  }

  @override
  Future<bool> jumpToChat(String? jumpKey) async {
    lastJumpKey = jumpKey;
    jumpCalls++;
    return jumpResult;
  }
}

/// A no-op message repository that records markReplied calls.
class _RecordingMessageRepo implements IMessageRepository {
  String? lastMarkedId;
  String? lastReplyContent;
  MessageRecord? stored;

  @override
  Future<Either<Failure, MessageRecord>> save(MessageRecord record) async {
    stored = record;
    return right(record);
  }

  @override
  Future<Either<Failure, bool>> existsByFingerprint(String fingerprint) async {
    return right(false);
  }

  @override
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({
    String? groupId,
    int limit = 50,
    int offset = 0,
  }) async {
    return right(stored == null ? <MessageRecord>[] : [stored!]);
  }

  @override
  Future<Either<Failure, MessageRecord?>> findById(String id) async {
    return right(stored);
  }

  @override
  Future<Either<Failure, void>> markRead(String id) async => right(null);

  @override
  Future<Either<Failure, void>> markReplied(String id, String replyContent) async {
    lastMarkedId = id;
    lastReplyContent = replyContent;
    return right(null);
  }
}

MessageRecord _msg({String? jumpKey}) {
  final now = DateTime(2026, 7, 31, 9, 0);
  return MessageRecord(
    id: 'm1',
    appId: 'com.tencent.mm',
    groupId: 'g1',
    groupName: '南京货运群',
    senderName: '王师傅',
    content: '南京到上海有一车货',
    score: 60,
    occurredAt: now,
    receivedAt: now,
    fingerprint: 'fp1',
    createdAt: now,
    jumpKey: jumpKey,
  );
}

List<QuickReply> _phrases() {
  final t = DateTime(2026);
  return [
    QuickReply(id: 'qr1', text: '接单', sortOrder: 0, isDefault: true, createdAt: t),
    QuickReply(id: 'qr2', text: '已发车', sortOrder: 1, createdAt: t),
  ];
}

Widget _harness(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: MessageDetailPage(id: 'm1'),
      debugShowCheckedModeBanner: false,
    ),
  );
}

void main() {
  testWidgets('detail page renders the 回复 button', (tester) async {
    final repo = _RecordingMessageRepo()..stored = _msg();
    await tester.pumpWidget(_harness([
      messageDetailProvider('m1').overrideWith((ref) async => repo.stored),
      quickReplyListProvider.overrideWith((ref) async => _phrases()),
      platformActionsProvider.overrideWithValue(_FakePlatformActions()),
      messageRepoProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '回复'), findsOneWidget);
    // The old "复制并打开微信" label must be gone.
    expect(find.text('复制并打开微信'), findsNothing);
  });

  testWidgets('tapping 回复 opens the sheet showing seeded phrases',
      (tester) async {
    final repo = _RecordingMessageRepo()..stored = _msg();
    await tester.pumpWidget(_harness([
      messageDetailProvider('m1').overrideWith((ref) async => repo.stored),
      quickReplyListProvider.overrideWith((ref) async => _phrases()),
      platformActionsProvider.overrideWithValue(_FakePlatformActions()),
      messageRepoProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '回复'));
    await tester.pumpAndSettle();

    // Sheet header + both phrases present.
    expect(find.text('选择回复话术'), findsOneWidget);
    expect(find.text('接单'), findsOneWidget);
    expect(find.text('已发车'), findsOneWidget);
    // The default phrase shows a 默认 chip.
    expect(find.widgetWithText(Chip, '默认'), findsOneWidget);
    // Custom entry present.
    expect(find.text('自定义…'), findsOneWidget);
  });

  testWidgets('tapping a phrase composes @sender phrase, copies, launches '
      'WeChat, marks replied, and shows the success SnackBar', (tester) async {
    final repo = _RecordingMessageRepo()..stored = _msg();
    final pa = _FakePlatformActions();
    await tester.pumpWidget(_harness([
      messageDetailProvider('m1').overrideWith((ref) async => repo.stored),
      quickReplyListProvider.overrideWith((ref) async => _phrases()),
      platformActionsProvider.overrideWithValue(pa),
      messageRepoProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '回复'));
    await tester.pumpAndSettle();

    // Tap the second phrase (已发车) — must compose "@王师傅 已发车".
    await tester.tap(find.text('已发车'));
    await tester.pumpAndSettle();

    expect(pa.copyCalls, 1);
    expect(pa.launchCalls, 1);
    expect(pa.lastCopied, '@王师傅 已发车');
    expect(repo.lastMarkedId, 'm1');
    expect(repo.lastReplyContent, '@王师傅 已发车');
    expect(find.text('已复制，已打开微信，请粘贴发送'), findsOneWidget);
  });

  testWidgets('falls back to launching WeChat (no jump) when launchWechat '
      'returns false', (tester) async {
    final repo = _RecordingMessageRepo()..stored = _msg();
    final pa = _FakePlatformActions()..launchResult = false;
    await tester.pumpWidget(_harness([
      messageDetailProvider('m1').overrideWith((ref) async => repo.stored),
      quickReplyListProvider.overrideWith((ref) async => _phrases()),
      platformActionsProvider.overrideWithValue(pa),
      messageRepoProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '回复'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('接单'));
    await tester.pumpAndSettle();

    expect(pa.lastCopied, '@王师傅 接单');
    // No jumpKey on the message → jumpToChat returns false → launchWechat
    // fallback is attempted (returns false here) → fallback SnackBar.
    expect(find.text('已复制，已打开微信，请粘贴发送'), findsOneWidget);
  });

  testWidgets('when jumpKey is present and jumpToChat succeeds, jumps straight '
      'to the chat (no launchWechat) and shows the jump SnackBar',
      (tester) async {
    final repo = _RecordingMessageRepo()..stored = _msg(jumpKey: 'g1');
    final pa = _FakePlatformActions()..jumpResult = true;
    await tester.pumpWidget(_harness([
      messageDetailProvider('m1').overrideWith((ref) async => repo.stored),
      quickReplyListProvider.overrideWith((ref) async => _phrases()),
      platformActionsProvider.overrideWithValue(pa),
      messageRepoProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '回复'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('接单'));
    await tester.pumpAndSettle();

    expect(pa.lastCopied, '@王师傅 接单');
    // jumpToChat called with the message's jumpKey; launchWechat NOT called.
    expect(pa.jumpCalls, 1);
    expect(pa.lastJumpKey, 'g1');
    expect(pa.launchCalls, 0);
    expect(find.text('已复制，已跳转到群聊，请粘贴发送'), findsOneWidget);
  });

  testWidgets('when jumpKey is present but jumpToChat fails, falls back to '
      'launchWechat', (tester) async {
    final repo = _RecordingMessageRepo()..stored = _msg(jumpKey: 'g1');
    final pa = _FakePlatformActions()
      ..jumpResult = false
      ..launchResult = true;
    await tester.pumpWidget(_harness([
      messageDetailProvider('m1').overrideWith((ref) async => repo.stored),
      quickReplyListProvider.overrideWith((ref) async => _phrases()),
      platformActionsProvider.overrideWithValue(pa),
      messageRepoProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '回复'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('接单'));
    await tester.pumpAndSettle();

    // Both attempted; jump failed so the launch fallback ran.
    expect(pa.jumpCalls, 1);
    expect(pa.launchCalls, 1);
    expect(find.text('已复制，已打开微信，请粘贴发送'), findsOneWidget);
  });

  testWidgets('sheet shows 暂无话术 when the phrase list is empty',
      (tester) async {
    final repo = _RecordingMessageRepo()..stored = _msg();
    await tester.pumpWidget(_harness([
      messageDetailProvider('m1').overrideWith((ref) async => repo.stored),
      quickReplyListProvider.overrideWith((ref) async => <QuickReply>[]),
      platformActionsProvider.overrideWithValue(_FakePlatformActions()),
      messageRepoProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '回复'));
    await tester.pumpAndSettle();

    expect(find.text('暂无话术'), findsOneWidget);
    // The custom reply fallback is still available.
    expect(find.text('自定义…'), findsOneWidget);
  });

  testWidgets('custom dialog composes a one-off reply', (tester) async {
    final repo = _RecordingMessageRepo()..stored = _msg();
    final pa = _FakePlatformActions();
    await tester.pumpWidget(_harness([
      messageDetailProvider('m1').overrideWith((ref) async => repo.stored),
      quickReplyListProvider.overrideWith((ref) async => _phrases()),
      platformActionsProvider.overrideWithValue(pa),
      messageRepoProvider.overrideWithValue(repo),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '回复'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('自定义…'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '马上到');
    await tester.tap(find.widgetWithText(FilledButton, '确定'));
    await tester.pumpAndSettle();

    expect(pa.lastCopied, '@王师傅 马上到');
    expect(find.text('已复制，已打开微信，请粘贴发送'), findsOneWidget);
  });
}
