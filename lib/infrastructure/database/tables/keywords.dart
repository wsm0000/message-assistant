import 'package:drift/drift.dart';

class KeywordRules extends Table {
  TextColumn get id => text()();
  TextColumn get keyword => text()();
  IntColumn get type => integer()(); // 0=exact,1=contains
  IntColumn get priority => integer().withDefault(const Constant(50))();
  TextColumn get scopeGroupIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get excludeWordsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get groupName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
