// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_reply.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$QuickReply {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  int get sortOrder =>
      throw _privateConstructorUsedError; // ascending; UI sorts by this
  bool get isDefault =>
      throw _privateConstructorUsedError; // the highlighted/first phrase
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of QuickReply
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuickReplyCopyWith<QuickReply> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuickReplyCopyWith<$Res> {
  factory $QuickReplyCopyWith(
    QuickReply value,
    $Res Function(QuickReply) then,
  ) = _$QuickReplyCopyWithImpl<$Res, QuickReply>;
  @useResult
  $Res call({
    String id,
    String text,
    bool enabled,
    int sortOrder,
    bool isDefault,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$QuickReplyCopyWithImpl<$Res, $Val extends QuickReply>
    implements $QuickReplyCopyWith<$Res> {
  _$QuickReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuickReply
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? enabled = null,
    Object? sortOrder = null,
    Object? isDefault = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuickReplyImplCopyWith<$Res>
    implements $QuickReplyCopyWith<$Res> {
  factory _$$QuickReplyImplCopyWith(
    _$QuickReplyImpl value,
    $Res Function(_$QuickReplyImpl) then,
  ) = __$$QuickReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String text,
    bool enabled,
    int sortOrder,
    bool isDefault,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$QuickReplyImplCopyWithImpl<$Res>
    extends _$QuickReplyCopyWithImpl<$Res, _$QuickReplyImpl>
    implements _$$QuickReplyImplCopyWith<$Res> {
  __$$QuickReplyImplCopyWithImpl(
    _$QuickReplyImpl _value,
    $Res Function(_$QuickReplyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuickReply
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? enabled = null,
    Object? sortOrder = null,
    Object? isDefault = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$QuickReplyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$QuickReplyImpl implements _QuickReply {
  const _$QuickReplyImpl({
    required this.id,
    required this.text,
    this.enabled = true,
    this.sortOrder = 0,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  final String id;
  @override
  final String text;
  @override
  @JsonKey()
  final bool enabled;
  @override
  @JsonKey()
  final int sortOrder;
  // ascending; UI sorts by this
  @override
  @JsonKey()
  final bool isDefault;
  // the highlighted/first phrase
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'QuickReply(id: $id, text: $text, enabled: $enabled, sortOrder: $sortOrder, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuickReplyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    text,
    enabled,
    sortOrder,
    isDefault,
    createdAt,
    updatedAt,
  );

  /// Create a copy of QuickReply
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuickReplyImplCopyWith<_$QuickReplyImpl> get copyWith =>
      __$$QuickReplyImplCopyWithImpl<_$QuickReplyImpl>(this, _$identity);
}

abstract class _QuickReply implements QuickReply {
  const factory _QuickReply({
    required final String id,
    required final String text,
    final bool enabled,
    final int sortOrder,
    final bool isDefault,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$QuickReplyImpl;

  @override
  String get id;
  @override
  String get text;
  @override
  bool get enabled;
  @override
  int get sortOrder; // ascending; UI sorts by this
  @override
  bool get isDefault; // the highlighted/first phrase
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of QuickReply
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuickReplyImplCopyWith<_$QuickReplyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
