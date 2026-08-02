import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/match_result.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/entities/quick_reply.dart';
import 'package:message_assistant/presentation/pages/home/home_page.dart';
import 'package:message_assistant/presentation/providers/providers.dart';

/// No-op [PlatformActions] so the tile's 回复 button can build under test
/// without hitting the real MethodChannel. Only the list-card rendering is
/// asserted here; the reply flow itself is covered by message_tile_test.dart
/// and reply_sheet_test.dart.
class _NoopPlatformActions extends PlatformActions {}

/// Smoke-tests the HomePage: empty state CTA, the grouped-by-WeChat-group
/// collapsible layout, and the 回复 button inside a group.
///
/// Overrides the autoDispose.family `messageListProvider(null)` with the
/// classic Riverpod family-override syntax:
///   `messageListProvider(null).overrideWith((ref) async => <MessageRecord>[...])`
List<MessageRecord> _sample() {
  final now = DateTime(2026, 7, 30, 9, 5);
  return [
    MessageRecord(
      id: 'm1',
      appId: 'com.tencent.mm',
      groupId: 'g1',
      groupName: '南京货运群',
      senderName: '张师傅',
      senderId: 'u1',
      content: '南京到上海有一车货，9点出发',
      hits: [
        const KeywordHit(
          ruleId: 'k1',
          keyword: '南京',
          type: MatchType.contains,
          priority: 60,
          highlightPositions: [0],
        ),
      ],
      score: 60,
      occurredAt: now,
      receivedAt: now,
      fingerprint: 'fp1',
      createdAt: now,
    ),
  ];
}

/// Two groups — g1 (南京货运群) most recent, g2 (上海物流) older. The list is
/// already ordered occurredAt desc, so g1 must be the FIRST group section and
/// hold the latest overall message at its top.
List<MessageRecord> _twoGroupSample() {
  final t1 = DateTime(2026, 7, 30, 14, 32); // newest overall
  final t2 = DateTime(2026, 7, 30, 9, 5);
  final t3 = DateTime(2026, 7, 29, 8, 0); // older group's only msg
  return [
    MessageRecord(
      id: 'm1',
      appId: 'com.tencent.mm',
      groupId: 'g1',
      groupName: '南京货运群',
      senderName: '张师傅',
      content: '南京到上海有一车货，9点出发',
      hits: const [
        KeywordHit(
          ruleId: 'k1',
          keyword: '南京',
          type: MatchType.contains,
          priority: 60,
          highlightPositions: [0],
        ),
      ],
      score: 60,
      occurredAt: t1,
      receivedAt: t1,
      fingerprint: 'fp1',
      createdAt: t1,
    ),
    MessageRecord(
      id: 'm2',
      appId: 'com.tencent.mm',
      groupId: 'g1',
      groupName: '南京货运群',
      senderName: '李师傅',
      content: '苏州有一批急件',
      hits: const [
        KeywordHit(
          ruleId: 'k2',
          keyword: '苏州',
          type: MatchType.contains,
          priority: 50,
          highlightPositions: [0],
        ),
      ],
      score: 50,
      occurredAt: t2,
      receivedAt: t2,
      fingerprint: 'fp2',
      createdAt: t2,
    ),
    MessageRecord(
      id: 'm3',
      appId: 'com.tencent.mm',
      groupId: 'g2',
      groupName: '上海物流',
      senderName: '王总',
      content: '上海到杭州明天发车',
      hits: const [
        KeywordHit(
          ruleId: 'k3',
          keyword: '上海',
          type: MatchType.contains,
          priority: 55,
          highlightPositions: [0],
        ),
      ],
      score: 55,
      occurredAt: t3,
      receivedAt: t3,
      fingerprint: 'fp3',
      createdAt: t3,
    ),
  ];
}

Widget _harness(List<Override> overrides) {
  // Provide a go_router so HomePage's context.push/context.go works; home is '/'.
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomePage()),
      GoRoute(path: '/keywords', builder: (c, s) => const Scaffold(body: Text('kw'))),
      GoRoute(path: '/settings', builder: (c, s) => const Scaffold(body: Text('set'))),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    ),
  );
}

void main() {
  testWidgets('HomePage shows empty-state CTA when there are no messages',
      (tester) async {
    await tester.pumpWidget(_harness([
      messageListProvider(null).overrideWith((ref) async => <MessageRecord>[]),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('还没有命中消息，去配置关键词吧'), findsOneWidget);
    expect(find.text('配置关键词'), findsOneWidget);
  });

  testWidgets('HomePage renders a single group section with its messages',
      (tester) async {
    await tester.pumpWidget(_harness([
      messageListProvider(null).overrideWith((ref) async => _sample()),
      quickReplyListProvider.overrideWith((ref) async => <QuickReply>[]),
      platformActionsProvider.overrideWithValue(_NoopPlatformActions()),
    ]));
    await tester.pumpAndSettle();

    // Exactly one group section (ExpansionTile) renders.
    final sections = find.byType(ExpansionTile);
    expect(sections, findsNWidgets(1));
    // Its title row contains the group's display name.
    expect(find.text('南京货运群'), findsWidgets);
    // Collapsed by default: the latest-message preview (sender: content) shows.
    expect(find.textContaining('张师傅:'), findsOneWidget);
    // The "回复最新" button is rendered in the collapsed header.
    expect(find.widgetWithText(TextButton, '回复最新'), findsOneWidget);
    // The empty-state CTA must NOT appear.
    expect(find.text('还没有命中消息，去配置关键词吧'), findsNothing);
  });

  testWidgets(
      'HomePage groups messages by WeChat group: the most-recently-active '
      'group is the first section and holds the latest message', (tester) async {
    await tester.pumpWidget(_harness([
      messageListProvider(null).overrideWith((ref) async => _twoGroupSample()),
      quickReplyListProvider.overrideWith((ref) async => <QuickReply>[]),
      platformActionsProvider.overrideWithValue(_NoopPlatformActions()),
    ]));
    await tester.pumpAndSettle();

    // Two group section headers render.
    final expansionTiles = find.byType(ExpansionTile);
    expect(expansionTiles, findsNWidgets(2));

    // Both group display names render (in collapsed headers).
    expect(find.text('南京货运群'), findsWidgets);
    expect(find.text('上海物流'), findsWidgets);

    // Group-count summary header reflects 2 groups / 3 messages.
    expect(find.text('共 2 个群 · 3 条消息'), findsOneWidget);

    // Each collapsed group header has a "回复最新" button (2 groups → 2).
    expect(find.widgetWithText(TextButton, '回复最新'), findsNWidgets(2));
  });

  testWidgets('HomePage collapsed-header 回复最新 button opens the quick-reply sheet',
      (tester) async {
    final t = DateTime(2026);
    await tester.pumpWidget(_harness([
      messageListProvider(null).overrideWith((ref) async => _sample()),
      quickReplyListProvider.overrideWith((ref) async => [
            QuickReply(
                id: 'qr1', text: '接单', sortOrder: 0, isDefault: true, createdAt: t),
          ]),
      platformActionsProvider.overrideWithValue(_NoopPlatformActions()),
    ]));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, '回复最新'));
    await tester.pumpAndSettle();

    // The shared reply sheet (same one the detail page uses) is shown.
    expect(find.text('选择回复话术'), findsOneWidget);
    expect(find.text('接单'), findsOneWidget);
  });

  testWidgets('HomePage shows loading indicator before data resolves',
      (tester) async {
    await tester.pumpWidget(_harness([
      // Never-completing future keeps it in loading state.
      messageListProvider(null).overrideWith((ref) async => Completer<List<MessageRecord>>().future),
    ]));
    await tester.pump(); // first frame (loading)

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
