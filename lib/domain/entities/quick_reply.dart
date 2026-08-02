import 'package:freezed_annotation/freezed_annotation.dart';
part 'quick_reply.freezed.dart';

/// A preset reply phrase shown in the detail page's reply sheet.
/// When the user picks one, the app composes `@<sender> <text>` and copies it.
@freezed
class QuickReply with _$QuickReply {
  const factory QuickReply({
    required String id,
    required String text,
    @Default(true) bool enabled,
    @Default(0) int sortOrder,      // ascending; UI sorts by this
    @Default(false) bool isDefault, // the highlighted/first phrase
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _QuickReply;

  /// Convenience constructor for new phrases (generates an id, stamps now).
  factory QuickReply.newPhrase({
    required String text,
    int sortOrder = 0,
    bool isDefault = false,
    bool enabled = true,
  }) {
    final now = DateTime.now();
    return QuickReply(
      id: 'qr_${now.millisecondsSinceEpoch}_${text.hashCode.toUnsigned(20)}',
      text: text, enabled: enabled, sortOrder: sortOrder,
      isDefault: isDefault, createdAt: now,
    );
  }
}
