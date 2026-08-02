// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$KeywordHit {
  String get ruleId => throw _privateConstructorUsedError;
  String get keyword => throw _privateConstructorUsedError;
  MatchType get type => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  List<int> get highlightPositions => throw _privateConstructorUsedError;

  /// Create a copy of KeywordHit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeywordHitCopyWith<KeywordHit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeywordHitCopyWith<$Res> {
  factory $KeywordHitCopyWith(
    KeywordHit value,
    $Res Function(KeywordHit) then,
  ) = _$KeywordHitCopyWithImpl<$Res, KeywordHit>;
  @useResult
  $Res call({
    String ruleId,
    String keyword,
    MatchType type,
    int priority,
    List<int> highlightPositions,
  });
}

/// @nodoc
class _$KeywordHitCopyWithImpl<$Res, $Val extends KeywordHit>
    implements $KeywordHitCopyWith<$Res> {
  _$KeywordHitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeywordHit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ruleId = null,
    Object? keyword = null,
    Object? type = null,
    Object? priority = null,
    Object? highlightPositions = null,
  }) {
    return _then(
      _value.copyWith(
            ruleId: null == ruleId
                ? _value.ruleId
                : ruleId // ignore: cast_nullable_to_non_nullable
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
            highlightPositions: null == highlightPositions
                ? _value.highlightPositions
                : highlightPositions // ignore: cast_nullable_to_non_nullable
                      as List<int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KeywordHitImplCopyWith<$Res>
    implements $KeywordHitCopyWith<$Res> {
  factory _$$KeywordHitImplCopyWith(
    _$KeywordHitImpl value,
    $Res Function(_$KeywordHitImpl) then,
  ) = __$$KeywordHitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String ruleId,
    String keyword,
    MatchType type,
    int priority,
    List<int> highlightPositions,
  });
}

/// @nodoc
class __$$KeywordHitImplCopyWithImpl<$Res>
    extends _$KeywordHitCopyWithImpl<$Res, _$KeywordHitImpl>
    implements _$$KeywordHitImplCopyWith<$Res> {
  __$$KeywordHitImplCopyWithImpl(
    _$KeywordHitImpl _value,
    $Res Function(_$KeywordHitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KeywordHit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ruleId = null,
    Object? keyword = null,
    Object? type = null,
    Object? priority = null,
    Object? highlightPositions = null,
  }) {
    return _then(
      _$KeywordHitImpl(
        ruleId: null == ruleId
            ? _value.ruleId
            : ruleId // ignore: cast_nullable_to_non_nullable
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
        highlightPositions: null == highlightPositions
            ? _value._highlightPositions
            : highlightPositions // ignore: cast_nullable_to_non_nullable
                  as List<int>,
      ),
    );
  }
}

/// @nodoc

class _$KeywordHitImpl implements _KeywordHit {
  const _$KeywordHitImpl({
    required this.ruleId,
    required this.keyword,
    required this.type,
    required this.priority,
    required final List<int> highlightPositions,
  }) : _highlightPositions = highlightPositions;

  @override
  final String ruleId;
  @override
  final String keyword;
  @override
  final MatchType type;
  @override
  final int priority;
  final List<int> _highlightPositions;
  @override
  List<int> get highlightPositions {
    if (_highlightPositions is EqualUnmodifiableListView)
      return _highlightPositions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlightPositions);
  }

  @override
  String toString() {
    return 'KeywordHit(ruleId: $ruleId, keyword: $keyword, type: $type, priority: $priority, highlightPositions: $highlightPositions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeywordHitImpl &&
            (identical(other.ruleId, ruleId) || other.ruleId == ruleId) &&
            (identical(other.keyword, keyword) || other.keyword == keyword) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(
              other._highlightPositions,
              _highlightPositions,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    ruleId,
    keyword,
    type,
    priority,
    const DeepCollectionEquality().hash(_highlightPositions),
  );

  /// Create a copy of KeywordHit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeywordHitImplCopyWith<_$KeywordHitImpl> get copyWith =>
      __$$KeywordHitImplCopyWithImpl<_$KeywordHitImpl>(this, _$identity);
}

abstract class _KeywordHit implements KeywordHit {
  const factory _KeywordHit({
    required final String ruleId,
    required final String keyword,
    required final MatchType type,
    required final int priority,
    required final List<int> highlightPositions,
  }) = _$KeywordHitImpl;

  @override
  String get ruleId;
  @override
  String get keyword;
  @override
  MatchType get type;
  @override
  int get priority;
  @override
  List<int> get highlightPositions;

  /// Create a copy of KeywordHit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeywordHitImplCopyWith<_$KeywordHitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MatchResult {
  MessageRecord get message => throw _privateConstructorUsedError;
  List<KeywordHit> get hits => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchResultCopyWith<MatchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchResultCopyWith<$Res> {
  factory $MatchResultCopyWith(
    MatchResult value,
    $Res Function(MatchResult) then,
  ) = _$MatchResultCopyWithImpl<$Res, MatchResult>;
  @useResult
  $Res call({MessageRecord message, List<KeywordHit> hits, int score});

  $MessageRecordCopyWith<$Res> get message;
}

/// @nodoc
class _$MatchResultCopyWithImpl<$Res, $Val extends MatchResult>
    implements $MatchResultCopyWith<$Res> {
  _$MatchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? hits = null,
    Object? score = null,
  }) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as MessageRecord,
            hits: null == hits
                ? _value.hits
                : hits // ignore: cast_nullable_to_non_nullable
                      as List<KeywordHit>,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageRecordCopyWith<$Res> get message {
    return $MessageRecordCopyWith<$Res>(_value.message, (value) {
      return _then(_value.copyWith(message: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchResultImplCopyWith<$Res>
    implements $MatchResultCopyWith<$Res> {
  factory _$$MatchResultImplCopyWith(
    _$MatchResultImpl value,
    $Res Function(_$MatchResultImpl) then,
  ) = __$$MatchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MessageRecord message, List<KeywordHit> hits, int score});

  @override
  $MessageRecordCopyWith<$Res> get message;
}

/// @nodoc
class __$$MatchResultImplCopyWithImpl<$Res>
    extends _$MatchResultCopyWithImpl<$Res, _$MatchResultImpl>
    implements _$$MatchResultImplCopyWith<$Res> {
  __$$MatchResultImplCopyWithImpl(
    _$MatchResultImpl _value,
    $Res Function(_$MatchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? hits = null,
    Object? score = null,
  }) {
    return _then(
      _$MatchResultImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as MessageRecord,
        hits: null == hits
            ? _value._hits
            : hits // ignore: cast_nullable_to_non_nullable
                  as List<KeywordHit>,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$MatchResultImpl implements _MatchResult {
  const _$MatchResultImpl({
    required this.message,
    required final List<KeywordHit> hits,
    required this.score,
  }) : _hits = hits;

  @override
  final MessageRecord message;
  final List<KeywordHit> _hits;
  @override
  List<KeywordHit> get hits {
    if (_hits is EqualUnmodifiableListView) return _hits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hits);
  }

  @override
  final int score;

  @override
  String toString() {
    return 'MatchResult(message: $message, hits: $hits, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchResultImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._hits, _hits) &&
            (identical(other.score, score) || other.score == score));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(_hits),
    score,
  );

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchResultImplCopyWith<_$MatchResultImpl> get copyWith =>
      __$$MatchResultImplCopyWithImpl<_$MatchResultImpl>(this, _$identity);
}

abstract class _MatchResult implements MatchResult {
  const factory _MatchResult({
    required final MessageRecord message,
    required final List<KeywordHit> hits,
    required final int score,
  }) = _$MatchResultImpl;

  @override
  MessageRecord get message;
  @override
  List<KeywordHit> get hits;
  @override
  int get score;

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchResultImplCopyWith<_$MatchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
