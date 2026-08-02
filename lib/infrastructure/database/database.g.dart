// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MessageRecordsTable extends MessageRecords
    with TableInfo<$MessageRecordsTable, MessageRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appIdMeta = const VerificationMeta('appId');
  @override
  late final GeneratedColumn<String> appId = GeneratedColumn<String>(
    'app_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchedKeywordsJsonMeta =
      const VerificationMeta('matchedKeywordsJson');
  @override
  late final GeneratedColumn<String> matchedKeywordsJson =
      GeneratedColumn<String>(
        'matched_keywords_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isRepliedMeta = const VerificationMeta(
    'isReplied',
  );
  @override
  late final GeneratedColumn<bool> isReplied = GeneratedColumn<bool>(
    'is_replied',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_replied" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _replyContentMeta = const VerificationMeta(
    'replyContent',
  );
  @override
  late final GeneratedColumn<String> replyContent = GeneratedColumn<String>(
    'reply_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jumpKeyMeta = const VerificationMeta(
    'jumpKey',
  );
  @override
  late final GeneratedColumn<String> jumpKey = GeneratedColumn<String>(
    'jump_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    appId,
    groupId,
    groupName,
    senderName,
    senderId,
    content,
    matchedKeywordsJson,
    score,
    occurredAt,
    receivedAt,
    isRead,
    isReplied,
    replyContent,
    fingerprint,
    createdAt,
    jumpKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('app_id')) {
      context.handle(
        _appIdMeta,
        appId.isAcceptableOrUnknown(data['app_id']!, _appIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_senderNameMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('matched_keywords_json')) {
      context.handle(
        _matchedKeywordsJsonMeta,
        matchedKeywordsJson.isAcceptableOrUnknown(
          data['matched_keywords_json']!,
          _matchedKeywordsJsonMeta,
        ),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('is_replied')) {
      context.handle(
        _isRepliedMeta,
        isReplied.isAcceptableOrUnknown(data['is_replied']!, _isRepliedMeta),
      );
    }
    if (data.containsKey('reply_content')) {
      context.handle(
        _replyContentMeta,
        replyContent.isAcceptableOrUnknown(
          data['reply_content']!,
          _replyContentMeta,
        ),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('jump_key')) {
      context.handle(
        _jumpKeyMeta,
        jumpKey.isAcceptableOrUnknown(data['jump_key']!, _jumpKeyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      appId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      ),
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      matchedKeywordsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matched_keywords_json'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      isReplied: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_replied'],
      )!,
      replyContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_content'],
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      jumpKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jump_key'],
      ),
    );
  }

  @override
  $MessageRecordsTable createAlias(String alias) {
    return $MessageRecordsTable(attachedDatabase, alias);
  }
}

class MessageRecord extends DataClass implements Insertable<MessageRecord> {
  final String id;
  final String appId;
  final String groupId;
  final String? groupName;
  final String senderName;
  final String? senderId;
  final String content;
  final String matchedKeywordsJson;
  final int score;
  final DateTime occurredAt;
  final DateTime receivedAt;
  final bool isRead;
  final bool isReplied;
  final String? replyContent;
  final String fingerprint;
  final DateTime createdAt;
  final String? jumpKey;
  const MessageRecord({
    required this.id,
    required this.appId,
    required this.groupId,
    this.groupName,
    required this.senderName,
    this.senderId,
    required this.content,
    required this.matchedKeywordsJson,
    required this.score,
    required this.occurredAt,
    required this.receivedAt,
    required this.isRead,
    required this.isReplied,
    this.replyContent,
    required this.fingerprint,
    required this.createdAt,
    this.jumpKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['app_id'] = Variable<String>(appId);
    map['group_id'] = Variable<String>(groupId);
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    map['sender_name'] = Variable<String>(senderName);
    if (!nullToAbsent || senderId != null) {
      map['sender_id'] = Variable<String>(senderId);
    }
    map['content'] = Variable<String>(content);
    map['matched_keywords_json'] = Variable<String>(matchedKeywordsJson);
    map['score'] = Variable<int>(score);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['is_read'] = Variable<bool>(isRead);
    map['is_replied'] = Variable<bool>(isReplied);
    if (!nullToAbsent || replyContent != null) {
      map['reply_content'] = Variable<String>(replyContent);
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || jumpKey != null) {
      map['jump_key'] = Variable<String>(jumpKey);
    }
    return map;
  }

  MessageRecordsCompanion toCompanion(bool nullToAbsent) {
    return MessageRecordsCompanion(
      id: Value(id),
      appId: Value(appId),
      groupId: Value(groupId),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
      senderName: Value(senderName),
      senderId: senderId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderId),
      content: Value(content),
      matchedKeywordsJson: Value(matchedKeywordsJson),
      score: Value(score),
      occurredAt: Value(occurredAt),
      receivedAt: Value(receivedAt),
      isRead: Value(isRead),
      isReplied: Value(isReplied),
      replyContent: replyContent == null && nullToAbsent
          ? const Value.absent()
          : Value(replyContent),
      fingerprint: Value(fingerprint),
      createdAt: Value(createdAt),
      jumpKey: jumpKey == null && nullToAbsent
          ? const Value.absent()
          : Value(jumpKey),
    );
  }

  factory MessageRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRecord(
      id: serializer.fromJson<String>(json['id']),
      appId: serializer.fromJson<String>(json['appId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      groupName: serializer.fromJson<String?>(json['groupName']),
      senderName: serializer.fromJson<String>(json['senderName']),
      senderId: serializer.fromJson<String?>(json['senderId']),
      content: serializer.fromJson<String>(json['content']),
      matchedKeywordsJson: serializer.fromJson<String>(
        json['matchedKeywordsJson'],
      ),
      score: serializer.fromJson<int>(json['score']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isReplied: serializer.fromJson<bool>(json['isReplied']),
      replyContent: serializer.fromJson<String?>(json['replyContent']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      jumpKey: serializer.fromJson<String?>(json['jumpKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'appId': serializer.toJson<String>(appId),
      'groupId': serializer.toJson<String>(groupId),
      'groupName': serializer.toJson<String?>(groupName),
      'senderName': serializer.toJson<String>(senderName),
      'senderId': serializer.toJson<String?>(senderId),
      'content': serializer.toJson<String>(content),
      'matchedKeywordsJson': serializer.toJson<String>(matchedKeywordsJson),
      'score': serializer.toJson<int>(score),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'isRead': serializer.toJson<bool>(isRead),
      'isReplied': serializer.toJson<bool>(isReplied),
      'replyContent': serializer.toJson<String?>(replyContent),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'jumpKey': serializer.toJson<String?>(jumpKey),
    };
  }

  MessageRecord copyWith({
    String? id,
    String? appId,
    String? groupId,
    Value<String?> groupName = const Value.absent(),
    String? senderName,
    Value<String?> senderId = const Value.absent(),
    String? content,
    String? matchedKeywordsJson,
    int? score,
    DateTime? occurredAt,
    DateTime? receivedAt,
    bool? isRead,
    bool? isReplied,
    Value<String?> replyContent = const Value.absent(),
    String? fingerprint,
    DateTime? createdAt,
    Value<String?> jumpKey = const Value.absent(),
  }) => MessageRecord(
    id: id ?? this.id,
    appId: appId ?? this.appId,
    groupId: groupId ?? this.groupId,
    groupName: groupName.present ? groupName.value : this.groupName,
    senderName: senderName ?? this.senderName,
    senderId: senderId.present ? senderId.value : this.senderId,
    content: content ?? this.content,
    matchedKeywordsJson: matchedKeywordsJson ?? this.matchedKeywordsJson,
    score: score ?? this.score,
    occurredAt: occurredAt ?? this.occurredAt,
    receivedAt: receivedAt ?? this.receivedAt,
    isRead: isRead ?? this.isRead,
    isReplied: isReplied ?? this.isReplied,
    replyContent: replyContent.present ? replyContent.value : this.replyContent,
    fingerprint: fingerprint ?? this.fingerprint,
    createdAt: createdAt ?? this.createdAt,
    jumpKey: jumpKey.present ? jumpKey.value : this.jumpKey,
  );
  MessageRecord copyWithCompanion(MessageRecordsCompanion data) {
    return MessageRecord(
      id: data.id.present ? data.id.value : this.id,
      appId: data.appId.present ? data.appId.value : this.appId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      matchedKeywordsJson: data.matchedKeywordsJson.present
          ? data.matchedKeywordsJson.value
          : this.matchedKeywordsJson,
      score: data.score.present ? data.score.value : this.score,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isReplied: data.isReplied.present ? data.isReplied.value : this.isReplied,
      replyContent: data.replyContent.present
          ? data.replyContent.value
          : this.replyContent,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      jumpKey: data.jumpKey.present ? data.jumpKey.value : this.jumpKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRecord(')
          ..write('id: $id, ')
          ..write('appId: $appId, ')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('senderName: $senderName, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('matchedKeywordsJson: $matchedKeywordsJson, ')
          ..write('score: $score, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('isRead: $isRead, ')
          ..write('isReplied: $isReplied, ')
          ..write('replyContent: $replyContent, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAt: $createdAt, ')
          ..write('jumpKey: $jumpKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    appId,
    groupId,
    groupName,
    senderName,
    senderId,
    content,
    matchedKeywordsJson,
    score,
    occurredAt,
    receivedAt,
    isRead,
    isReplied,
    replyContent,
    fingerprint,
    createdAt,
    jumpKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRecord &&
          other.id == this.id &&
          other.appId == this.appId &&
          other.groupId == this.groupId &&
          other.groupName == this.groupName &&
          other.senderName == this.senderName &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.matchedKeywordsJson == this.matchedKeywordsJson &&
          other.score == this.score &&
          other.occurredAt == this.occurredAt &&
          other.receivedAt == this.receivedAt &&
          other.isRead == this.isRead &&
          other.isReplied == this.isReplied &&
          other.replyContent == this.replyContent &&
          other.fingerprint == this.fingerprint &&
          other.createdAt == this.createdAt &&
          other.jumpKey == this.jumpKey);
}

class MessageRecordsCompanion extends UpdateCompanion<MessageRecord> {
  final Value<String> id;
  final Value<String> appId;
  final Value<String> groupId;
  final Value<String?> groupName;
  final Value<String> senderName;
  final Value<String?> senderId;
  final Value<String> content;
  final Value<String> matchedKeywordsJson;
  final Value<int> score;
  final Value<DateTime> occurredAt;
  final Value<DateTime> receivedAt;
  final Value<bool> isRead;
  final Value<bool> isReplied;
  final Value<String?> replyContent;
  final Value<String> fingerprint;
  final Value<DateTime> createdAt;
  final Value<String?> jumpKey;
  final Value<int> rowid;
  const MessageRecordsCompanion({
    this.id = const Value.absent(),
    this.appId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupName = const Value.absent(),
    this.senderName = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.matchedKeywordsJson = const Value.absent(),
    this.score = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isReplied = const Value.absent(),
    this.replyContent = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.jumpKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageRecordsCompanion.insert({
    required String id,
    required String appId,
    required String groupId,
    this.groupName = const Value.absent(),
    required String senderName,
    this.senderId = const Value.absent(),
    required String content,
    this.matchedKeywordsJson = const Value.absent(),
    this.score = const Value.absent(),
    required DateTime occurredAt,
    required DateTime receivedAt,
    this.isRead = const Value.absent(),
    this.isReplied = const Value.absent(),
    this.replyContent = const Value.absent(),
    required String fingerprint,
    required DateTime createdAt,
    this.jumpKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       appId = Value(appId),
       groupId = Value(groupId),
       senderName = Value(senderName),
       content = Value(content),
       occurredAt = Value(occurredAt),
       receivedAt = Value(receivedAt),
       fingerprint = Value(fingerprint),
       createdAt = Value(createdAt);
  static Insertable<MessageRecord> custom({
    Expression<String>? id,
    Expression<String>? appId,
    Expression<String>? groupId,
    Expression<String>? groupName,
    Expression<String>? senderName,
    Expression<String>? senderId,
    Expression<String>? content,
    Expression<String>? matchedKeywordsJson,
    Expression<int>? score,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? receivedAt,
    Expression<bool>? isRead,
    Expression<bool>? isReplied,
    Expression<String>? replyContent,
    Expression<String>? fingerprint,
    Expression<DateTime>? createdAt,
    Expression<String>? jumpKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appId != null) 'app_id': appId,
      if (groupId != null) 'group_id': groupId,
      if (groupName != null) 'group_name': groupName,
      if (senderName != null) 'sender_name': senderName,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (matchedKeywordsJson != null)
        'matched_keywords_json': matchedKeywordsJson,
      if (score != null) 'score': score,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (receivedAt != null) 'received_at': receivedAt,
      if (isRead != null) 'is_read': isRead,
      if (isReplied != null) 'is_replied': isReplied,
      if (replyContent != null) 'reply_content': replyContent,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (createdAt != null) 'created_at': createdAt,
      if (jumpKey != null) 'jump_key': jumpKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? appId,
    Value<String>? groupId,
    Value<String?>? groupName,
    Value<String>? senderName,
    Value<String?>? senderId,
    Value<String>? content,
    Value<String>? matchedKeywordsJson,
    Value<int>? score,
    Value<DateTime>? occurredAt,
    Value<DateTime>? receivedAt,
    Value<bool>? isRead,
    Value<bool>? isReplied,
    Value<String?>? replyContent,
    Value<String>? fingerprint,
    Value<DateTime>? createdAt,
    Value<String?>? jumpKey,
    Value<int>? rowid,
  }) {
    return MessageRecordsCompanion(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      matchedKeywordsJson: matchedKeywordsJson ?? this.matchedKeywordsJson,
      score: score ?? this.score,
      occurredAt: occurredAt ?? this.occurredAt,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
      isReplied: isReplied ?? this.isReplied,
      replyContent: replyContent ?? this.replyContent,
      fingerprint: fingerprint ?? this.fingerprint,
      createdAt: createdAt ?? this.createdAt,
      jumpKey: jumpKey ?? this.jumpKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (appId.present) {
      map['app_id'] = Variable<String>(appId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (matchedKeywordsJson.present) {
      map['matched_keywords_json'] = Variable<String>(
        matchedKeywordsJson.value,
      );
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isReplied.present) {
      map['is_replied'] = Variable<bool>(isReplied.value);
    }
    if (replyContent.present) {
      map['reply_content'] = Variable<String>(replyContent.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (jumpKey.present) {
      map['jump_key'] = Variable<String>(jumpKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageRecordsCompanion(')
          ..write('id: $id, ')
          ..write('appId: $appId, ')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('senderName: $senderName, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('matchedKeywordsJson: $matchedKeywordsJson, ')
          ..write('score: $score, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('isRead: $isRead, ')
          ..write('isReplied: $isReplied, ')
          ..write('replyContent: $replyContent, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAt: $createdAt, ')
          ..write('jumpKey: $jumpKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KeywordRulesTable extends KeywordRules
    with TableInfo<$KeywordRulesTable, KeywordRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeywordRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(50),
  );
  static const VerificationMeta _scopeGroupIdsJsonMeta = const VerificationMeta(
    'scopeGroupIdsJson',
  );
  @override
  late final GeneratedColumn<String> scopeGroupIdsJson =
      GeneratedColumn<String>(
        'scope_group_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _excludeWordsJsonMeta = const VerificationMeta(
    'excludeWordsJson',
  );
  @override
  late final GeneratedColumn<String> excludeWordsJson = GeneratedColumn<String>(
    'exclude_words_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    keyword,
    type,
    priority,
    scopeGroupIdsJson,
    excludeWordsJson,
    enabled,
    groupName,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'keyword_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeywordRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('scope_group_ids_json')) {
      context.handle(
        _scopeGroupIdsJsonMeta,
        scopeGroupIdsJson.isAcceptableOrUnknown(
          data['scope_group_ids_json']!,
          _scopeGroupIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('exclude_words_json')) {
      context.handle(
        _excludeWordsJsonMeta,
        excludeWordsJson.isAcceptableOrUnknown(
          data['exclude_words_json']!,
          _excludeWordsJsonMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KeywordRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeywordRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      scopeGroupIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_group_ids_json'],
      )!,
      excludeWordsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exclude_words_json'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $KeywordRulesTable createAlias(String alias) {
    return $KeywordRulesTable(attachedDatabase, alias);
  }
}

class KeywordRule extends DataClass implements Insertable<KeywordRule> {
  final String id;
  final String keyword;
  final int type;
  final int priority;
  final String scopeGroupIdsJson;
  final String excludeWordsJson;
  final bool enabled;
  final String? groupName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const KeywordRule({
    required this.id,
    required this.keyword,
    required this.type,
    required this.priority,
    required this.scopeGroupIdsJson,
    required this.excludeWordsJson,
    required this.enabled,
    this.groupName,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['keyword'] = Variable<String>(keyword);
    map['type'] = Variable<int>(type);
    map['priority'] = Variable<int>(priority);
    map['scope_group_ids_json'] = Variable<String>(scopeGroupIdsJson);
    map['exclude_words_json'] = Variable<String>(excludeWordsJson);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  KeywordRulesCompanion toCompanion(bool nullToAbsent) {
    return KeywordRulesCompanion(
      id: Value(id),
      keyword: Value(keyword),
      type: Value(type),
      priority: Value(priority),
      scopeGroupIdsJson: Value(scopeGroupIdsJson),
      excludeWordsJson: Value(excludeWordsJson),
      enabled: Value(enabled),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory KeywordRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeywordRule(
      id: serializer.fromJson<String>(json['id']),
      keyword: serializer.fromJson<String>(json['keyword']),
      type: serializer.fromJson<int>(json['type']),
      priority: serializer.fromJson<int>(json['priority']),
      scopeGroupIdsJson: serializer.fromJson<String>(json['scopeGroupIdsJson']),
      excludeWordsJson: serializer.fromJson<String>(json['excludeWordsJson']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      groupName: serializer.fromJson<String?>(json['groupName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'keyword': serializer.toJson<String>(keyword),
      'type': serializer.toJson<int>(type),
      'priority': serializer.toJson<int>(priority),
      'scopeGroupIdsJson': serializer.toJson<String>(scopeGroupIdsJson),
      'excludeWordsJson': serializer.toJson<String>(excludeWordsJson),
      'enabled': serializer.toJson<bool>(enabled),
      'groupName': serializer.toJson<String?>(groupName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  KeywordRule copyWith({
    String? id,
    String? keyword,
    int? type,
    int? priority,
    String? scopeGroupIdsJson,
    String? excludeWordsJson,
    bool? enabled,
    Value<String?> groupName = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => KeywordRule(
    id: id ?? this.id,
    keyword: keyword ?? this.keyword,
    type: type ?? this.type,
    priority: priority ?? this.priority,
    scopeGroupIdsJson: scopeGroupIdsJson ?? this.scopeGroupIdsJson,
    excludeWordsJson: excludeWordsJson ?? this.excludeWordsJson,
    enabled: enabled ?? this.enabled,
    groupName: groupName.present ? groupName.value : this.groupName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  KeywordRule copyWithCompanion(KeywordRulesCompanion data) {
    return KeywordRule(
      id: data.id.present ? data.id.value : this.id,
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
      type: data.type.present ? data.type.value : this.type,
      priority: data.priority.present ? data.priority.value : this.priority,
      scopeGroupIdsJson: data.scopeGroupIdsJson.present
          ? data.scopeGroupIdsJson.value
          : this.scopeGroupIdsJson,
      excludeWordsJson: data.excludeWordsJson.present
          ? data.excludeWordsJson.value
          : this.excludeWordsJson,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeywordRule(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('type: $type, ')
          ..write('priority: $priority, ')
          ..write('scopeGroupIdsJson: $scopeGroupIdsJson, ')
          ..write('excludeWordsJson: $excludeWordsJson, ')
          ..write('enabled: $enabled, ')
          ..write('groupName: $groupName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    keyword,
    type,
    priority,
    scopeGroupIdsJson,
    excludeWordsJson,
    enabled,
    groupName,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeywordRule &&
          other.id == this.id &&
          other.keyword == this.keyword &&
          other.type == this.type &&
          other.priority == this.priority &&
          other.scopeGroupIdsJson == this.scopeGroupIdsJson &&
          other.excludeWordsJson == this.excludeWordsJson &&
          other.enabled == this.enabled &&
          other.groupName == this.groupName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class KeywordRulesCompanion extends UpdateCompanion<KeywordRule> {
  final Value<String> id;
  final Value<String> keyword;
  final Value<int> type;
  final Value<int> priority;
  final Value<String> scopeGroupIdsJson;
  final Value<String> excludeWordsJson;
  final Value<bool> enabled;
  final Value<String?> groupName;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const KeywordRulesCompanion({
    this.id = const Value.absent(),
    this.keyword = const Value.absent(),
    this.type = const Value.absent(),
    this.priority = const Value.absent(),
    this.scopeGroupIdsJson = const Value.absent(),
    this.excludeWordsJson = const Value.absent(),
    this.enabled = const Value.absent(),
    this.groupName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeywordRulesCompanion.insert({
    required String id,
    required String keyword,
    required int type,
    this.priority = const Value.absent(),
    this.scopeGroupIdsJson = const Value.absent(),
    this.excludeWordsJson = const Value.absent(),
    this.enabled = const Value.absent(),
    this.groupName = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       keyword = Value(keyword),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<KeywordRule> custom({
    Expression<String>? id,
    Expression<String>? keyword,
    Expression<int>? type,
    Expression<int>? priority,
    Expression<String>? scopeGroupIdsJson,
    Expression<String>? excludeWordsJson,
    Expression<bool>? enabled,
    Expression<String>? groupName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (keyword != null) 'keyword': keyword,
      if (type != null) 'type': type,
      if (priority != null) 'priority': priority,
      if (scopeGroupIdsJson != null) 'scope_group_ids_json': scopeGroupIdsJson,
      if (excludeWordsJson != null) 'exclude_words_json': excludeWordsJson,
      if (enabled != null) 'enabled': enabled,
      if (groupName != null) 'group_name': groupName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeywordRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? keyword,
    Value<int>? type,
    Value<int>? priority,
    Value<String>? scopeGroupIdsJson,
    Value<String>? excludeWordsJson,
    Value<bool>? enabled,
    Value<String?>? groupName,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return KeywordRulesCompanion(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      scopeGroupIdsJson: scopeGroupIdsJson ?? this.scopeGroupIdsJson,
      excludeWordsJson: excludeWordsJson ?? this.excludeWordsJson,
      enabled: enabled ?? this.enabled,
      groupName: groupName ?? this.groupName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (scopeGroupIdsJson.present) {
      map['scope_group_ids_json'] = Variable<String>(scopeGroupIdsJson.value);
    }
    if (excludeWordsJson.present) {
      map['exclude_words_json'] = Variable<String>(excludeWordsJson.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeywordRulesCompanion(')
          ..write('id: $id, ')
          ..write('keyword: $keyword, ')
          ..write('type: $type, ')
          ..write('priority: $priority, ')
          ..write('scopeGroupIdsJson: $scopeGroupIdsJson, ')
          ..write('excludeWordsJson: $excludeWordsJson, ')
          ..write('enabled: $enabled, ')
          ..write('groupName: $groupName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonitoredGroupsTable extends MonitoredGroups
    with TableInfo<$MonitoredGroupsTable, MonitoredGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitoredGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appIdMeta = const VerificationMeta('appId');
  @override
  late final GeneratedColumn<String> appId = GeneratedColumn<String>(
    'app_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isWhitelistMeta = const VerificationMeta(
    'isWhitelist',
  );
  @override
  late final GeneratedColumn<bool> isWhitelist = GeneratedColumn<bool>(
    'is_whitelist',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_whitelist" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isBlacklistMeta = const VerificationMeta(
    'isBlacklist',
  );
  @override
  late final GeneratedColumn<bool> isBlacklist = GeneratedColumn<bool>(
    'is_blacklist',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_blacklist" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastActiveAtMeta = const VerificationMeta(
    'lastActiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveAt = GeneratedColumn<DateTime>(
    'last_active_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    groupId,
    groupName,
    appId,
    isWhitelist,
    isBlacklist,
    lastActiveAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitored_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonitoredGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('app_id')) {
      context.handle(
        _appIdMeta,
        appId.isAcceptableOrUnknown(data['app_id']!, _appIdMeta),
      );
    } else if (isInserting) {
      context.missing(_appIdMeta);
    }
    if (data.containsKey('is_whitelist')) {
      context.handle(
        _isWhitelistMeta,
        isWhitelist.isAcceptableOrUnknown(
          data['is_whitelist']!,
          _isWhitelistMeta,
        ),
      );
    }
    if (data.containsKey('is_blacklist')) {
      context.handle(
        _isBlacklistMeta,
        isBlacklist.isAcceptableOrUnknown(
          data['is_blacklist']!,
          _isBlacklistMeta,
        ),
      );
    }
    if (data.containsKey('last_active_at')) {
      context.handle(
        _lastActiveAtMeta,
        lastActiveAt.isAcceptableOrUnknown(
          data['last_active_at']!,
          _lastActiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastActiveAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId};
  @override
  MonitoredGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitoredGroup(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      appId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_id'],
      )!,
      isWhitelist: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_whitelist'],
      )!,
      isBlacklist: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_blacklist'],
      )!,
      lastActiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_at'],
      )!,
    );
  }

  @override
  $MonitoredGroupsTable createAlias(String alias) {
    return $MonitoredGroupsTable(attachedDatabase, alias);
  }
}

class MonitoredGroup extends DataClass implements Insertable<MonitoredGroup> {
  final String groupId;
  final String groupName;
  final String appId;
  final bool isWhitelist;
  final bool isBlacklist;
  final DateTime lastActiveAt;
  const MonitoredGroup({
    required this.groupId,
    required this.groupName,
    required this.appId,
    required this.isWhitelist,
    required this.isBlacklist,
    required this.lastActiveAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['group_name'] = Variable<String>(groupName);
    map['app_id'] = Variable<String>(appId);
    map['is_whitelist'] = Variable<bool>(isWhitelist);
    map['is_blacklist'] = Variable<bool>(isBlacklist);
    map['last_active_at'] = Variable<DateTime>(lastActiveAt);
    return map;
  }

  MonitoredGroupsCompanion toCompanion(bool nullToAbsent) {
    return MonitoredGroupsCompanion(
      groupId: Value(groupId),
      groupName: Value(groupName),
      appId: Value(appId),
      isWhitelist: Value(isWhitelist),
      isBlacklist: Value(isBlacklist),
      lastActiveAt: Value(lastActiveAt),
    );
  }

  factory MonitoredGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitoredGroup(
      groupId: serializer.fromJson<String>(json['groupId']),
      groupName: serializer.fromJson<String>(json['groupName']),
      appId: serializer.fromJson<String>(json['appId']),
      isWhitelist: serializer.fromJson<bool>(json['isWhitelist']),
      isBlacklist: serializer.fromJson<bool>(json['isBlacklist']),
      lastActiveAt: serializer.fromJson<DateTime>(json['lastActiveAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'groupName': serializer.toJson<String>(groupName),
      'appId': serializer.toJson<String>(appId),
      'isWhitelist': serializer.toJson<bool>(isWhitelist),
      'isBlacklist': serializer.toJson<bool>(isBlacklist),
      'lastActiveAt': serializer.toJson<DateTime>(lastActiveAt),
    };
  }

  MonitoredGroup copyWith({
    String? groupId,
    String? groupName,
    String? appId,
    bool? isWhitelist,
    bool? isBlacklist,
    DateTime? lastActiveAt,
  }) => MonitoredGroup(
    groupId: groupId ?? this.groupId,
    groupName: groupName ?? this.groupName,
    appId: appId ?? this.appId,
    isWhitelist: isWhitelist ?? this.isWhitelist,
    isBlacklist: isBlacklist ?? this.isBlacklist,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
  );
  MonitoredGroup copyWithCompanion(MonitoredGroupsCompanion data) {
    return MonitoredGroup(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      appId: data.appId.present ? data.appId.value : this.appId,
      isWhitelist: data.isWhitelist.present
          ? data.isWhitelist.value
          : this.isWhitelist,
      isBlacklist: data.isBlacklist.present
          ? data.isBlacklist.value
          : this.isBlacklist,
      lastActiveAt: data.lastActiveAt.present
          ? data.lastActiveAt.value
          : this.lastActiveAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitoredGroup(')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('appId: $appId, ')
          ..write('isWhitelist: $isWhitelist, ')
          ..write('isBlacklist: $isBlacklist, ')
          ..write('lastActiveAt: $lastActiveAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    groupId,
    groupName,
    appId,
    isWhitelist,
    isBlacklist,
    lastActiveAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitoredGroup &&
          other.groupId == this.groupId &&
          other.groupName == this.groupName &&
          other.appId == this.appId &&
          other.isWhitelist == this.isWhitelist &&
          other.isBlacklist == this.isBlacklist &&
          other.lastActiveAt == this.lastActiveAt);
}

class MonitoredGroupsCompanion extends UpdateCompanion<MonitoredGroup> {
  final Value<String> groupId;
  final Value<String> groupName;
  final Value<String> appId;
  final Value<bool> isWhitelist;
  final Value<bool> isBlacklist;
  final Value<DateTime> lastActiveAt;
  final Value<int> rowid;
  const MonitoredGroupsCompanion({
    this.groupId = const Value.absent(),
    this.groupName = const Value.absent(),
    this.appId = const Value.absent(),
    this.isWhitelist = const Value.absent(),
    this.isBlacklist = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonitoredGroupsCompanion.insert({
    required String groupId,
    required String groupName,
    required String appId,
    this.isWhitelist = const Value.absent(),
    this.isBlacklist = const Value.absent(),
    required DateTime lastActiveAt,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       groupName = Value(groupName),
       appId = Value(appId),
       lastActiveAt = Value(lastActiveAt);
  static Insertable<MonitoredGroup> custom({
    Expression<String>? groupId,
    Expression<String>? groupName,
    Expression<String>? appId,
    Expression<bool>? isWhitelist,
    Expression<bool>? isBlacklist,
    Expression<DateTime>? lastActiveAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (groupName != null) 'group_name': groupName,
      if (appId != null) 'app_id': appId,
      if (isWhitelist != null) 'is_whitelist': isWhitelist,
      if (isBlacklist != null) 'is_blacklist': isBlacklist,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonitoredGroupsCompanion copyWith({
    Value<String>? groupId,
    Value<String>? groupName,
    Value<String>? appId,
    Value<bool>? isWhitelist,
    Value<bool>? isBlacklist,
    Value<DateTime>? lastActiveAt,
    Value<int>? rowid,
  }) {
    return MonitoredGroupsCompanion(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      appId: appId ?? this.appId,
      isWhitelist: isWhitelist ?? this.isWhitelist,
      isBlacklist: isBlacklist ?? this.isBlacklist,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (appId.present) {
      map['app_id'] = Variable<String>(appId.value);
    }
    if (isWhitelist.present) {
      map['is_whitelist'] = Variable<bool>(isWhitelist.value);
    }
    if (isBlacklist.present) {
      map['is_blacklist'] = Variable<bool>(isBlacklist.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitoredGroupsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('groupName: $groupName, ')
          ..write('appId: $appId, ')
          ..write('isWhitelist: $isWhitelist, ')
          ..write('isBlacklist: $isBlacklist, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessageRecordsTable messageRecords = $MessageRecordsTable(this);
  late final $KeywordRulesTable keywordRules = $KeywordRulesTable(this);
  late final $MonitoredGroupsTable monitoredGroups = $MonitoredGroupsTable(
    this,
  );
  late final MessageDao messageDao = MessageDao(this as AppDatabase);
  late final KeywordDao keywordDao = KeywordDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messageRecords,
    keywordRules,
    monitoredGroups,
  ];
}

typedef $$MessageRecordsTableCreateCompanionBuilder =
    MessageRecordsCompanion Function({
      required String id,
      required String appId,
      required String groupId,
      Value<String?> groupName,
      required String senderName,
      Value<String?> senderId,
      required String content,
      Value<String> matchedKeywordsJson,
      Value<int> score,
      required DateTime occurredAt,
      required DateTime receivedAt,
      Value<bool> isRead,
      Value<bool> isReplied,
      Value<String?> replyContent,
      required String fingerprint,
      required DateTime createdAt,
      Value<String?> jumpKey,
      Value<int> rowid,
    });
typedef $$MessageRecordsTableUpdateCompanionBuilder =
    MessageRecordsCompanion Function({
      Value<String> id,
      Value<String> appId,
      Value<String> groupId,
      Value<String?> groupName,
      Value<String> senderName,
      Value<String?> senderId,
      Value<String> content,
      Value<String> matchedKeywordsJson,
      Value<int> score,
      Value<DateTime> occurredAt,
      Value<DateTime> receivedAt,
      Value<bool> isRead,
      Value<bool> isReplied,
      Value<String?> replyContent,
      Value<String> fingerprint,
      Value<DateTime> createdAt,
      Value<String?> jumpKey,
      Value<int> rowid,
    });

class $$MessageRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MessageRecordsTable> {
  $$MessageRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appId => $composableBuilder(
    column: $table.appId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchedKeywordsJson => $composableBuilder(
    column: $table.matchedKeywordsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReplied => $composableBuilder(
    column: $table.isReplied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyContent => $composableBuilder(
    column: $table.replyContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jumpKey => $composableBuilder(
    column: $table.jumpKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessageRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageRecordsTable> {
  $$MessageRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appId => $composableBuilder(
    column: $table.appId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchedKeywordsJson => $composableBuilder(
    column: $table.matchedKeywordsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReplied => $composableBuilder(
    column: $table.isReplied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyContent => $composableBuilder(
    column: $table.replyContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jumpKey => $composableBuilder(
    column: $table.jumpKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessageRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageRecordsTable> {
  $$MessageRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get appId =>
      $composableBuilder(column: $table.appId, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get matchedKeywordsJson => $composableBuilder(
    column: $table.matchedKeywordsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isReplied =>
      $composableBuilder(column: $table.isReplied, builder: (column) => column);

  GeneratedColumn<String> get replyContent => $composableBuilder(
    column: $table.replyContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get jumpKey =>
      $composableBuilder(column: $table.jumpKey, builder: (column) => column);
}

class $$MessageRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessageRecordsTable,
          MessageRecord,
          $$MessageRecordsTableFilterComposer,
          $$MessageRecordsTableOrderingComposer,
          $$MessageRecordsTableAnnotationComposer,
          $$MessageRecordsTableCreateCompanionBuilder,
          $$MessageRecordsTableUpdateCompanionBuilder,
          (
            MessageRecord,
            BaseReferences<_$AppDatabase, $MessageRecordsTable, MessageRecord>,
          ),
          MessageRecord,
          PrefetchHooks Function()
        > {
  $$MessageRecordsTableTableManager(
    _$AppDatabase db,
    $MessageRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> appId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String?> senderId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> matchedKeywordsJson = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isReplied = const Value.absent(),
                Value<String?> replyContent = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> jumpKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageRecordsCompanion(
                id: id,
                appId: appId,
                groupId: groupId,
                groupName: groupName,
                senderName: senderName,
                senderId: senderId,
                content: content,
                matchedKeywordsJson: matchedKeywordsJson,
                score: score,
                occurredAt: occurredAt,
                receivedAt: receivedAt,
                isRead: isRead,
                isReplied: isReplied,
                replyContent: replyContent,
                fingerprint: fingerprint,
                createdAt: createdAt,
                jumpKey: jumpKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String appId,
                required String groupId,
                Value<String?> groupName = const Value.absent(),
                required String senderName,
                Value<String?> senderId = const Value.absent(),
                required String content,
                Value<String> matchedKeywordsJson = const Value.absent(),
                Value<int> score = const Value.absent(),
                required DateTime occurredAt,
                required DateTime receivedAt,
                Value<bool> isRead = const Value.absent(),
                Value<bool> isReplied = const Value.absent(),
                Value<String?> replyContent = const Value.absent(),
                required String fingerprint,
                required DateTime createdAt,
                Value<String?> jumpKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageRecordsCompanion.insert(
                id: id,
                appId: appId,
                groupId: groupId,
                groupName: groupName,
                senderName: senderName,
                senderId: senderId,
                content: content,
                matchedKeywordsJson: matchedKeywordsJson,
                score: score,
                occurredAt: occurredAt,
                receivedAt: receivedAt,
                isRead: isRead,
                isReplied: isReplied,
                replyContent: replyContent,
                fingerprint: fingerprint,
                createdAt: createdAt,
                jumpKey: jumpKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessageRecordsTable,
      MessageRecord,
      $$MessageRecordsTableFilterComposer,
      $$MessageRecordsTableOrderingComposer,
      $$MessageRecordsTableAnnotationComposer,
      $$MessageRecordsTableCreateCompanionBuilder,
      $$MessageRecordsTableUpdateCompanionBuilder,
      (
        MessageRecord,
        BaseReferences<_$AppDatabase, $MessageRecordsTable, MessageRecord>,
      ),
      MessageRecord,
      PrefetchHooks Function()
    >;
typedef $$KeywordRulesTableCreateCompanionBuilder =
    KeywordRulesCompanion Function({
      required String id,
      required String keyword,
      required int type,
      Value<int> priority,
      Value<String> scopeGroupIdsJson,
      Value<String> excludeWordsJson,
      Value<bool> enabled,
      Value<String?> groupName,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$KeywordRulesTableUpdateCompanionBuilder =
    KeywordRulesCompanion Function({
      Value<String> id,
      Value<String> keyword,
      Value<int> type,
      Value<int> priority,
      Value<String> scopeGroupIdsJson,
      Value<String> excludeWordsJson,
      Value<bool> enabled,
      Value<String?> groupName,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$KeywordRulesTableFilterComposer
    extends Composer<_$AppDatabase, $KeywordRulesTable> {
  $$KeywordRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeGroupIdsJson => $composableBuilder(
    column: $table.scopeGroupIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get excludeWordsJson => $composableBuilder(
    column: $table.excludeWordsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeywordRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeywordRulesTable> {
  $$KeywordRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeGroupIdsJson => $composableBuilder(
    column: $table.scopeGroupIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get excludeWordsJson => $composableBuilder(
    column: $table.excludeWordsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeywordRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeywordRulesTable> {
  $$KeywordRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get scopeGroupIdsJson => $composableBuilder(
    column: $table.scopeGroupIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get excludeWordsJson => $composableBuilder(
    column: $table.excludeWordsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KeywordRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeywordRulesTable,
          KeywordRule,
          $$KeywordRulesTableFilterComposer,
          $$KeywordRulesTableOrderingComposer,
          $$KeywordRulesTableAnnotationComposer,
          $$KeywordRulesTableCreateCompanionBuilder,
          $$KeywordRulesTableUpdateCompanionBuilder,
          (
            KeywordRule,
            BaseReferences<_$AppDatabase, $KeywordRulesTable, KeywordRule>,
          ),
          KeywordRule,
          PrefetchHooks Function()
        > {
  $$KeywordRulesTableTableManager(_$AppDatabase db, $KeywordRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeywordRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeywordRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeywordRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> keyword = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> scopeGroupIdsJson = const Value.absent(),
                Value<String> excludeWordsJson = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeywordRulesCompanion(
                id: id,
                keyword: keyword,
                type: type,
                priority: priority,
                scopeGroupIdsJson: scopeGroupIdsJson,
                excludeWordsJson: excludeWordsJson,
                enabled: enabled,
                groupName: groupName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String keyword,
                required int type,
                Value<int> priority = const Value.absent(),
                Value<String> scopeGroupIdsJson = const Value.absent(),
                Value<String> excludeWordsJson = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeywordRulesCompanion.insert(
                id: id,
                keyword: keyword,
                type: type,
                priority: priority,
                scopeGroupIdsJson: scopeGroupIdsJson,
                excludeWordsJson: excludeWordsJson,
                enabled: enabled,
                groupName: groupName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeywordRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeywordRulesTable,
      KeywordRule,
      $$KeywordRulesTableFilterComposer,
      $$KeywordRulesTableOrderingComposer,
      $$KeywordRulesTableAnnotationComposer,
      $$KeywordRulesTableCreateCompanionBuilder,
      $$KeywordRulesTableUpdateCompanionBuilder,
      (
        KeywordRule,
        BaseReferences<_$AppDatabase, $KeywordRulesTable, KeywordRule>,
      ),
      KeywordRule,
      PrefetchHooks Function()
    >;
typedef $$MonitoredGroupsTableCreateCompanionBuilder =
    MonitoredGroupsCompanion Function({
      required String groupId,
      required String groupName,
      required String appId,
      Value<bool> isWhitelist,
      Value<bool> isBlacklist,
      required DateTime lastActiveAt,
      Value<int> rowid,
    });
typedef $$MonitoredGroupsTableUpdateCompanionBuilder =
    MonitoredGroupsCompanion Function({
      Value<String> groupId,
      Value<String> groupName,
      Value<String> appId,
      Value<bool> isWhitelist,
      Value<bool> isBlacklist,
      Value<DateTime> lastActiveAt,
      Value<int> rowid,
    });

class $$MonitoredGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $MonitoredGroupsTable> {
  $$MonitoredGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appId => $composableBuilder(
    column: $table.appId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWhitelist => $composableBuilder(
    column: $table.isWhitelist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBlacklist => $composableBuilder(
    column: $table.isBlacklist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonitoredGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitoredGroupsTable> {
  $$MonitoredGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appId => $composableBuilder(
    column: $table.appId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWhitelist => $composableBuilder(
    column: $table.isWhitelist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBlacklist => $composableBuilder(
    column: $table.isBlacklist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonitoredGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitoredGroupsTable> {
  $$MonitoredGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get appId =>
      $composableBuilder(column: $table.appId, builder: (column) => column);

  GeneratedColumn<bool> get isWhitelist => $composableBuilder(
    column: $table.isWhitelist,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBlacklist => $composableBuilder(
    column: $table.isBlacklist,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => column,
  );
}

class $$MonitoredGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonitoredGroupsTable,
          MonitoredGroup,
          $$MonitoredGroupsTableFilterComposer,
          $$MonitoredGroupsTableOrderingComposer,
          $$MonitoredGroupsTableAnnotationComposer,
          $$MonitoredGroupsTableCreateCompanionBuilder,
          $$MonitoredGroupsTableUpdateCompanionBuilder,
          (
            MonitoredGroup,
            BaseReferences<
              _$AppDatabase,
              $MonitoredGroupsTable,
              MonitoredGroup
            >,
          ),
          MonitoredGroup,
          PrefetchHooks Function()
        > {
  $$MonitoredGroupsTableTableManager(
    _$AppDatabase db,
    $MonitoredGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitoredGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitoredGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitoredGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<String> appId = const Value.absent(),
                Value<bool> isWhitelist = const Value.absent(),
                Value<bool> isBlacklist = const Value.absent(),
                Value<DateTime> lastActiveAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitoredGroupsCompanion(
                groupId: groupId,
                groupName: groupName,
                appId: appId,
                isWhitelist: isWhitelist,
                isBlacklist: isBlacklist,
                lastActiveAt: lastActiveAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String groupName,
                required String appId,
                Value<bool> isWhitelist = const Value.absent(),
                Value<bool> isBlacklist = const Value.absent(),
                required DateTime lastActiveAt,
                Value<int> rowid = const Value.absent(),
              }) => MonitoredGroupsCompanion.insert(
                groupId: groupId,
                groupName: groupName,
                appId: appId,
                isWhitelist: isWhitelist,
                isBlacklist: isBlacklist,
                lastActiveAt: lastActiveAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonitoredGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonitoredGroupsTable,
      MonitoredGroup,
      $$MonitoredGroupsTableFilterComposer,
      $$MonitoredGroupsTableOrderingComposer,
      $$MonitoredGroupsTableAnnotationComposer,
      $$MonitoredGroupsTableCreateCompanionBuilder,
      $$MonitoredGroupsTableUpdateCompanionBuilder,
      (
        MonitoredGroup,
        BaseReferences<_$AppDatabase, $MonitoredGroupsTable, MonitoredGroup>,
      ),
      MonitoredGroup,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessageRecordsTableTableManager get messageRecords =>
      $$MessageRecordsTableTableManager(_db, _db.messageRecords);
  $$KeywordRulesTableTableManager get keywordRules =>
      $$KeywordRulesTableTableManager(_db, _db.keywordRules);
  $$MonitoredGroupsTableTableManager get monitoredGroups =>
      $$MonitoredGroupsTableTableManager(_db, _db.monitoredGroups);
}
