import 'package:dartz/dartz.dart';
import '../entities/failure.dart';

class QuietHours {
  final int startHour; // 0-23
  final int endHour; // 0-23
  final bool enabled;
  const QuietHours({
    required this.startHour,
    required this.endHour,
    required this.enabled,
  });
  const QuietHours.disabled()
      : startHour = 22,
        endHour = 7,
        enabled = false;
}

abstract class IConfigStore {
  Future<Either<Failure, QuietHours>> getQuietHours();
  Future<Either<Failure, void>> setQuietHours(QuietHours qh);
  Future<Either<Failure, List<String>>> getTargetAppPackages();
  Future<Either<Failure, String>> getDefaultReplyText();
  Future<Either<Failure, void>> setDefaultReplyText(String text);
}
