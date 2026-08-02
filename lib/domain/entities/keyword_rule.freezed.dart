// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keyword_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

KeywordRule _$KeywordRuleFromJson(Map<String, dynamic> json) {
  return _KeywordRule.fromJson(json);
}

/// @nodoc
mixin _$KeywordRule {
  String get id => throw _privateConstructorUsedError;
  String get keyword => throw _privateConstructorUsedError;
  MatchType get type => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  List<String> get scopeGroupIds => throw _privateConstructorUsedError;
  List<String> get excludeWords => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  String? get groupName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this KeywordRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KeywordRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeywordRuleCopyWith<KeywordRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeywordRuleCopyWith<$Res> {
  factory $KeywordRuleCopyWith(
    KeywordRule value,
    $Res Function(KeywordRule) then,
  ) = _$KeywordRuleCopyWithImpl<$Res, KeywordRule>;
  @useResult
  $Res call({
    String id,
    String keyword,
    MatchType type,
    int priority,
    List<String> scopeGroupIds,
    List<String> excludeWords,
    bool enabled,
    String? groupName,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$KeywordRuleCopyWithImpl<$Res, $Val extends KeywordRule>
    implements $KeywordRuleCopyWith<$Res> {
  _$KeywordRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeywordRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyword = null,
    Object? type = null,
    Object? priority = null,
    Object? scopeGroupIds = null,
    Object? excludeWords = null,
    Object? enabled = null,
    Object? groupName = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            keyword: null == keyword
                ? _value.keyword
                : keyword // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MatchType,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
            scopeGroupIds: null == scopeGroupIds
                ? _value.scopeGroupIds
                : scopeGroupIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            excludeWords: null == excludeWords
                ? _value.excludeWords
                : excludeWords // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            groupName: freezed == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$KeywordRuleImplCopyWith<$Res>
    implements $KeywordRuleCopyWith<$Res> {
  factory _$$KeywordRuleImplCopyWith(
    _$KeywordRuleImpl value,
    $Res Function(_$KeywordRuleImpl) then,
  ) = __$$KeywordRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String keyword,
    MatchType type,
    int priority,
    List<String> scopeGroupIds,
    List<String> excludeWords,
    bool enabled,
    String? groupName,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$KeywordRuleImplCopyWithImpl<$Res>
    extends _$KeywordRuleCopyWithImpl<$Res, _$KeywordRuleImpl>
    implements _$$KeywordRuleImplCopyWith<$Res> {
  __$$KeywordRuleImplCopyWithImpl(
    _$KeywordRuleImpl _value,
    $Res Function(_$KeywordRuleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KeywordRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? keyword = null,
    Object? type = null,
    Object? priority = null,
    Object? scopeGroupIds = null,
    Object? excludeWords = null,
    Object? enabled = null,
    Object? groupName = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$KeywordRuleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        keyword: null == keyword
            ? _value.keyword
            : keyword // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MatchType,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
        scopeGroupIds: null == scopeGroupIds
            ? _value._scopeGroupIds
            : scopeGroupIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        excludeWords: null == excludeWords
            ? _value._excludeWords
            : excludeWords // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        groupName: freezed == groupName
            ? _value.groupName
            : groupName // ignore: cast_nullable_to_non_nullable
                  as String?,
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
@JsonSerializable()
class _$KeywordRuleImpl implements _KeywordRule {
  const _$KeywordRuleImpl({
    required this.id,
    required this.keyword,
    this.type = MatchType.contains,
    this.priority = 50,
    final List<String> scopeGroupIds = const [],
    final List<String> excludeWords = const [],
    this.enabled = true,
    this.groupName,
    required this.createdAt,
    this.updatedAt,
  }) : _scopeGroupIds = scopeGroupIds,
       _excludeWords = excludeWords;

  factory _$KeywordRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeywordRuleImplFromJson(json);

  @override
  final String id;
  @override
  final String keyword;
  @override
  @JsonKey()
  final MatchType type;
  @override
  @JsonKey()
  final int priority;
  final List<String> _scopeGroupIds;
  @override
  @JsonKey()
  List<String> get scopeGroupIds {
    if (_scopeGroupIds is EqualUnmodifiableListView) return _scopeGroupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scopeGroupIds);
  }

  final List<String> _excludeWords;
  @override
  @JsonKey()
  List<String> get excludeWords {
    if (_excludeWords is EqualUnmodifiableListView) return _excludeWords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludeWords);
  }

  @override
  @JsonKey()
  final bool enabled;
  @override
  final String? groupName;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'KeywordRule(id: $id, keyword: $keyword, type: $type, priority: $priority, scopeGroupIds: $scopeGroupIds, excludeWords: $excludeWords, enabled: $enabled, groupName: $groupName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeywordRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.keyword, keyword) || other.keyword == keyword) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(
              other._scopeGroupIds,
              _scopeGroupIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludeWords,
              _excludeWords,
            ) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    keyword,
    type,
    priority,
    const DeepCollectionEquality().hash(_scopeGroupIds),
    const DeepCollectionEquality().hash(_excludeWords),
    enabled,
    groupName,
    createdAt,
    updatedAt,
  );

  /// Create a copy of KeywordRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeywordRuleImplCopyWith<_$KeywordRuleImpl> get copyWith =>
      __$$KeywordRuleImplCopyWithImpl<_$KeywordRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KeywordRuleImplToJson(this);
  }
}

abstract class _KeywordRule implements KeywordRule {
  const factory _KeywordRule({
    required final String id,
    required final String keyword,
    final MatchType type,
    final int priority,
    final List<String> scopeGroupIds,
    final List<String> excludeWords,
    final bool enabled,
    final String? groupName,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$KeywordRuleImpl;

  factory _KeywordRule.fromJson(Map<String, dynamic> json) =
      _$KeywordRuleImpl.fromJson;

  @override
  String get id;
  @override
  String get keyword;
  @override
  MatchType get type;
  @override
  int get priority;
  @override
  List<String> get scopeGroupIds;
  @override
  List<String> get excludeWords;
  @override
  bool get enabled;
  @override
  String? get groupName;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of KeywordRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeywordRuleImplCopyWith<_$KeywordRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
