import 'package:drift/drift.dart';

class MonitoredGroups extends Table {
  TextColumn get groupId => text()();
  TextColumn get groupName => text()();
  TextColumn get appId => text()();
  BoolColumn get isWhitelist => boolean().withDefault(const Constant(false))();
  BoolColumn get isBlacklist => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastActiveAt => dateTime()();

  @override
  Set<Column> get primaryKey => {groupId};
}
