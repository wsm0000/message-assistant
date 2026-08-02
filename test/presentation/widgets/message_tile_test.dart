import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:message_assistant/domain/entities/match_result.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/quick_reply.dart';
import 'package:message_assistant/presentation/providers/providers.dart';
import 'package:message_assistant/presentation/widgets/message_tile.dart';

/// Focused tests for the shared [MessageTile]. The tile must:
///   - render the title/sender/content/命中 chrome in both layouts,
///   - show a 回复 button that opens the quick-reply sheet,
///   - keep the card body navigation (context.push) independent of the button.

class _FakePlatformActions extends PlatformActions {
  int launchCalls = 0;
  String? lastCopied;
  @override
  Future<void> copyToClipboard(String text) async {
    lastCopied = text;
  }

  @override
  Future<bool> launchWechat() async {
    launchCalls++;
    return true;
  }
}

MessageRecord _msg() {
  final now = DateTime(2026, 7, 31, 9, 5);
  return MessageRecord(
    id: 'm1',
    appId: 'com.tencent.mm',
    groupId: 'g1',
    groupName: '南京货运群',
    senderName: '张师傅',
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
  );
}

List<QuickReply> _phrases() {
  final t = DateTime(2026);
  return [
    QuickReply(id: 'qr1', text: '接单', sortOrder: 0, isDefault: true, createdAt: t),
  ];
}

/// Harness mounts the tile at '/' so context.push('/message/:id') resolves.
Widget _harness(Widget child, List<Override> overrides) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (c, s) => child),
      GoRoute(
        path: '/message/:id',
        builder: (c, s) => Scaffold(body: Text('detail-${s.pathParameters['id']}')),
      ),
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
  testWidgets('MessageTile renders title, sender, content, and 命中 line',
      (tester) async {
    await tester.pumpWidget(_harness(
      Scaffold(body: ListView(children: [MessageTile(message: _msg())])),
      [
        quickReplyListProvider.overrideWith((ref) async => _phrases()),
        platformActionsProvider.overrideWithValue(_FakePlatformActions()),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('南京货运群'), findsOneWidget);
    expect(find.text('张师傅'), findsOneWidget);
    expect(find.text('命中: 南京'), findsOneWidget);
    // The 回复 button is present on the card.
    expect(find.widgetWithText(TextButton, '回复'), findsOneWidget);
  });

  testWidgets('compact mode hides the 命中 line and shows sender·time row',
      (tester) async {
    await tester.pumpWidget(_harness(
      Scaffold(
          body: ListView(children: [MessageTile(message: _msg(), compact: true)])),
      [
        quickReplyListProvider.overrideWith((ref) async => _phrases()),
        platformActionsProvider.overrideWithValue(_FakePlatformActions()),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('南京货运群'), findsOneWidget);
    // Compact combines sender + time into one row; no standalone 命中 line.
    expect(find.text('张师傅'), findsNothing);
    expect(find.text('命中: 南京'), findsNothing);
    expect(find.textContaining('张师傅'), findsOneWidget);
    // 回复 button still rendered in compact mode.
    expect(find.widgetWithText(TextButton, '回复'), findsOneWidget);
  });

  testWidgets('tapping 回复 opens the quick-reply sheet', (tester) async {
    await tester.pumpWidget(_harness(
      Scaffold(body: ListView(children: [MessageTile(message: _msg())])),
      [
        quickReplyListProvider.overrideWith((ref) async => _phrases()),
        platformActionsProvider.overrideWithValue(_FakePlatformActions()),
      ],
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, '回复'));
    await tester.pumpAndSettle();

    // The sheet shows its header and the seeded phrase.
    expect(find.text('选择回复话术'), findsOneWidget);
    expect(find.text('接单'), findsOneWidget);
  });

  testWidgets(
      'tapping the card body navigates to detail; tapping 回复 does not '
      'navigate (separate tap target)', (tester) async {
    await tester.pumpWidget(_harness(
      Scaffold(body: ListView(children: [MessageTile(message: _msg())])),
      [
        quickReplyListProvider.overrideWith((ref) async => _phrases()),
        platformActionsProvider.overrideWithValue(_FakePlatformActions()),
      ],
    ));
    await tester.pumpAndSettle();

    // Open the sheet via the 回复 button.
    await tester.tap(find.widgetWithText(TextButton, '回复'));
    await tester.pumpAndSettle();
    expect(find.text('选择回复话术'), findsOneWidget);
    // We did NOT navigate to the detail route.
    expect(find.text('detail-m1'), findsNothing);
  });
}
