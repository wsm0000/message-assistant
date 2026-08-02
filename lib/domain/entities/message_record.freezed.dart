// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MessageRecord {
  String get id => throw _privateConstructorUsedError;
  String get appId => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String? get groupName => throw _privateConstructorUsedError;
  String get senderName => throw _privateConstructorUsedError;
  String? get senderId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<KeywordHit> get hits => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  DateTime get occurredAt => throw _privateConstructorUsedError;
  DateTime get receivedAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isReplied => throw _privateConstructorUsedError;
  String? get replyContent => throw _privateConstructorUsedError;
  String get fingerprint => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // The native contentIntent captured for this group's latest WeChat
  // notification, referenced by the groupId (jump key). Held only in native
  // memory (JumpIntentStore); null on old DB records → reply flow falls back
  // to launching WeChat home. NOT part of the dedup fingerprint.
  String? get jumpKey => throw _privateConstructorUsedError;

  /// Create a copy of MessageRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageRecordCopyWith<MessageRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageRecordCopyWith<$Res> {
  factory $MessageRecordCopyWith(
    MessageRecord value,
    $Res Function(MessageRecord) then,
  ) = _$MessageRecordCopyWithImpl<$Res, MessageRecord>;
  @useResult
  $Res call({
    String id,
    String appId,
    String groupId,
    String? groupName,
    String senderName,
    String? senderId,
    String content,
    List<KeywordHit> hits,
    int score,
    DateTime occurredAt,
    DateTime receivedAt,
    bool isRead,
    bool isReplied,
    String? replyContent,
    String fingerprint,
    DateTime createdAt,
    String? jumpKey,
  });
}

/// @nodoc
class _$MessageRecordCopyWithImpl<$Res, $Val extends MessageRecord>
    implements $MessageRecordCopyWith<$Res> {
  _$MessageRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? appId = null,
    Object? groupId = null,
    Object? groupName = freezed,
    Object? senderName = null,
    Object? senderId = freezed,
    Object? content = null,
    Object? hits = null,
    Object? score = null,
    Object? occurredAt = null,
    Object? receivedAt = null,
    Object? isRead = null,
    Object? isReplied = null,
    Object? replyContent = freezed,
    Object? fingerprint = null,
    Object? createdAt = null,
    Object? jumpKey = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            appId: null == appId
                ? _value.appId
                : appId // ignore: cast_nullable_to_non_nullable
                      as String,
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            groupName: freezed == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderName: null == senderName
                ? _value.senderName
                : senderName // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: freezed == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            hits: null == hits
                ? _value.hits
                : hits // ignore: cast_nullable_to_non_nullable
                      as List<KeywordHit>,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            occurredAt: null == occurredAt
                ? _value.occurredAt
                : occurredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            receivedAt: null == receivedAt
                ? _value.receivedAt
                : receivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            isReplied: null == isReplied
                ? _value.isReplied
                : isReplied // ignore: cast_nullable_to_non_nullable
                      as bool,
            replyContent: freezed == replyContent
                ? _value.replyContent
                : replyContent // ignore: cast_nullable_to_non_nullable
                      as String?,
            fingerprint: null == fingerprint
                ? _value.fingerprint
                : fingerprint // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            jumpKey: freezed == jumpKey
                ? _value.jumpKey
                : jumpKey // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageRecordImplCopyWith<$Res>
    implements $MessageRecordCopyWith<$Res> {
  factory _$$MessageRecordImplCopyWith(
    _$MessageRecordImpl value,
    $Res Function(_$MessageRecordImpl) then,
  ) = __$$MessageRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String appId,
    String groupId,
    String? groupName,
    String senderName,
    String? senderId,
    String content,
    List<KeywordHit> hits,
    int score,
    DateTime occurredAt,
    DateTime receivedAt,
    bool isRead,
    bool isReplied,
    String? replyContent,
    String fingerprint,
    DateTime createdAt,
    String? jumpKey,
  });
}

/// @nodoc
class __$$MessageRecordImplCopyWithImpl<$Res>
    extends _$MessageRecordCopyWithImpl<$Res, _$MessageRecordImpl>
    implements _$$MessageRecordImplCopyWith<$Res> {
  __$$MessageRecordImplCopyWithImpl(
    _$MessageRecordImpl _value,
    $Res Function(_$MessageRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? appId = null,
    Object? groupId = null,
    Object? groupName = freezed,
    Object? senderName = null,
    Object? senderId = freezed,
    Object? content = null,
    Object? hits = null,
    Object? score = null,
    Object? occurredAt = null,
    Object? receivedAt = null,
    Object? isRead = null,
    Object? isReplied = null,
    Object? replyContent = freezed,
    Object? fingerprint = null,
    Object? createdAt = null,
    Object? jumpKey = freezed,
  }) {
    return _then(
      _$MessageRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        appId: null == appId
            ? _value.appId
            : appId // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        groupName: freezed == groupName
            ? _value.groupName
            : groupName // ignore: cast_nullable_to_non_nullable
                  as String?,
        senderName: null == senderName
            ? _value.senderName
            : senderName // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: freezed == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        hits: null == hits
            ? _value._hits
            : hits // ignore: cast_nullable_to_non_nullable
                  as List<KeywordHit>,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        occurredAt: null == occurredAt
            ? _value.occurredAt
            : occurredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        receivedAt: null == receivedAt
            ? _value.receivedAt
            : receivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        isReplied: null == isReplied
            ? _value.isReplied
            : isReplied // ignore: cast_nullable_to_non_nullable
                  as bool,
        replyContent: freezed == replyContent
            ? _value.replyContent
            : replyContent // ignore: cast_nullable_to_non_nullable
                  as String?,
        fingerprint: null == fingerprint
            ? _value.fingerprint
            : fingerprint // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        jumpKey: freezed == jumpKey
            ? _value.jumpKey
            : jumpKey // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$MessageRecordImpl implements _MessageRecord {
  const _$MessageRecordImpl({
    required this.id,
    required this.appId,
    required this.groupId,
    this.groupName,
    required this.senderName,
    this.senderId,
    required this.content,
    final List<KeywordHit> hits = const [],
    this.score = 0,
    required this.occurredAt,
    required this.receivedAt,
    this.isRead = false,
    this.isReplied = false,
    this.replyContent,
    required this.fingerprint,
    required this.createdAt,
    this.jumpKey,
  }) : _hits = hits;

  @override
  final String id;
  @override
  final String appId;
  @override
  final String groupId;
  @override
  final String? groupName;
  @override
  final String senderName;
  @override
  final String? senderId;
  @override
  final String content;
  final List<KeywordHit> _hits;
  @override
  @JsonKey()
  List<KeywordHit> get hits {
    if (_hits is EqualUnmodifiableListView) return _hits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hits);
  }

  @override
  @JsonKey()
  final int score;
  @override
  final DateTime occurredAt;
  @override
  final DateTime receivedAt;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isReplied;
  @override
  final String? replyContent;
  @override
  final String fingerprint;
  @override
  final DateTime createdAt;
  // The native contentIntent captured for this group's latest WeChat
  // notification, referenced by the groupId (jump key). Held only in native
  // memory (JumpIntentStore); null on old DB records → reply flow falls back
  // to launching WeChat home. NOT part of the dedup fingerprint.
  @override
  final String? jumpKey;

  @override
  String toString() {
    return 'MessageRecord(id: $id, appId: $appId, groupId: $groupId, groupName: $groupName, senderName: $senderName, senderId: $senderId, content: $content, hits: $hits, score: $score, occurredAt: $occurredAt, receivedAt: $receivedAt, isRead: $isRead, isReplied: $isReplied, replyContent: $replyContent, fingerprint: $fingerprint, createdAt: $createdAt, jumpKey: $jumpKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._hits, _hits) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.occurredAt, occurredAt) ||
                other.occurredAt == occurredAt) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isReplied, isReplied) ||
                other.isReplied == isReplied) &&
            (identical(other.replyContent, replyContent) ||
                other.replyContent == replyContent) &&
            (identical(other.fingerprint, fingerprint) ||
                other.fingerprint == fingerprint) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.jumpKey, jumpKey) || other.jumpKey == jumpKey));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    appId,
    groupId,
    groupName,
    senderName,
    senderId,
    content,
    const DeepCollectionEquality().hash(_hits),
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

  /// Create a copy of MessageRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageRecordImplCopyWith<_$MessageRecordImpl> get copyWith =>
      __$$MessageRecordImplCopyWithImpl<_$MessageRecordImpl>(this, _$identity);
}

abstract class _MessageRecord implements MessageRecord {
  const factory _MessageRecord({
    required final String id,
    required final String appId,
    required final String groupId,
    final String? groupName,
    required final String senderName,
    final String? senderId,
    required final String content,
    final List<KeywordHit> hits,
    final int score,
    required final DateTime occurredAt,
    required final DateTime receivedAt,
    final bool isRead,
    final bool isReplied,
    final String? replyContent,
    required final String fingerprint,
    required final DateTime createdAt,
    final String? jumpKey,
  }) = _$MessageRecordImpl;

  @override
  String get id;
  @override
  String get appId;
  @override
  String get groupId;
  @override
  String? get groupName;
  @override
  String get senderName;
  @override
  String? get senderId;
  @override
  String get content;
  @override
  List<KeywordHit> get hits;
  @override
  int get score;
  @override
  DateTime get occurredAt;
  @override
  DateTime get receivedAt;
  @override
  bool get isRead;
  @override
  bool get isReplied;
  @override
  String? get replyContent;
  @override
  String get fingerprint;
  @override
  DateTime get createdAt; // The native contentIntent captured for this group's latest WeChat
  // notification, referenced by the groupId (jump key). Held only in native
  // memory (JumpIntentStore); null on old DB records → reply flow falls back
  // to launching WeChat home. NOT part of the dedup fingerprint.
  @override
  String? get jumpKey;

  /// Create a copy of MessageRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageRecordImplCopyWith<_$MessageRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
