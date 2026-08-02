import 'package:dartz/dartz.dart';

import '../../domain/entities/failure.dart';
import '../../domain/entities/message_stats.dart';
import '../../domain/repositories/i_stats_repository.dart';
import 'database.dart';

/// `IStatsRepository` backed by the Drift database. Aggregates the per-metric
/// counts produced by [MessageDao] into a single [MessageStats] value.
class DriftStatsRepository implements IStatsRepository {
  final AppDatabase db;
  DriftStatsRepository(this.db);

  @override
  Future<Either<Failure, MessageStats>> getStats() async {
    try {
      final total = await db.messageDao.totalCount();
      final today = await db.messageDao.countToday();
      final unread = await db.messageDao.unreadCount();
      final replied = await db.messageDao.repliedCount();
      final last7 = await db.messageDao.last7DaysCounts();
      final topG = await db.messageDao.topGroups(5);
      final topK = await db.messageDao.topKeywords(5);
      final rate = total > 0 ? replied / total : 0.0;
      return right(MessageStats(
        todayCount: today,
        totalCount: total,
        unreadCount: unread,
        repliedCount: replied,
        replyRate: rate,
        last7Days: last7,
        topGroups: topG,
        topKeywords: topK,
      ));
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
