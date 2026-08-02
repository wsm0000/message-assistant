import 'package:dartz/dartz.dart';
import '../entities/auto_reply.dart';
import '../entities/failure.dart';

abstract class IAutoReplyGateway {
  Future<Either<Failure, AutoReplyOutcome>> execute(AutoReplyRequest request);
  Stream<AutoReplyProgress> get progress;
  Future<void> cancel();
}
