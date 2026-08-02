import 'package:dartz/dartz.dart';
import '../entities/keyword_rule.dart';
import '../entities/failure.dart';

abstract class IKeywordRepository {
  Future<Either<Failure, List<KeywordRule>>> findAll();
  Future<Either<Failure, List<KeywordRule>>> findByScope(String groupId);
  Future<Either<Failure, KeywordRule>> save(KeywordRule rule);
  Future<Either<Failure, void>> delete(String id);
}
