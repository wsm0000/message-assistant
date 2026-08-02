import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/message_stats.dart';
import '../../providers/providers.dart';

/// "数据统计" dashboard. Shows four summary cards, a 7-day hit-trend bar chart,
/// the top-5 groups and the top-5 keywords by hit count. Falls back to a
/// friendly empty state when there are no hits yet.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('数据统计')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('加载失败：$e'),
          ),
        ),
        data: (stats) => _Body(stats: stats),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final MessageStats stats;
  const _Body({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.totalCount == 0) {
      return const _EmptyState();
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      children: [
        _SummaryGrid(stats: stats),
        const SizedBox(height: 12),
        _SectionCard(
          title: '近 7 天命中趋势',
          child: _TrendChart(daily: stats.last7Days),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: '命中最多的群 (Top 5)',
          child: _TopList(items: stats.topGroups),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: '命中最多的关键词 (Top 5)',
          child: _TopList(items: stats.topKeywords),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('还没有命中数据，配置关键词后这里会显示统计'),
          ],
        ),
      ),
    );
  }
}

// --- Summary cards ------------------------------------------------------------

class _SummaryGrid extends StatelessWidget {
  final MessageStats stats;
  const _SummaryGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _SummaryCard(
          label: '今日命中',
          value: '${stats.todayCount}',
          icon: Icons.today,
        ),
        _SummaryCard(
          label: '总命中',
          value: '${stats.totalCount}',
          icon: Icons.all_inclusive,
        ),
        _SummaryCard(
          label: '未读',
          value: '${stats.unreadCount}',
          icon: Icons.mark_chat_unread_outlined,
        ),
        _SummaryCard(
          label: '回复率',
          value: '${(stats.replyRate * 100).round()}%',
          icon: Icons.reply,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Section wrapper ----------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// --- 7-day trend bar chart ----------------------------------------------------

class _TrendChart extends StatelessWidget {
  final List<DailyCount> daily;
  const _TrendChart({required this.daily});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = theme.colorScheme.primary;
    final entries = daily.take(7).toList();
    final maxY = entries.fold<double>(
      0,
      (m, d) => d.count > m ? d.count.toDouble() : m,
    );

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          // Leave a little headroom above the tallest bar; guard /0.
          maxY: maxY <= 0 ? 1 : maxY * 1.2,
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final d = entries[i].day;
                  final label =
                      '${d.month.toString().padLeft(2, '0')}'
                      '-${d.day.toString().padLeft(2, '0')}';
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].count.toDouble(),
                    color: barColor,
                    width: 14,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// --- Top-N list ---------------------------------------------------------------

class _TopList extends StatelessWidget {
  final List<NamedCount> items;
  const _TopList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '暂无数据',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }
    final maxCount = items.fold<int>(
      0,
      (m, n) => n.count > m ? n.count : m,
    );
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _TopRow(
            rank: i + 1,
            name: items[i].name,
            count: items[i].count,
            fraction: maxCount == 0 ? 0.0 : items[i].count / maxCount,
          ),
      ],
    );
  }
}

class _TopRow extends StatelessWidget {
  final int rank;
  final String name;
  final int count;
  final double fraction;
  const _TopRow({
    required this.rank,
    required this.name,
    required this.count,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name, style: theme.textTheme.bodyMedium),
                    ),
                    Text(
                      '$count',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 4,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
