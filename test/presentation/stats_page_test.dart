import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:message_assistant/domain/entities/message_stats.dart';
import 'package:message_assistant/presentation/pages/stats/stats_page.dart';
import 'package:message_assistant/presentation/providers/providers.dart';

/// Sample dashboard data used across the populated-state assertions.
MessageStats _sample() {
  // 7 consecutive days, oldest -> newest.
  final base = DateTime(2026, 7, 25);
  final days = [
    for (var i = 0; i < 7; i++) DailyCount(DateTime(base.year, base.month, base.day + i), (i + 1) * 3),
  ];
  return MessageStats(
    todayCount: 5,
    totalCount: 42,
    unreadCount: 7,
    repliedCount: 25,
    replyRate: 25 / 42,
    last7Days: days,
    topGroups: const [
      NamedCount('南京货运群', 18),
      NamedCount('上海物流', 10),
    ],
    topKeywords: const [
      NamedCount('南京', 12),
      NamedCount('接单', 8),
    ],
  );
}

Widget _harness(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: StatsPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

void main() {
  testWidgets('StatsPage shows the empty state when there are no hits',
      (tester) async {
    await tester.pumpWidget(_harness([
      statsProvider.overrideWith((ref) async => MessageStats.empty),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('还没有命中数据，配置关键词后这里会显示统计'), findsOneWidget);
    // No chart / summary cards in the empty state.
    expect(find.byType(BarChart), findsNothing);
    expect(find.text('今日命中'), findsNothing);
  });

  testWidgets('StatsPage renders summary cards, chart and rankings',
      (tester) async {
    // The dashboard is scrollable; give the test a tall viewport so every
    // ListView child (including the off-screen Top-5 sections) is built.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness([
      statsProvider.overrideWith((ref) async => _sample()),
    ]));
    await tester.pumpAndSettle();

    // --- Four summary cards (label + value pairs). ---
    expect(find.text('今日命中'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('总命中'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('未读'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('回复率'), findsOneWidget);
    // 25/42 = 59.5% -> rounds to 60%.
    expect(find.text('60%'), findsOneWidget);

    // --- Trend chart title + BarChart widget. ---
    expect(find.text('近 7 天命中趋势'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);

    // --- Top groups / keywords titles + rows. ---
    expect(find.text('命中最多的群 (Top 5)'), findsOneWidget);
    expect(find.text('南京货运群'), findsOneWidget);
    expect(find.text('上海物流'), findsOneWidget);
    expect(find.text('命中最多的关键词 (Top 5)'), findsOneWidget);
    expect(find.text('南京'), findsOneWidget);
    expect(find.text('接单'), findsOneWidget);

    // --- Day axis labels (oldest day = 07-25). ---
    expect(find.text('07-25'), findsOneWidget);
    expect(find.text('07-31'), findsOneWidget);
  });

  testWidgets('StatsPage shows loading indicator before data resolves',
      (tester) async {
    await tester.pumpWidget(_harness([
      // Never-completing future keeps it in loading state.
      statsProvider.overrideWith((ref) => Completer<MessageStats>().future),
    ]));
    await tester.pump(); // first frame (loading)

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('数据统计'), findsOneWidget);
  });
}
