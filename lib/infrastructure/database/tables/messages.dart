import 'package:drift/drift.dart';

class MessageRecords extends Table {
  TextColumn get id => text()();
  TextColumn get appId => text()();
  TextColumn get groupId => text()();
  TextColumn get groupName => text().nullable()();
  TextColumn get senderName => text()();
  TextColumn get senderId => text().nullable()();
  TextColumn get content => text()();
  TextColumn get matchedKeywordsJson => text().withDefault(const Constant('[]'))();
  IntColumn get score => integer().withDefault(const Constant(0))();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get receivedAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isReplied => boolean().withDefault(const Constant(false))();
  TextColumn get replyContent => text().nullable()();
  TextColumn get fingerprint => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  // The jump key (groupId) referencing a native-held contentIntent; nullable so
  // old DB rows (pre-v2) and messages without a captured intent are null.
  TextColumn get jumpKey => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
