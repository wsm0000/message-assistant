import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:message_assistant/domain/entities/quick_reply.dart';
import 'package:message_assistant/presentation/pages/settings/settings_page.dart';
import 'package:message_assistant/presentation/providers/providers.dart';

/// SettingsPage reads `platformActionsProvider` in initState to refresh
/// status; override it with a stub that returns safe defaults so the widget
/// test never touches the real MethodChannel.
class _StubPlatformActions extends PlatformActions {
  @override
  Future<bool> isNotificationListenerEnabled() async => false;
  @override
  Future<bool> isMonitorServiceRunning() async => false;
  @override
  Future<void> openNotificationListenerSettings() async {}
  @override
  Future<void> restartMonitorService() async {}
}

List<QuickReply> _phrases() {
  final t = DateTime(2026);
  return [
    QuickReply(id: 'qr1', text: '接单', sortOrder: 0, isDefault: true, createdAt: t),
    QuickReply(id: 'qr2', text: '已发车', sortOrder: 1, createdAt: t),
    QuickReply(id: 'qr3', text: '稍后联系', sortOrder: 2, createdAt: t),
  ];
}

Widget _harness(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: SettingsPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

void main() {
  testWidgets('settings page shows the 回复话术管理 section with seeded phrases',
      (tester) async {
    await tester.pumpWidget(_harness([
      quickReplyListProvider.overrideWith((ref) async => _phrases()),
      platformActionsProvider.overrideWithValue(_StubPlatformActions()),
    ]));
    await tester.pumpAndSettle();

    // The settings ListView builds lazily; scroll the phrase section into view.
    await tester.scrollUntilVisible(
      find.text('回复话术管理'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('回复话术管理'), findsOneWidget);
    expect(find.text('接单'), findsOneWidget);
    expect(find.text('已发车'), findsOneWidget);
    expect(find.text('稍后联系'), findsOneWidget);
    // The default phrase shows a 默认 chip; "+ 新建话术" entry is present.
    expect(find.widgetWithText(Chip, '默认'), findsOneWidget);
    expect(find.text('新建话术'), findsOneWidget);
  });

  testWidgets('tapping + 新建话术 opens the dialog and saves a new phrase',
      (tester) async {
    // Use a real in-memory repo (the production default) wired through the
    // command runner so save() actually persists and the list refreshes.
    await tester.pumpWidget(_harness([
      platformActionsProvider.overrideWithValue(_StubPlatformActions()),
    ]));
    await tester.pumpAndSettle();

    // Seeded default phrase present once the section scrolls into view.
    await tester.scrollUntilVisible(
      find.text('新建话术'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('接单'), findsOneWidget);

    await tester.tap(find.text('新建话术'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '马上到');
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    // The new phrase now appears in the list.
    expect(find.text('马上到'), findsOneWidget);
    expect(find.text('已新建'), findsOneWidget);
  });

  testWidgets('setting a phrase as default clears the previous default',
      (tester) async {
    await tester.pumpWidget(_harness([
      platformActionsProvider.overrideWithValue(_StubPlatformActions()),
    ]));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('新建话术'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // 接单 is the seeded default; 已发车 is not.
    expect(find.widgetWithText(Chip, '默认'), findsOneWidget);

    // Tap the set-default (star) IconButton on the 已发车 row. Scroll the row
    // into view first so the star button is guaranteed hittable regardless of
    // how much content sits above the phrase section.
    final facarTile = find.ancestor(
      of: find.text('已发车'),
      matching: find.byType(ListTile),
    );
    await tester.scrollUntilVisible(
      facarTile,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: facarTile,
      matching: find.byType(IconButton),
    ));
    await tester.pumpAndSettle();

    // Now 已发车 is default and 接单 is not — still exactly one 默认 chip.
    expect(find.widgetWithText(Chip, '默认'), findsOneWidget);
    expect(find.text('已设为默认'), findsOneWidget);
  });

  testWidgets('long-pressing a phrase opens a delete-confirm dialog',
      (tester) async {
    await tester.pumpWidget(_harness([
      platformActionsProvider.overrideWithValue(_StubPlatformActions()),
    ]));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('稍后联系'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('稍后联系'), findsOneWidget);

    await tester.longPress(find.text('稍后联系'));
    await tester.pumpAndSettle();

    expect(find.text('删除话术'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    // The phrase is gone from the list.
    expect(find.text('稍后联系'), findsNothing);
    expect(find.text('已删除'), findsOneWidget);
  });
}
