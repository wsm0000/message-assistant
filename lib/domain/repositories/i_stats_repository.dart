import 'package:dartz/dartz.dart';
import '../entities/failure.dart';
import '../entities/message_stats.dart';

/// Reads aggregate statistics for the dashboard.
abstract class IStatsRepository {
  Future<Either<Failure, MessageStats>> getStats();
}
