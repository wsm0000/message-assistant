// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_reply.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AutoReplyRequest {
  String get messageId => throw _privateConstructorUsedError;
  String get groupName => throw _privateConstructorUsedError;
  String get senderName => throw _privateConstructorUsedError;
  String get replyText => throw _privateConstructorUsedError;

  /// Create a copy of AutoReplyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutoReplyRequestCopyWith<AutoReplyRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutoReplyRequestCopyWith<$Res> {
  factory $AutoReplyRequestCopyWith(
    AutoReplyRequest value,
    $Res Function(AutoReplyRequest) then,
  ) = _$AutoReplyRequestCopyWithImpl<$Res, AutoReplyRequest>;
  @useResult
  $Res call({
    String messageId,
    String groupName,
    String senderName,
    String replyText,
  });
}

/// @nodoc
class _$AutoReplyRequestCopyWithImpl<$Res, $Val extends AutoReplyRequest>
    implements $AutoReplyRequestCopyWith<$Res> {
  _$AutoReplyRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutoReplyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? groupName = null,
    Object? senderName = null,
    Object? replyText = null,
  }) {
    return _then(
      _value.copyWith(
            messageId: null == messageId
                ? _value.messageId
                : messageId // ignore: cast_nullable_to_non_nullable
                      as String,
            groupName: null == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                      as String,
            senderName: null == senderName
                ? _value.senderName
                : senderName // ignore: cast_nullable_to_non_nullable
                      as String,
            replyText: null == replyText
                ? _value.replyText
                : replyText // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AutoReplyRequestImplCopyWith<$Res>
    implements $AutoReplyRequestCopyWith<$Res> {
  factory _$$AutoReplyRequestImplCopyWith(
    _$AutoReplyRequestImpl value,
    $Res Function(_$AutoReplyRequestImpl) then,
  ) = __$$AutoReplyRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String messageId,
    String groupName,
    String senderName,
    String replyText,
  });
}

/// @nodoc
class __$$AutoReplyRequestImplCopyWithImpl<$Res>
    extends _$AutoReplyRequestCopyWithImpl<$Res, _$AutoReplyRequestImpl>
    implements _$$AutoReplyRequestImplCopyWith<$Res> {
  __$$AutoReplyRequestImplCopyWithImpl(
    _$AutoReplyRequestImpl _value,
    $Res Function(_$AutoReplyRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AutoReplyRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? groupName = null,
    Object? senderName = null,
    Object? replyText = null,
  }) {
    return _then(
      _$AutoReplyRequestImpl(
        messageId: null == messageId
            ? _value.messageId
            : messageId // ignore: cast_nullable_to_non_nullable
                  as String,
        groupName: null == groupName
            ? _value.groupName
            : groupName // ignore: cast_nullable_to_non_nullable
                  as String,
        senderName: null == senderName
            ? _value.senderName
            : senderName // ignore: cast_nullable_to_non_nullable
                  as String,
        replyText: null == replyText
            ? _value.replyText
            : replyText // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$AutoReplyRequestImpl implements _AutoReplyRequest {
  const _$AutoReplyRequestImpl({
    required this.messageId,
    required this.groupName,
    required this.senderName,
    required this.replyText,
  });

  @override
  final String messageId;
  @override
  final String groupName;
  @override
  final String senderName;
  @override
  final String replyText;

  @override
  String toString() {
    return 'AutoReplyRequest(messageId: $messageId, groupName: $groupName, senderName: $senderName, replyText: $replyText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoReplyRequestImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.replyText, replyText) ||
                other.replyText == replyText));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, messageId, groupName, senderName, replyText);

  /// Create a copy of AutoReplyRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoReplyRequestImplCopyWith<_$AutoReplyRequestImpl> get copyWith =>
      __$$AutoReplyRequestImplCopyWithImpl<_$AutoReplyRequestImpl>(
        this,
        _$identity,
      );
}

abstract class _AutoReplyRequest implements AutoReplyRequest {
  const factory _AutoReplyRequest({
    required final String messageId,
    required final String groupName,
    required final String senderName,
    required final String replyText,
  }) = _$AutoReplyRequestImpl;

  @override
  String get messageId;
  @override
  String get groupName;
  @override
  String get senderName;
  @override
  String get replyText;

  /// Create a copy of AutoReplyRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutoReplyRequestImplCopyWith<_$AutoReplyRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AutoReplyProgress {
  AutoReplyStep get step => throw _privateConstructorUsedError;
  AutoReplyStepStatus get status => throw _privateConstructorUsedError;
  int get attempt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of AutoReplyProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutoReplyProgressCopyWith<AutoReplyProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutoReplyProgressCopyWith<$Res> {
  factory $AutoReplyProgressCopyWith(
    AutoReplyProgress value,
    $Res Function(AutoReplyProgress) then,
  ) = _$AutoReplyProgressCopyWithImpl<$Res, AutoReplyProgress>;
  @useResult
  $Res call({
    AutoReplyStep step,
    AutoReplyStepStatus status,
    int attempt,
    String? errorMessage,
  });
}

/// @nodoc
class _$AutoReplyProgressCopyWithImpl<$Res, $Val extends AutoReplyProgress>
    implements $AutoReplyProgressCopyWith<$Res> {
  _$AutoReplyProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutoReplyProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? status = null,
    Object? attempt = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            step: null == step
                ? _value.step
                : step // ignore: cast_nullable_to_non_nullable
                      as AutoReplyStep,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AutoReplyStepStatus,
            attempt: null == attempt
                ? _value.attempt
                : attempt // ignore: cast_nullable_to_non_nullable
                      as int,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AutoReplyProgressImplCopyWith<$Res>
    implements $AutoReplyProgressCopyWith<$Res> {
  factory _$$AutoReplyProgressImplCopyWith(
    _$AutoReplyProgressImpl value,
    $Res Function(_$AutoReplyProgressImpl) then,
  ) = __$$AutoReplyProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AutoReplyStep step,
    AutoReplyStepStatus status,
    int attempt,
    String? errorMessage,
  });
}

/// @nodoc
class __$$AutoReplyProgressImplCopyWithImpl<$Res>
    extends _$AutoReplyProgressCopyWithImpl<$Res, _$AutoReplyProgressImpl>
    implements _$$AutoReplyProgressImplCopyWith<$Res> {
  __$$AutoReplyProgressImplCopyWithImpl(
    _$AutoReplyProgressImpl _value,
    $Res Function(_$AutoReplyProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AutoReplyProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? status = null,
    Object? attempt = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$AutoReplyProgressImpl(
        step: null == step
            ? _value.step
            : step // ignore: cast_nullable_to_non_nullable
                  as AutoReplyStep,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AutoReplyStepStatus,
        attempt: null == attempt
            ? _value.attempt
            : attempt // ignore: cast_nullable_to_non_nullable
                  as int,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AutoReplyProgressImpl implements _AutoReplyProgress {
  const _$AutoReplyProgressImpl({
    required this.step,
    required this.status,
    this.attempt = 1,
    this.errorMessage,
  });

  @override
  final AutoReplyStep step;
  @override
  final AutoReplyStepStatus status;
  @override
  @JsonKey()
  final int attempt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'AutoReplyProgress(step: $step, status: $status, attempt: $attempt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoReplyProgressImpl &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.attempt, attempt) || other.attempt == attempt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, step, status, attempt, errorMessage);

  /// Create a copy of AutoReplyProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoReplyProgressImplCopyWith<_$AutoReplyProgressImpl> get copyWith =>
      __$$AutoReplyProgressImplCopyWithImpl<_$AutoReplyProgressImpl>(
        this,
        _$identity,
      );
}

abstract class _AutoReplyProgress implements AutoReplyProgress {
  const factory _AutoReplyProgress({
    required final AutoReplyStep step,
    required final AutoReplyStepStatus status,
    final int attempt,
    final String? errorMessage,
  }) = _$AutoReplyProgressImpl;

  @override
  AutoReplyStep get step;
  @override
  AutoReplyStepStatus get status;
  @override
  int get attempt;
  @override
  String? get errorMessage;

  /// Create a copy of AutoReplyProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutoReplyProgressImplCopyWith<_$AutoReplyProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AutoReplyOutcome {
  AutoReplyResult get result => throw _privateConstructorUsedError;
  List<AutoReplyProgress> get steps => throw _privateConstructorUsedError;
  String? get failedAtStep => throw _privateConstructorUsedError;

  /// Create a copy of AutoReplyOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutoReplyOutcomeCopyWith<AutoReplyOutcome> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutoReplyOutcomeCopyWith<$Res> {
  factory $AutoReplyOutcomeCopyWith(
    AutoReplyOutcome value,
    $Res Function(AutoReplyOutcome) then,
  ) = _$AutoReplyOutcomeCopyWithImpl<$Res, AutoReplyOutcome>;
  @useResult
  $Res call({
    AutoReplyResult result,
    List<AutoReplyProgress> steps,
    String? failedAtStep,
  });
}

/// @nodoc
class _$AutoReplyOutcomeCopyWithImpl<$Res, $Val extends AutoReplyOutcome>
    implements $AutoReplyOutcomeCopyWith<$Res> {
  _$AutoReplyOutcomeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutoReplyOutcome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = null,
    Object? steps = null,
    Object? failedAtStep = freezed,
  }) {
    return _then(
      _value.copyWith(
            result: null == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as AutoReplyResult,
            steps: null == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as List<AutoReplyProgress>,
            failedAtStep: freezed == failedAtStep
                ? _value.failedAtStep
                : failedAtStep // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AutoReplyOutcomeImplCopyWith<$Res>
    implements $AutoReplyOutcomeCopyWith<$Res> {
  factory _$$AutoReplyOutcomeImplCopyWith(
    _$AutoReplyOutcomeImpl value,
    $Res Function(_$AutoReplyOutcomeImpl) then,
  ) = __$$AutoReplyOutcomeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AutoReplyResult result,
    List<AutoReplyProgress> steps,
    String? failedAtStep,
  });
}

/// @nodoc
class __$$AutoReplyOutcomeImplCopyWithImpl<$Res>
    extends _$AutoReplyOutcomeCopyWithImpl<$Res, _$AutoReplyOutcomeImpl>
    implements _$$AutoReplyOutcomeImplCopyWith<$Res> {
  __$$AutoReplyOutcomeImplCopyWithImpl(
    _$AutoReplyOutcomeImpl _value,
    $Res Function(_$AutoReplyOutcomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AutoReplyOutcome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = null,
    Object? steps = null,
    Object? failedAtStep = freezed,
  }) {
    return _then(
      _$AutoReplyOutcomeImpl(
        result: null == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as AutoReplyResult,
        steps: null == steps
            ? _value._steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<AutoReplyProgress>,
        failedAtStep: freezed == failedAtStep
            ? _value.failedAtStep
            : failedAtStep // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AutoReplyOutcomeImpl implements _AutoReplyOutcome {
  const _$AutoReplyOutcomeImpl({
    required this.result,
    required final List<AutoReplyProgress> steps,
    this.failedAtStep,
  }) : _steps = steps;

  @override
  final AutoReplyResult result;
  final List<AutoReplyProgress> _steps;
  @override
  List<AutoReplyProgress> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  final String? failedAtStep;

  @override
  String toString() {
    return 'AutoReplyOutcome(result: $result, steps: $steps, failedAtStep: $failedAtStep)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoReplyOutcomeImpl &&
            (identical(other.result, result) || other.result == result) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.failedAtStep, failedAtStep) ||
                other.failedAtStep == failedAtStep));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    result,
    const DeepCollectionEquality().hash(_steps),
    failedAtStep,
  );

  /// Create a copy of AutoReplyOutcome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoReplyOutcomeImplCopyWith<_$AutoReplyOutcomeImpl> get copyWith =>
      __$$AutoReplyOutcomeImplCopyWithImpl<_$AutoReplyOutcomeImpl>(
        this,
        _$identity,
      );
}

abstract class _AutoReplyOutcome implements AutoReplyOutcome {
  const factory _AutoReplyOutcome({
    required final AutoReplyResult result,
    required final List<AutoReplyProgress> steps,
    final String? failedAtStep,
  }) = _$AutoReplyOutcomeImpl;

  @override
  AutoReplyResult get result;
  @override
  List<AutoReplyProgress> get steps;
  @override
  String? get failedAtStep;

  /// Create a copy of AutoReplyOutcome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutoReplyOutcomeImplCopyWith<_$AutoReplyOutcomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
