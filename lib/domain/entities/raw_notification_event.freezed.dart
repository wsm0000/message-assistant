// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raw_notification_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RawNotificationEvent {
  String get appId => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String? get groupName => throw _privateConstructorUsedError;
  String get senderName => throw _privateConstructorUsedError;
  String? get senderId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get occurredAt =>
      throw _privateConstructorUsedError; // The jump key (groupId) carried from native so the pipeline can stash it
  // on the MessageRecord. Null when the native side didn't supply one.
  String? get jumpKey => throw _privateConstructorUsedError;

  /// Create a copy of RawNotificationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RawNotificationEventCopyWith<RawNotificationEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RawNotificationEventCopyWith<$Res> {
  factory $RawNotificationEventCopyWith(
    RawNotificationEvent value,
    $Res Function(RawNotificationEvent) then,
  ) = _$RawNotificationEventCopyWithImpl<$Res, RawNotificationEvent>;
  @useResult
  $Res call({
    String appId,
    String groupId,
    String? groupName,
    String senderName,
    String? senderId,
    String content,
    DateTime occurredAt,
    String? jumpKey,
  });
}

/// @nodoc
class _$RawNotificationEventCopyWithImpl<
  $Res,
  $Val extends RawNotificationEvent
>
    implements $RawNotificationEventCopyWith<$Res> {
  _$RawNotificationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RawNotificationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appId = null,
    Object? groupId = null,
    Object? groupName = freezed,
    Object? senderName = null,
    Object? senderId = freezed,
    Object? content = null,
    Object? occurredAt = null,
    Object? jumpKey = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            occurredAt: null == occurredAt
                ? _value.occurredAt
                : occurredAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$RawNotificationEventImplCopyWith<$Res>
    implements $RawNotificationEventCopyWith<$Res> {
  factory _$$RawNotificationEventImplCopyWith(
    _$RawNotificationEventImpl value,
    $Res Function(_$RawNotificationEventImpl) then,
  ) = __$$RawNotificationEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String appId,
    String groupId,
    String? groupName,
    String senderName,
    String? senderId,
    String content,
    DateTime occurredAt,
    String? jumpKey,
  });
}

/// @nodoc
class __$$RawNotificationEventImplCopyWithImpl<$Res>
    extends _$RawNotificationEventCopyWithImpl<$Res, _$RawNotificationEventImpl>
    implements _$$RawNotificationEventImplCopyWith<$Res> {
  __$$RawNotificationEventImplCopyWithImpl(
    _$RawNotificationEventImpl _value,
    $Res Function(_$RawNotificationEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RawNotificationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appId = null,
    Object? groupId = null,
    Object? groupName = freezed,
    Object? senderName = null,
    Object? senderId = freezed,
    Object? content = null,
    Object? occurredAt = null,
    Object? jumpKey = freezed,
  }) {
    return _then(
      _$RawNotificationEventImpl(
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
        occurredAt: null == occurredAt
            ? _value.occurredAt
            : occurredAt // ignore: cast_nullable_to_non_nullable
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

class _$RawNotificationEventImpl implements _RawNotificationEvent {
  const _$RawNotificationEventImpl({
    required this.appId,
    required this.groupId,
    this.groupName,
    required this.senderName,
    this.senderId,
    required this.content,
    required this.occurredAt,
    this.jumpKey,
  });

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
  @override
  final DateTime occurredAt;
  // The jump key (groupId) carried from native so the pipeline can stash it
  // on the MessageRecord. Null when the native side didn't supply one.
  @override
  final String? jumpKey;

  @override
  String toString() {
    return 'RawNotificationEvent(appId: $appId, groupId: $groupId, groupName: $groupName, senderName: $senderName, senderId: $senderId, content: $content, occurredAt: $occurredAt, jumpKey: $jumpKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RawNotificationEventImpl &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.occurredAt, occurredAt) ||
                other.occurredAt == occurredAt) &&
            (identical(other.jumpKey, jumpKey) || other.jumpKey == jumpKey));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    appId,
    groupId,
    groupName,
    senderName,
    senderId,
    content,
    occurredAt,
    jumpKey,
  );

  /// Create a copy of RawNotificationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RawNotificationEventImplCopyWith<_$RawNotificationEventImpl>
  get copyWith =>
      __$$RawNotificationEventImplCopyWithImpl<_$RawNotificationEventImpl>(
        this,
        _$identity,
      );
}

abstract class _RawNotificationEvent implements RawNotificationEvent {
  const factory _RawNotificationEvent({
    required final String appId,
    required final String groupId,
    final String? groupName,
    required final String senderName,
    final String? senderId,
    required final String content,
    required final DateTime occurredAt,
    final String? jumpKey,
  }) = _$RawNotificationEventImpl;

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
  DateTime get occurredAt; // The jump key (groupId) carried from native so the pipeline can stash it
  // on the MessageRecord. Null when the native side didn't supply one.
  @override
  String? get jumpKey;

  /// Create a copy of RawNotificationEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RawNotificationEventImplCopyWith<_$RawNotificationEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}
