import 'package:dartz/dartz.dart';
import '../entities/message_record.dart';
import '../entities/failure.dart';

abstract class IMessageRepository {
  Future<Either<Failure, MessageRecord>> save(MessageRecord record);
  Future<Either<Failure, bool>> existsByFingerprint(String fingerprint);
  Future<Either<Failure, List<MessageRecord>>> findRecentPaged({
    String? groupId,
    int limit = 50,
    int offset = 0,
  });
  Future<Either<Failure, MessageRecord?>> findById(String id);
  Future<Either<Failure, void>> markRead(String id);
  Future<Either<Failure, void>> markReplied(String id, String replyContent);
}
