import 'package:dartz/dartz.dart';
import '../entities/quick_reply.dart';
import '../entities/failure.dart';

abstract class IQuickReplyRepository {
  Future<Either<Failure, List<QuickReply>>> findAll();
  Future<Either<Failure, QuickReply>> save(QuickReply phrase);
  Future<Either<Failure, void>> delete(String id);
  /// Reorder: persist the new sort order for the given id list (ascending).
  Future<Either<Failure, void>> reorder(List<String> orderedIds);
}
