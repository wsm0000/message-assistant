import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:message_assistant/app/app.dart';
import 'package:message_assistant/domain/entities/keyword_rule.dart';
import 'package:message_assistant/domain/entities/message_record.dart';
import 'package:message_assistant/domain/entities/quick_reply.dart';
import 'package:message_assistant/presentation/providers/providers.dart';

/// End-to-end routing test for the bottom navigation bar.
///
/// Pumps the real [MessageAssistantApp] (so the [GoRouter] with its
/// `StatefulShellRoute.indexedStack` is exercised) inside a [ProviderScope]
/// that stubs the native/bootstrap and read-model providers, then asserts:
///   - the Material 3 [NavigationBar] renders exactly the 4 destinations
///     (消息 / 关键词 / 历史 / 设置),
///   - tapping a tab switches the active branch body.

class _NoopPlatformActions extends PlatformActions {}

List<Override> _overrides() => [
      // Avoid touching native notification/MethodChannels at startup.
      bootstrapProvider.overrideWith((ref) async {}),
      platformActionsProvider.overrideWithValue(_NoopPlatformActions()),
      // Empty read-models so each tab page builds its empty state quickly.
      messageListProvider(null).overrideWith((ref) async => <MessageRecord>[]),
      keywordListProvider.overrideWith((ref) async => <KeywordRule>[]),
      quickReplyListProvider.overrideWith((ref) async => <QuickReply>[]),
    ];

void main() {
  testWidgets('Bottom nav renders 4 destinations: 消息/关键词/历史/设置',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(),
        child: const MessageAssistantApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Material 3 NavigationBar (not the legacy BottomNavigationBar).
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);

    // Exactly 4 destinations with the expected labels.
    final labels = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .map((d) => d.label)
        .toList();
    expect(labels, ['消息', '关键词', '历史', '设置']);
  });

  testWidgets('Tapping a bottom-nav tab switches the body branch',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(),
        child: const MessageAssistantApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Start on 消息 tab — HomePage's AppBar title is visible.
    expect(find.text('消息助手'), findsOneWidget);

    // Tap 设置 → SettingsPage AppBar title ('设置') becomes visible, and
    // HomePage's title disappears.
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsWidgets);
    expect(find.text('消息助手'), findsNothing);

    // Tap 关键词 → KeywordListPage AppBar title ('关键词') is visible.
    await tester.tap(find.text('关键词'));
    await tester.pumpAndSettle();
    expect(find.text('关键词'), findsWidgets);

    // Tap 历史 → HistoryPage AppBar title ('历史') is visible.
    await tester.tap(find.text('历史'));
    await tester.pumpAndSettle();
    expect(find.text('历史'), findsWidgets);
  });
}
