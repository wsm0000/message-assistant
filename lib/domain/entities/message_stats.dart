import 'package:equatable/equatable.dart';

/// One day's hit count, for the trend chart.
class DailyCount extends Equatable {
  /// The calendar day, normalized to local midnight.
  final DateTime day;
  final int count;

  const DailyCount(this.day, this.count);

  @override
  List<Object?> get props => [day, count];
}

/// A (label, count) pair for top-N rankings (top groups / top keywords).
class NamedCount extends Equatable {
  final String name;
  final int count;

  const NamedCount(this.name, this.count);

  @override
  List<Object?> get props => [name, count];
}

/// Aggregate statistics for the dashboard.
class MessageStats extends Equatable {
  /// Hits whose `occurredAt` falls on today's date.
  final int todayCount;
  /// All hits.
  final int totalCount;
  /// Hits with `isRead = false`.
  final int unreadCount;
  /// Hits with `isReplied = true`.
  final int repliedCount;
  /// `repliedCount / totalCount` (0 when there are no hits).
  final double replyRate;
  /// 7 entries, oldest -> newest, with `day` normalized to midnight and
  /// zero counts filled in for days that had no hits.
  final List<DailyCount> last7Days;
  /// Groups ranked by hit count, capped at the requested limit.
  final List<NamedCount> topGroups;
  /// Keywords ranked by hit count (parsed from `matchedKeywordsJson`),
  /// capped at the requested limit.
  final List<NamedCount> topKeywords;

  const MessageStats({
    required this.todayCount,
    required this.totalCount,
    required this.unreadCount,
    required this.repliedCount,
    required this.replyRate,
    required this.last7Days,
    required this.topGroups,
    required this.topKeywords,
  });

  /// Empty value used as a fallback when [IStatsRepository.getStats] fails or
  /// before any data exists. All counters are zero and the rankings are empty.
  static const MessageStats empty = MessageStats(
    todayCount: 0,
    totalCount: 0,
    unreadCount: 0,
    repliedCount: 0,
    replyRate: 0.0,
    last7Days: [],
    topGroups: [],
    topKeywords: [],
  );

  @override
  List<Object?> get props => [
        todayCount,
        totalCount,
        unreadCount,
        repliedCount,
        replyRate,
        last7Days,
        topGroups,
        topKeywords,
      ];
}
