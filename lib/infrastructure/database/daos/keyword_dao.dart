import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/keywords.dart';

part 'keyword_dao.g.dart';

@DriftAccessor(tables: [KeywordRules])
class KeywordDao extends DatabaseAccessor<AppDatabase> with _$KeywordDaoMixin {
  KeywordDao(super.db);

  Future<List<KeywordRule>> all() => select(keywordRules).get();

  Future<void> upsert(KeywordRulesCompanion entry) =>
      into(keywordRules).insertOnConflictUpdate(entry);

  Future<int> deleteById(String id) =>
      (delete(keywordRules)..where((t) => t.id.equals(id))).go();
}
